//
//  IMGCommentRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGCommentRequest.h"
#import "IMGComment.h"
#import "IMGSession.h"

@implementation IMGCommentRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"comment";
}

#pragma mark - Load

+ (void)commentWithID:(NSInteger)commentID withReplies:(BOOL)replies success:(void (^)(IMGComment * comment))success failure:(void (^)(NSError * error))failure{
    NSString *path = [self pathWithID:[NSString stringWithFormat:@"%lu", (unsigned long)commentID]];
    
    if(replies)
        path = [self pathWithID:[NSString stringWithFormat:@"%lu", (unsigned long)commentID] withOption:@"replies"];
    
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

+ (void)repliesWithCommentID:(NSInteger)commentID success:(void (^)(NSArray * replies))success failure:(void (^)(NSError * error))failure{
    
    NSString *path = [self pathWithID:[NSString stringWithFormat:@"%lu", (unsigned long)commentID] withOption:@"replies"];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * jsonArray = responseObject[@"children"];
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

#pragma mark - Create

+ (void)submitComment:(NSString*)caption withImageID:(NSString *)imageId success:(void (^)(NSInteger commentID))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:imageId];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    NSDictionary * params = @{@"image_id":imageId,@"comment":caption};
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //returns string in dictionary for some reason
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * commentId = [f numberFromString:responseObject[@"id"]];
        
        if(success)
            success([commentId integerValue]);
        
    } failure:failure];
}

+ (void)replyToComment:(NSString*)caption withImageID:(NSString*)imageId withParentCommentID:(NSInteger)parentCommentId success:(void (^)(NSInteger))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:[NSString stringWithFormat:@"%ld",(long)parentCommentId]];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    NSDictionary * params = @{@"image_id":imageId,@"comment":caption};
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //returns string in dictionary for some reason
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * commentId = [f numberFromString:responseObject[@"id"]];
        
        if(success)
            success([commentId integerValue]);
        
    } failure:failure];
}

#pragma mark - Delete

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

#pragma mark - Vote

+ (void)voteCommentWithID:(NSInteger)commentID withVote:(IMGVoteType)vote success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:[NSString stringWithFormat:@"%lu", (unsigned long)commentID] withOption:@"vote" withID2:[IMGVote strForVote:vote]];
    
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


#pragma mark - Report

+ (void)reportCommentWithID:(NSInteger)commentID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:[NSString stringWithFormat:@"%lu", (unsigned long)commentID] withOption:@"vote/report"];
    
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

@end
