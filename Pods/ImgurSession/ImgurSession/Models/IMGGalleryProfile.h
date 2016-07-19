//
//  IMGGalleryProfile.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"


@interface IMGGalleryTrophy : IMGModel

/**
 Trophy ID
 */
@property (readonly,nonatomic, copy) NSString * trophyID;
/**
 The name of the trophy
 */
@property (readonly,nonatomic, copy) NSString * name;
/**
 Can be thought of as the ID of a trophy type
 */
@property (readonly,nonatomic, copy) NSString * type;
/**
 A description of the trophy and how it was earned.
 */
@property (readonly,nonatomic, copy) NSString * profileDescription;
/**
 The ID of the image or the ID of the comment where the trophy was earned
 */
@property (readonly,nonatomic, copy) NSString * data;
/**
 A link to where the trophy was earned
 */
@property (readonly,nonatomic) NSURL * link;
/**
 Date the trophy was earned, epoch time
 */
@property (readonly,nonatomic) NSDate *dateAwarded;
/**
 Image URL for trophy representation
 */
@property (readonly,nonatomic) NSURL * imageUrl;



@end

/**
 Model object class to represent user gallery profile. https://api.imgur.com/models/gallery_profile
 */
@interface IMGGalleryProfile : IMGModel

/**
 Total number of comments the user has made in the gallery
 */
@property (readonly,nonatomic) NSInteger totalComments;
/**
 Total number of images liked by the user in the gallery
 */
@property (readonly,nonatomic) NSInteger totalLikes;
/**
 Total number of images submitted by the user.
 */
@property (readonly,nonatomic) NSInteger totalSubmissions;
/**
 An array of trophies that the user has.
 */
@property (readonly,nonatomic, copy) NSArray * trophies;
/**
 Username for gallery profile
 */
@property (readonly,nonatomic, copy) NSString * userName;



/**
 Custom init with username
 */
- (instancetype)initWithUser:(NSString*)username JSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error;

@end
