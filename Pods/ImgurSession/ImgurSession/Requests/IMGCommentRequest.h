//
//  IMGCommentRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"
#import "IMGVote.h"

@class IMGComment;

/**
 Comment Requests. https://api.imgur.com/endpoints/comment
 */
@interface IMGCommentRequest : IMGEndpoint

#pragma mark - Load
/**
 Load comment with an ID
 @param commentId string Id for comment
 @param replies boolean to fetch the replies if YES
 */
+ (void)commentWithID:(NSInteger)commentId withReplies:(BOOL)replies success:(void (^)(IMGComment * comment))success failure:(void (^)(NSError *error))failure;
/**
 Fetch replies to a parent comment
 @param commentID comment ID to fetch replies for
 */
+ (void)repliesWithCommentID:(NSInteger)commentID success:(void (^)(NSArray * replies))success failure:(void (^)(NSError *error))failure;

#pragma mark - Create
/**
 Create top-level comment on the image or album. Must be logged in.
 @param caption comment string
 @param imageID id of object to comment on
 */
+ (void)submitComment:(NSString*)caption withImageID:(NSString *)imageID success:(void (^)(NSInteger commentID))success failure:(void (^)(NSError *error))failure;
/**
 Reply to a comment. Must be logged in.
 @param caption comment string
 @param imageId id of image to comment on
 @param parentCommentId id of parent comment to reply to
 */
+ (void)replyToComment:(NSString*)caption withImageID:(NSString *)imageID withParentCommentID:(NSInteger)parentCommentID success:(void (^)(NSInteger commentID))success failure:(void (^)(NSError * error))failure;

#pragma mark - Delete
/**
 Delete comment. Must be logged in.
 @param commentId comment id to delete
 */
+ (void)deleteCommentWithID:(NSInteger)commentID success:(void (^)())success failure:(void (^)(NSError *error))failure;

#pragma mark - Vote
/**
 Vote on a comment. Must be logged in.
 @param commentId comment id to vote on
 @param vote vote to give comment
 */
+ (void)voteCommentWithID:(NSInteger)commentID withVote:(IMGVoteType)vote success:(void (^)())success failure:(void (^)(NSError *error))failure;

#pragma mark - Report
/**
 Report a comment as inappropiate. Must be logged in.
 @param commentId comment id to report
 */
+ (void)reportCommentWithID:(NSInteger)commentID success:(void (^)())success failure:(void (^)(NSError *error))failure;

@end
