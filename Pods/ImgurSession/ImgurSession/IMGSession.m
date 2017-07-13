    //
//  IMGClient.m
//  ImgurSession
//
//  Geoff MacDonald - Pivotal Labs
//  Distributed under the MIT license.
//

#import "IMGSession.h"

#import "IMGResponseSerializer.h"
#import "IMGAccountRequest.h"
#import "IMGNotificationRequest.h"

@interface IMGSession ()

@property (readwrite, nonatomic,copy) NSString *clientID;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *mashapeKey;
@property (readwrite, nonatomic, copy) NSString *refreshToken;
@property (readwrite, nonatomic, copy) NSString *accessToken;
@property (readwrite, nonatomic, copy) NSString *codeAwaitingAuthentication;
@property (readwrite, nonatomic) NSDate *accessTokenExpiry;
@property (readwrite, nonatomic) IMGAuthType authType;
@property (readwrite,nonatomic) NSInteger creditsUserRemaining;
@property (readwrite,nonatomic) NSInteger creditsUserLimit;
@property (readwrite,nonatomic) NSInteger creditsUserReset;
@property (readwrite,nonatomic) NSInteger creditsClientRemaining;
@property (readwrite,nonatomic) NSInteger creditsClientLimit;
@property (readwrite, nonatomic) BOOL isAnonymous;
@property (readwrite, nonatomic) BOOL isConfigured;
@property (readwrite, nonatomic) IMGAccount * user;
@property (readwrite, nonatomic) AFHTTPSessionManager *authSession;

@property dispatch_semaphore_t refreshSemaphore;

/**
 Timer to check for notifications
 */
@property NSTimer * notificationRefreshTimer;

@end

@implementation IMGSession;

#pragma mark - Initialize

+ (instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    static IMGSession *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IMGSession alloc] init];
    });
    
    return sharedInstance;
}

static BOOL useMashape = NO;

+(instancetype)authenticatedSessionWithClientID:(NSString *)clientID secret:(NSString *)secret authType:(IMGAuthType)authType withDelegate:(id<IMGSessionDelegate>)delegate{

    return [self authenticatedSessionWithClientID:clientID secret:secret mashapeKey:nil authType:authType withDelegate:delegate];
}

+(instancetype)authenticatedSessionWithClientID:(NSString *)clientID secret:(NSString *)secret mashapeKey:(NSString *)mashapeKey authType:(IMGAuthType)authType withDelegate:(id<IMGSessionDelegate>)delegate{
    
    NSParameterAssert(clientID);
    NSParameterAssert(secret);
    NSParameterAssert(authType != IMGNoAuthType);
    NSParameterAssert(delegate);
    NSAssert([delegate respondsToSelector:@selector(imgurSessionNeedsExternalWebview:completion:)], @"ImgurSession requires a delegate that implements imgurSessionNeedsExternalWebview: in order to authenticate from external imgur service");
    
    useMashape = mashapeKey != nil;
    
    //for testing, do not reset access tokens
    if(![[self sharedInstance] isAnonymous] && [clientID isEqualToString:[[self sharedInstance] clientID]] && [secret isEqualToString:[[self sharedInstance] secret]] && authType == [[self sharedInstance] authType])
        return [self sharedInstance];
    
    [[IMGSession sharedInstance] setupClientWithID:clientID secret:secret mashapeKey:mashapeKey authType:authType withDelegate:delegate];
    
    return [self sharedInstance];
}

+(instancetype)anonymousSessionWithClientID:(NSString *)clientID withDelegate:(id<IMGSessionDelegate>)delegate{
    
    return [self anonymousSessionWithClientID:clientID mashapeKey:nil withDelegate:delegate];
}

