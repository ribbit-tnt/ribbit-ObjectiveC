//
//  Service.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//
#import "SBJSON.h"
#import "Service.h"
#import "SignedRequest.h"


@implementation Service

@synthesize serviceId, active, status;
@synthesize voicemail, serviceType, folders;

-(id)initWithDictionary:(NSDictionary*) dictionary ribbitConfig:(RibbitConfig*)ribbitConfig{
	[super init];
	self.config = ribbitConfig;
//	NSLog(@"init service");
	serviceId = [dictionary objectForKey:@"id"];
	serviceType = [dictionary objectForKey:@"type"];
	voicemail = [dictionary objectForKey:@"voicemail"];
	status = [dictionary objectForKey:@"stauts"];
//	NSLog(@"init service2");
	NSArray *array = [dictionary objectForKey:@"folders"];
	folders = [[NSArray alloc] initWithArray:array];
	
	[dictionary release];
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Service: Id=%@ Properties=%@",serviceId, voicemail];
}

-(void)setServiceFoldersWithFolders:(NSArray*)folderNames {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:folderNames forKey:@"folders"];
	
	NSString *url = [[[@"services/" stringByAppendingString:[config getActiveUserId]] stringByAppendingString:@"/"] stringByAppendingString:serviceId];
	//[request httpPutWithURI:uri variables:vars];
	
	[dict setObject:@"PUT" forKey:@"method"];
	[dict setObject:url forKey:@"url"];
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];

	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dict setObject:body forKey:@"json"];
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dict];
	
}

-(void)clearServiceFolders {	
	NSLog(@"Clearing %@", [self serviceId]);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	[array addObject:[[NSNull alloc] init]];
	[self setServiceFoldersWithFolders:array ];
	
	// TODO deserialize reponse
	// Reload folder?
	// set folders to deserialize result
}

-(void)setAsVoicemailTranscriptionProviderWithStatus:(BOOL)voicemailStatus {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableDictionary *vars = [[NSDictionary alloc] init];
	[vars setObject:voicemailStatus forKey:@"voicemail"];
	
	NSString *uri = [[@"services/" stringByAppendingString:[config getActiveUserId]] stringByAppendingString:serviceId];
	[request httpPutWithURI:uri variables:vars];
	
	voicemail = (BOOL)voicemailStatus;
	
}


@end
