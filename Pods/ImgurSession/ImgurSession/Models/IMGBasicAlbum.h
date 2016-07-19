//
//  ImgurPartialAlbum.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 24/07/13.
//  Distributed under the MIT license.
//

#import "IMGModel.h"

#import "IMGObject.h"


typedef NS_ENUM(NSInteger, IMGAlbumPrivacy){
    IMGAlbumDefault = 1,
    IMGAlbumPublic = 1,
    IMGAlbumHidden,
    IMGAlbumSecret
};

typedef NS_ENUM(NSInteger, IMGAlbumLayout){
    IMGDefaultLayout = 1,
    IMGBlogLayout = 1,
    IMGGridLayout,
    IMGHorizontalLayout,
    IMGVerticalLayout
};

/**
 Model object class to represent common denominator properties to gallery and user albums. https://api.imgur.com/models/album
 */
@interface IMGBasicAlbum : IMGModel <NSCopying,NSCoding,IMGObjectProtocol>

/**
 Album ID
 */
@property (nonatomic, readonly, copy) NSString *albumID;
/**
 Title of album
 */
@property (nonatomic, readonly, copy) NSString *title;
/**
 Album description
 */
@property (nonatomic, readonly, copy) NSString *albumDescription;
/**
 Album creation date
 */
@property (nonatomic, readonly) NSDate *datetime;
/**
 Image Id for cover of album
 */
@property (nonatomic, readonly, copy) NSString *coverID;
/**
 Cover image width in px
 */
@property (nonatomic, readonly) CGFloat coverWidth;
/**
 Cover image height in px
 */
@property (nonatomic, readonly) CGFloat coverHeight;
/**
 account username of album creator, not a URL but named like this anyway. nil if anonymous
 */
@property (nonatomic, readonly, copy) NSString *accountURL;
/**
 Privacy of album
 */
@property (nonatomic, readonly, copy) NSString *privacy;
/**
 Type of layout for album
 */
@property (nonatomic, readonly) IMGAlbumLayout layout;
/**
 Number of views for album
 */
@property (nonatomic, readonly) NSInteger views;
/**
 URL for album link
 */
@property (nonatomic, readonly) NSURL *url;
/**
 Number of images in album
 */
@property (nonatomic, readonly) NSInteger imagesCount; // Optional: can be set to nil
/**
 Array of images in IMGImage form
 */
@property (nonatomic, readonly, copy) NSArray *images; // Optional: can be set to nil

/**
 For custom init with gallery ID and cover ID
 */
-(instancetype)initWithGalleryID:(NSString*)objectID coverID:(NSString*)coverID error:(NSError *__autoreleasing *)error;


#pragma mark - Album Layout setting
/**
 Returns string for layout constant
 @param layoutType layout constant
 @return string for layout constant
 */
+(NSString*)strForLayout:(IMGAlbumLayout)layoutType;

/**
 Returns constant for string layout
 @param string for layout constant
 @return layout layout constant
 */
+(IMGAlbumLayout)layoutForStr:(NSString*)layoutStr;

#pragma mark - Album Privacy setting
/**
 Returns string for privacy constant
 @param privacy privacy constant
 @return string for privacy constant
 */
+(NSString*)strForPrivacy:(IMGAlbumPrivacy)privacy;

/**
 Returns constant for privacy layout
 @param string for privacy constant
 @return privacy privacy constant
 */
+(IMGAlbumPrivacy)privacyForStr:(NSString*)privacyStr;


@end