+(instancetype)anonymousSessionWithClientID:(NSString *)clientID mashapeKey:(NSString *)mashapeKey withDelegate:(id<IMGSessionDelegate>)delegate{
    
    NSParameterAssert(clientID);
    
    useMashape = mashapeKey != nil;
    
    //for testing, do not reset access tokens
    if([[self sharedInstance] isAnonymous] && clientID == [[self sharedInstance] clientID])
        return [self sharedInstance];
    
    [[IMGSession sharedInstance] setupClientWithID:clientID secret:nil mashapeKey:mashapeKey authType:IMGNoAuthType withDelegate:delegate];
    
    return [self sharedInstance];
}

/**
 Initialize AFHTTPSessionManger session with hardcoded Imgur base URL and serializer.
 */
- (instancetype)init{
    
    if(self = [self initWithBaseURL:[NSURL URLWithString:useMashape ? IMGMashapeBaseURL : IMGImgurBaseURL]]){
        
        _warnRateLimit = 100;
        _notificationRefreshPeriod = 60;
        _isConfigured = NO;
        
        //to enable rate tracking
        IMGResponseSerializer * responseSerializer = [IMGResponseSerializer serializer];
        [self setResponseSerializer:responseSerializer];
    }
    return self;
}

/**
 Configure session with client credentials. Anonymous session if secret is null
 */
-(void)setupClientWithID:(NSString*)clientID secret:(NSString*)secret mashapeKey:(NSString *)mashapeKey authType:(IMGAuthType)authType withDelegate:(id<IMGSessionDelegate>)delegate{
    
    //ensure stale fields are null
    self.secret = nil;
    self.user = nil;
    self.codeAwaitingAuthentication = nil;
    //clear auth fields
    self.accessToken = nil;
    self.accessTokenExpiry = nil;
    self.refreshToken = nil;
    self.isConfigured = YES;
    
    //clear header
    AFHTTPRequestSerializer * serializer = self.requestSerializer;
    [serializer clearAuthorizationHeader];
    
    self.clientID = clientID;
    self.mashapeKey = mashapeKey;
    self.authType = authType;
    self.delegate = delegate;
    
    if(secret){
        self.secret = secret;
        self.isAnonymous = NO;
        
        if(self.notificationRefreshPeriod){
            //setup timer to check for notifications, does not actually check unless delegate responds
            self.notificationRefreshTimer = [NSTimer timerWithTimeInterval:self.notificationRefreshPeriod target:self selector:@selector(checkUserUnreadNotifications) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.notificationRefreshTimer forMode:NSDefaultRunLoopMode];
        }
        
        [self informClientAuthStateChanged:IMGAuthStateNone];
    } else {
        
        [self.notificationRefreshTimer invalidate];
        self.notificationRefreshTimer = nil;
        
        //assumed anon if no secret given
        self.isAnonymous = YES;
        self.authType = IMGNoAuthType;
        [self setAnonmyousAuthenticationWithID:clientID];
        
        [self informClientAuthStateChanged:IMGAuthStateAnon];
    }
    
    //setup reachability manager to notify delegate of lost connections
    self.imgurReachability = [AFNetworkReachabilityManager managerForDomain:@"imgur.com"];
    __weak typeof(self) welf = self;
    [self.imgurReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //warn delegate
            if(welf.delegate && [welf.delegate respondsToSelector:@selector(imgurReachabilityChanged:)])
                [welf.delegate imgurReachabilityChanged:status];
            [[NSNotificationCenter defaultCenter] postNotificationName:IMGReachabilityChangedNotification object:nil];
        });
    }];
}

#pragma mark - Authentication

-(IMGAuthState)sessionAuthState{
    
    if(self.isAnonymous){
        //anon clients only need the clientID to log in
        if(self.clientID.length)
            return IMGAuthStateAnon;
        else
            return IMGAuthStateMissingParameters;
    } else {
        
        if(self.accessToken.length && self.refreshToken.length && [self.accessTokenExpiry timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970])
            return IMGAuthStateAuthenticated;                   //continue with request
        else if(self.codeAwaitingAuthentication.length)
            return IMGAuthStateAwaitingCodeInput;               //no access token, delay the request until tokens are retrieved
        else if(self.refreshToken.length)
            return IMGAuthStateExpired;                         //access token is expired, delay request until new access token retrieved
        else if(self.clientID.length && self.secret.length)
            return IMGAuthStateNone;                            //enough information to retrieve tokens, wait until tokens are retrieved
        else
            return IMGAuthStateMissingParameters;               //not enough information to login
    }
}

