//
//  IMGModel.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "NSError+IMGError.h"

@interface IMGModel : NSObject <NSCoding>

/**
 Common initializer for JSON HTTP response which processes the "data" JSON object into model object class
 @return initilialized instancetype object
 */
- (instancetype)initWithJSONObject:(NSDictionary *)jsonData error:(NSError *__autoreleasing *)error;

/**
 Intercept class to allow notification/delegates
 @return initilialized instancetype object
 */
- (instancetype)trackModels;



@end
