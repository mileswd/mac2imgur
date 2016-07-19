//
//  IMGGalleryRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGGalleryRequest.h"
#import "IMGGalleryImage.h"
#import "IMGGalleryAlbum.h"
#import "IMGComment.h"
#import "IMGCommentRequest.h"
#import "IMGImageRequest.h"
#import "IMGAccountRequest.h"
#import "IMGSession.h"


@interface IMGGalleryAlbum ()

@property (readwrite,nonatomic) NSArray *images;

@end

@implementation IMGGalleryRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"gallery";
}

#pragma mark - Load Gallery Pages

+(void)hotGalleryPage:(NSInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    //all default params
    [IMGGalleryRequest hotGalleryPage:page withViralSort:YES success:success failure:failure];
}

+(void)hotGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary * params = @{@"section":@"hot", @"page":[NSNumber numberWithInteger:page], @"sort":(viralSort ? @"viral" : @"time")};
    
    [IMGGalleryRequest galleryWithParameters:params success:success failure:failure];
}

+(void)topGalleryPage:(NSInteger)page withWindow:(IMGTopGalleryWindow)window success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    [IMGGalleryRequest topGalleryPage:page withWindow:window withViralSort:YES success:success failure:failure];
}

+(void)topGalleryPage:(NSInteger)page withWindow:(IMGTopGalleryWindow)window withViralSort:(BOOL)viralSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString * windowStr;
    switch (window) {
        case IMGTopGalleryWindowDay:
            windowStr = @"day";
            break;
        case IMGTopGalleryWindowWeek:
            windowStr = @"week";
            break;
        case IMGTopGalleryWindowMonth:
            windowStr = @"month";
            break;
        case IMGTopGalleryWindowYear:
            windowStr = @"year";
            break;
        case IMGTopGalleryWindowAll:
            windowStr = @"all";
            break;
        default:
            windowStr = @"day";
            break;
    }
    
    //defauts are viral sort
    NSDictionary * params = @{@"section" : @"top", @"page":[NSNumber numberWithInteger:page], @"window": windowStr, @"sort":(viralSort ? @"viral" : @"time")};
    
    [IMGGalleryRequest galleryWithParameters:params success:success failure:failure];
}

+(void)userGalleryPage:(NSInteger)page showViral:(BOOL)showViral success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    [IMGGalleryRequest userGalleryPage:page withViralSort:NO showViral:showViral success:success failure:failure];
}

+(void)userGalleryPage:(NSInteger)page withViralSort:(BOOL)viralSort showViral:(BOOL)showViral success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary * params = @{@"section":@"user", @"page":[NSNumber numberWithInteger:page], @"sort":(viralSort ? @"viral" : @"time"), @"showViral": (showViral ? @"true" : @"false" )};
    
    [IMGGalleryRequest galleryWithParameters:params success:success failure:failure];
}

+(void)galleryWithParameters:(NSDictionary *)parameters success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self path];
    
    if(parameters[@"section"])
        path = [path stringByAppendingPathComponent:parameters[@"section"]];
    
    if(parameters[@"sort"])
        path = [path stringByAppendingPathComponent:parameters[@"sort"]];
    
    if(parameters[@"page"])
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld?page=%ld", (long)[(NSNumber*)parameters[@"page"] integerValue],(long)[(NSNumber*)parameters[@"page"] integerValue]]];
    
    if(parameters[@"showViral"])
        path = [path stringByAppendingString:[NSString stringWithFormat:@"&showViral=%@",[(NSNumber*)parameters[@"showViral"] boolValue] ? @"true" : @"false"]];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * jsonArray = responseObject;
        NSMutableArray * images = [NSMutableArray new];
        
        for(NSDictionary * json in jsonArray){
            
            if([json[@"is_album"] boolValue]){
                NSError *JSONError = nil;
                IMGGalleryAlbum * album = [[IMGGalleryAlbum alloc] initWithJSONObject:json error:&JSONError];
                if(!JSONError && album)
                    [images addObject:album];
            } else {
                
                NSError *JSONError = nil;
                IMGGalleryImage * image = [[IMGGalleryImage alloc] initWithJSONObject:json error:&JSONError];
                if(!JSONError && image)
                    [images addObject:image];
            }
        }
        if(success)
            success([NSArray arrayWithArray:images]);

    } failure:failure];
}

#pragma mark - Load Gallery objects

