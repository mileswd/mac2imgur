//
//  IMGGalleryProfile.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGGalleryProfile.h"

#import "IMGSession.h"


#pragma mark - IMGGalleryTrophy

@implementation IMGGalleryTrophy

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        _trophyID = jsonData[@"id"];
        _name = jsonData[@"name"];
        _type = jsonData[@"name_clean"];//doesn't really make sense
        _profileDescription = jsonData[@"description"];
        _data = jsonData[@"data"];
        _link = [NSURL URLWithString:jsonData[@"data_link"]];
        _dateAwarded = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        _imageUrl = [NSURL URLWithString:jsonData[@"image"]];
    }
    return [self trackModels];
}


@end

#pragma mark - IMGGalleryProfile


@implementation IMGGalleryProfile

#pragma mark - Init With Json

- (instancetype)initWithUser:(NSString*)username JSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        } else if (!jsonData[@"score"] || !jsonData[@"ups"] || !jsonData[@"down"]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
        
        _totalComments = [jsonData[@"total_gallery_comments"] integerValue];
        _totalLikes = [jsonData[@"total_gallery_likes"] integerValue];
        _totalSubmissions = [jsonData[@"total_gallery_submissions"] integerValue];
        _userName = username;
        
        //enumerate all blocked users
        NSMutableArray * trophies = [NSMutableArray new];
        for(NSDictionary * trophyJSON in jsonData[@"trophies"]){
            IMGGalleryTrophy * trophy = [[IMGGalleryTrophy alloc] initWithJSONObject:trophyJSON error:nil];
            [trophies addObject:trophy];
        }
        _trophies = [NSArray arrayWithArray:trophies];
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:@"%@; comments: %ld; likes: %ld; submissions: %ld; trophies: %ld;",  [super description],(long)self.totalComments, (long)self.totalLikes, (long)self.totalSubmissions, (long)[self.trophies count]];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGGalleryProfile class]]) {
        return NO;
    }
        
    return ([[object userName] isEqualToString:self.userName]);
}


@end
