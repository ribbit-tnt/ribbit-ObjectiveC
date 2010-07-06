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
	[url appendString:@"/"];
	[url appendString:[self deviceId]];
	[request httpDeleteWithURI:url];
}

-(void)updateDeviceWithDictionary:(NSMutableDictionary *)dictionary {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	//[signedRequest httpPostWithURI:uri vars:dict];
	//NSLog(@"user id = %@", userId);
	NSString *url = [[[config.endpoint stringByAppendingString:@"devices/"] stringByAppendingString:[config getActiveUserId]] stringByAppendingString:[@"/" stringByAppendingString:[self deviceId]]];
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[dictionary setObject:@"PUT" forKey:@"method"];
	[dictionary setObject:url forKey:@"url"];
	
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dictionary error:&jsonerror];
	[dictionary setObject:body forKey:@"json"];
	
	
	[signedRequest httpRequestWithDictionary:dictionary];
}
@end
