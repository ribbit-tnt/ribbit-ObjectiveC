//
//  RibbitConfig.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


// TODO change this to subclass a NSMutableDictionary

@interface RibbitConfig : NSObject {
	
	NSString *username;
	NSString *applicationId;
	NSString *accountId;
	NSString *domain;
	NSString *consumerKey;
	NSString *secretKey;
	NSString *endpoint;
	
	NSString *requestToken;
	NSString *requestSecret;
	
	NSString *accessToken;
	NSString *accessSecret;
	
	long *accessTokenAllocatedTime;
	long *accessTokenLastUsed;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *applicationId;
@property (nonatomic, retain) NSString *accountId;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *consumerKey;
@property (nonatomic, retain) NSString *secretKey;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *accessSecret;
@property (nonatomic, retain) NSString *requestToken;
@property (nonatomic, retain) NSString *requestSecret;
@property (nonatomic, retain) NSString *endpoint;
@property (nonatomic) long *accessTokenAllocatedTime;
@property (nonatomic) long *accessTokenLastUsed;

/**
 Sets the active user with given parameters
 @param acctId the account id of the authenticated user
 @param userId the user id of the authenticatd user
 @param access the access token key that was retrieved
 @param accSecret the access token secret key that was retrieved
 */
-(void) setUserWithAccountId:(NSString*)acctId userId:(NSString*)userId accessToken:(NSString*)access accessSecret:(NSString*)accSecret;
/**
 Returns the a NSString representing the active user.
 */
-(NSString*)getActiveUserId;
/**
 Clear the logged in user.
 */
-(void) clearUser;

@end
