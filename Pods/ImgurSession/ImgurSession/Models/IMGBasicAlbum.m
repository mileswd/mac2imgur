//
//  ImgurPartialAlbum.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 24/07/13.
//  Distributed under the MIT license.
//

#import "IMGBasicAlbum.h"
#import "IMGImage.h"
#import "NSDictionary+IMG.h"

@interface IMGBasicAlbum ()

@property (readwrite,nonatomic) NSString *albumID;
@property (readwrite,nonatomic) NSString *title;
@property (readwrite,nonatomic) NSString *albumDescription;
@property (readwrite,nonatomic) NSDate *datetime;
@property (readwrite,nonatomic) NSString *coverID;
@property (readwrite,nonatomic) CGFloat coverWidth;
@property (readwrite,nonatomic) CGFloat coverHeight;
@property (readwrite,nonatomic) NSString *accountURL;
@property (readwrite,nonatomic) NSString *privacy;
@property (readwrite,nonatomic) IMGAlbumLayout layout;
@property (readwrite,nonatomic) NSInteger views;
@property (readwrite,nonatomic) NSURL *url;
@property (readwrite,nonatomic) NSInteger imagesCount;
@property (readwrite,nonatomic) NSArray *images;

@end

@implementation IMGBasicAlbum;

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    
    if(self = [super init]) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        }
        //clean NSNull
        jsonData = [jsonData IMG_cleanNull];
        
        _albumID = jsonData[@"id"];
        _title = jsonData[@"title"];
        _albumDescription = jsonData[@"description"];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[jsonData[@"datetime"] integerValue]];
        _coverID = jsonData[@"cover"];
        _coverHeight = [jsonData[@"cover_height"] floatValue] / 2.0f;  //assume retina px scaling
        _coverWidth = [jsonData[@"cover_width"] floatValue] / 2.0f;    //assume retina px scaling
        _accountURL = jsonData[@"account_url"];
        _privacy = jsonData[@"privacy"];
        _layout = [IMGBasicAlbum layoutForStr:jsonData[@"layout"]];
        _views = [jsonData[@"views"] integerValue];
        _url = [NSURL URLWithString:jsonData[@"link"]];
        _imagesCount = [jsonData[@"images_count"] integerValue];
        
        //intrepret images if available
        NSMutableArray * images = [NSMutableArray new];
        for(NSDictionary * imageJSON in jsonData[@"images"]){
            
            NSError *JSONError = nil;
            IMGImage * image = [[IMGImage alloc] initWithJSONObject:imageJSON error:&JSONError];
            
            if(!JSONError && image){
                [images addObject:image];
            }
        }
        _images = [NSArray arrayWithArray:images];
        
        if(!_images.count && _coverID){
            //construct cover if not available
            IMGImage * cover  = [[IMGImage alloc] initCoverImageWithAlbum:self error:error];
            [self setCoverImage:cover];
        }
        
        if (!_albumID || !_coverID){
            
            if(error)
                *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorResponseMissingParameters userInfo:nil];
            return nil;
        }
    }
    return [self trackModels];
}

-(instancetype)initWithGalleryID:(NSString*)objectID coverID:(NSString*)coverID error:(NSError *__autoreleasing *)error{
    
    NSParameterAssert(objectID);
    
    if(self = [super init]){
        
        _albumID = objectID;
        _coverID = coverID;
        
        NSMutableArray * images = [NSMutableArray new];
        _images = [NSArray arrayWithArray:images];
        
        //construct cover URL
        IMGImage * cover  = [[IMGImage alloc] initCoverImageWithAlbum:self error:error];
        [self setCoverImage:cover];
        
    }
    return [self trackModels];
}

#pragma mark - IMGObjectProtocol

