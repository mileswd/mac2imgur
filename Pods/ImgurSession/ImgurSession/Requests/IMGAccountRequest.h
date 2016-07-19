//
//  IMGAccountRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//
#import "IMGEndpoint.h"

#import "IMGSession.h"
#import "IMGBasicAlbum.h"

@class IMGAccount,IMGAccountSettings,IMGAlbum,IMGImage,IMGComment,IMGGalleryProfile;


/**
 Account requests. https://api.imgur.com/endpoints/account
 */
@interface IMGAccountRequest : IMGEndpoint


#pragma mark - Load

//call IMGSession refreshUserAccount to refresh the current user's account. Retrieve at the 'user' property

/**
 Request standard user information. If you need the username for the account that is logged in, it is returned in the request for an access token.
 @param username username to fetch
 */
+ (void)accountWithUser:(NSString *)username success:(void (^)(IMGAccount *account))success failure:(void (^)(NSError *error))failure;

#pragma mark - Favourites
/**
 Return the images the user has favorited in the gallery.
 @param username name of account
 @param page page of requests
 */
+ (void)accountFavouritesWithUser:(NSString *)username withPage:(NSInteger)page success:(void (^)(NSArray * favs))success failure:(void (^)(NSError *error))failure;

#pragma mark - Gallery Profile
/**
 Returns the totals for the gallery profile.
 @param username name of account
 */
+ (void)accountGalleryProfileWithUser:(NSString *)username success:(void (^)(IMGGalleryProfile * profile))success failure:(void (^)(NSError *error))failure;

#pragma mark - Verify User Email
/**
 Sends the verification email to user
 */
+(void)sendUserEmailVerification:(void (^)())success failure:(void (^)(NSError * error))failure;
/**
 Determines whether the user has verified their email
 */
+(void)isUserEmailVerification:(void (^)(BOOL verified))success failure:(void (^)(NSError * error))failure;

#pragma mark - Submissions
/**
 Retrieve account submissions.
 @param page pagination, page number to retrieve
 @param username name of account
 */
+ (void)accountSubmissionsWithUser:(NSString*)username withPage:(NSInteger)page success:(void (^)(NSArray * submissions))success failure:(void (^)(NSError *error))failure;


#pragma mark - Load settings
/**
 Retrieve account settings only for current user. Must be logged in.
 */
+ (void)accountSettings:(void (^)(IMGAccountSettings *settings))success failure:(void (^)(NSError *error))failure;

#pragma mark - Update settings
/**
 Update current account settings with new values. Must be logged in.
 */
+ (void)changeAccountWithBio:(NSString*)bio success:(void (^)())success failure:(void (^)(NSError *error))failure;
/**
 Update current account settings with new values. Must be logged in.
 */
+ (void)changeAccountWithBio:(NSString*)bio messagingEnabled:(BOOL)msgEnabled publicImages:(BOOL)publicImages albumPrivacy:(IMGAlbumPrivacy)privacy acceptedGalleryTerms:(BOOL)galTerms success:(void (^)())success failure:(void (^)(NSError *error))failure;


#pragma mark - Albums associated with account

/**
 Get all the albums associated with the account. Must be logged in as the user to see secret and hidden albums.
 */
+ (void)accountAlbumsWithUser:(NSString*)username withPage:(NSInteger)page success:(void (^)(NSArray * albums))success failure:(void (^)(NSError * error))failure;
/**
 Return an array of all of the album IDs.
 */
+ (void)accountAlbumIDsWithUser:(NSString*)username success:(void (^)(NSArray * albumIDs))success failure:(void (^)(NSError * error))failure;
/**
 Get additional information about an album, this endpoint works the same as the Album Endpoint. You can also use any of the additional routes that are used on an album in the album endpoint.
 */
+ (void)accountAlbumWithID:(NSString*)albumID success:(void (^)(IMGAlbum * album))success failure:(void (^)(NSError * error))failure;
/**
 Return the total number of albums associated with the account.
 */
+ (void)accountAlbumCountWithUser:(NSString*)username success:(void (^)(NSInteger albumCount))success failure:(void (^)(NSError * error))failure;
/**
 Delete an Album with a given id.  Must be logged in.
 */
+ (void)accountDeleteAlbumWithID:(NSString*)albumID success:(void (^)())success failure:(void (^)(NSError * error))failure;



#pragma mark - Images associated with account

/**
 Return all of the images associated with the account. You can page through the images by setting the page, this defaults to 0.
 */
+ (void)accountImagesWithUser:(NSString*)username withPage:(NSInteger)page success:(void (^)(NSArray * images))success failure:(void (^)(NSError * error))failure;
/**
 Returns an array of Image IDs that are associated with the account..
 */
+ (void)accountImageIDsWithUser:(NSString*)username success:(void (^)(NSArray * imageIDs))success failure:(void (^)(NSError * error))failure;
/**
 Return information about a specific image. This endpoint works the same as the Image Endpoint. You can use any of the additional actions that the image endpoint with this endpoint.
 */
+ (void)accountImageWithID:(NSString*)imageId success:(void (^)(IMGImage * image))success failure:(void (^)(NSError * error))failure;
/**
 Returns the total number of images associated with the account.
 */
+ (void)accountImageCount:(NSString*)username success:(void (^)(NSInteger imageCount))success failure:(void (^)(NSError * error))failure;
/**
 Deletes an Image. This requires a delete hash rather than an ID.
 */
+ (void)accountDeleteImageWithUser:(NSString*)username deletehash:(NSString*)deleteHash success:(void (^)())success failure:(void (^)(NSError * error))failure;


#pragma mark - Comments associated with account

/**
 Return the comments the current user has created.
 */
+ (void)accountCommentsWithUser:(NSString*)username success:(void (^)(NSArray * comments))success failure:(void (^)(NSError * error))failure;
/**
 Return an array of all of the comment IDs.
 */
+ (void)accountCommentIDsWithUser:(NSString*)username success:(void (^)(NSArray * commentIDs))success failure:(void (^)(NSError * error))failure;
/**
 Return information about a specific comment. This endpoint works the same as the Comment Endpoint. You can use any of the additional actions that the comment endpoint allows on this end point.
 */
+ (void)accountCommentWithID:(NSInteger)commentID success:(void (^)(IMGComment * comment))success failure:(void (^)(NSError * error))failure;
/**
 Return a count of all of the comments associated with the current account.
 */
+ (void)accountCommentCount:(NSString*)username success:(void (^)(NSInteger commentCount))success failure:(void (^)(NSError * error))failure;
/**
 Delete a comment from the current account. Must be logged in.
 */
+ (void)accountDeleteCommentWithID:(NSInteger)commentID success:(void (^)())success failure:(void (^)(NSError * error))failure;


#pragma mark - Replies associated with account

/**
 Returns all reply notification for the current account
 */
+ (void)accountAllReplies:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Returns all unread reply notifications for the current account
 */
+ (void)accountUnreadReplies:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

@end
