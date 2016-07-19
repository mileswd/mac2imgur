//
//  IMGAlbum.m
//  ImgurSession
//
//  Created by Johann Pardanaud on 11/07/13.
//  Distributed under the MIT license.
//

#import "IMGAlbum.h"
#import "IMGImage.h"


@implementation IMGAlbum;

#pragma mark - Init With Json

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    self = [super initWithJSONObject:jsonData error:error];
    
    if(self && !*error) {
        
        if(![jsonData isKindOfClass:[NSDictionary class]]){
            
            *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:@{@"ImgurClass":[self class]}];
            return nil;
        }
        
        _deletehash = jsonData[@"deletehash"];
    }
    return [self trackModels];
}


#pragma mark - Describe

- (NSString *)description{
    return [NSString stringWithFormat: @"%@ ; deletehash: %@",[super description], self.deletehash];
}

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IMGAlbum class]]) {
        return NO;
    }
    
    return ([[object albumID] isEqualToString:self.albumID]);
}

-(NSUInteger)hash{
    
    return [self.albumID hash];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSString * deletehash = [decoder decodeObjectForKey:@"deletehash"];
    
    if (self = [super initWithCoder:decoder]) {
        _deletehash = deletehash;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.deletehash forKey:@"deletehash"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    IMGAlbum * copy = [super copyWithZone:zone];
    
    if (copy) {
        // Copy NSObject subclasses
        [copy setDeletehash:[self.deletehash copyWithZone:zone]];
    }
    
    return copy;
}
@end
