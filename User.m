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
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	
	//[signedRequest httpPostWithURI:uri vars:dict];
	NSString *url = [[config.endpoint stringByAppendingString:@"users/"] stringByAppendingString:[config getActiveUserId]];
	
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	NSString *body_sig = [signedRequest sign_for_oauth:[body UTF8String]];
	////(void)NSLog(body);
	// Create the string for the auth header signature
	NSString *nonce = [SignedRequest generate_nonce];
	double timestamp = [SignedRequest current_millis];
	
	NSString *q = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%.0f&oauth_token=%@&xoauth_body_signature=%@&xoauth_body_signature_method=HMAC-SHA1",
				   [config consumerKey],
				   nonce,
				   timestamp,
				   [config accessToken],
				   body_sig];
	NSString *string_to_sign = [NSString stringWithFormat:@"PUT&%@&%@",[SignedRequest URLEncode:url],[SignedRequest URLEncode:q]];
	
	
	NSString *string_sig = [signedRequest sign_for_oauth:[string_to_sign UTF8String]];
	NSString *auth_header = [NSString stringWithFormat:@"OAuth realm=\"%@\",oauth_consumer_key=\"%@\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"%.0f\",oauth_nonce=\"%@\",oauth_signature=\"%@\",oauth_token=\"%@\",xoauth_body_signature=\"%@\",xoauth_body_signature_method=\"HMAC-SHA1\"",
							 [SignedRequest URLEncode:@"\"http://oauth.ribbit.com\""],
							 config.consumerKey,
							 timestamp,
							 nonce,
							 [SignedRequest URLEncode:string_sig],
							 [SignedRequest URLEncode:[config accessToken]],
							 [SignedRequest URLEncode:body_sig]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setTimeoutInterval:10]; 
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"PUT"];
	
	[request addValue:auth_header forHTTPHeaderField: @"Authorization"];
	[request addValue:@"application/json" forHTTPHeaderField: @"Accept"];
	[request addValue:@"application/json" forHTTPHeaderField: @"Content-type"];
	[request addValue:[[NSURL URLWithString:url] host] forHTTPHeaderField: @"Host"];
	[request addValue:@"Ribbit_ObjectiveC" forHTTPHeaderField: @"User-Agent"];
	
	//	if(cookies) [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
	
	NSNumber *length = [NSNumber numberWithUnsignedInteger:[body length]];
	NSString *postLength = [length stringValue];		
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[signedRequest getDataWithRequest:request delegate:self
					didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
					  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
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