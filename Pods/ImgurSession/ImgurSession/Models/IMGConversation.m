//
//  IMGConversation.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-20.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGConversation.h"
#import "IMGMessage.h"

@interface IMGConversation ()

@property (readwrite,nonatomic) NSArray *messages;
@property (readwrite,nonatomic) NSString *fromUsername;
@property (readwrite,nonatomic) NSString *lastMessage;
@property (readwrite,nonatomic) NSDate *datetime;
@property (readwrite,nonatomic) NSInteger conversationID;
@property (readwrite,nonatomic) NSInteger authorID;
@property (readwrite,nonatomic) NSInteger messageCount;

@end

@implementation IMGConversation

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        } else if (!jsonData[@"id"] || !jsonData[@"with_account"]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
        
        _conversationID = [jsonData[@"id"] integerValue];
        _fromUsername = jsonData[@"with_account"];
        _authorID = [jsonData[@"with_account_id"] integerValue];
        _lastMessage = jsonData[@"last_message_preview"];
        _messageCount = [jsonData[@"message_count"] integerValue];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        
        NSMutableArray * msgs  = [NSMutableArray new];
        for(NSDictionary * json in jsonData[@"messages"]){
            
            NSError * JSONError;
            IMGMessage * msg = [[IMGMessage alloc] initWithJSONObject:json error:&JSONError];
            
            if(msg && !JSONError){
               [msgs addObject:msg];
            }
        }
        _messages = [NSArray arrayWithArray:msgs];
    }
    return [self trackModels];
}

- (instancetype)initWithJSONObjectFromNotification:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        _conversationID = [jsonData[@"id"] integerValue];
        _fromUsername = jsonData[@"from"];
        _authorID = [jsonData[@"with_account"] integerValue];
        _lastMessage = jsonData[@"last_message"];
        _messageCount = [jsonData[@"message_num"] integerValue];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@  author: \"%@\"; last message: %@; count: %lu;", [super description], self.fromUsername, self.lastMessage, (long)self.messageCount];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGConversation class]]) {
        return NO;
    }
    
    return ([object conversationID] == self.conversationID);
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSInteger conversationID = [[decoder decodeObjectForKey:@"conversationID"] integerValue];
    NSInteger authorID = [[decoder decodeObjectForKey:@"authorID"] integerValue];
    NSInteger messageCount = [[decoder decodeObjectForKey:@"messageCount"] integerValue];
    NSString * fromUsername = [decoder decodeObjectForKey:@"fromUsername"];
    NSString * lastMessage = [decoder decodeObjectForKey:@"lastMessage"];
    NSDate *datetime = [decoder decodeObjectForKey:@"datetime"];
    NSArray *messages = [decoder decodeObjectForKey:@"messages"];
    
    if (self = [super initWithCoder:decoder]) {
        _conversationID = conversationID;
        _fromUsername = fromUsername;
        _authorID = authorID;
        _lastMessage = lastMessage;
        _datetime = datetime;
        _messageCount = messageCount;
        _messages = messages;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.messages forKey:@"messages"];
    [coder encodeObject:self.fromUsername forKey:@"fromUsername"];
    [coder encodeObject:self.lastMessage forKey:@"lastMessage"];
    [coder encodeObject:self.datetime forKey:@"datetime"];
    
    [coder encodeObject:@(self.conversationID) forKey:@"conversationID"];
    [coder encodeObject:@(self.authorID) forKey:@"authorID"];
    [coder encodeObject:@(self.messageCount) forKey:@"messageCount"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGConversation * copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setFromUsername:[self.fromUsername copyWithZone:zone]];
        [copy setLastMessage:[self.lastMessage copyWithZone:zone]];
        [copy setMessages:[self.messages copyWithZone:zone]];
        [copy setDatetime:[self.datetime copyWithZone:zone]];
        
        // Set primitives
        [copy setAuthorID:self.authorID];
        [copy setConversationID:self.conversationID];
        [copy setMessageCount:self.messageCount];
    }
    
    return copy;
}

@end
