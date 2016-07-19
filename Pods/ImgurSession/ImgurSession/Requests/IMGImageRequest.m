//
//  IMGImageRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGImageRequest.h"

#import "IMGSession.h"
#import "IMGImage.h"

@implementation IMGImageRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"image";
}

#pragma mark - Load

+ (void)imageWithID:(NSString *)imageID success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:imageID];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGImage *image = [[IMGImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && image) {
            if(success)
                success(image);
        }
        else {
        
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Upload one image

+ (void)uploadImageWithGifData:(NSData *)gifData title:(NSString *)title success:(void (^)(IMGImage *))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError *))failure{
    
    [self uploadImageWithGifData:gifData compression:1.0f title:title description:nil linkToAlbumWithID:nil success:success progress:progress failure:failure];
}

+ (void)uploadImageWithGifData:(NSData *)gifData compression:(CGFloat)compression title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *))success  progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError *))failure{
    //upload file from binary data
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"type"] = @"file";
    
    // Add used parameters
    if(title)
        parameters[@"title"] = title;
    if(description)
        parameters[@"description"] = description;
    if(albumID )
        parameters[@"album"] = albumID;
    
    // Create the request with the file appended to the body
    __block NSError *fileAppendingError = nil;
    
    void (^appendFile)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:gifData name:@"image" fileName:title mimeType:@"image/gif"];
    };
    
    // If there's a file appending error, we must abort and return the error
    if(fileAppendingError){
        if(failure)
            failure(fileAppendingError);
        return;
    }
    
    //post
    [[IMGSession sharedInstance] POST:[self path] parameters:parameters constructingBodyWithBlock:appendFile success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGImage *image = [[IMGImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && image) {
            if(success)
                success(image);
        }
        else {
            if(failure)
                failure(JSONError);
        }
        
    } progress:progress failure:failure];
}

+ (void)uploadImageWithData:(NSData*)imageData title:(NSString *)title success:(void (^)(IMGImage *))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError *))failure{
 
    [self uploadImageWithData:imageData title:title description:nil linkToAlbumWithID:nil success:success progress:progress failure:failure];
}

+ (void)uploadImageWithData:(NSData*)imageData title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError *))failure{
    //upload file from binary data
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"type"] = @"file";
    
    // Add used parameters
    if(title)
        parameters[@"title"] = title;
    if(description)
        parameters[@"description"] = description;
    if(albumID )
        parameters[@"album"] = albumID;
    
    // Create the request with the file appended to the body
    __block NSError *fileAppendingError = nil;
    
    void (^appendFile)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:title mimeType:@"image/jpeg"];
    };
    
    
    // If there's a file appending error, we must abort and return the error
    if(fileAppendingError){
        if(failure)
            failure(fileAppendingError);
        return;
    }
    
    //post
    [[IMGSession sharedInstance] POST:[self path] parameters:parameters constructingBodyWithBlock:appendFile success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGImage *image = [[IMGImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && image) {
            if(success)
                success(image);
        }
        else {
            if(failure)
                failure(JSONError);
        }
        
    } progress:progress failure:failure];
}

+ (void)uploadImageWithFileURL:(NSURL *)fileURL success:(void (^)(IMGImage *))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError *))failure{
    
    [self uploadImageWithFileURL:fileURL title:nil description:nil linkToAlbumWithID:nil success:success progress:progress failure:failure];
}

+ (void)uploadImageWithFileURL:(NSURL *)fileURL title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *))success progress:(NSProgress * __autoreleasing *)progress failure:(void (^)(NSError *))failure{
    //upload file from binary data
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"type"] = @"file";
    
    // Add used parameters
    if(title)
        parameters[@"title"] = title;
    if(description)
        parameters[@"description"] = description;
    if(albumID )
        parameters[@"album"] = albumID;
    
    // Create the request with the file appended to the body
    __block NSError *fileAppendingError = nil;
    
    void (^appendFile)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:fileURL name:@"image" error:&fileAppendingError];
    };
    
    // If there's a file appending error, we must abort and return the error
    if(fileAppendingError){
        if(failure)
            failure(fileAppendingError);
        return;
    }
    
    //post
    [[IMGSession sharedInstance] POST:[self path] parameters:parameters constructingBodyWithBlock:appendFile success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGImage *image = [[IMGImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && image) {
            if(success)
                success(image);
        }
        else {
            if(failure)
                failure(JSONError);
        }
        
    } progress:progress failure:failure];
}

