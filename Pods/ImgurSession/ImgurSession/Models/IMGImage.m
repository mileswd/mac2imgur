//
//  IMGImage.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 10/07/13.
//  Distributed under the MIT license.
//

#import "IMGImage.h"
#import "IMGBasicAlbum.h"
#import "NSDictionary+IMG.h"

@interface IMGImage ()

@property (readwrite,nonatomic) NSString *imageID;
@property (readwrite,nonatomic) NSString *title;
@property (readwrite,nonatomic) NSString * imageDescription;
@property (readwrite,nonatomic) NSDate *datetime;
@property (readwrite,nonatomic) NSString *type;
@property (readwrite,nonatomic) BOOL animated;
@property (readwrite,nonatomic) CGFloat width;
@property (readwrite,nonatomic) CGFloat height;
@property (readwrite,nonatomic) NSInteger size;
@property (readwrite,nonatomic) NSInteger views;
@property (readwrite,nonatomic) NSInteger bandwidth;
@property (readwrite,nonatomic) NSString *deletehash;
@property (readwrite,nonatomic) NSString *section;
@property (readwrite,nonatomic) NSURL *url;

@end

@implementation IMGImage;

#pragma mark - Init With JSON

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        } else if (!jsonData[@"id"] || !jsonData[@"link"]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
        //clean NSNull
        jsonData = [jsonData IMG_cleanNull];
        
        _imageID = jsonData[@"id"];
        _title = jsonData[@"title"];
        _imageDescription = jsonData[@"description"];
        _type = jsonData[@"type"];
        _section = jsonData[@"section"];
        _animated = [jsonData[@"animated"] boolValue];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        _deletehash = jsonData[@"deletehash"];
        _url = [NSURL URLWithString:jsonData[@"link"]];
        
        _width = [jsonData[@"width"] floatValue] / 2.0f;   //assume retina px scaling
        _height = [jsonData[@"height"] floatValue] / 2.0f; //assume retina px scaling
        _size = [jsonData[@"size"] integerValue];
        _views = [jsonData[@"views"] integerValue];
        _bandwidth = [jsonData[@"bandwidth"] integerValue];
        
        if (!_imageID || !_url){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
    }   
    return [self trackModels];
}

-(instancetype)initCoverImageWithAlbum:(IMGBasicAlbum*)album error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]){
        
        _imageID = album.coverID;
        _height = album.coverHeight;
        _width = album.coverWidth;
        
        //guess at url
        NSString * constructedStr = [NSString stringWithFormat:@"http://i.imgur.com/%@.jpg", _imageID];
        _url = [NSURL URLWithString:constructedStr];
        
        if (!album.coverID){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
    }
    return [self trackModels];
}

-(instancetype)initWithGalleryID:(NSString*)objectID error:(NSError *__autoreleasing *)error{
    
    NSParameterAssert(objectID);
    
    if(self = [super init]){
        
        _imageID = objectID;
        
        //guess at url
        NSString * constructedStr = [NSString stringWithFormat:@"http://i.imgur.com/%@.jpg", _imageID];
        _url = [NSURL URLWithString:constructedStr];

    }
    return [self trackModels];
}

#pragma mark - IMGObject

-(BOOL)isAlbum{
    return NO;
}

-(IMGImage *)coverImage{
    
    return self;
}

-(void)setCoverImage:(IMGImage*)coverImage{
    
}

-(NSString *)objectID{
    
    return self.imageID;
    
}

-(NSString*)galleryDescription{
    
    return self.imageDescription;
}

-(NSString *)coverID{
    return self.imageID;
}

-(NSURL *)link{
    
    //remove extension from url
    return [self.url URLByDeletingPathExtension];
}

#pragma mark - Display

