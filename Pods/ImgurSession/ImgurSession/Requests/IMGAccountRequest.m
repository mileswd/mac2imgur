//
//  IMGAccountRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGAccountRequest.h"
#import "IMGAlbumRequest.h"
#import "IMGCommentRequest.h"
#import "IMGImageRequest.h"
#import "IMGAccount.h"
#import "IMGAccountSettings.h"
#import "IMGAlbum.h"
#import "IMGGalleryAlbum.h"
#import "IMGGalleryImage.h"
#import "IMGGalleryProfile.h"
#import "IMGNotification.h"
#import "IMGComment.h"

@implementation IMGAccountRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"account";
}

#pragma mark - Load

+ (void)accountWithUser:(NSString *)username success:(void (^)(IMGAccount *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:username];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGAccount *account = [[IMGAccount alloc] initWithJSONObject:responseObject withName:username error:&JSONError];
        
        if(!JSONError && account) {
            if(success)
                success(account);
        }
        else {
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Favourites

+ (void)accountFavouritesWithUser:(NSString *)username withPage:(NSInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:username withOption:@"gallery_favorites" withID2:[[NSNumber numberWithInteger:page] stringValue]];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * fullJSON = responseObject;
        NSMutableArray * favs = [NSMutableArray new];
        
        //could be gallery image or gallery album
        for(NSDictionary * json in fullJSON){
            
            NSError *JSONError = nil;
            if(json[@"layout"]){
                //album
                
                IMGGalleryAlbum *album = [[IMGGalleryAlbum alloc] initWithJSONObject:json error:&JSONError];
                if(!JSONError && album){
                    [favs addObject:album];
                }
            } else {
                //image
                
                IMGGalleryImage *image = [[IMGGalleryImage alloc] initWithJSONObject:json error:&JSONError];
                if(!JSONError && image){
                    [favs addObject:image];
                }
            }
        }
        
        if(success)
            success([NSArray arrayWithArray:favs]);
        
    } failure:failure];
}

+ (void)accountSubmissionsWithUser:(NSString*)username withPage:(NSInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:username withOption:@"submissions" withID2:[NSString stringWithFormat:@"%ld",(long)page]];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        NSArray * fullJSON = responseObject;
        NSMutableArray * submissionsPage = [NSMutableArray new];
        
        //could be gallery image or gallery album
        for(NSDictionary * json in fullJSON){
            JSONError = nil;
            
            if(json[@"layout"]){
                //album
                
                IMGGalleryAlbum *album = [[IMGGalleryAlbum alloc] initWithJSONObject:json error:&JSONError];
                if(!JSONError && album){
                    [submissionsPage addObject:album];
                }
            } else {
                //image
                
                IMGGalleryImage *image = [[IMGGalleryImage alloc] initWithJSONObject:json error:&JSONError];
                if(!JSONError && image){
                    [submissionsPage addObject:image];
                }
            }
        }
        
        if(success)
            success([NSArray arrayWithArray:submissionsPage]);
        
    } failure:failure];
}

#pragma mark - Load account settings