/**
 String constant for auth type
 */
+(NSString*)strForAuthType:(IMGAuthType)authType{
    NSString * authStr;
    switch (authType) {
        case IMGPinAuth:
            authStr = @"pin";
            break;
        case IMGTokenAuth:
            authStr = @"token";
            break;
        case IMGCodeAuth:
            authStr = @"code";
            break;
        default:
            NSAssert(NO, @"Bad ImgurSession Authorization Type");
            break;
    }
    return authStr;
}

/**
 Retrieves URL associated with website authorization page for session authentication type
 @return    authorization URL to open in Webview or Safari
 */
- (NSURL *)authenticateWithExternalURL{
    
    if(self.isAnonymous)
        return nil;
    
    // Always use the imgur base URL for auth
    NSString *path = [NSString stringWithFormat:@"%@/oauth2/authorize?response_type=%@&client_id=%@", IMGImgurBaseURL, [IMGSession strForAuthType:self.authType], _clientID];
    return [NSURL URLWithString:path];
}

/**
 Inform the delegate of changes in authentication state of the session as they happen. Delegate can also call sessionAuthState.
 */
-(void)informClientAuthStateChanged:(IMGAuthState)authState{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionAuthStateChanged:)])
            [_delegate imgurSessionAuthStateChanged:authState];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IMGAuthChangedNotification object:[NSNumber numberWithInt:authState]];
    });
}

-(void)authenticate{
    
    [self authenticate:nil failure:nil];
}

-(void)authenticate:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure{

    [self refreshAuthentication:^(NSString *refreshToken) {
        
        if(success)
            success(refreshToken);
        
    } failure:^(NSError *error) {
        
        if(failure)
            failure(error);
        
    }];
}

-(AFHTTPSessionManager *)authSession {
    
    if(!_authSession) {
        
        // Always use the imgur base URL for auth
        self.authSession = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:IMGImgurBaseURL]];
        
        //to enable rate tracking
        IMGResponseSerializer * responseSerializer = [IMGResponseSerializer serializer];
        [_authSession setResponseSerializer:responseSerializer];
    }
    
    return _authSession;
}

-(void)postForRefreshTokensWithCode:(NSString *)inputCode success:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure{
    
    [self.requestSerializer clearAuthorizationHeader];
    
    NSString * grantTypeStr = (self.authType == IMGPinAuth ? [IMGSession strForAuthType:IMGPinAuth] : @"authorization_code");
    
    //call oauth/token with auth type
    NSDictionary * params = @{[IMGSession strForAuthType:self.authType]:inputCode, @"client_id":_clientID, @"client_secret":_secret, @"grant_type":grantTypeStr};
    
    //use super to bypass authentication checks
    [self.authSession POST:IMGOAuthEndpoint parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //alert delegate
        [self informClientAuthStateChanged:IMGAuthStateAuthenticated];
        
        NSDictionary * json = responseObject;
        //set auth header
        [self setAuthorizationHeader:json];
        //retrieve user account
        [self refreshUserAccount];
        
        if(success)
            success(self.refreshToken);
        
        //alert after resuming
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionTokenRefreshed)])
                [_delegate imgurSessionTokenRefreshed];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:IMGAuthRefreshedNotification object:nil];
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        //alert delegate
        [self informClientAuthStateChanged:IMGAuthStateBad];
        
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorCouldNotAuthenticate userInfo:@{IMGErrorAuthenticationError:error}]);
    }];
}

