//
//  IMGAccountSettings.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-12.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

#import "IMGBasicAlbum.h"


/**
 Model object class to represent blocked users from account settings
 */
@interface IMGBlockedUser : IMGModel

/**
 Blocked users Id
 */
@property (nonatomic, readonly, copy) NSString *blockedID;
/**
 Blocked users URL for account page
 */
@property (nonatomic, readonly) NSURL *blockedURL;

//initializer with a dictionary with just two keys
- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError * __autoreleasing *)error;

@end


/**
 Model object class to represent account settings. https://api.imgur.com/models/account_settings
 */
@interface IMGAccountSettings : IMGModel <NSCopying,NSCoding>

/**
 User's email string.
 */
@property (nonatomic, readonly, copy) NSString *email;
/**
 User's album privacy setting. If hidden, public cannot see user's albums.
 */
@property (nonatomic, readonly) IMGAlbumPrivacy albumPrivacy;
/**
 User allows all images submitted to be accessible to public.
 */
@property (nonatomic, readonly) BOOL publicImages;
/**
 Does user have Imgur regulated ability to upload high quality images
 */
@property (nonatomic, readonly) BOOL highQuality;
/**
 Expiry date or false if not a pro user
 */
@property (nonatomic, readonly) NSDate * proExpiration;
/**
 Has user accepted gallery submission terms?
 */
@property (nonatomic, readonly) BOOL acceptedGalleryTerms;
/**
 Array of email strings that are allowed to upload to imgur
 */
@property (nonatomic, readonly, copy) NSArray *activeEmails;
/**
 Is user allowing incoming messages
 */
@property (nonatomic, readonly) BOOL messagingEnabled;
/**
 Array of blocked users with IMGBLockedUser model object.
 */
@property (nonatomic, readonly, copy) NSArray *blockedUsers;
/**
 Username string
 */
@property (nonatomic, readonly, copy) NSString *username;

/**
 Custom init with username
 */
- (instancetype)initWithJSONObject:(NSDictionary *)jsonData withName:(NSString*)username error:(NSError * __autoreleasing *)error;

@end
