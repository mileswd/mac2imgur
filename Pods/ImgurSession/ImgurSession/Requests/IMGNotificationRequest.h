//
//  IMGNotificationRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"


@class IMGNotification;

/**
 User notification requests. https://api.imgur.com/endpoints/notification
 */
@interface IMGNotificationRequest : IMGEndpoint

#pragma mark - Load
/**
 Get all unread  notifications for the user that's currently logged in. Must be logged in.
 */
+ (void)unreadNotifications:(void (^)(NSArray * notifications))success failure:(void (^)(NSError * error))failure;

/**
 Get all notifications for the user that's currently logged in. Must be logged in.
 */
+ (void)allNotifications:(void (^)(NSArray * notifications))success failure:(void (^)(NSError * error))failure;
/**
 Returns the data about a specific notification. Must be logged in.
 */
+ (void)notificationWithID:(NSString*)notificationId success:(void (^)(IMGNotification * notification))success failure:(void (^)(NSError * error))failure;


#pragma mark - Delete
/**
 Marks a notification as viewed, this way it no longer shows up in the basic notification request. Must be logged in.
 */
+ (void)notificationViewed:(NSString *)notificationId success:(void (^)())success failure:(void (^)(NSError * error))failure;


@end