+ (void)accountSettings:(void (^)(IMGAccountSettings *settings))success failure:(void (^)(NSError *error))failure{
    //only allows settings for current account after login
    NSString *path = [self pathWithID:@"me" withOption:@"settings"];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGAccountSettings *settings = [[IMGAccountSettings alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && settings) {
            if(success)
                success(settings);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Update account settings

+ (void)changeAccountWithBio:(NSString*)bio success:(void (^)())success failure:(void (^)(NSError *error))failure{
    //only allows settings for current account after login
    NSString *path = [self pathWithID:@"me" withOption:@"settings"];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    NSDictionary * params = @{@"bio":bio};
    
    //put or post
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}

+ (void)changeAccountWithBio:(NSString*)bio messagingEnabled:(BOOL)msgEnabled publicImages:(BOOL)publicImages albumPrivacy:(IMGAlbumPrivacy)privacy acceptedGalleryTerms:(BOOL)galTerms success:(void (^)())success failure:(void (^)(NSError *error))failure{
    //only allows settings for current account after login
    NSString *path = [self pathWithID:@"me" withOption:@"settings"];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    NSDictionary * params = @{@"bio":bio,@"public_images":(publicImages ? @"true" : @"false" ),@"messaging_enabled":(msgEnabled ? @"true" : @"false"),@"album_privacy":[IMGBasicAlbum strForPrivacy:privacy],@"accepted_gallery_terms":(galTerms ? @"true" : @"false" )};
    
    //put or post
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}


#pragma mark - Gallery Profile

+ (void)accountGalleryProfileWithUser:(NSString *)username success:(void (^)(IMGGalleryProfile *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:username withOption:@"gallery_profile"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGGalleryProfile *profile = [[IMGGalleryProfile alloc] initWithUser:username JSONObject:responseObject error:&JSONError];
        
        if(!JSONError && profile) {
            if(success)
                success(profile);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Verify User Email

+(void)sendUserEmailVerification:(void (^)())success failure:(void (^)(NSError * error))failure{
    
    NSString *path = [self pathWithID:@"me" withOption:@"verifyemail"];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:^(NSError *error) {
        
        if(failure)
            failure(error);
    }];
}

+(void)isUserEmailVerification:(void (^)(BOOL verified))success failure:(void (^)(NSError * error))failure{
    
    NSString *path = [self pathWithID:@"me" withOption:@"verifyemail"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success([responseObject boolValue]);
        
    } failure:^(NSError *error) {
        
        if(failure)
            failure(error);
    }];
}

#pragma mark - Albums associated with account

+ (void)accountAlbumsWithUser:(NSString*)username withPage:(NSInteger)page  success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:username withOption:@"albums" withID2:[NSString stringWithFormat:@"%ld",(long)page]];

    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * accountAlbumsJSON = responseObject;
        NSMutableArray * accountAlbums = [NSMutableArray new];
        
        for(NSDictionary * albumJSON in accountAlbumsJSON){
            
            NSError *JSONError = nil;
            IMGAlbum *album = [[IMGAlbum alloc] initWithJSONObject:albumJSON error:&JSONError];
            
            if(!JSONError && album){
                [accountAlbums addObject:album];
            }
        }
        
        if(success)
            success([NSArray arrayWithArray:accountAlbums]);
        
    } failure:failure];
}

+ (void)accountAlbumWithID:(NSString*)albumID success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    [IMGAlbumRequest albumWithID:albumID success:success failure:failure];
}

+ (void)accountAlbumIDsWithUser:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:username withOption:@"albums/ids"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * albumIDs = responseObject;
        if(success)
            success(albumIDs);
        
    } failure:failure];
    
    
}

+ (void)accountAlbumCountWithUser:(NSString*)username success:(void (^)(NSInteger))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:username withOption:@"albums/count"];

    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber * numAccountAlbums = responseObject; //NSNumber??
        if(success)
            success([numAccountAlbums integerValue]);
        
    } failure:failure];
    
}

+ (void)accountDeleteAlbumWithID:(NSString*)albumID success:(void (^)())success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:@"me" withOption:@"albums" withID2:albumID];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }

    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}


#pragma mark - Images associated with account


+ (void)accountImagesWithUser:(NSString*)username withPage:(NSInteger)page  success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:username withOption:@"images" withID2:[NSString stringWithFormat:@"%ld",(long)page]];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * accountImagesJSON = responseObject;
        NSMutableArray * accountImages = [NSMutableArray new];
        
        for(NSDictionary * imageJSON in accountImagesJSON){
            
            NSError *JSONError = nil;
            IMGImage *image = [[IMGImage alloc] initWithJSONObject:imageJSON error:&JSONError];
            
            if(!JSONError && image){
                [accountImages addObject:image];
            }
        }
    
        if(success)
            success([NSArray arrayWithArray:accountImages]);
        
    } failure:failure];
}

