//
//  IMGClient.h
//  ImgurSession
//
//  Geoff MacDonald - Pivotal Labs
//  Distributed under the MIT license.
//

#import "IMGAccount.h"
#import <AFNetworking/AFNetworking.h>

//endpoints
static NSString * const IMGImgurBaseURL = @"https://api.imgur.com";
static NSString * const IMGMashapeBaseURL = @"https://imgur-apiv3.p.mashape.com";
static NSString * const IMGAPIVersion = @"3";
static NSString * const IMGOAuthEndpoint = @"oauth2/token";

//rate limit header names
static NSString * const IMGHeaderUserLimit = @"X-RateLimit-UserLimit";
static NSString * const IMGHeaderUserRemaining = @"X-RateLimit-UserRemaining";
static NSString * const IMGHeaderUserReset = @"X-RateLimit-UserReset";
static NSString * const IMGHeaderClientLimit = @"X-RateLimit-ClientLimit";
static NSString * const IMGHeaderClientRemaining = @"X-RateLimit-ClientRemaining";

//notification names
static NSString * const IMGRateLimitExceededNotification = @"IMGRateLimitExceededNotification";
static NSString * const IMGRateLimitNearLimitNotification = @"IMGRateLimitNearLimitNotification";
static NSString * const IMGNeedsExternalWebviewNotification = @"IMGNeedsExternalWebviewNotification";
static NSString * const IMGModelFetchedNotification = @"IMGModelFetchedNotification";
static NSString * const IMGAuthChangedNotification = @"IMGAuthChangedNotification";
static NSString * const IMGAuthRefreshedNotification = @"IMGAuthRefreshedNotification";
static NSString * const IMGRefreshedUserNotification = @"IMGRefreshedUserNotification";
static NSString * const IMGRefreshedNotificationsNotification = @"IMGRefreshedNotificationsNotification";
static NSString * const IMGRequestFailedNotification = @"IMGRequestFailedNotification";
static NSString * const IMGReachabilityChangedNotification = @"IMGReachabilityChangedNotification";

/**
 Type of authorization to use, you should probably use code on iOS. See https://api.imgur.com/oauth2
 */
typedef NS_ENUM(NSInteger, IMGAuthType){
    IMGNoAuthType,
    IMGPinAuth,
    IMGTokenAuth,
    IMGCodeAuth
};

/**
 Session state of the authentication. Determined based on expiry dates for authenticated sessions.
 */
typedef NS_ENUM(NSInteger, IMGAuthState){
    IMGAuthStateMissingParameters = 0,
    IMGAuthStateBad = 0,
    IMGAuthStateNone,
    IMGAuthStateAuthenticated,
    IMGAuthStateAnon,
    IMGAuthStateExpired,
    IMGAuthStateAwaitingCodeInput
};


/**
 Protocol to be alerted of ImgurSession notifcations. Called on main thread.
 */
@protocol IMGSessionDelegate <NSObject>

@optional
/**
 Alerts delegate that request limit is hit and cannot continue. Must be implemented
 */
-(void)imgurSessionRateLimitExceeded;
/**
 Alerts delegate that webview is needed to present Imgur OAuth authentication with the authentication type (pin,code,token) set by the initializers. Call completion upon authenticating with asyncAuthenticateWithType when you want to ensure previous requests do not fail, as this method was called lazily by the session just before a request is attempted. Not calling completion will still work but result in the previous request never running. This method is required when using an authenticated session
 */
-(void)imgurSessionNeedsExternalWebview:(NSURL*)url completion:(void(^)())completion;
/**
 Alerts delegate that request limit is being approached
 */
-(void)imgurSessionNearRateLimit:(NSInteger)remainingRequests;
/**
 Informs delegate of new model objects being created
 @param model Model object that was created
 */
-(void)imgurSessionModelFetched:(id)model;
/**
 Informs delegate of new access token refreshs
 */
-(void)imgurSessionTokenRefreshed;
/**
 Informs delegate of new authentication success
 @param state authentication state of the session. You can call sessionAuthState anytime for this value.
 */
-(void)imgurSessionAuthStateChanged:(IMGAuthState)state;
/**
 Informs delegate of user refreshes
 */
-(void)imgurSessionUserRefreshed:(IMGAccount*)user;
/**
 Informs delegate of fresh notifications
 */
-(void)imgurSessionNewNotifications:(NSArray*)freshNotifications;
/**
 Inform delegate of request failures
 */
