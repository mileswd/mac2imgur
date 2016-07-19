//
//  IMGImageRequest.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"

@class IMGImage;

/**
 Image requests. https://api.imgur.com/endpoints/image
 */
@interface IMGImageRequest : IMGEndpoint

#pragma mark - Load

/**
 Retrieves image info from imageID
 */
+ (void)imageWithID:(NSString *)imageID success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;

#pragma mark - Upload one image

/**
 Upload a gif with NSData
 */
+ (void)uploadImageWithGifData:(NSData *)gifData title:(NSString *)title success:(void (^)(IMGImage * image))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError * error))failure;
+ (void)uploadImageWithGifData:(NSData *)gifData compression:(CGFloat)compression title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage * image))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError * error))failure;
/**
 Upload an image with NSData
 */
+ (void)uploadImageWithData:(NSData*)imageData title:(NSString *)title success:(void (^)(IMGImage * image))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError * error))failure;
+ (void)uploadImageWithData:(NSData*)imageData title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage * image))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError * error))failure;
/**
 Upload an image with local image URL
 */
+ (void)uploadImageWithFileURL:(NSURL *)fileURL success:(void (^)(IMGImage *image))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError * error))failure;
+ (void)uploadImageWithFileURL:(NSURL *)fileURL title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *image))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError *error))failure;

/**
 Upload an image with an external image URL
 */
+ (void)uploadImageWithURL:(NSURL *)url success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;
+ (void)uploadImageWithURL:(NSURL *)url title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *image))success failure:(void (^)(NSError *error))failure;

#pragma mark - Upload multiple images - JPEG only

/**
 Upload multiple images using image file url, title and description in NSDictionary in files and optionally link the images to an album
 */
+(void)uploadImages:(NSArray*)files toAlbumWithID:(NSString*)albumID success:(void (^)(NSArray *))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError * error))failure;
+(void)uploadImages:(NSArray*)files success:(void (^)(NSArray *))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError * error))failure;

#pragma mark - Delete

/**
 Delete an image with an image ID if you are the owner of the image. Must be logged in.
 */
+ (void)deleteImageWithID:(NSString *)imageID success:(void (^)())success failure:(void (^)(NSError *error))failure;
/**
 Delete an image with an anonymous deletehash
 */
+ (void)deleteImageWithHash:(NSString *)deletehash success:(void (^)())success failure:(void (^)(NSError * error))failure;

#pragma mark - Favourtie
/**
 Fav an album. Must be signed in.
 */
+(void)favouriteImageWithID:(NSString*)imageID  success:(void (^)())success failure:(void (^)(NSError *error))failure;


#pragma mark - Update

/**
 Change image title or description or both. Must be logged In.
 */
+ (void)updateImageWithID:(NSString *)imageID title:(NSString*)title description:(NSString*)description success:(void (^)())success failure:(void (^)(NSError * error))failure;
/**
 Anonymously change title or description with deletehash
 */
+ (void)updateImageWithDeleteHash:(NSString *)deletehash title:(NSString*)title description:(NSString*)description success:(void (^)())success failure:(void (^)(NSError * error))failure;
@end
