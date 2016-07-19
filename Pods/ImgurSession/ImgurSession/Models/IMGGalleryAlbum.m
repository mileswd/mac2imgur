//
//  IMGGalleryAlbum.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGGalleryAlbum.h"
#import "NSDictionary+IMG.h"

@interface IMGGalleryAlbum ()

@property (readwrite, nonatomic) IMGVoteType vote;
@property (readwrite, nonatomic) NSString *section;
@property (readwrite, nonatomic) NSInteger ups;
@property (readwrite, nonatomic) NSInteger downs;
@property (readwrite, nonatomic) NSInteger score;
@property (readwrite, nonatomic) BOOL favorite;
@property (readwrite, nonatomic) BOOL nsfw;

@end

@implementation IMGGalleryAlbum;

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error
{
    self = [super initWithJSONObject:jsonData error:error];
    
    if(self && !*error) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        }
        jsonData = [jsonData IMG_cleanNull];
        
        _ups = [jsonData[@"ups"] integerValue];
        _downs = [jsonData[@"downs"] integerValue];
        _score = [jsonData[@"score"] integerValue];
        _vote = [IMGVote voteForStr:jsonData[@"vote"]];
        
        _section = jsonData[@"section"];
        _nsfw = [jsonData[@"nsfw"] boolValue];
        _favorite = [jsonData[@"favorite"] boolValue];
    }
    return [self trackModels];
}

-(instancetype)initWithComment:(IMGComment*)comment error:(NSError *__autoreleasing *)error{
    
    NSParameterAssert(comment);
    
    if(self = [super initWithGalleryID:comment.galleryID coverID:comment.albumCover error:error]){
        
        
    }
    return [self trackModels];
}

#pragma mark - Describe

- (NSString *)description{
    
    return [NSString stringWithFormat: @"%@; ups: %ld; downs: %ld; score: %ld; vote: %ld", [super description], (long)self.ups, (long)self.downs, (long)self.score, (long)self.vote];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGBasicAlbum class]]) {
        return NO;
    }
    
    return ([[object albumID] isEqualToString:self.albumID]);
}

-(NSUInteger)hash{
    
    return [self.albumID hash];
}

#pragma mark - IMGGalleryObjectProtocol

-(BOOL)isAlbum{
    return YES;
}

-(IMGVoteType)usersVote{
    return self.vote;
}

-(BOOL)isFavorite{
    return self.favorite;
}

-(BOOL)isNSFW{
    return self.nsfw;
}

-(IMGImage *)coverImage{
    
    //image should be included in the images array
    __block IMGImage * cover = nil;
    
    [self.images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IMGImage * img = obj;
        
        if([self.coverID isEqualToString:img.imageID]){
            //this is the cover
            cover = img;
            *stop = YES;
        }
    }];
    
    return cover;
}

-(NSString *)objectID{
    
    return self.albumID;
    
}

-(NSString*)galleryDescription{
    
    return self.albumDescription;
}

-(NSString*)fromUsername{
    
    return self.accountURL;
}

-(void)setUsersVote:(IMGVoteType)vote{
    
    self.vote = vote;
    
}

-(void)setUsersFav:(BOOL)faved{
    
    self.favorite = faved;
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSString * section = [decoder decodeObjectForKey:@"section"];
    IMGVoteType vote = [[decoder decodeObjectForKey:@"vote"] integerValue];
    NSInteger ups = [[decoder decodeObjectForKey:@"ups"] integerValue];
    NSInteger downs = [[decoder decodeObjectForKey:@"downs"] integerValue];
    NSInteger score = [[decoder decodeObjectForKey:@"score"] integerValue];
    BOOL favorite = [[decoder decodeObjectForKey:@"favorite"] boolValue];
    BOOL nsfw = [[decoder decodeObjectForKey:@"nsfw"] boolValue];
    
    if (self = [super initWithCoder:decoder]) {
        _vote = vote;
        _section = section;
        _ups = ups;
        _downs = downs;
        _score =  score;
        _favorite = favorite;
        _nsfw = nsfw;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.section forKey:@"section"];

    [coder encodeObject:@(self.vote) forKey:@"vote"];
    [coder encodeObject:@(self.ups) forKey:@"ups"];
    [coder encodeObject:@(self.downs) forKey:@"downs"];
    [coder encodeObject:@(self.score) forKey:@"score"];
    [coder encodeObject:@(self.favorite) forKey:@"favorite"];
    [coder encodeObject:@(self.nsfw) forKey:@"nsfw"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGGalleryAlbum *  copy = [super copyWithZone:zone];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setSection:[self.section copyWithZone:zone]];
        [copy setVote:self.vote];
        [copy setUps:self.ups];
        [copy setDowns:self.downs];
        [copy setScore:self.score];
        [copy setNsfw:self.nsfw];
        [copy setFavorite:self.favorite];
    }
    
    return copy;
}

@end