-(void)postForAccessTokens:(void (^)())success failure:(void (^)(NSError *error))failure{
    
    NSDictionary * refreshParams = @{@"refresh_token":_refreshToken, @"client_id":_clientID, @"client_secret":_secret, @"grant_type":@"refresh_token"};
    
    //use super to bypass authentication checks
    [self.authSession POST:IMGOAuthEndpoint parameters:refreshParams progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary * json = responseObject;
        //set auth header
        [self setAuthorizationHeader:json];
        //immediately request latest user updates
        [self refreshUserAccount];
        
        if(success)
            success();
        
        //alert after resuming
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionTokenRefreshed)])
                [_delegate imgurSessionTokenRefreshed];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:IMGAuthRefreshedNotification object:nil];
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //in my experience, usually banned at this point, refresh codes shouldn't expire unless another input code invalidates it
        
        
        //only fail if we are sure error is not due to internet,etc
        if(error.code >= IMGErrorInvalidRefreshToken && error.code < 500){
            
            //set to nil to ensure we acquire new refresh token
            self.refreshToken = nil;
            
            if(failure)
                failure(error);
        }
    }];

}

/**
 Acquires new access token. This method may choose to acquire access token from code input if it does not have a refresh token or elese refresh the access token with the refresh token.
 @param success completion block upon recieving a valid access token
 @param failure completion block upon inability to acquire tokens by any method
 */
-(void)refreshAuthentication:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure{
    
    //create synchronous queue so that requests to refresh happen one at a time and multiple token posts are not sent
    static dispatch_once_t onceToken;
    static dispatch_queue_t refreshQueue;
    dispatch_once(&onceToken, ^{
        refreshQueue = dispatch_queue_create("RefreshQueue",DISPATCH_QUEUE_SERIAL);
    });
    
    //keep track of multiple file uploads with semaphore
    static dispatch_once_t semaToken;
    dispatch_once(&semaToken, ^{
        self.refreshSemaphore  = dispatch_semaphore_create(0);
    });
    
    //save date to be copied to block so that if this call was awaiting a current failed request to finish, it will be able to tell if refresh has since happened
    NSDate * requestRefreshDate = [NSDate date];
    
    dispatch_async(refreshQueue, ^{
        
        IMGAuthState state = [self sessionAuthState];
        
        if(state == IMGAuthStateExpired){
            //refresh access token with refresh token
            
            [self postForAccessTokens:^{
                 
                //resume
                dispatch_semaphore_signal(self.refreshSemaphore);
                
                if(success)
                    success(self.refreshToken);
                
            } failure:^(NSError *error) {
                
                //resume to allow possible refreshes
                dispatch_semaphore_signal(self.refreshSemaphore);
                
                //need to ask user for a new code input
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate imgurSessionNeedsExternalWebview:[self authenticateWithExternalURL] completion:^{
                        
                        //post code and retrieve new tokens
                        [self refreshAuthentication:^(NSString * refresh) {
                            
                            if(success)
                                success(refresh);
                            
                        } failure:failure]; //failure will generate IMGErrorCouldNotAuthenticate error code as per above
                    }];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:IMGNeedsExternalWebviewNotification object:nil];
                });
            }];
            //wait for signal from post request before accepting new requests
            dispatch_semaphore_wait(self.refreshSemaphore, DISPATCH_TIME_FOREVER);
            
        } else if(state == IMGAuthStateAwaitingCodeInput){
            //retrieve refresh tokens with input code
            
            [self postForRefreshTokensWithCode:self.codeAwaitingAuthentication success:^(NSString *refreshToken) {
                
                //resume
                dispatch_semaphore_signal(self.refreshSemaphore);
                
                if(success)
                    success(refreshToken);
                
            } failure:^(NSError *error) {
                
                //resume to allow possible refreshes
                dispatch_semaphore_signal(self.refreshSemaphore);
                
                if(failure)
                    failure(error);
            }];
            
            //set to nil so we don't do this again
            self.codeAwaitingAuthentication = nil;
            
            //wait for signal from post request before accepting new requests
            dispatch_semaphore_wait(self.refreshSemaphore, DISPATCH_TIME_FOREVER);
        
        } else {
            
            //do not await this logic
            
            if(state == IMGAuthStateNone){
                //we need to retrieve refresh token with client credentials first
                
                //alert app that it needs to present webview or go to safari
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionNeedsExternalWebview:completion:)])
                        [_delegate imgurSessionNeedsExternalWebview:[self authenticateWithExternalURL] completion:^{
                            
                            //refresh upon recieving new auth code
                            [self refreshAuthentication:^(NSString * refresh) {
                                
                                if(success)
                                    success(refresh);
                                
                            } failure:failure];
                        }];
                    [[NSNotificationCenter defaultCenter] postNotificationName:IMGNeedsExternalWebviewNotification object:self];
                });
                
                
            } else if(state == IMGAuthStateAuthenticated){
                
                //this call may have been queued up at which time a refresh or code input happens and the access token is refreshed
                //this is the case where multiple requests fail without warning
                //we need to compare expiry date of access token to decide whether to refresh or simply redo the request
                if([self.accessTokenExpiry timeIntervalSinceReferenceDate] - 3600 > [requestRefreshDate timeIntervalSinceReferenceDate]){
                    //new access token has been retrieved since we failed

                    if(success)
                        success(nil);
                } else {
                    //refresh as if we expired
                    self.accessToken = nil;
                    self.accessTokenExpiry = nil;
                    
                    [self refreshAuthentication:success failure:failure];
                }
                
            } else if(state == IMGAuthStateMissingParameters){
                //we do not have enough information to authenticate
                
                if(failure)
                    failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorMissingClientAuthentication userInfo:nil]);
                
            } else if(state == IMGAuthStateBad){
                //the client credentials are being refused
                
                if(failure)
                    failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorCouldNotAuthenticate userInfo:nil]);
                
            } else {//if(state == IMGAuthStateAnon){
                
                //just go to completion we don't care
                if(success)
                    success(nil);
            }
        }
    });
    
}

