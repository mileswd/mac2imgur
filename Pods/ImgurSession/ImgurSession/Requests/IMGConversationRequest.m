//
//  IMGConversationRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGConversationRequest.h"
#import "IMGMessage.h"
#import "IMGConversation.h"
#import "IMGSession.h"

@implementation IMGConversationRequest
#pragma mark - Path

+(NSString *)pathComponent{
    return @"conversations";
}

#pragma mark - Load

+ (void)conversations:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString * path = [self path];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * convoJSON = responseObject;
        NSMutableArray * convos = [NSMutableArray new];
        
        for(NSDictionary * conversationJSON in convoJSON){
            
            NSError *JSONError = nil;
            IMGConversation *convo = [[IMGConversation alloc] initWithJSONObject:conversationJSON error:&JSONError];
            
            if(!JSONError && convo){
                [convos addObject:convo];
            }
        }
        
        if(success)
            success([NSArray arrayWithArray:convos]);
        
    } failure:failure];
}

+ (void)conversationWithMessageID:(NSInteger)messageId success:(void (^)(IMGConversation *))success failure:(void (^)(NSError *))failure{
    NSString * path = [self pathWithID:[NSString stringWithFormat:@"%lu", (long)messageId]];
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGConversation *convo = [[IMGConversation alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && convo) {
            if(success)
                success(convo);
        }
        else {
            if(failure)
                failure(JSONError);
        }
        
    } failure:failure];
}

#pragma mark - Create


+ (void)createMessageWithRecipient:(NSString*)recipient withBody:(NSString*)body success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:recipient];
    NSDictionary * params = @{@"recipient":recipient,@"body":body};
    
    if([[IMGSession sharedInstance] isAnonymous]){
        if(failure)
            failure([NSError errorWithDomain:IMGErrorDomain code:IMGErrorRequiresUserAuthentication userInfo:@{IMGErrorServerPath:path}]);
        return;
    }
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
        
    } failure:failure];
}

#pragma mark - Delete

+ (void)deleteConversation:(NSInteger)convoID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithID:[NSString stringWithFormat:@"%lu", (long)convoID]];
    
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

#pragma mark - Report

+ (void)reportSender:(NSString*)username success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"report" withID2:username];
    
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

#pragma mark - Block

+ (void)blockSender:(NSString*)username success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithOption:@"block" withID2:username];
    
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