+ (void)uploadImageWithURL:(NSURL *)url success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    return [self uploadImageWithURL:url title:nil description:nil linkToAlbumWithID:nil success:success failure:failure];
}

+ (void)uploadImageWithURL:(NSURL *)url title:(NSString *)title description:(NSString *)description linkToAlbumWithID:(NSString *)albumID success:(void (^)(IMGImage *))success failure:(void (^)(NSError *))failure{
    //just upload with a url
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"image"] = [url absoluteString];
    parameters[@"name"] = [url lastPathComponent];
    parameters[@"type"] = @"URL";
    
    // Add used parameters
    if(title)
        parameters[@"title"] = title;
    if(description)
        parameters[@"description"] = description;
    if(albumID )
        parameters[@"album"] = albumID;
    
    [[IMGSession sharedInstance] POST:[self path] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGImage *image = [[IMGImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && image) {
            if(success)
                success(image);
        } else {
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

#pragma mark - Upload multiple images

+(void)uploadImages:(NSArray*)files success:(void (^)(NSArray *))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError *))failure{
    
    [self uploadImages:files toAlbumWithID:nil success:success progress:progress failure:failure];
}

+(void)uploadImages:(NSArray*)files toAlbumWithID:(NSString*)albumID success:(void (^)(NSArray *))success progress:(NSProgress * __autoreleasing *)progress  failure:(void (^)(NSError *))failure{
    
    NSParameterAssert(files);
    
    //async invocation
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //keep track of multiple file uploads with semaphore
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        //return images
        __block NSMutableArray * images = [NSMutableArray new];
        
        for(NSDictionary * file in files){
            
            //expects titles and files and descriptions
            NSParameterAssert(file[@"title"]);
            NSParameterAssert(file[@"description"]);
            NSParameterAssert(file[@"fileURL"]);
            
            [self uploadImageWithFileURL:file[@"fileURL"] title:file[@"title"] description:file[@"description"] linkToAlbumWithID:albumID success:^(IMGImage *image) {
                
                [images addObject:image];
                
                dispatch_semaphore_signal(sema);
                
            } progress:progress failure:^(NSError *error) {
                
                dispatch_semaphore_signal(sema);
            }];
        }
        
        //waits until above is completed
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //for each
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }];

        if(success){
            success([NSArray arrayWithArray:images]);
        }
    });
}

#pragma mark - Delete

+ (void)deleteImageWithID:(NSString *)imageID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:imageID];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [self deleteImageWithHash:imageID success:success failure:failure];
}

+ (void)deleteImageWithHash:(NSString *)deletehash success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:deletehash];
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            
            success();
    } failure:failure];
}

#pragma mark - Favourite

+(void)favouriteImageWithID:(NSString*)imageID  success:(void (^)())success failure:(void (^)(NSError *error))failure{
    NSString *path = [self pathWithID:imageID withOption:@"favorite"];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] POST:path parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
    } failure:failure];
}

#pragma mark - Update

+ (void)updateImageWithID:(NSString *)imageID title:(NSString*)title description:(NSString*)description success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:imageID];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [self updateImageWithDeleteHash:imageID title:title description:description success:success failure:failure];
}

+ (void)updateImageWithDeleteHash:(NSString *)deletehash title:(NSString*)title description:(NSString*)description success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:deletehash];

    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    // Add used parameters
    if(title)
        parameters[@"title"] = title;
    if(description)
        parameters[@"description"] = description;
    
    [[IMGSession sharedInstance] POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}
@end
