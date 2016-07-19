//
//  IMGVote.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

typedef NS_ENUM(NSInteger, IMGVoteType) {
    IMGDownVote      = -1,
    IMGNeutralVote   = 0,
    IMGUpVote        = 1
};


/**
 Model object class to represent votes on images, albums, and comments. https://api.imgur.com/models/vote
 */
@interface IMGVote : IMGModel

/**
 up votes
 */
@property (readonly,nonatomic) NSInteger ups;
/**
 down votes
 */
@property (readonly,nonatomic) NSInteger downs;

/**
 Return string for vote value
 @param vote enumerated value with IMGVoteType
 @return string description of vote as per https://api.imgur.com/endpoints/gallery#gallery-voting specifications
 */
+(NSString*)strForVote:(IMGVoteType)vote;
/**
 Return NSInteger from enumerable representing input string
 @param voteStr string description of vote type
 @return integer representing this vote
 */
+(IMGVoteType)voteForStr:(NSString*)voteStr;

@end
