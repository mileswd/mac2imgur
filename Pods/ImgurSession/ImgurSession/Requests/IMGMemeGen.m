//
//  IMGMemeGen.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-05-14.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGMemeGen.h"

#import "IMGImage.h"
#import "IMGSession.h"

@implementation IMGMemeGen

+(NSString*)pathComponent{
    return @"memegen";
}

+(void)defaultMemes:(void (^)(NSArray * memeImages))success failure:(void (^)(NSError * error))failure{
    NSString *path = [self pathWithID:@"defaults"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    
        NSMutableArray * memeImages = [NSMutableArray new];
        NSArray * jsonArray = responseObject;
        
        for(NSDictionary * json in jsonArray){
            
            NSError *JSONError = nil;
            IMGImage * meme = [[IMGImage alloc] initWithJSONObject:json error:&JSONError];
            if(!JSONError && meme)
                [memeImages addObject:meme];
        }
        if(success)
            success([NSArray arrayWithArray:memeImages]);

        
    } failure:failure];
}

@end
