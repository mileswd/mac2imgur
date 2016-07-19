//
//  IMGGalleryAlbum.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGAlbum.h"

#import "IMGVote.h"
#import "IMGGalleryImage.h"
#import "IMGComment.h"


/**
 Model object class to represent albums posted to the gallery. https://api.imgur.com/models/gallery_album
 */
@interface IMGGalleryAlbum : IMGBasicAlbum <IMGGalleryObjectProtocol>


/**
 Users up or down vote on the image
 */
@property (nonatomic, readonly) IMGVoteType vote;
/**
 Section description of album
 */
@property (nonatomic, readonly, copy) NSString *section;
/**
 Global up votes
 */
@property (nonatomic, readonly) NSInteger ups;
/**
 Global down votes
 */
@property (nonatomic, readonly) NSInteger downs;
/**
 Up votes minus down vote.
 */
@property (nonatomic, readonly) NSInteger score;
/**
 Has the user favorited?
 */
@property (nonatomic, readonly) BOOL favorite;
/**
 Is it flagged NSFW>
 */
@property (nonatomic, readonly) BOOL nsfw;

/**
 Custom init with comment
 */
-(instancetype)initWithComment:(IMGComment*)comment error:(NSError *__autoreleasing *)error;
@end
