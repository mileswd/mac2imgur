//
//  IMGComment.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-12.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

#import "IMGGalleryObject.h"

/**
 Model object class to represent comments on images, albums, and comments. https://api.imgur.com/models/comment
 */
@interface IMGComment : IMGModel <NSCopying,NSCoding>


/**
 Comment ID
 */
@property (readonly,nonatomic) NSInteger commentID;
/**
 Gallery Object ID comment is associated with (IMGGalleryImage or IMGGalleryAlbum)
 */
@property (readonly,nonatomic, copy) NSString * galleryID;
/**
 Actual comment string
 */
@property (readonly,nonatomic, copy) NSString * caption;
/**
 Authors username
 */
@property (readonly,nonatomic, copy) NSString * author;
/**
 Authors account id
 */
@property (readonly,nonatomic) NSInteger authorID;
/**
 Comment on an album, not image
 */
@property (readonly,nonatomic) BOOL onAlbum;
/**
 Album Cover Image Id, used for album comments
 */
@property (readonly,nonatomic, copy) NSString * albumCover;
/**
 Up-votes
 */
@property (readonly,nonatomic) NSInteger ups;
/**
 down-votes
 */
@property (readonly,nonatomic) NSInteger downs;
/**
 sum of up-votes minus down-votes
 */
@property (readonly,nonatomic) NSInteger points;
/**
 timestamp of creation of comment
 */
@property (readonly,nonatomic) NSDate * datetime;
/**
 Parent comment ID, nil if no parent
 */
@property (readonly,nonatomic) NSInteger parentID;
/**
 Is comment deleted? Still exists on server
 */
@property (readonly,nonatomic) BOOL deleted;
/**
 Responses to this comment. Only included with withReplies=YES
 */
@property (readonly,nonatomic, copy) NSArray * children;
/**
 UNDOCUMENTED
 Users up or down vote on the comment
 */
@property (nonatomic, readonly) IMGVoteType vote;

/**
 Retrieve constructed gallery object for this comment
 */
-(id <IMGGalleryObjectProtocol>)galleryObject;


/**
 Custom init for when replying to a comment and only the ID is returned by the server
 */
- (instancetype)initUserCommentWithID:(NSInteger)commentID parentID:(NSInteger)parentID caption:(NSString*)caption;

/**
 Set the user's vote for this comment
 */
-(void)setUsersVote:(IMGVoteType)vote;

@end