-(void)setAuthenticationInputCode:(NSString*)code{
    
    //immediately invalidate access token
    self.accessToken = nil;
    self.accessTokenExpiry = nil;
    self.refreshToken = nil;
    
    self.codeAwaitingAuthentication = code;
    
    [self informClientAuthStateChanged:IMGAuthStateAwaitingCodeInput];
}

-(void)authenticateWithRefreshToken:(NSString*)refreshToken{
    
    self.refreshToken = refreshToken;
    //set access token to nil to ensure we have manually expired access tokens if they exist so that we get IMGAuthStateExpired to refresh
    self.accessToken = nil;
    self.codeAwaitingAuthentication = nil;
    
    [self authenticate];
}

- (void)authenticateWithCode:(NSString*)code{
    
    [self setAuthenticationInputCode:code];
    //set access token to nil to ensure we have manually expired access tokens if they exist so that we get IMGAuthStateExpired to refresh
    self.accessToken = nil;
    self.refreshToken = nil;
    
    [self authenticate];
}

#pragma mark - Authorized User Account

-(void)refreshUserAccount{
    
    [self refreshUserAccount:nil failure:nil];
}

-(void)refreshUserAccount:(void (^)(IMGAccount * user))success failure:(void (^)(NSError * err))failure{
    
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
        //set need user
        self.user = account;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //only if delegate responds do we inform
            if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionUserRefreshed:)]){
                [_delegate imgurSessionUserRefreshed:account];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:IMGRefreshedUserNotification object:account];
        });
        
        //also check for notifications if necessary
        [self checkUserUnreadNotifications];
        
        if(success)
            success(account);
        
    } failure:failure];
}

/**
 Method request new user notifications if they are available. Called by default every 30 seconds.
 */
