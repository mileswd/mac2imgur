//
//  IMGModel.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGModel.h"

#import "IMGSession.h"

//category for declaring non-public IMGSession method only exposed to this class
@interface IMGSession()

#pragma mark - Model Tracking
/**
 Tracks new imgur Model objects being created to allow introspection by client
 @param model the model object that was created
 */
-(void)trackModelObjectsForDelegateHandling:(id)model;

@end

@implementation IMGModel

- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error{
    NSAssert(NO, @"Should be overridden by subclass");
    return nil;
}

-(instancetype)trackModels{
    
    //track if object is not nil
    if(self)
        [[IMGSession sharedInstance] trackModelObjectsForDelegateHandling:self];
    
    return self;
}

#pragma mark - NSCoding

//all model objects conform to NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
 
    if(self = [super init]){
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
}

@end
