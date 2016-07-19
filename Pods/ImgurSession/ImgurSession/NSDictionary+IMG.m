//
//  NSDictionary+IMG.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-04-10.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "NSDictionary+IMG.h"

@implementation NSDictionary (IMG)

-(NSDictionary *)IMG_cleanNull {
    return [self dictionaryWithValuesForKeys:[[self keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return ![obj isEqual:[NSNull null]];
    }] allObjects]];
}

@end