+ (void)objectWithID:(NSString *)galleryObjectID success:(void (^)(id<IMGGalleryObjectProtocol>))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:galleryObjectID];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        
        //check if album or image
        if([responseObject[@"is_album"] boolValue]){
            
            IMGGalleryAlbum *album = [[IMGGalleryAlbum alloc] initWithJSONObject:responseObject error:&JSONError];
            
            if(!JSONError && album) {
                if(success)
                    success(album);
            }
            else {
                if(failure)
                    failure(JSONError);
            }
        } else {
            IMGGalleryImage *image = [[IMGGalleryImage alloc] initWithJSONObject:responseObject error:&JSONError];
            
            if(!JSONError && image) {
                if(success)
                    success(image);
            }
            else {
                
                if(failure)
                    failure(JSONError);
            }
        }
        
    } failure:failure];
}

+(void)imageWithID:(NSString *)imageID success:(void (^)(IMGGalleryImage *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"image" withID2:imageID];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGGalleryImage *image = [[IMGGalleryImage alloc] initWithJSONObject:responseObject error:&JSONError];
        
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

+ (void)albumWithID:(NSString *)albumID success:(void (^)(IMGGalleryAlbum *))success failure:(void (^)(NSError *))failure{
    [self albumWithID:albumID withCoverImage:NO success:success failure:failure];
}

+ (void)albumWithID:(NSString *)albumID withCoverImage:(BOOL)coverImage success:(void (^)(IMGGalleryAlbum *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"album" withID2:albumID];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        

        
        NSError *JSONError = nil;
        IMGGalleryAlbum *album = [[IMGGalleryAlbum alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && album) {
            if(coverImage){
                [IMGImageRequest imageWithID:album.coverID success:^(IMGImage *image) {
                    
                    //set just the cover image
                    [album setImages:[NSArray arrayWithObject:image]];
                    
                    if(success)
                        success(album);
                    
                } failure:failure];
            } else {
                //don't download cover
                if(success)
                    success(album);
            }
        }
        else {
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

+ (void)albumCoverWithAlbum:(IMGGalleryAlbum*)album success:(void (^)(IMGGalleryAlbum *))success failure:(void (^)(NSError *))failure{

    [IMGImageRequest imageWithID:album.coverID success:^(IMGImage *image) {
        
        //set just the cover image
        [album setCoverImage:image];
        
        if(success)
            success(album);
        
    } failure:failure];
}

#pragma mark - Submit Gallery Objects

+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title success:(void (^)())success failure:(void (^)(NSError *))failure{
    return [self submitImageWithID:imageID title:title terms:YES success:success failure:failure];
}

+ (void)submitImageWithID:(NSString *)imageID title:(NSString *)title terms:(BOOL)terms success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"image" withID2:imageID];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    NSDictionary *parameters = @{@"title":title , @"terms": (terms ? @"true" : @"false" )};
    
    [[IMGSession sharedInstance] POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {

        if(success)
            success();
        
    } failure:^(NSError *error) {
        
        //is it unverified?
        if(error.code == 400){
            
            //send user email
            [IMGAccountRequest sendUserEmailVerification:^{
                if(failure)
                    failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorNeededVerificationAndSent userInfo:nil]);
                
            } failure:^(NSError *sendError) {
                if(failure)
                    failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorNeededVerificationCouldNotSend userInfo:nil]);
            }];
         } else {
             if(failure)
                 failure(error);
         }
    }];
}

+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title success:(void (^)())success failure:(void (^)(NSError *))failure{
    return [self submitAlbumWithID:albumID title:title terms:YES success:success failure:failure];
}

+ (void)submitAlbumWithID:(NSString *)albumID title:(NSString *)title terms:(BOOL)terms success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"album" withID2:albumID];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    NSDictionary *parameters = @{@"title":title , @"terms": (terms ? @"true" : @"false" )};
    
    [[IMGSession sharedInstance] POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    
        if(success)
            success();
    } failure:^(NSError *error) {
        
        //is it unverified?
        if(error.code == 400){
            
            //send user email
            [IMGAccountRequest sendUserEmailVerification:^{
                if(failure)
                    failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorNeededVerificationAndSent userInfo:nil]);
                
            } failure:^(NSError *sendError) {
                if(failure)
                    failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorNeededVerificationCouldNotSend userInfo:nil]);
            }];
        } else {
            if(failure)
                failure(error);
        }
    }];
}

#pragma mark - Remove Gallery objects

+ (void)removeImageWithID:(NSString *)imageID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:imageID];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}

+ (void)removeAlbumWithID:(NSString *)albumID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:albumID];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        if(success)
            success();
    } failure:failure];
}

#pragma mark - Voting/Reporting

