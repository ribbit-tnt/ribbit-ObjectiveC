//
//  User.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/17/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import "Resource.h"
#import <Foundation/Foundation.h>

/**
 Class to represent a Ribbit user.
 */
@interface User : Resource {
	NSString *userId;
	NSString *login;
	NSString *domain;
	NSString *firstName;
	NSString *lastName;
	BOOL *suspended;
	NSString *status;
	NSString *createdWith;
	NSString *pwdStatus;
	NSInteger *accountId;
	NSDate *createdOn;
	NSString *callerId;
}

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic) BOOL *suspended;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *createdWith;
@property (nonatomic, retain) NSString *pwdStatus;
@property (nonatomic) NSInteger *accountId;
@property (nonatomic, retain) NSDate *createdOn;
@property (nonatomic, retain) NSString *callerId;

/**
 Initializes a Ribbit user with a RibbitConfig and a given dictionary
 @param dict the dictionary of settings to assign to the new object
 @param ribbitConfig RibbitConfig object
 @returns an initialized object
 */
-(id) initFromDict:(NSDictionary*)dict ribbitConfig:(RibbitConfig*)ribbitConfig;
/**
 Updates a Ribbit user with a given dictionary
 @param dict the dictionary of settings to assign to the object
 */
-(void) updateUserWithDictionary:(NSDictionary*)dict;
@end
