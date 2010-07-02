//
//  CallLeg.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "CallLeg.h"
#import "SBJSON.h"
#import "SignedRequest.h"


@implementation CallLeg

@synthesize callID;
@synthesize callLegId;
@synthesize status;
@synthesize startTime;
@synthesize answerTime;
@synthesize endTime;
@synthesize duration;
@synthesize mode;
@synthesize announce;
@synthesize playing;
@synthesize recording;

-(id)initWithConfig:(RibbitConfig*)ribbitConfig callID:(NSString*)callId {
	self = [super init];
	self.config = ribbitConfig;
	self.callID = callId;
	return self;
}

-(void)updateLegWithDictionary:(NSMutableDictionary*)dictionary {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}

	NSMutableString *url = [[config.endpoint stringByAppendingString:@"calls/"] stringByAppendingString: config.accountId];
	[url appendString:@"/"];
	[url appendString:[dictionary objectForKey:@"callID"]];
	[url appendString:@"/"];
	[url appendString:callID];
	
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
