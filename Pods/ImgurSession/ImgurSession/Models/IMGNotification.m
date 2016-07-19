//
//  IMGNotification.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGNotification.h"

#import "IMGComment.h"
#import "IMGMessage.h"
#import "IMGConversation.h"

@interface IMGNotification ()

@property (readwrite,nonatomic) NSString *notificationID;
@property (readwrite,nonatomic) NSInteger accountID;
@property (readwrite,nonatomic) IMGComment * reply;
@property (readwrite,nonatomic) IMGConversation * conversation;
@property (readwrite,nonatomic) BOOL isReply;
@property (readwrite,nonatomic) NSDate * datetime;

@end

@implementation IMGNotification

- (instancetype)initReplyNotificationWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        } else if (!jsonData[@"id"]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
        
        _notificationID = jsonData[@"id"];
        _accountID = [jsonData[@"account_id"] integerValue];
        _isViewed = [jsonData[@"viewed"] boolValue];
        _isReply = YES;
        
        NSDictionary * content = jsonData[@"content"];
        
        IMGComment * comment = [[IMGComment alloc] initWithJSONObject:content error:error];
        _reply = comment;
        _datetime = comment.datetime;
    }
    return [self trackModels];
}

- (instancetype)initConversationNotificationWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        _notificationID = jsonData[@"id"];
        _accountID = [jsonData[@"account_id"] integerValue];
        _isViewed = [jsonData[@"viewed"] boolValue];
        _isReply = NO;
        
        NSDictionary * content = jsonData[@"content"];
        
        IMGConversation * convo = [[IMGConversation alloc] initWithJSONObjectFromNotification:content error:error];
        _conversation = convo;
        _datetime = convo.datetime;
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@ ; notifyId: \"%@\"; accountId: %ld; viewed: %@;", [super description], self.notificationID, (long)self.accountID, (self.isViewed ? @"YES" : @"NO")];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGNotification class]]) {
        return NO;
    }
    
    if(self.isReply){
        
        return ([[object reply] isEqual:self.reply]);
    } else {
        
        return ([[object conversation] isEqual:self.conversation]);
    }
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSInteger accountID = [[decoder decodeObjectForKey:@"accountID"] integerValue];
    NSString * notificationID = [decoder decodeObjectForKey:@"notificationID"];
    
    IMGComment * reply= [decoder decodeObjectForKey:@"reply"];
    IMGConversation * conversation = [decoder decodeObjectForKey:@"conversation"];
    BOOL isViewed = [[decoder decodeObjectForKey:@"isViewed"] boolValue];
    BOOL isReply = [[decoder decodeObjectForKey:@"isReply"] boolValue];
    NSDate * date = [decoder decodeObjectForKey:@"date"];
        
    if (self = [super initWithCoder:decoder]) {
        _accountID = accountID;
        _notificationID = notificationID;
        
        _reply = reply;
        _conversation = conversation;
        _isViewed = isViewed;
        _isReply = isReply;
        _datetime = date;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.notificationID forKey:@"notificationID"];
    [coder encodeObject:self.conversation forKey:@"conversation"];
    [coder encodeObject:self.reply forKey:@"reply"];
    [coder encodeObject:self.datetime forKey:@"date"];
    
    [coder encodeObject:@(self.accountID) forKey:@"accountID"];
    [coder encodeObject:@(self.isViewed) forKey:@"isViewed"];
    [coder encodeObject:@(self.isReply) forKey:@"isReply"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGNotification * copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setNotificationID:[self.notificationID copyWithZone:zone]];
        [copy setReply:[self.reply copyWithZone:zone]];
        [copy setConversation:[self.conversation copyWithZone:zone]];
        [copy setDatetime:[self.datetime copyWithZone:zone]];
        
        // Set primitives
        [copy setAccountID:self.accountID];
        [copy setIsReply:self.isReply];
        [copy setIsViewed:self.isViewed];
    }
    
    return copy;
}

@end
