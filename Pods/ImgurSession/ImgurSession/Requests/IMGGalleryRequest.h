//  IMGGalleryRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"

#import "IMGVote.h"

@class IMGGalleryAlbum,IMGGalleryImage,IMGGalleryProfile,IMGComment;

@protocol IMGGalleryObjectProtocol;

typedef NS_ENUM(NSInteger, IMGGallerySectionType) {
    IMGGallerySectionTypeHot, //default
    IMGGallerySectionTypeTop,
    IMGGallerySectionTypeUser
};

typedef NS_ENUM(NSInteger, IMGTopGalleryWindow) {
    IMGTopGalleryWindowDay, //default
    IMGTopGalleryWindowWeek,
    IMGTopGalleryWindowMonth,
    IMGTopGalleryWindowYear,
    IMGTopGalleryWindowAll
};

typedef NS_ENUM(NSInteger, IMGGalleryCommentSortType) {
    IMGGalleryCommentSortBest, //default
    IMGGalleryCommentSortHot,
    IMGGalleryCommentSortNew
};

@interface IMGGalleryRequest : IMGEndpoint


#pragma mark - Load Gallery Pages

/**
 Retrieves same gallery as gooing to imgur.com. All params are default. Returns both gallery images and gallery albums.
 @param page    imgur pagination page to retrieve
 */
+(void)hotGalleryPage:(NSInteger)page success:(void (^)(NSArray * objects))success failure:(void (^)(NSError *error))failure;
/**
 Retrieves same gallery as gooing to imgur.com. All params are default.
 @param page    imgur pagination page to retrieve
 @param viralSort    should sort by virality
 */
+(void)hotGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort success:(void (^)(NSArray * objects))success failure:(void (^)(NSError *error))failure;
/**
 Retrieves same gallery as gooing to imgur.com. All params are default.
 @param page    imgur pagination page to retrieve
 @param window    imgur time period to retrieve. day,year,etc.
 */
+(void)topGalleryPage:(NSInteger)page withWindow:(IMGTopGalleryWindow)window success:(void (^)(NSArray * objects))success failure:(void (^)(NSError * error))failure;
+(void)topGalleryPage:(NSInteger)page withWindow:(IMGTopGalleryWindow)window withViralSort:(BOOL)viralSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Retrieves user's gallery with viral options
 @param page    imgur pagination page to retrieve
 @param viralSort    should sort by virality
 @param showViral    show viral
 */
+(void)userGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort showViral:(BOOL)showViral success:(void (^)(NSArray * objects))success failure:(void (^)(NSError * error))failure;

+(void)userGalleryPage:(NSInteger)page showViral:(BOOL)showViral success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
/**
 Retrieves gallery with parameters specified in dictionary
 @param parameters    dictionary of parameters to specify
 */
+(void)galleryWithParameters:(NSDictionary *)parameters success:(void (^)(NSArray * objects))success failure:(void (^)(NSError * error))failure;

#pragma mark - Load Gallery objects
/**
 Retrieves gallery object with id
 @param galleryObjectID    object Id string as retrieved through gallery page call
 */
+ (void)objectWithID:(NSString *)galleryObjectID success:(void (^)(id<IMGGalleryObjectProtocol> object))success failure:(void (^)(NSError * error))failure;
/**
 Retrieves gallery image with id
 @param imageID    image Id string as retrieved through gallery page call
 */
+ (void)imageWithID:(NSString *)imageID success:(void (^)(IMGGalleryImage *image))success failure:(void (^)(NSError *error))failure;
/**
 Retrieves gallery album with id
 @param albumID    album Id string as retrieved through gallery page call
 */
+ (void)albumWithID:(NSString *)albumID success:(void (^)(IMGGalleryAlbum *album))success failure:(void (^)(NSError *error))failure;
/**
 Retrieves gallery album with id
 @param albumID    album Id string as retrieved through gallery page call
 @param coverImage    should we download the cover image as well
 */
+ (void)albumWithID:(NSString *)albumID withCoverImage:(BOOL)coverImage success:(void (^)(IMGGalleryAlbum *album))success failure:(void (^)(NSError *error))failure;
/**
 Retrieves gallery cover image and places it in images array
 @param album    album object o update with cover image
 */
+ (void)albumCoverWithAlbum:(IMGGalleryAlbum*)album success:(void (^)(IMGGalleryAlbum * album))success failure:(void (^)(NSError * error))failure;
#pragma mark - Submit Gallery Objects

