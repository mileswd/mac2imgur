//
//  IMGConversationRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"

@class IMGMessage,IMGConversation;

/**
 Conversation requests. https://api.imgur.com/endpoints/conversation
 */
@interface IMGConversationRequest : IMGEndpoint


#pragma mark - Load
/**
 Get list of all conversations for the logged in user. Must be logged in.
 */
+ (void)conversations:(void (^)(NSArray * conversations))success failure:(void (^)(NSError *error))failure;
/**
 Get information about a specific conversation. Includes messages. Must be logged in.
 */
+ (void)conversationWithMessageID:(NSInteger)messageID success:(void (^)(IMGConversation * conversation))success failure:(void (^)(NSError *error))failure;

#pragma mark - Create
/**
 Create a new message. Must be logged in.
 */
+ (void)createMessageWithRecipient:(NSString*)recipient withBody:(NSString*)body success:(void (^)())success failure:(void (^)(NSError *error))failure;


#pragma mark - Delete
/**
 Delete a conversation. Must be logged in.
 @param commentId comment id to delete
 */
+ (void)deleteConversation:(NSInteger)convoID success:(void (^)())success failure:(void (^)(NSError *error))failure;

#pragma mark - Report
/**
 Report a user for sending messages that are against the Terms of Service. Must be logged in.
 */
+ (void)reportSender:(NSString*)username success:(void (^)())success failure:(void (^)(NSError *error))failure;

#pragma mark - Block
/**
 Report a user for sending messages that are against the Terms of Service. Must be logged in.
 */
+ (void)blockSender:(NSString*)username success:(void (^)())success failure:(void (^)(NSError *error))failure;
@end
