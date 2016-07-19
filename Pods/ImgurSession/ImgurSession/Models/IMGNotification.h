//
//  IMGNotification.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

@class IMGComment, IMGMessage,IMGConversation;

/**
 Model object class to represent user notifications. https://api.imgur.com/models/notifications
 */
@interface IMGNotification : IMGModel  <NSCopying,NSCoding>

/**
 notification ID
 */
@property (readonly,nonatomic, copy) NSString * notificationID;
/**
 Account ID notification is associated with
 */
@property (readonly,nonatomic) NSInteger accountID;
/**
 Has notification been viewed yet?
 */
@property (readwrite,nonatomic) BOOL isViewed;
/**
 Is the notification a IMGComment? Else it is IMGConversation
 */
@property (readonly,nonatomic) BOOL isReply;
/**
 Message object if this notification was a reply to a user's post
 */
@property (readonly,nonatomic) IMGComment * reply;
/**
 Conversation object if this notification was a conversation
 */
@property (readonly,nonatomic) IMGConversation * conversation;
/**
 Datetime notification was triggered
 */
@property (readonly,nonatomic) NSDate * datetime;


/**
 Special Init for notification with IMGComment object
 */
- (instancetype)initReplyNotificationWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error;
/**
 Special Init for notification with IMGConversation object
 */
- (instancetype)initConversationNotificationWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error;


@end
