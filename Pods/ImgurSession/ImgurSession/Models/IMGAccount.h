//
//  IMGAccount.h
//  ImgurSession
//
//  Created by Johann Pardanaud on 10/07/13.
//  Distributed under the MIT license.
//

#import "IMGModel.h"

/**
 Model object class to represent account settings. https://api.imgur.com/models/account
 */
@interface IMGAccount : IMGModel  <NSCopying,NSCoding>

/**
 Account ID
 */
@property (nonatomic, readonly) NSInteger accountID;
/**
 Username string
 */
@property (nonatomic, readonly, copy) NSString *username;
/**
 Biography string displayed on right pane on account page
 */
@property (nonatomic, readonly, copy) NSString *bio;
/**
 Reputation
 */
@property (nonatomic, readonly) NSInteger reputation;
/**
 Creation date for account
 */
@property (nonatomic, readonly) NSDate *created;

#pragma mark - Initializer
/**
 @param jsonData response "data" json Object for account
 @param username name of account
 @param error address of error object to output to
 */
- (instancetype)initWithJSONObject:(NSDictionary *)jsonData withName:(NSString*)username error:(NSError * __autoreleasing *)error;



#pragma mark - Convenience

/**
 Returns string representing 'notoriety' as seen on Imgur account page based on reputation. Not localized.
 */
-(NSString*)notorietyString;
    
@end
