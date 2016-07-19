//
//  IMGResponseSerializer.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGResponseSerializer.h"

#import "IMGSession.h"
#import "IMGModel.h"


@interface IMGSession()

#pragma mark - Rate Limit Tracking
/**
 Tracks rate limiting using HTTP headers from the response
 @param response HTTP response returned from Imgur call
 */
-(void)updateClientRateLimiting:(NSHTTPURLResponse*)response;

@end

@implementation IMGResponseSerializer

/**
 Returns data for IMG Request classes to parse from network request. The json should be parsed from data using the JSON serializer with the super call to responseObjectForResponse. Thus the json should be the basic model described at https://api.imgur.com/models/basic . The 'data' key is all that matters, additonal success and status keys are redundant and not useful for us since we can get those from the http status code. We also use this opportunity to grab the response headers and track rate limiting since this method is called for every single response.
 */
-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    
    NSHTTPURLResponse * httpRes = (NSHTTPURLResponse *)response;
    
    //json parsing with AFJSONResponseSerializer, result should be 'basic' model specifed @ https://api.imgur.com/models/basic
    NSError * jsonError;
    NSDictionary * jsonResult = [super responseObjectForResponse:response data:data error:&jsonError];
    
    if(httpRes.statusCode == 200){
        //successful request!

        if(jsonError){
            //decoding error
            
            NSString * errorDescription = [jsonError localizedDescription];
            NSMutableDictionary * errorDict = [NSMutableDictionary new];
            if(errorDescription)
                [errorDict setObject:errorDescription forKey:NSLocalizedDescriptionKey];
            if(jsonError)
                [errorDict setObject:jsonError forKey:IMGErrorDecoding];
            
            *error = [NSError errorWithDomain:IMGErrorDomain code:IMGErrorMalformedResponseFormat userInfo:[NSDictionary dictionaryWithDictionary:errorDict]];
            return nil;
        }
        
        //decoding successful, continue to API completion
        
        //we need the data object or if does not exist pass the full JSON object for oauth/token endpoint
        if(jsonResult[@"data"]){
            //let response continue processing by ImgurSession completion blocks
            
            //update rate limit tracking in the session
            [[IMGSession sharedInstance] updateClientRateLimiting:httpRes];
            
            //pass back only "data" for simplicity to request subclasses
            return jsonResult[@"data"];
            
        } else {
            //the basic model is not respected for oauth calls, still need to respond with JSON
            //cannot handle client rate limiting in this case, headers are not sent
            return jsonResult;
        }
        
    } else {
        
        /**
         Error handling detailed @ https://api.imgur.com/errorhandling
         
         Status Code: 200
            The request has succeeded and there were no errors. Congrats!
         Status Code: 400
            This error indicates that a required parameter is missing or a parameter has a value that is out of bounds or otherwise incorrect. This status code is also returned when image uploads fail due to images that are corrupt or do not meet the format requirements.
         Status Code: 401
            The request requires user authentication. Either you didn't send send OAuth credentials, or the ones you sent were invalid.
         Status Code: 403
            Forbidden. You don't have access to this action. If you're getting this error, check that you haven't run out of API credits or make sure you're sending the OAuth headers correctly and have valid tokens/secrets.
         Status Code: 404
            Resource does not exist. This indicates you have requested a resource that does not exist. For example, requesting an image that doesn't exist.
         Status Code: 429
            Rate limiting. This indicates you have hit either the rate limiting on the application or on the user's IP address.
         Status Code: 500
            Unexpected internal error. What it says. We'll strive NOT to return these but your app should be prepared to see it. It basically means that something is broken with the Imgur service.
         **/
        
        //construct error to inform original API request of exact issue.
        //Special cases are needed for 401,403,429 as detaileed in NSError+IMGError and IMGSession
        
        NSString * errorDescription = jsonResult[@"data"][@"error"];
        NSString * errorPath = jsonResult[@"data"][@"request"];
        NSString * errorMethod = jsonResult[@"data"][@"method"];
        
        NSMutableDictionary * errorDict = [NSMutableDictionary new];
        if(errorDescription)
            [errorDict setObject:errorDescription forKey:IMGErrorServerDescription];
        if(errorPath)
            [errorDict setObject:errorPath forKey:IMGErrorServerPath];
        if(errorMethod)
            [errorDict setObject:errorMethod forKey:IMGErrorServerMethod];
        
        
        *error = [NSError errorWithDomain:IMGErrorDomain code:httpRes.statusCode userInfo:[NSDictionary dictionaryWithDictionary:errorDict]];
        return nil;
    }
}
@end
