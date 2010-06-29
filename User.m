//
//  User.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/17/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "User.h"
#import "SignedRequest.h"
#import "SBJSON.h"


@implementation User

@synthesize userId, login, domain;
@synthesize firstName,lastName;
@synthesize suspended, status,createdWith;
@synthesize pwdStatus, accountId,createdOn,callerId;

-(id) initFromDict:(NSDictionary*)dict ribbitConfig:(RibbitConfig*)ribbitConfig {
	[self init];
	self.config = ribbitConfig;
	self.userId = [dict objectForKey:@"id"];
	self.login = [dict objectForKey:@"login"];
	self.domain = [dict objectForKey:@"domain"];
	self.firstName = [dict objectForKey:@"firstName"];
	self.lastName = [dict objectForKey:@"lastName"];
	self.status = [dict objectForKey:@"status"];
	self.callerId = [dict objectForKey:@"callerId"];
	self.createdWith = [dict objectForKey:@"createdWith"];
	NSString *dateString = [dict objectForKey:@"createdOn"];
	self.createdOn = [[NSDate alloc] initWithString:dateString];
	self.suspended = (BOOL*)[dict objectForKey:@"suspended"];

	NSLog(@"user = %@", self);
	
	return self;
}

-(void) updateUserWithDictionary:(NSDictionary*)dict {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	//[signedRequest httpPostWithURI:uri vars:dict];
	NSLog(@"user id = %@", userId);
	NSString *url = [[config.endpoint stringByAppendingString:@"users/"] stringByAppendingString:userId];
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	
	[dict setObject:@"PUT" forKey:@"method"];
	[dict setObject:url forKey:@"url"];

	
	
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dict setObject:body forKey:@"json"];
	
	
	[signedRequest httpRequestWithDictionary:dict];
}

-(NSString*) description {
	NSMutableString *text = [[[NSMutableString alloc] init] autorelease];
	[text appendString:self.firstName];
	[text appendString:@" "];
	[text appendString:self.lastName];
	[text appendString:@" "];
	[text appendString:self.login];
	return text;
}

@end
