//
//  IMGGalleryImage.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGImage.h"

#import "IMGVote.h"
#import "IMGGalleryObject.h"
#import "IMGComment.h"

/**
 Model object class to represent images that are posted to the Imgur Gallery. Can be a part of an album. https://api.imgur.com/models/gallery_image 
 */
@interface IMGGalleryImage : IMGImage <IMGGalleryObjectProtocol>

/**
 Users up or down vote on the image
 */
@property (nonatomic, readonly) IMGVoteType vote;
/**
 Username of submitter if not anon
 */
@property (nonatomic, readonly, copy) NSString *accountURL;
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