-(BOOL)isAlbum{
    return YES;
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

-(void)setCoverImage:(IMGImage*)coverImage{
    
    if([self.images containsObject:coverImage])
        return;
    else {
        
        NSMutableArray * marray = [NSMutableArray arrayWithArray:self.images];
        [marray addObject:coverImage];
        self.images = [NSArray arrayWithArray:marray];
    }
}

-(NSString *)objectID{
    
    return self.albumID;
}

-(NSString*)galleryDescription{
    
    return self.albumDescription;
}

- (NSURL *)URLWithSize:(IMGSize)size{
    //could be nil if cover image not retrieved
    return [self.coverImage URLWithSize:size];
}

-(NSURL *)link{
    return self.url;
}

#pragma mark - Album Layout setting

+(NSString*)strForLayout:(IMGAlbumLayout)layoutType{
    switch (layoutType) {
        case IMGBlogLayout:
            return @"blog";
            break;
        case IMGGridLayout:
            return @"grid";
            break;
        case IMGHorizontalLayout:
            return @"horizontal";
            break;
        case IMGVerticalLayout:
            return @"vertical";
            break;
            
        default:
            return @"blog";
            break;
    }
}

+(IMGAlbumLayout)layoutForStr:(NSString*)layoutStr{
    if([[layoutStr lowercaseString] isEqualToString:@"default"])
        return IMGDefaultLayout;
    else if([[layoutStr lowercaseString] isEqualToString:@"blog"])
        return IMGBlogLayout;
    else if([[layoutStr lowercaseString] isEqualToString:@"grid"])
        return IMGGridLayout;
    else if([[layoutStr lowercaseString] isEqualToString:@"horizontal"])
        return IMGHorizontalLayout;
    else if([[layoutStr lowercaseString] isEqualToString:@"vertical"])
        return IMGVerticalLayout;
    return IMGDefaultLayout;
}

#pragma mark - Album Privacy setting

+(NSString*)strForPrivacy:(IMGAlbumPrivacy)privacy{
    switch (privacy) {
        case IMGAlbumPublic:
            return @"public";
            break;
        case IMGAlbumHidden:
            return @"hidden";
            break;
        case IMGAlbumSecret:
            return @"secret";
            break;
            
        default:
            return @"public";
            break;
    }
}

+(IMGAlbumPrivacy)privacyForStr:(NSString*)privacyStr{
    if([[privacyStr lowercaseString] isEqualToString:@"public"])
        return IMGAlbumPublic;
    else if([[privacyStr lowercaseString] isEqualToString:@"hidden"])
        return IMGAlbumHidden;
    else if([[privacyStr lowercaseString] isEqualToString:@"secret"])
        return IMGAlbumSecret;
    return IMGAlbumDefault;
}

#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat: @"%@; albumId:  \"%@\"; title: \"%@\"; datetime: %@; cover: %@; accountURL: \"%@\"; privacy: %@; layout: %@; views: %ld; link: %@; imagesCount: %ld",  [super description], self.albumID, self.title,  self.datetime, self.coverID, self.accountURL, self.privacy, [IMGBasicAlbum strForLayout:self.layout], (long)self.views, self.url, (long)self.imagesCount];
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
    
    return [_albumID hash];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    CGFloat width = [[decoder decodeObjectForKey:@"coverWidth"] floatValue];
    CGFloat height = [[decoder decodeObjectForKey:@"coverHeight"] floatValue];
    NSInteger views = [[decoder decodeObjectForKey:@"views"] integerValue];
    IMGAlbumLayout layout = [[decoder decodeObjectForKey:@"layout"] integerValue];
    NSInteger imagesCount = [[decoder decodeObjectForKey:@"imagesCount"] integerValue];
    NSString * albumID = [decoder decodeObjectForKey:@"albumID"];
    NSString * coverID = [decoder decodeObjectForKey:@"coverID"];
    NSURL * url = [decoder decodeObjectForKey:@"url"];
    NSString * privacy = [decoder decodeObjectForKey:@"privacy"];
    NSString * accountURL = [decoder decodeObjectForKey:@"accountURL"];
    NSString * title = [decoder decodeObjectForKey:@"title"];
    NSString * albumDescription = [decoder decodeObjectForKey:@"albumDescription"];
    NSDate *datetime = [decoder decodeObjectForKey:@"datetime"];
    NSArray * images = [decoder decodeObjectForKey:@"images"];
    
    if (self = [super initWithCoder:decoder]) {
        _albumID = albumID;
        _albumDescription = albumDescription;
        _coverHeight = height;
        _coverWidth = width;
        _coverID = coverID;
        _views = views;
        _layout = layout;
        _accountURL = accountURL;
        _privacy = privacy;
        _datetime = datetime;
        _title = title;
        _imagesCount = imagesCount;
        _url = url;
        _images = images;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.albumID forKey:@"albumID"];
    [coder encodeObject:self.coverID forKey:@"coverID"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.privacy forKey:@"privacy"];
    [coder encodeObject:self.albumDescription forKey:@"albumDescription"];
    [coder encodeObject:self.accountURL forKey:@"accountURL"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.datetime forKey:@"datetime"];
    
    [coder encodeObject:@(self.imagesCount) forKey:@"imagesCount"];
    [coder encodeObject:@(self.views) forKey:@"views"];
    [coder encodeObject:@(self.coverWidth) forKey:@"coverWidth"];
    [coder encodeObject:@(self.coverHeight) forKey:@"coverHeight"];
    [coder encodeObject:@(self.layout) forKey:@"layout"];
    [coder encodeObject:@(self.imagesCount) forKey:@"images"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGBasicAlbum * copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setAlbumID:[self.albumID copyWithZone:zone]];
        [copy setCoverID:[self.coverID copyWithZone:zone]];
        [copy setAlbumDescription:[self.albumDescription copyWithZone:zone]];
        [copy setUrl:[self.url copyWithZone:zone]];
        [copy setDatetime:[self.datetime copyWithZone:zone]];
        [copy setTitle:[self.title copyWithZone:zone]];
        [copy setAccountURL:[self.accountURL copyWithZone:zone]];
        [copy setPrivacy:[self.privacy copyWithZone:zone]];
        [copy setImages:[self.images copyWithZone:zone]];
        
        // Set primitives
        [copy setCoverWidth:self.coverWidth];
        [copy setCoverHeight:self.coverHeight];
        [copy setViews:self.views];
        [copy setLayout:self.layout];
        [copy setImagesCount:self.imagesCount];
    }
    
    return copy;
}

@end