-(void)checkForUserNotifications:(void (^)(NSArray * unreadNotifications))success failure:(void (^)(NSError * err))failure{
    
    //only if delegate responds do we check
    if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionNewNotifications:)] && [self sessionAuthState] == IMGAuthStateAuthenticated){
        
        [IMGNotificationRequest unreadNotifications:^(NSArray * fresh) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate imgurSessionNewNotifications:fresh];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:IMGRefreshedNotificationsNotification object:fresh];
            });
            
            if(success)
                success(fresh);
            
        } failure:^(NSError *error) {
            
            if(failure)
                failure(error);
        }];
    }
}

-(void)setNotificationRefreshPeriod:(NSInteger)notificationRefreshPeriod{
    //reset notification timer with correct period
    
    _notificationRefreshPeriod = notificationRefreshPeriod;
    
    [self.notificationRefreshTimer invalidate];
    self.notificationRefreshTimer = nil;
    
    //ensure it is authorized session
    if(notificationRefreshPeriod && !self.isAnonymous){
        //setup timer to check for notifications, does not actually check unless delegate responds
        self.notificationRefreshTimer = [NSTimer timerWithTimeInterval:self.notificationRefreshPeriod target:self selector:@selector(checkUserUnreadNotifications) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.notificationRefreshTimer forMode:NSDefaultRunLoopMode];
    }
}

-(void)checkUserUnreadNotifications:(void (^)(NSArray * unreadNotifications))success failure:(void (^)(NSError * err))failure{
    
    [self checkForUserNotifications:success failure:failure];
}

-(void)checkUserUnreadNotifications{
    
    [self checkForUserNotifications:nil failure:nil];
}

-(void)retrieveRateLimitingCredits:(void (^)(NSDictionary * credits))success failure:(void (^)(NSError * error))failure{
    //request response serialized goes through updateClientRateLimiting: to update credits
    [self GET:[NSString stringWithFormat:@"%@/3/credits", useMashape ? IMGMashapeBaseURL : IMGImgurBaseURL] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(responseObject);
        
    } failure:^(NSError *error) {
        
        if(failure)
            failure(error);
    }];
}

#pragma mark - Authorization Header

/**
 Sets the Authorization header for requests with just he client ID for anonymous sessions.
 */
-(void)setAnonmyousAuthenticationWithID:(NSString*)clientID{
    
    //change the serializer to include this authorization header
    AFHTTPRequestSerializer * serializer = self.requestSerializer;
    [serializer setValue:[NSString stringWithFormat:@"Client-ID %@", clientID] forHTTPHeaderField:@"Authorization"];
    
    if(self.mashapeKey){
        [serializer setValue:self.mashapeKey forHTTPHeaderField:@"X-Mashape-Key"];
    }
}

/**
 Sets the Authorization header for authorized sessions with the access tokens. Sets expiry date and refresh tokens if available.
 */
