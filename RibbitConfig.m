//
//  RibbitConfig.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "RibbitConfig.h"


@implementation RibbitConfig

@synthesize username;
@synthesize applicationId;
@synthesize accountId;
@synthesize domain;
@synthesize consumerKey;
@synthesize secretKey;
@synthesize accessToken;
@synthesize accessSecret;
@synthesize requestToken;
@synthesize requestSecret;

@synthesize endpoint;

@synthesize accessTokenAllocatedTime;
@synthesize accessTokenLastUsed;

-(void)clearUser {
	
}

-(NSString*)getActiveUserId {
	NSString *output = self.accountId;
	
	return output;
}

-(void) setUserWithAccountId:(NSString*)acctId userId:(NSString*)userId accessToken:(NSString*)access accessSecret:(NSString*)accSecret {
	self.accountId = acctId;
	self.username = userId;
	self.accessToken = access;
	self.accessSecret = accSecret;
}

@end
