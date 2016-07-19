//
//  IMGObject.h
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-04-14.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

@class IMGImage;

/*
 There are 6 total thumbnails that an image can be resized to. Each one is accessable by appending a single character suffix to the end of the image id, and before the file extension. The thumbnails are:
 
 Thumbnail Suffix	Thumbnail Name	Thumbnail Size	Keeps Image Proportions
 s	Small Square	90x90	No
 b	Big Square	160x160	No
 t	Small Thumbnail	160x160	Yes
 m	Medium Thumbnail	320x320	Yes
 l	Large Thumbnail	640x640	Yes
 h	Huge Thumbnail	1024x1024	Yes
 For example, the image located at http://i.imgur.com/12345.jpg has the Medium Thumbnail located at http://i.imgur.com/12345m.jpg
 */
typedef NS_ENUM(NSInteger, IMGSize) {
    IMGSmallSquareSize,
    IMGBigSquareSize,
    IMGSmallThumbnailSize,
    IMGMediumThumbnailSize,
    IMGLargeThumbnailSize,
    IMGHugeThumbnailSize
};

#ifndef ImgurSession_IMGObject_h
#define ImgurSession_IMGObject_h

/**
 Protocol to represent both IMGGalleryImage and IMGGalleryAlbum which contain similar information.
 */
@protocol IMGObjectProtocol <NSObject>

/**
 Is the object an an album
 */
-(BOOL)isAlbum;
/**
 Get the cover image representation of object
 */
-(IMGImage*)coverImage;
/**
 Set the cover image representation of object
 */
-(void)setCoverImage:(IMGImage*)coverImage;
/**
 ID for the  object
 */
-(NSString*)objectID;
/**
 Title of object
 */
-(NSString*)title;
/**
 ID of cover Image
 */
-(NSString*)coverID;
/**
 Views
 */
-(NSInteger)views;
/**
 description
 */
-(NSString*)galleryDescription;
/**
 Get thumbnails for image/album
 */
- (NSURL *)URLWithSize:(IMGSize)size;
/**
 Get date object was created
 */
- (NSDate *)datetime;
/**
 Get imgur web page for object
 */
-(NSURL*)link;

@end



#endif
