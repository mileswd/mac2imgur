//
//  IMGMessage.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGMessage.h"

#import "IMGSession.h"

@interface IMGMessage ()

@property (readwrite,nonatomic) NSString *messageID;
@property (readwrite,nonatomic) NSString *fromUsername;
@property (readwrite,nonatomic) NSString * subject;
@property (readwrite,nonatomic) NSString *body;
@property (readwrite,nonatomic) NSDate *datetime;
@property (readwrite,nonatomic) NSInteger conversationID;
@property (readwrite,nonatomic) NSInteger authorID;

@end

@implementation IMGMessage

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        } else if (!jsonData[@"id"] || !jsonData[@"conversation_id"]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
        
        _messageID = jsonData[@"id"];
        _fromUsername = jsonData[@"from"];
        _authorID = [jsonData[@"sender_id"] integerValue];
        _subject = jsonData[@"subject"];
        _body = jsonData[@"body"];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        _conversationID = [jsonData[@"conversation_id"] integerValue];
    }
    return [self trackModels];
}

- (instancetype)initWithBody:(NSString*)body{
    
    if(self = [super init]) {
        
        _fromUsername = [[IMGSession sharedInstance] user].username;
        _authorID = [[IMGSession sharedInstance] user].accountID;
        _body = body;
        _datetime = [NSDate date];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@ ; subject: \"%@\"; author: \"%@\"; message: %@;", [super description], self.subject, self.fromUsername, self.body];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGMessage class]]) {
        return NO;
    }
    
    return ([[object messageID] isEqualToString:self.messageID]);
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSInteger authorID = [[decoder decodeObjectForKey:@"authorID"] integerValue];
    NSInteger conversationID = [[decoder decodeObjectForKey:@"conversationID"] integerValue];
    NSString * messageID = [decoder decodeObjectForKey:@"messageID"];
    NSString * fromUsername = [decoder decodeObjectForKey:@"fromUsername"];
    NSString * subject = [decoder decodeObjectForKey:@"subject"];
    NSString * body = [decoder decodeObjectForKey:@"body"];
    NSDate *datetime = [decoder decodeObjectForKey:@"datetime"];
    
    if (self = [super initWithCoder:decoder]) {
        _authorID = authorID;
        _fromUsername = fromUsername;
        _subject = subject;
        _conversationID = conversationID;
        _messageID = messageID;
        _body = body;
        _datetime = datetime;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.messageID forKey:@"messageID"];
    [coder encodeObject:self.subject forKey:@"subject"];
    [coder encodeObject:self.fromUsername forKey:@"fromUsername"];
    [coder encodeObject:self.body forKey:@"body"];
    [coder encodeObject:self.datetime forKey:@"datetime"];
    
    [coder encodeObject:@(self.authorID) forKey:@"authorID"];
    [coder encodeObject:@(self.conversationID) forKey:@"conversationID"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGMessage * copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setMessageID:[self.messageID copyWithZone:zone]];
        [copy setFromUsername:[self.fromUsername copyWithZone:zone]];
        [copy setBody:[self.body copyWithZone:zone]];
        [copy setSubject:[self.subject copyWithZone:zone]];
        [copy setDatetime:[self.datetime copyWithZone:zone]];
        
        // Set primitives
        [copy setAuthorID:self.authorID];
        [copy setConversationID:self.conversationID];
    }
    
    return copy;
}

@end