+ (void)accountImageWithID:(NSString*)imageID success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    
    [IMGImageRequest imageWithID:imageID success:success failure:failure];
}

+ (void)accountImageIDsWithUser:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:username withOption:@"images/ids"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * albumIds = responseObject;
        if(success)
            success(albumIds);
        
    } failure:failure];
}

+ (void)accountImageCount:(NSString*)username success:(void (^)(NSInteger))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:username withOption:@"images/count"];
   
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber * numAccountAlbums = responseObject; //NSNumber??
        if(success)
            success([numAccountAlbums integerValue]);
        
    } failure:failure];
}

+ (void)accountDeleteImageWithUser:(NSString*)username deletehash:(NSString*)deleteHash success:(void (^)())success failure:(void (^)(NSError *))failure{

    NSString *path = [self pathWithID:username withOption:@"image" withID2:deleteHash];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    
        if(success)
            success();
        
    } failure:failure];
}


#pragma mark - Comments associated with account


+ (void)accountCommentsWithUser:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:username withOption:@"comments"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * commentsJSON = responseObject;
        NSMutableArray * comments = [NSMutableArray new];
        
        for(NSDictionary * commentJSON in commentsJSON){
            
            NSError *JSONError = nil;
            IMGComment *comment = [[IMGComment alloc] initWithJSONObject:commentJSON error:&JSONError];
            
            if(!JSONError && comment){
                [comments addObject:comment];
            }
        }
        
        if(success)
            success([NSArray arrayWithArray:comments]);
        
    } failure:failure];
}

+ (void)accountCommentIDsWithUser:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:username withOption:@"comments/ids"];
    
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * albumIds = responseObject;
        
        if(success)
            success(albumIds);
        
    } failure:failure];
}

+ (void)accountCommentWithID:(NSInteger)commentID success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    
    [IMGCommentRequest commentWithID:commentID withReplies:NO success:success failure:failure];
}

+ (void)accountCommentCount:(NSString*)username success:(void (^)(NSInteger))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:username withOption:@"comments/count"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber * numAccountAlbums = responseObject; //NSNumber??
        
        if(success)
            success([numAccountAlbums integerValue]);
        
    } failure:failure];
}

+ (void)accountDeleteCommentWithID:(NSInteger)commentID success:(void (^)())success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:@"me" withOption:@"comment" withID2:[NSString stringWithFormat:@"%lu", (unsigned long)commentID]];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}


#pragma mark - Replies associated with account

+ (void)accountAllReplies:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    //fresh replies only
    [self accountRepliesWithFresh:NO success:success failure:failure];
}

+ (void)accountUnreadReplies:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    //fresh replies only
    [self accountRepliesWithFresh:YES success:success failure:failure];
}

+ (void)accountRepliesWithFresh:(BOOL)freshOnly success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:@"me" withOption:@"notifications/replies"];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    NSDictionary * params = @{@"new":(freshOnly ? @"true" : @"false" )};
    
    [[IMGSession sharedInstance] GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * notificationsJSON = responseObject;
        NSMutableArray * notifications = [NSMutableArray new];
        
        for(NSDictionary * notificationJSON in notificationsJSON){
            
            NSError *JSONError = nil;
            IMGNotification * notification;
            //is it a reply or message
            if(notificationJSON[@"caption"]){
                //reply
                notification = [[IMGNotification alloc] initReplyNotificationWithJSONObject:responseObject error:&JSONError];
            } else {
                //message
                notification = [[IMGNotification alloc] initConversationNotificationWithJSONObject:responseObject error:&JSONError];
            }
            
            if(!JSONError && notification){
                [notifications addObject:notification];
            }
        }
        
        if(success)
            success([NSArray arrayWithArray:notifications]);
        
    } failure:failure];
}


@end