- (void)setAuthorizationHeader:(NSDictionary *)tokens{
    //store authentication from oauth/token response and set metadata
    
    //refresh token may not be here if we are refreshing
    if(tokens[@"refresh_token"]){
        self.refreshToken = tokens[@"refresh_token"];
    }
    
    //set expiracy time, currrently at 3600 seconds after
    NSInteger expirySeconds = [tokens[@"expires_in"] integerValue];
    self.accessTokenExpiry = [NSDate dateWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate] + expirySeconds)];
    //call accessToken expired to refresh authentication
    NSTimer * timer = [NSTimer timerWithTimeInterval:expirySeconds target:self selector:@selector(accessTokenExpired) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.accessToken = tokens[@"access_token"];
    
    //change the serializer to include this authorization header
    AFHTTPRequestSerializer * serializer = self.requestSerializer;
    [serializer setValue:[NSString stringWithFormat:@"Bearer %@", tokens[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    if(self.mashapeKey){
        [serializer setValue:self.mashapeKey forHTTPHeaderField:@"X-Mashape-Key"];
    }
}

-(void)accessTokenExpired{
    
    [self refreshAuthentication:nil failure:nil];
}

#pragma mark - Rate Limit Tracking

-(void)updateClientRateLimiting:(NSHTTPURLResponse*)response{
    
    NSDictionary * headers = response.allHeaderFields;
    //sometimes the headers aren't there and 0 is the result which will wrongly trigger ratelimitexceeded
    if(headers[IMGHeaderClientRemaining])
        self.creditsClientRemaining = [headers[IMGHeaderClientRemaining] integerValue];
    if(headers[IMGHeaderClientLimit])
        self.creditsClientLimit = [headers[IMGHeaderClientLimit] integerValue];
    if(headers[IMGHeaderUserLimit])
        self.creditsUserLimit = [headers[IMGHeaderUserLimit] integerValue];
    if(headers[IMGHeaderUserRemaining])
        self.creditsUserRemaining = [headers[IMGHeaderUserRemaining] integerValue];
    if(headers[IMGHeaderUserReset])
        self.creditsUserReset = [headers[IMGHeaderUserReset] integerValue];
    
    //only warn if headers were included
    if(headers[IMGHeaderUserRemaining]){
        //warn delegate if necessary
        if(_creditsUserRemaining < _warnRateLimit && _creditsUserRemaining > 0){
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionNearRateLimit:) ]){
                    [_delegate imgurSessionNearRateLimit:_creditsUserRemaining];
                }
                
                //post notifications as well
                [[NSNotificationCenter defaultCenter] postNotificationName:IMGRateLimitNearLimitNotification object:nil];
            });
        } else if (_creditsUserRemaining == 0){
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionRateLimitExceeded)]){
                    [_delegate imgurSessionRateLimitExceeded];
                }
                
                //post notifications as well
                [[NSNotificationCenter defaultCenter] postNotificationName:IMGRateLimitExceededNotification object:nil];
            });
        }
    }
}

#pragma mark - Request authorization management

//needed to subclass to manage authentication state

/**
 Proactive method request handling to determine if authentication is needed before the request is actually made
 @param completion block to be executed once the session is authenticated
 @param failure block invoked on ability to authenticate
 @return task to be run
 */
-(NSURLSessionDataTask *)methodRequest:(NSURLSessionDataTask * (^)())completion failure:(void (^)( NSError *))failure{
    
    
    IMGAuthState auth = [self sessionAuthState];
    
    if(self.imgurReachability && [self.imgurReachability networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable){
        
        //error no connection, don't even try
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:AFNetworkReachabilityStatusNotReachable userInfo:nil]);
        
    } else if(auth == IMGAuthStateMissingParameters){
        
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorMissingClientAuthentication userInfo:nil]);
        
    } else if (auth == IMGAuthStateBad){
        
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorCouldNotAuthenticate userInfo:nil]);
        
    } else if (auth == IMGAuthStateExpired || auth == IMGAuthStateNone || auth == IMGAuthStateAwaitingCodeInput){
        
        //refresh or ask delegate for external webview to login for first time
        [self refreshAuthentication:^(NSString * refreshToken) {
            
            completion();
            
        } failure:^(NSError *error) {
            
            //inform of either refresh failure or delegate needs to login
            if(error.code == IMGErrorCouldNotAuthenticate){
                if(failure)
                    failure(error);
            }
        }];
    } else {
        
        //continue with request
        return completion();
    }
    return nil;
}

/**
 Determines if failed request can be recovered with a refresh
 @return BOOL value YES if the session can re-authenticate
 */
-(BOOL)canRequestFailureBeRecovered:(NSError*)error{

    if(self.isAnonymous){
        //anon, nothing we can do but tell the user
        return NO;
    } else if(error.code == IMGErrorUserRateLimitExceeded){
        //rate limiting error 429 is not recoverable
        
        //warn client
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionRateLimitExceeded)]){
                [_delegate imgurSessionRateLimitExceeded];
            }
            
            //post notifications as well
            [[NSNotificationCenter defaultCenter] postNotificationName:IMGRateLimitExceededNotification object:nil];
        });
        return NO;
        
    } else {
        //if authenticated, attempt refresh or worst case code input in case of 401 and 403
        //500 error will not be helped by re-authenticating
        
        return (error.code == IMGErrorForbidden || error.code == IMGErrorRequiresUserAuthentication);
    }
}

