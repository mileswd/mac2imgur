//
//  IMGVote.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGVote.h"

@implementation IMGVote

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        } else if (!jsonData[@"ups"] || !jsonData[@"downs"]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
        _ups = [jsonData[@"ups"] integerValue];
        _downs = [jsonData[@"downs"] integerValue];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@; ups: \"%ld\"; downs: \"%ld\";",  [super description], (long)self.ups, (long)self.downs];
}

+(NSString*)strForVote:(IMGVoteType)vote{
    NSString * str;
    switch (vote) {
        case IMGDownVote:
            str = @"down";
            break;
            
        case IMGUpVote:
            str = @"up";
            break;
        case IMGNeutralVote:
            str = @"";
            break;
        default:
            break;
    }
    return str;
}

+(IMGVoteType)voteForStr:(NSString*)voteStr{
    
    if([voteStr isEqualToString:@"up"])
        return IMGUpVote;
    else if([voteStr isEqualToString:@"down"])
        return IMGDownVote;
    else
        return IMGNeutralVote;
}

@end