- (NSURL *)URLWithSize:(IMGSize)size{
    
    NSString *path = [[self.url absoluteString] stringByDeletingPathExtension];
    NSString *extension = [self.url pathExtension];
    NSString *stringURL;
    
    switch (size) {
        case IMGSmallSquareSize:
            stringURL = [NSString stringWithFormat:@"%@s.%@", path, extension];
            break;
            
        case IMGBigSquareSize:
            stringURL = [NSString stringWithFormat:@"%@b.%@", path, extension];
            break;
            
            //keeps image proportions below, please use these for better looking design
            
        case IMGSmallThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@t.%@", path, extension];
            break;
            
        case IMGMediumThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@m.%@", path, extension];
            break;
            
        case IMGLargeThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@l.%@", path, extension];
            break;
            
        case IMGHugeThumbnailSize:
            stringURL = [NSString stringWithFormat:@"%@h.%@", path, extension];
            break;
            
        default:
            stringURL = [NSString stringWithFormat:@"%@m.%@", path, extension];
            return nil;
    }
    return [NSURL URLWithString:stringURL];
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat:
            @"%@; image ID: %@ ; title: \"%@\"; datetime: %@; type: %@; animated: %d; width: %ld; height: %ld; size: %ld; views: %ld; bandwidth: %ld",
            [super description],  self.imageID, self.title, self.datetime, self.type, self.animated, (long)self.width, (long)self.height, (long)self.size, (long)self.views, (long)self.bandwidth];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGImage class]]) {
        return NO;
    }
    
    return ([[object imageID] isEqualToString:self.imageID]);
}

-(NSUInteger)hash{
    
    return [_imageID hash];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    CGFloat width = [[decoder decodeObjectForKey:@"width"] floatValue];
    CGFloat height = [[decoder decodeObjectForKey:@"height"] floatValue];
    NSInteger views = [[decoder decodeObjectForKey:@"views"] integerValue];
    NSInteger size = [[decoder decodeObjectForKey:@"size"] integerValue];
    NSInteger bandwidth = [[decoder decodeObjectForKey:@"bandwidth"] integerValue];
    NSString * imageID = [decoder decodeObjectForKey:@"imageID"];
    NSURL * url = [decoder decodeObjectForKey:@"url"];
    NSString * deletehash = [decoder decodeObjectForKey:@"deletehash"];
    NSString * title = [decoder decodeObjectForKey:@"title"];
    NSString * imageDescription = [decoder decodeObjectForKey:@"imageDescription"];
    NSString * type = [decoder decodeObjectForKey:@"type"];
    NSString * section = [decoder decodeObjectForKey:@"section"];
    NSDate *datetime = [decoder decodeObjectForKey:@"datetime"];
    BOOL animated  = [[decoder decodeObjectForKey:@"animated"] boolValue];
    
    if (self = [super initWithCoder:decoder]) {
        _imageID = imageID;
        _imageDescription = imageDescription;
        _animated = animated;
        _height = height;
        _width = width;
        _views = views;
        _size = size;
        _section = section;
        _datetime = datetime;
        _type = type;
        _bandwidth = bandwidth;
        _deletehash = deletehash;
        _title = title;
        _url = url;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.imageID forKey:@"imageID"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.imageDescription forKey:@"imageDescription"];
    [coder encodeObject:self.section forKey:@"section"];
    [coder encodeObject:self.deletehash forKey:@"deletehash"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.datetime forKey:@"datetime"];
    
    [coder encodeObject:@(self.bandwidth) forKey:@"bandwidth"];
    [coder encodeObject:@(self.views) forKey:@"views"];
    [coder encodeObject:@(self.width) forKey:@"width"];
    [coder encodeObject:@(self.height) forKey:@"height"];
    [coder encodeObject:@(self.size) forKey:@"size"];
    [coder encodeObject:@(self.animated) forKey:@"animated"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGImage * copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setImageID:[self.imageID copyWithZone:zone]];
        [copy setImageDescription:[self.imageDescription copyWithZone:zone]];
        [copy setUrl:[self.url copyWithZone:zone]];
        [copy setDatetime:[self.datetime copyWithZone:zone]];
        [copy setTitle:[self.title copyWithZone:zone]];
        [copy setType:[self.type copyWithZone:zone]];
        [copy setSection:[self.section copyWithZone:zone]];
        [copy setDeletehash:[self.deletehash copyWithZone:zone]];
        
        // Set primitives
        [copy setWidth:self.width];
        [copy setHeight:self.height];
        [copy setViews:self.views];
        [copy setBandwidth:self.bandwidth];
        [copy setSize:self.size];
        [copy setAnimated:self.animated];
    }
    
    return copy;
}


@end
