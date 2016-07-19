//
//  IMGGalleryObject.h
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-04-14.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//
#import "IMGVote.h"
#import "IMGObject.h"

#ifndef ImgurSession_IMGGalleryObject_h
#define ImgurSession_IMGGalleryObject_h

/**
 Protocol to represent both IMGGalleryImage and IMGGalleryAlbum which contain similar information.
 */
@protocol IMGGalleryObjectProtocol <IMGObjectProtocol>


/**
 Has the user favorited the object, false if anon
 */
-(BOOL)isFavorite;
/**
 Is it safe for work?
 */
-(BOOL)isNSFW;
/**
 The user's vote for the object, if authenticated
 */
-(IMGVoteType)usersVote;
/**
 ID for the gallery object
 */
-(NSString*)objectID;
/**
 Score
 */
-(NSInteger)score;
/**
 Ups
 */
-(NSInteger)ups;
/**
 downs
 */
-(NSInteger)downs;
/**
 Username who submitted this gallery image or album.
 */
-(NSString*)fromUsername;
/**
 Sets users vote
 */
-(void)setUsersVote:(IMGVoteType)vote;
/**
 Sets users fav
 */
-(void)setUsersFav:(BOOL)faved;


@end


#endif
