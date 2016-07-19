//
//  IMGAccountSettings.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-12.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGAccount.h"
#import "IMGAccountSettings.h"
#import "IMGBasicAlbum.h"


@interface IMGAccountSettings ()
@property (readwrite) NSString *email;
@property (readwrite) NSString *username;
@property (readwrite) IMGAlbumPrivacy albumPrivacy;
@property (readwrite) BOOL publicImages;
@property (readwrite) BOOL highQuality;
@property (readwrite) NSDate * proExpiration;
@property (readwrite) BOOL acceptedGalleryTerms;
@property (readwrite) NSArray *activeEmails;
@property (readwrite) BOOL messagingEnabled;
@property (readwrite) NSArray *blockedUsers;
@end

@implementation IMGBlockedUser

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError * __autoreleasing *)error{
    
    if(self = [super init]) {
        _blockedID = jsonData[@"blocked_id"];
        _blockedURL = [NSURL URLWithString:jsonData[@"blocked_url"]];
    }
    return [self trackModels];
}

@end

@implementation IMGAccountSettings

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError * __autoreleasing *)error{
    
    if(self = [super init]) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        } else if (!jsonData[@"email"] || !jsonData[@"album_privacy"] || !jsonData[@"accepted_gallery_terms"]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
        
        _email = jsonData[@"email"];
        _albumPrivacy = [IMGBasicAlbum privacyForStr:jsonData[@"album_privacy"]];
        _publicImages = [jsonData[@"public_images"] integerValue];
        _highQuality = [jsonData[@"high_quality"] integerValue];
        if([jsonData[@"pro_expiration"] integerValue])
            _proExpiration = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"pro_expiration"] integerValue]];
        else
            _proExpiration = nil;
        _acceptedGalleryTerms = [jsonData[@"accepted_gallery_terms"] integerValue];
        
        //enumerate all active emails
        NSMutableArray * activeEmails = [NSMutableArray new];
        for(NSString * email in jsonData[@"active_emails"]){
            [activeEmails addObject:email];
        }
        _activeEmails = [NSArray arrayWithArray:activeEmails];
        _messagingEnabled = [jsonData[@"messaging_enabled"] integerValue];
        
        //enumerate all blocked users
        NSMutableArray * blockedUsers = [NSMutableArray new];
        for(NSDictionary * user in jsonData[@"blocked_users"]){
            IMGBlockedUser * blocked = [[IMGBlockedUser alloc] initWithJSONObject:user error:nil];
            if(blocked)
                [blockedUsers addObject:blocked];
        }
        _blockedUsers = [NSArray arrayWithArray:blockedUsers];
    }
    return [self trackModels];
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData withName:(NSString*)username error:(NSError * __autoreleasing *)error{
    
    self = [self initWithJSONObject:jsonData error:error];
    
    if(self)
        _username = username;
    
    return self;
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat: @"%@; email: \"%@\"; high quality: \"%@\"; album_privact: \"%@\"",  [super description], self.email, (self.highQuality ? @"YES" : @"NO"), [IMGBasicAlbum strForPrivacy:self.albumPrivacy]];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGAccountSettings class]]) {
        return NO;
    }
    
    return ([[object username] isEqualToString:self.username]);
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    IMGAlbumPrivacy albumPrivacy = [[decoder decodeObjectForKey:@"albumPrivacy"] integerValue];
    NSString * email = [decoder decodeObjectForKey:@"email"];
    NSString * username = [decoder decodeObjectForKey:@"username"];
    NSDate * proExpiration = [decoder decodeObjectForKey:@"proExpiration"];
    
    BOOL publicImages = [[decoder decodeObjectForKey:@"publicImages"] boolValue];
    BOOL highQuality = [[decoder decodeObjectForKey:@"highQuality"] boolValue];
    BOOL acceptedGalleryTerms = [[decoder decodeObjectForKey:@"acceptedGalleryTerms"] boolValue];
    BOOL messagingEnabled = [[decoder decodeObjectForKey:@"messagingEnabled"] boolValue];
    
    NSArray * blockUsers = [decoder decodeObjectForKey:@"blockUsers"];
    NSArray * activeEmails = [decoder decodeObjectForKey:@"activeEmails"];
    
    if (self = [super init]) {
        _email = email;
        _username = username;
        _albumPrivacy = albumPrivacy;
        _proExpiration = proExpiration;
        _blockedUsers = blockUsers;
        _activeEmails = activeEmails;
        
        _messagingEnabled = messagingEnabled;
        _acceptedGalleryTerms = acceptedGalleryTerms;
        _publicImages = publicImages;
        _highQuality = highQuality;
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:@(self.albumPrivacy) forKey:@"albumPrivacy"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.username forKey:@"username"];
    [coder encodeObject:self.proExpiration forKey:@"proExpiration"];
    [coder encodeObject:self.blockedUsers forKey:@"blockedUsers"];
    [coder encodeObject:self.activeEmails forKey:@"activeEmails"];
    [coder encodeObject:@(self.albumPrivacy) forKey:@"albumPrivacy"];
    [coder encodeObject:@(self.publicImages) forKey:@"publicImages"];
    [coder encodeObject:@(self.messagingEnabled) forKey:@"messagingEnabled"];
    [coder encodeObject:@(self.highQuality) forKey:@"highQuality"];;
    [coder encodeObject:@(self.acceptedGalleryTerms) forKey:@"acceptedGalleryTerms"];;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    
    IMGAccountSettings * copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setEmail:[self.email copyWithZone:zone]];
        [copy setBlockedUsers:[self.blockedUsers copyWithZone:zone]];
        [copy setActiveEmails:[self.activeEmails copyWithZone:zone]];
        [copy setProExpiration:self.proExpiration];
        [copy setUsername:self.username];
        
        // Set primitives
        [copy setAcceptedGalleryTerms:self.acceptedGalleryTerms];
        [copy setMessagingEnabled:self.messagingEnabled];
        [copy setPublicImages:self.publicImages];
        [copy setHighQuality:self.highQuality];
        [copy setAlbumPrivacy:self.albumPrivacy];
    }
    
    return copy;
}


@end
