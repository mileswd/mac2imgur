//
//  IMGResponseSerializer.h
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <AFNetworking/AFURLResponseSerialization.h>

/*
 Subclass of AFJSONResponseSerializer to provide ImgurSession a method to track client API rate limits
 **/

@interface IMGResponseSerializer : AFJSONResponseSerializer <AFURLResponseSerialization>

@end
