//
//  IMGEndpoint.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-12.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "NSError+IMGError.h"

/**
 Endpoint superclass for Imgur endpoints. Provides convenience methods common to all endpoints.
 */
@interface IMGEndpoint : NSObject

/**
 @return path component common to this endpoint
 */
+(NSString*)pathComponent;

/**
 @return full path to this endpoint
 */
+(NSString*)path;
/**
 @return full path to this endpoint appended by /id1
 */
+(NSString*)pathWithID:(NSString*)id1;
/**
 @return full path to this endpoint appended by /id1/option
 */
+(NSString*)pathWithID:(NSString*)id1 withOption:(NSString*)option;
/**
 @return full path to this endpoint appended by /option/id2
 */
+(NSString*)pathWithOption:(NSString*)option withID2:(NSString*)id2;
/**
 @return full path to this endpoint appended by /id1/option/id2
 */
+(NSString*)pathWithID:(NSString*)id1 withOption:(NSString*)option withID2:(NSString*)id2;

@end
