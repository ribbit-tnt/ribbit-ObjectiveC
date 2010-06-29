//
//  Device.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/13/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "Device.h"
#import "SBJSON.h"
#import "RibbitConfig.h"
#import "SignedRequest.h"

@implementation Device

@synthesize deviceId, label, name, carrier, key, verifyBy;
@synthesize verified, callme, attachmessage, useWAV, callbackreachme;
@synthesize notifyvm, notifytranscription, notifymissedcall, showcalled;
@synthesize mailtext, shared, answersecurity, ringstatus, autoAnswer, allowCCF;


-(id)initWithDictionary:(NSDictionary*)dictionary ribbitConfig:(RibbitConfig*)ribbitconfig {
	[super init];
	self.config = ribbitconfig;
	deviceId = [dictionary objectForKey:@"id"];
    name = [dictionary objectForKey:@"name"];
    carrier = [dictionary objectForKey:@"carrier"];
    verified = (BOOL*)[dictionary objectForKey:@"verified"];
    callme = (BOOL*)[dictionary objectForKey:@"callme"];
    attachmessage = (BOOL*)[dictionary objectForKey:@"attachmessage"];
    useWAV = (BOOL*)[dictionary objectForKey:@"usewave"];
	callbackreachme = (BOOL*)[dictionary objectForKey:@"callbackreachme"];
	mailtext = (BOOL*)[dictionary objectForKey:@"mailtext"];
	shared = (BOOL*)[dictionary objectForKey:@"shared"];
	notifymissedcall = (BOOL*)[dictionary objectForKey:@"notifymissedcall"];
	answersecurity = (BOOL*)[dictionary objectForKey:@"answersecurity"];
	showcalled = (BOOL*)[dictionary objectForKey:@"showcalled"];
	ringstatus = (BOOL*)[dictionary objectForKey:@"ringstatus"];
	autoAnswer = (BOOL*)[dictionary objectForKey:@"autoAnswer"];
	allowCCF = (BOOL*)[dictionary objectForKey:@"allowCCF"];
	[dictionary release];
	return self;
}
-(NSString*)deviceId {
    return deviceId;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Device: Id=%@",[self deviceId]];
}
-(void)removeDevice {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"devices/"];
	[url appendString:[config getActiveUserId]];
	[url appendString:[self deviceId]];
	[request httpGetWithURI:url];
}

-(void) updateDeviceWithDictionary:(NSDictionary*)dict {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	
	//[signedRequest httpPostWithURI:uri vars:dict];
	NSString *url = [[[config.endpoint stringByAppendingString:@"devices/"] stringByAppendingString:[config getActiveUserId]] stringByAppendingString:[@"/" stringByAppendingString:[self deviceId]]];
	
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


@end
