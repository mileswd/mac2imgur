//
//  IMGMeme.m
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-05-14.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGMeme.h"

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

@interface IMGMeme()

@property (readwrite,nonatomic) NSString * topText;
@property (readwrite,nonatomic) NSString * bottomText;

@end

//TODO: - implementation using Core Graphics on images

@implementation IMGMeme

-(instancetype)initWithImage:(IMGImage*)image withTopText:(NSString*)top withBottomText:(NSString*)bottom withTitle:(NSString*)title withDescription:(NSString*)description{
    
    NSError * err;
    
    //init with bare bones IMGImage
    if((self = [super initWithGalleryID:image.imageID error:&err]) && !err){
        
        self.imageDescription = description;
        self.title = title;
        
        _bottomText = bottom;
        _topText = top;
    
        
        
    }
    return self;
}


@end