-(void)imgurRequestFailed:(NSError*)error;
/**
 Inform delegate of unreachable domain due to internet connection or domain status on either Wifi or cell
 */
-(void)imgurReachabilityChanged:(AFNetworkReachabilityStatus)status;

@end


/**
 Session manager class for ImgurSession session singleton. Controls all requests by subclassing AFHTTPSessionManager. Handles all imgur requests by managing authentication state for both authenticated sessions forom imgur authentication callbakc and anonymous sessions. Must supply credentials for Imgur registered app.
 */
@interface IMGSession : AFHTTPSessionManager


// client authorization

/**
 App Id as registered with Imgur at http://imgur.com/account/settings/apps
 */
@property (readonly, nonatomic,copy) NSString *clientID;
/**
 App Secret as registered with Imgur at http://imgur.com/account/settings/apps
 */
@property (readonly, nonatomic, copy) NSString *secret;
/**
 Refresh token as retrieved from oauth/token GET request. Subsequent requests invalidate previous refresh tokens.
 */
@property (readonly, nonatomic, copy) NSString *refreshToken;
/**
 Access token as retrieved from oauth/token GET request with PIN. Expires after 1 hour after retrieval as in the 'expires_in' header
 */
@property (readonly, nonatomic, copy) NSString *accessToken;
/**
 Code retrieved from imgur by using external URL for authentication. Set via setAuthCode to input code from web service.
 */
@property (readonly, nonatomic, copy) NSString * codeAwaitingAuthentication;
/**
 Access token expiry date
 */
@property (readonly, nonatomic) NSDate *accessTokenExpiry;
/**
 Type of authentication intended, IMGNoAuthType if anon
 */
@property (readonly, nonatomic) IMGAuthType authType;
/**
 Is current session anonymous?
 */
@property (readonly, nonatomic) BOOL isAnonymous;
/**
 Is session configured yet?
 */
@property (readonly, nonatomic) BOOL isConfigured;
/**
 User Account if logged in. Refreshed on authentication or refresh tokens. Also refreshed with refreshUserAccount method.
 */
@property (readonly, nonatomic) IMGAccount * user;
/**
 Time period when notification updates are requested to see if user has new updates. Set to 0 to disable. 30 seconds by default. Only for authroized Sessions.
 */
@property  (readwrite,nonatomic) NSInteger notificationRefreshPeriod;

// rate limiting

/**
 Requests current user has remaining
 */
@property (readonly,nonatomic) NSInteger creditsUserRemaining;
/**
 Daily limit on user requests
 */
@property (readonly,nonatomic) NSInteger creditsUserLimit;
/**
 unix epoch date when user credits are reset
 */
@property (readonly,nonatomic) NSInteger creditsUserReset;
/**
 Requests app has remaining
 */
@property (readonly,nonatomic) NSInteger creditsClientRemaining;
/**
 Daily limit for the app
 */
@property (readonly,nonatomic) NSInteger creditsClientLimit;
/**
 Warn client after going below this number of available requests. The default is 100 requests.
 */
@property  (readonly,nonatomic) NSInteger warnRateLimit;

/**
 Reachability manager for the domain imgur.com. Must call -startMonitoring to actual monitor.
 */
@property AFNetworkReachabilityManager * imgurReachability;

/**
 Required delegate to warn of imgur events.
 */
@property (weak) id<IMGSessionDelegate> delegate;

#pragma mark - Public methods

#pragma mark - Initialize

/**
 Returns shared instance, or else creates one with nil authentication params.
 @return Session manager
 */
+ (instancetype)sharedInstance;
/**
 Resets sharedInstance singleton to authenticated session with these parameters. If credentials are nil, assert will be thrown. Must be called before requests are made.
 @param clientID    client Id string as registered with Imgur
 @param secret      secret string as registered with Imgur
 @param authType    type of authorization - code, pin or token
 @param delegate    delegate to respond to required imgur delegate methods
 */
+(instancetype)authenticatedSessionWithClientID:(NSString *)clientID secret:(NSString *)secret authType:(IMGAuthType)authType withDelegate:(id<IMGSessionDelegate>)delegate;
/**
 Resets sharedInstance singleton to authenticated session with these parameters. If credentials are nil, assert will be thrown. Must be called before requests are made.
 @param clientID    client Id string as registered with Imgur
 @param secret      secret string as registered with Imgur
 @param mashapeKey  Mashape key as registered with Mashape, or nil to access imgur directly
 @param authType    type of authorization - code, pin or token
 @param delegate    delegate to respond to required imgur delegate methods
 */
