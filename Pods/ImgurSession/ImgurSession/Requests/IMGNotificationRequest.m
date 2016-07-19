//
//  IMGNotificationRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGNotificationRequest.h"
#import "IMGNotification.h"
#import "IMGSession.h"

@implementation IMGNotificationRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"notification";
}

#pragma mark - Load

+ (void)unreadNotifications:(void (^)(NSArray * notifications))success failure:(void (^)(NSError * error))failure{
    
    return [IMGNotificationRequest notificationsWithUnread:YES success:success failure:failure];
}

+ (void)allNotifications:(void (^)(NSArray * notifications))success failure:(void (^)(NSError * error))failure{
    
    return [IMGNotificationRequest notificationsWithUnread:NO success:success failure:failure];
}

+ (void)notificationsWithUnread:(BOOL)unreadOnly success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self path];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] GET:path parameters:@{@"new":(unreadOnly ? @"true" : @"false" )} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSArray * repliesJSON = responseObject[@"replies"];
        NSMutableArray * replies = [NSMutableArray new];
        for(NSDictionary * replyJSON in repliesJSON){
            NSError *JSONError = nil;
            IMGNotification * notification = [[IMGNotification alloc] initReplyNotificationWithJSONObject:replyJSON error:&JSONError];
            if(!JSONError && notification)
                [replies addObject:notification];
        }
        
        NSArray * messagesJSON = responseObject[@"messages"];
        NSMutableArray * messages = [NSMutableArray new];
        for(NSDictionary * messageJSON in messagesJSON){
            NSError *JSONError = nil;
            IMGNotification * notification = [[IMGNotification alloc] initConversationNotificationWithJSONObject:messageJSON error:&JSONError];
            //API returns duplicates of the same object for some reason
            if(!JSONError && notification && ![messages containsObject:notification])
                [messages addObject:notification];
        }
        
        NSMutableArray * result = [NSMutableArray arrayWithArray:messages];
        [result addObjectsFromArray:replies];
        
        if(success)
            success([NSArray arrayWithArray:result]);
        
    } failure:failure];
}

+ (void)notificationWithID:(NSString*)notificationId success:(void (^)(IMGNotification * notification))success failure:(void (^)(NSError * error))failure{
    NSString *path = [self pathWithID:notificationId];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGNotification * notification;
        
        //is it a reply or message
        if(responseObject[@"content"][@"caption"]){
            //reply
            notification = [[IMGNotification alloc] initReplyNotificationWithJSONObject:responseObject error:&JSONError];
        } else {
            //convo
            notification = [[IMGNotification alloc] initConversationNotificationWithJSONObject:responseObject error:&JSONError];
        }
        
        if(!JSONError && notification) {
            if(success)
                success(notification);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}


#pragma mark - Delete

+ (void)notificationViewed:(NSString *)notificationId success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:notificationId];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    //PUT or POST or DELETE
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success(nil);
        
    } failure:failure];
}
@end
