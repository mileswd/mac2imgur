//
//  IMGMemeGen.h
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-05-14.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"

@interface IMGMemeGen : IMGEndpoint

/**
 Return list of meme IMGImage models. Use IMGMeme to create memes and upload them with regular file upload in IMGImageRequest
 */
+(void)defaultMemes:(void (^)(NSArray * memeImages))success failure:(void (^)(NSError * error))failure;
@end