/**
 Submits gallery image with id. Must be logged in.
 @param imageId    imageId to submit to gallery
 @param title    title to append to top of imgur page
 */
+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title success:(void (^)())success failure:(void (^)(NSError *error))failure;
+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title terms:(BOOL)terms success:(void (^)())success failure:(void (^)(NSError *error))failure;
/**
 Submits gallery album with id. Must be logged in.
 @param albumID    albumID to submit to gallery
 @param title    title to append to top of imgur page
 */
+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title success:(void (^)())success failure:(void (^)(NSError *error))failure;
+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title terms:(BOOL)terms success:(void (^)())success failure:(void (^)(NSError *error))failure;

#pragma mark - Remove Gallery objects

/**
 Removes gallery image from gallery. Must be logged in.
 @param imageID    imageID to remove from gallery
 */
+ (void)removeImageWithID:(NSString *)imageID success:(void (^)())success failure:(void (^)(NSError *error))failure;
/**
 Removes gallery album from gallery. Must be logged in.
 @param albumID    albumID to remove from gallery
 */
+ (void)removeAlbumWithID:(NSString *)albumID success:(void (^)())success failure:(void (^)(NSError *error))failure;


#pragma mark - Voting/Reporting

/**
 Report gallery object ID as being offensive
 @param galleryObjectId    gallery object id string to report
 */
+ (void)reportWithID:(NSString *)galleryObjectID success:(void (^)())success failure:(void (^)(NSError *error))failure;
/**
 Vote on gallery object ID. Must be logged in.
 @param vote    vote type for user to vote on gallery object
 */
+ (void)voteWithID:(NSString *)galleryObjectID withVote:(IMGVoteType)vote success:(void (^)())success failure:(void (^)(NSError *error))failure;
/**
 Retrieve voting results for a gallery object
 */
+ (void)voteResultsWithID:(NSString *)galleryObjectID success:(void (^)(IMGVote * vote))success failure:(void (^)(NSError *error))failure;

#pragma mark - Comment Actions - IMGCommentRequest

/**
 Retrieves comments from gallery object
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 @param commentSort    sort comments by best, hot or new
 */
+ (void)commentsWithGalleryID:(NSString *)galleryObjectID withSort:(IMGGalleryCommentSortType)commentSort success:(void (^)(NSArray * comments))success failure:(void (^)(NSError * error))failure;
/**
 Retrieves comment IDS from gallery object
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 @param commentSort    sort comments by best, hot or new
 */
+ (void)commentIDsWithGalleryID:(NSString *)galleryObjectID withSort:(IMGGalleryCommentSortType)commentSort success:(void (^)(NSArray * commentIDs))success failure:(void (^)(NSError * error))failure;
/**
 Retrieve a comment with an ID from a gallery object
 @param commentId    comment ID to get
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 */
+ (void)commentWithID:(NSInteger)commentID galleryID:(NSString *)galleryObjectID success:(void (^)(IMGComment * comment))success failure:(void (^)(NSError * error))failure;
/**
 Submits a comment to a gallery object. Must be logged in.
 @param caption    comment to post
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 */
+ (void)submitComment:(NSString*)caption galleryID:(NSString *)galleryObjectID success:(void (^)(IMGComment * comment))success failure:(void (^)(NSError * error))failure;
/**
 Reply to a comment. Must be logged in.
 @param caption    comment to post
 @param galleryObjectId    ID string of gallery object to retrieve comments from
 @param parentCommentID    ID string of parent comment to post this comment to
 */
+ (void)replyToComment:(NSString*)caption galleryID:(NSString *)galleryObjectID parentComment:(NSInteger)parentCommentID success:(void (^)(IMGComment *comment))success failure:(void (^)(NSError * error))failure;
/**
 Delete a posted comment with an ID. Must be logged in.
 @param commentId    comment ID to get
 */
+ (void)deleteCommentWithID:(NSInteger)commentID success:(void (^)())success failure:(void (^)(NSError * error))failure;
/**
 Retrieves count of comments from gallery object
 @param galleryObjectId    ID string of gallery object to retrieve comment count from
 */
+ (void)commentCountWithGalleryID:(NSString *)galleryObjectID success:(void (^)(NSInteger commentCount))success failure:(void (^)(NSError * error))failure;



@end
