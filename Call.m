//
//  Call.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "Call.h"
#import "SBJSON.h"
#import "SignedRequest.h"
#import "OAServiceTicket.h"


@implementation Call

@synthesize legs;
@synthesize callURI;
@synthesize callID;
@synthesize callerId;
@synthesize mode;
@synthesize announce;
@synthesize startTime;
@synthesize endTime;
@synthesize duration;
@synthesize success;
@synthesize active;
@synthesize recording;
@synthesize outbound;
@synthesize recordings;

-(id)initWithConfig:(RibbitConfig*)ribbitConfig {
	self = [super init];
	self.config = ribbitConfig;
	NSLog(@"self.config = %@", self.config);
	self.legs = [[NSMutableArray alloc] initWithObjects:nil];
	self.recordings = [[NSMutableArray alloc] initWithObjects:nil];
	
	return self;
}

-(id)initWithDictionary:(NSDictionary*)dictionary ribbitConfig:(RibbitConfig*)ribbitconfig {
	[super init];
	self.config = ribbitconfig;
	callID = [dictionary objectForKey:@"id"];
    duration = [dictionary objectForKey:@"duration"];
    startTime = [dictionary objectForKey:@"startTime"];
    endTime = [dictionary objectForKey:@"endTime"];
    success = (BOOL*)[dictionary objectForKey:@"success"];
    active = (BOOL*)[dictionary objectForKey:@"active"];
    recording = (BOOL*)[dictionary objectForKey:@"recording"];
	outbound = (BOOL*)[dictionary objectForKey:@"outbound"];
	
	self.legs = [[NSMutableArray alloc] initWithObjects:nil];
	self.recordings = [[NSMutableArray alloc] initWithObjects:nil];
	
	NSArray *legsArray = [[NSArray alloc] arrayByAddingObjectsFromArray:[dictionary objectForKey:@"legs"]];
	int i;
	for (i=0; i < [legsArray count]; i++) {
		// parse multileg object here
	}
	
	NSArray *recordingsArray = [[NSArray alloc] arrayByAddingObjectsFromArray:[dictionary objectForKey:@"recordings"]];
	for (i=0; i < [recordingsArray count]; i++) {
		// parse multileg object here
	}
	
	[dictionary release];
	return self;
}

-(void)addLeg:(CallLeg*)leg {
	NSLog(@"here %@", [leg callLegId]);
	
	[legs addObject:leg];
	NSLog(@"here legs = %@", legs);
//	NSLog(@"here counts %@", [legs count]);
}

-(void)startCall {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	NSMutableArray *ids;
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	@try {
		// collect ids
		ids = [[NSMutableArray alloc] init];
		int i;
		for(i = 0; i < [legs count]; i++) {
			CallLeg *leg = [legs objectAtIndex:i];
			NSLog(@"leg %@", leg.callLegId);
			[ids addObject:leg.callLegId];
		}

		[dict setObject:ids forKey:@"legs"];

		if (callerId != nil && [callerId length] > 0) {
			[dict setObject:callerId forKey:@"callerId"];
		}
		if (callerId != nil && [callerId length] > 0) {
			[dict setObject:mode forKey:@"mode"];
		}
		if (announce != nil && [announce length] > 0) {
			[dict setObject:announce forKey:@"announce"];
		}
	}
	@catch (NSException * e) {
		//
		NSLog(@"error = %@", e);
	}
	@finally {
		//
	}
	
	NSString *url = [[config.endpoint stringByAppendingString:@"calls/"] stringByAppendingString: config.accountId];

	[dict setObject:url forKey:@"url"];
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dict setObject:body forKey:@"json"];
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dict];
	// Figure out why it doesn't wait for the response
	
	//NSArray *chunks = [response componentsSeparatedByString: @"/"];
	//callID = [chunks objectAtIndex:[chunks count] - 1 ];
	//callURI = response;
}

-(void)updateCallWithDictionary:(NSDictionary*)dictionary {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}

	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	
	//[signedRequest httpPostWithURI:uri vars:dict];
	NSString *url = [[[config.endpoint stringByAppendingString:@"calls/"] stringByAppendingString: config.accountId] stringByAppendingString:callID];
	
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dictionary error:&jsonerror];
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
	
	// Figure out why it doesn't wait for the response
	
	//NSArray *chunks = [response componentsSeparatedByString: @"/"];
	//callID = [chunks objectAtIndex:[chunks count] - 1 ];
	//callURI = response;
}

-(void)dropCall {
	
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	//	NSLog(@"data = %@", data);
	NSLog(@"my Data: %.*s", [data length], [data bytes]);
	if (ticket.didSucceed) {
		//NSLog(@"data = %@", data);
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		//NSLog(@"responseBody = %@", responseBody);
		OAToken *requestToken;
		requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		//self.response = responseBody;
		NSLog(@"response body= %@", responseBody);
	} else {
		
	}
	
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)requestError {
	NSLog(@"ticket_request= %@", ticket.request);
	NSLog(@"ticket_response= %@", ticket.response);
    NSLog(@"error= %@", requestError);
}


@end
