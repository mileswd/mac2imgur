//
//  IMGMessage.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"


/**
 Model object class to represent messages. https://api.imgur.com/models/message
 */
@interface IMGMessage : IMGModel  <NSCopying,NSCoding>

/**
 Message ID
 */
@property (readonly,nonatomic, copy) NSString * messageID;
/**
 Username who sent the message
 */
@property (readonly,nonatomic, copy) NSString * fromUsername;
/**
 Authors account id
 */
@property (readonly,nonatomic) NSInteger authorID;
/**
 message subject
 */
@property (readonly,nonatomic, copy) NSString * subject;
/**
 message body
 */
@property (readonly,nonatomic, copy) NSString * body;
/**
 Readable string of time since now message was sent
 */
@property (readonly,nonatomic) NSDate * datetime;
/**
 Parent convoId
 */
@property (readonly,nonatomic) NSInteger conversationID;

/**
 Custom Init for use when usinbg model that hasn't been returned from server yet
 */
- (instancetype)initWithBody:(NSString*)body;

//ALL MESSAGE ENDPOINTS ARE DEPRECATED, USE CONVERSATION INSTEAD

@end
