//
//  Service.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "Service.h"
#import "SignedRequest.h"


@implementation Service

@synthesize serviceId, active, status;
@synthesize voicemail, serviceType, folders;

-(id)initWithDictionary:(NSDictionary*) dictionary ribbitConfig:(RibbitConfig*)ribbitConfig{
	[super init];
	self.config = ribbitConfig;
	
	serviceId = [dictionary objectForKey:@"id"];
	serviceType = [dictionary objectForKey:@"type"];
	voicemail = [dictionary objectForKey:@"voicemail"];
	status = [dictionary objectForKey:@"stauts"];
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
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	if ([folderNames count] == 0) {
		// TODO throw an exception here
	}
	
	NSMutableDictionary *vars = [[NSDictionary alloc] init];
	[vars setObject:folderNames forKey:@"folder"];
	
	NSString *uri = [[@"services/" stringByAppendingString:[config getActiveUserId]] stringByAppendingString:serviceId];
	[request httpPutWithURI:uri variables:vars];
	
	// TODO deserialize reponse
	// set folders to deserialize result	
}

-(void)clearServiceFolders {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableDictionary *vars = [[NSDictionary alloc] init];
	[vars setObject:[[NSArray alloc]init] forKey:@"folder"];
	
	NSString *uri = [[@"services/" stringByAppendingString:[config getActiveUserId]] stringByAppendingString:serviceId];
	[request httpPutWithURI:uri variables:vars];
	
	// TODO deserialize reponse
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
	
	voicemail = voicemailStatus;
	
}


@end