+ (void)reportWithID:(NSString *)galleryObjectID success:(void (^)())success failure:(void (^)(NSError *error))failure{
    NSString *path = [self pathWithID:galleryObjectID withOption:@"report"];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
    } failure:failure];
}

+ (void)voteWithID:(NSString *)galleryObjectID withVote:(IMGVoteType)vote success:(void (^)())success failure:(void (^)(NSError *error))failure{
    NSString *path = [self pathWithID:galleryObjectID withOption:@"vote" withID2:[IMGVote strForVote:vote]];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
    } failure:failure];
}

+ (void)voteResultsWithID:(NSString *)galleryObjectID success:(void (^)(IMGVote *))success failure:(void (^)(NSError *error))failure{
    NSString *path = [self pathWithID:galleryObjectID withOption:@"votes"];
    
    [[IMGSession sharedInstance] POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSError *JSONError = nil;
        IMGVote * vote = [[IMGVote alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && vote) {
            if(success)
                success(vote);
        }
        else {
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}


#pragma mark - Comment Actions - IMGCommentRequest

+ (void)commentsWithGalleryID:(NSString *)galleryObjectID withSort:(IMGGalleryCommentSortType)commentSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString * sortStr;
    switch (commentSort) {
        case IMGGalleryCommentSortBest:
            sortStr = @"best";
            break;
        case IMGGalleryCommentSortHot:
            sortStr = @"hot";
            break;
        case IMGGalleryCommentSortNew:
            sortStr = @"new";
            break;
        default:
            sortStr = @"best";
            break;
    }
    NSString *path = [self pathWithID:galleryObjectID withOption:@"comments" withID2:sortStr];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * jsonArray = responseObject;
        NSMutableArray * comments = [NSMutableArray new];
        
        for(NSDictionary * json in jsonArray){
            
            NSError *JSONError = nil;
            IMGComment * comment = [[IMGComment alloc] initWithJSONObject:json error:&JSONError];
            if(!JSONError && comment)
                [comments addObject:comment];
        }
        if(success)
            success([NSArray arrayWithArray:comments]);
        
    } failure:failure];
}

+ (void)commentIDsWithGalleryID:(NSString *)galleryObjectID withSort:(IMGGalleryCommentSortType)commentSort success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:galleryObjectID withOption:@"comments/ids"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * idArray = responseObject;
        if(success)
            success(idArray);
        
    } failure:failure];
}

+ (void)commentWithID:(NSInteger)commentID galleryID:(NSString *)galleryObjectID success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:galleryObjectID withOption:@"comment" withID2:[NSString stringWithFormat:@"%lu", (unsigned long)commentID]];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGComment *comment = [[IMGComment alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && comment) {
            if(success)
                success(comment);
        }
        else {
            if(failure)
                failure(JSONError);
        }
        
    } failure:failure];
}

+ (void)submitComment:(NSString*)caption galleryID:(NSString *)galleryObjectID success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    
    [self submitComment:caption galleryID:galleryObjectID parentComment:0 success:success failure:failure];
}

+ (void)submitComment:(NSString*)caption galleryID:(NSString *)galleryObjectID parentComment:(NSInteger)parentCommentID success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    
    NSString *path;
    if(parentCommentID)
        path = [self pathWithID:galleryObjectID withOption:@"comment"];
    else
        path = [self pathWithID:galleryObjectID withOption:@"comment" withID2:[NSString stringWithFormat:@"%lu", (unsigned long)parentCommentID]];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    NSDictionary * params = @{@"comment":caption};
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGComment *comment = [[IMGComment alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && comment) {
            if(success)
                success(comment);
        }
        else {
            if(failure)
                failure(JSONError);
        }
    } failure:failure];
}

+ (void)replyToComment:(NSString*)caption galleryID:(NSString *)galleryObjectID parentComment:(NSInteger)parentCommentID success:(void (^)(IMGComment *))success failure:(void (^)(NSError *))failure{
    [self submitComment:caption galleryID:galleryObjectID parentComment:parentCommentID success:success failure:failure];
}

+ (void)deleteCommentWithID:(NSInteger)commentID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:[NSString stringWithFormat:@"%lu", (unsigned long)commentID]];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}

+ (void)commentCountWithGalleryID:(NSString *)galleryObjectID success:(void (^)(NSInteger))success failure:(void (^)(NSError *))failure{
    
    NSString *path = [self pathWithID:galleryObjectID withOption:@"comments/count"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber * numComments = responseObject;
        if(success)
            success([numComments integerValue]);
        
    } failure:failure];
}

@end