+(instancetype)authenticatedSessionWithClientID:(NSString *)clientID secret:(NSString *)secret mashapeKey:(NSString *)mashapeKey authType:(IMGAuthType)authType withDelegate:(id<IMGSessionDelegate>)delegate;
/**
 Resets sharedInstance singleton to anonymous session with client ID. Must be called before requests are made.
 @param clientID    client Id string as registered with Imgur
 @param delegate    delegate to respond to required imgur delegate methods
 */
+(instancetype)anonymousSessionWithClientID:(NSString *)clientID withDelegate:(id<IMGSessionDelegate>)delegate;
/**
 Resets sharedInstance singleton to anonymous session with client ID. Must be called before requests are made.
 @param clientID    client Id string as registered with Imgur
 @param mashapeKey  Mashape key as registered with Mashape, or nil to access imgur directly
 @param delegate    delegate to respond to required imgur delegate methods
 */
+(instancetype)anonymousSessionWithClientID:(NSString *)clientID mashapeKey:(NSString *)mashapeKey withDelegate:(id<IMGSessionDelegate>)delegate;

#pragma mark - Authentication

/**
 Immediately attempts to authenticate based on state of the session. If it does have a refresh token, this will post to oauth/token to refresh access tokens. If it does not have a refresh token, will authenticate with user inputted code. If there is not a user-inputted code, will attempt to retrieve from external webview.
 */
-(void)authenticate:(void (^)(NSString * refreshToken))success failure:(void (^)(NSError *error))failure;
/**
 Immediately attempts to authenticate based on state of the session. Observe IMGAuthChangedNotification or imgurSessionAuthStateChanged: for asynchronous result.
 */
-(void)authenticate;
/**
 Sets the session input code retrieved by the OAuth service upon allowing the application permission via external web service. This code will be used lazily the next time a request is made to acquire a new refresh token. If this is never set the session will never authenicate unless manually using authenticateWithRefreshToken: or authenticateWithType:
 @param code input code to be submitted to OAuth to retrieve refresh token with
 */
-(void)setAuthenticationInputCode:(NSString*)code;
/**
 Authenticates immediately directly from refresh token. Note that code input from oath/token will invalidate previous refresh tokens. Necessary to avoid code input for persisting authentications between app launches.
 @param refreshToken     valid refresh token to manually set
 */
-(void)authenticateWithRefreshToken:(NSString*)refreshToken;
/**
 Authenticates immediately by requesting refresh token using inputted code. Not necessary. Lazily authenticates before each request by using setAuthCode:
 @param code     code input string for authorization
 */
- (void)authenticateWithCode:(NSString*)code;
/**
 Returns status of session authentication. Based on token expiry, not gauranteed to be accurate.
 @return    IMGAuthState state of current session
 */
-(IMGAuthState)sessionAuthState;

#pragma mark - Authorized User Account

/**
 Requests the logged-in user's account.
 @param success completion block invoked on successful account retrieval
 @param failure block invoked on failed request
 */
-(void)refreshUserAccount:(void (^)(IMGAccount * user))success failure:(void (^)(NSError * err))failure;
/**
 Requests the logged-in user's account. Observe IMGRefreshedUserNotification or imgurSessionUserRefreshed: delegate method for asynchronous result.
 */
-(void)refreshUserAccount;
/**
 Requests any unread notifications if they exist for logged in user.
 @param success completion block invoked on response
 @param failure block invoked on failed request
 */
-(void)checkUserUnreadNotifications:(void (^)(NSArray * unreadNotifications))success failure:(void (^)(NSError * err))failure;
/**
 Requests any unread notifications if they exist for logged in user.
 */
-(void)checkUserUnreadNotifications;
/**
 Request Imgur for latest API credits information. Use the session properties or returned dictionaries for result. This request is not necessary unless you need
 the latest status otherwise just check the session class properties.
*/
-(void)retrieveRateLimitingCredits:(void (^)(NSDictionary * credits))success failure:(void (^)(NSError * error))failure;

#pragma mark - Imgur Request Methods - Handles authentication state, responding to errors and tracking

-(NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask * task, id responseObject))success failure:(void (^)( NSError * error))failure;

-(NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask * task, id responseObject))success failure:(void (^)(NSError * error))failure;

-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask * task, id responseObject))success failure:(void (^)( NSError * error))failure;

//- (NSURLSessionDataTask *)POST:(NSString *)URLString
//                    parameters:(id)parameters
//     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
//                      progress:(void (^)(NSProgress *))uploadProgress
//                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
//                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


@end
