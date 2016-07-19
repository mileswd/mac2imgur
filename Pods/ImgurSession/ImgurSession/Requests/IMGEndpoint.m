//
//  IMGEndpoint.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-12.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGEndpoint.h"

#import "IMGSession.h"


@implementation IMGEndpoint

+(NSString *)pathComponent{
    NSAssert(NO, @"Should be overridden by subclass");
    return nil;
}

+(NSString*)path{
    return [NSString stringWithFormat:@"%@/%@", IMGAPIVersion, [self pathComponent]];
}

+(NSString*)pathWithID:(NSString*)id1 {
    NSParameterAssert(id1);
    
    return [NSString stringWithFormat:@"%@/%@/%@", IMGAPIVersion, [self pathComponent], id1];
}

+(NSString*)pathWithID:(NSString*)id1 withOption:(NSString*)option{
    NSParameterAssert(id1);
    NSParameterAssert(option);
    
    return [NSString stringWithFormat:@"%@/%@/%@/%@", IMGAPIVersion, [self pathComponent], id1, option];
}

+(NSString*)pathWithOption:(NSString*)option withID2:(NSString*)id2{
    NSParameterAssert(id2);
    NSParameterAssert(option);
    
    return [NSString stringWithFormat:@"%@/%@/%@/%@", IMGAPIVersion, [self pathComponent], option, id2];
}

+(NSString*)pathWithID:(NSString*)id1 withOption:(NSString*)option withID2:(NSString*)id2{
    NSParameterAssert(id1);
    NSParameterAssert(option);
    NSParameterAssert(id2);
    
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@", IMGAPIVersion, [self pathComponent], id1, option, id2];
}

@end