/**
 Convienience method to transform failure completions into one which alerts delegate of failures.
 @param failure failure completion blocks to overwrite
 */
-(void(^)(NSError* error))requestFailure:(void (^)(NSError * error))failure{
    
    void (^modifiedFailure)(NSError* error) = ^void(NSError * error){
        
        //alert of failures
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if(_delegate && [_delegate respondsToSelector:@selector(imgurRequestFailed:)]){
                
                [_delegate imgurRequestFailed:error];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:IMGRequestFailedNotification object:self userInfo:@{@"error":error}];
        });
        
        //ensure to call original failure completion block as well
        if(failure)
            failure(error);
    };
    
    return modifiedFailure;
}

#pragma mark - Requests
//overriden to handle authentication state proactively and reactively

-(NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask * task, id responseObject))success failure:(void (^)(NSError * error))failure{
    
    //override failure block to also allow failure tracking
    failure = [self requestFailure:failure];
    
    //proactively check to ensure we can send a request if we are authenticated. If not, then authenticate before sending request
    return [self methodRequest:^{
        
        //actually make the request after ensuring we are authenticated
        return [super GET:URLString parameters:parameters progress:nil success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            //if the request fails based on status code, check to see if we can recover by authenticating if for some reason our previous check was not the truth
            if([self canRequestFailureBeRecovered:error]){
                
                //reactive authentication in response to 401 or 403
                [self refreshAuthentication:^(NSString * accessCode) {
                    
                    //send actual request to super this time and give-up if it still fails
                    [super GET:URLString parameters:parameters progress:nil success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                        failure(error);
                    }];
                } failure:failure];
                
            } else {
                //cannot recover
                failure(error);
            }
        }];
        //failure method from not being able to authenticate in refreshAuthentication:
    } failure:failure];
}

-(NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask * task, id responseObject))success failure:(void (^)( NSError * error))failure{
    
    failure = [self requestFailure:failure];
    
    return [self methodRequest:^{
        
        return [super DELETE:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            if([self canRequestFailureBeRecovered:error]){
                
                [self refreshAuthentication:^(NSString * accessCode) {
                    
                    [super DELETE:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask *task, NSError *error){
                        
                        failure(error);
                    }];
                } failure:failure];
                
            } else {
                
                failure(error);
            }
        }];
        
    } failure:failure];
}

-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask * task, id responseObject))success failure:(void (^)( NSError * error))failure{
    
    failure = [self requestFailure:failure];
    
    return [self methodRequest:^{
        
        return [super POST:URLString parameters:parameters progress:nil success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            if([self canRequestFailureBeRecovered:error]){
                
                
                [self refreshAuthentication:^(NSString * accessCode) {
                    
                    [super POST:URLString parameters:parameters progress:nil success:success failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                        failure(error);
                    }];
                } failure:failure];
                
            } else {
                
                failure(error);
            }
        }];
        
    } failure:failure];
}

//- (NSURLSessionDataTask *)POST:(NSString *)URLString
//                    parameters:(id)parameters
//     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
//                      progress:(void (^)(NSProgress *))uploadProgress
//                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
//                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
//    
//    return [super POST:URLString
//            parameters:parameters
//constructingBodyWithBlock:block
//              progress:uploadProgress
//               success:success
//               failure:failure];
//}

#pragma mark - Model Tracking

-(void)trackModelObjectsForDelegateHandling:(id)model{
    
    //post notifications as well to class name
    dispatch_async(dispatch_get_main_queue(), ^{
    
        //tell delegate if necessary
        if(_delegate && [_delegate respondsToSelector:@selector(imgurSessionModelFetched:)]){
                [_delegate imgurSessionModelFetched:model];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IMGModelFetchedNotification object:model];
    });
}

@end
