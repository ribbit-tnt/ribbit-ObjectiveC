//
//  Ribbit.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "Ribbit.h"
#import "Device.h"
#import "Message.h"
#import "Service.h"
#import "User.h"
#import "JSON.h"
#import "SBJSON.h"
#import "SignedRequest.h"
#import "OAServiceTicket.h"


@implementation Ribbit

-(id) initWithConfig:(RibbitConfig*)ribbitConfig {
	[self setConfig:ribbitConfig];
	return self;
}

-(BOOL*)loginWithUsername:(NSString*)username password:(NSString*)password {
	[self logout];
	
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	
	NSString *response = [[NSString alloc]init];
	
	@try {
		[request sendLoginRequestWithURI:@"login" username:@"test" pass:@"testtest"];
	//	[request sendLoginRequestWithURI:@"login" username:@"test" password:@"testtest"];
		response = request.response;
	} @catch( NSException *e) {
		NSLog(@"caught NSException: %@", e);
		@throw e;
	}
	
	NSArray *components = [response componentsSeparatedByString:@"&"];
	NSString *accessToken = [[[components objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
	NSString *accessSecret = [[[components objectAtIndex:1] componentsSeparatedByString:@"="] objectAtIndex:1];
	NSString *loggedInUser = [[[components objectAtIndex:2] componentsSeparatedByString:@"="] objectAtIndex:1];
	
	[config setUsername:username];
	[config	setAccountId:loggedInUser];
	[config setAccessToken:accessToken];
	[config	setAccessSecret:accessSecret];

	return (BOOL*)TRUE;
}

-(void)logout {
	[self.config clearUser];
}

-(NSString*) createUserAuthenticationURLWithCallback:(NSString*)callbackURL {
	[self logout];
	
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	
	NSString *response = [[NSString alloc]init];
	
	@try {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		//[dict setObject:@"request_token" forKey:@"url"];
		//[request httpRequestWithDictionary:dict];
		
		[request httpPostWithURI:@"request_token"];
		response = request.response;
		NSArray *components = [[response componentsSeparatedByString:@"&"] autorelease];
		NSString *requestToken = [[[[components objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1] autorelease];
		NSString *requestSecret = [[[[components objectAtIndex:1] componentsSeparatedByString:@"="] objectAtIndex:1] autorelease];
		NSMutableString *callbackQueryParams = [[NSMutableString alloc] initWithString:@""];
		
		[config setRequestToken:requestToken];
		[config setRequestSecret:requestSecret];
		
		
		NSLog(@"authURL = %@", request.response);
		
		if (callbackURL != nil) {
			[[callbackQueryParams stringByAppendingString:@"&oauth_callback="] stringByAppendingString:callbackURL];
		} 
			 
		return [[[[config endpoint] stringByAppendingString: @"oauth/display_token.html?oauth_token="] stringByAppendingString:requestToken] stringByAppendingString:callbackQueryParams];
		
	} @catch( NSException *e) {
		NSLog(@"caught NSException: %@", e);
		@throw e;
	}
	
	return nil;
}

-(BOOL)checkAuthenticatedUser {
	return TRUE;
}

-(Call*)newCall {
	Call *call = [[Call alloc]initWithConfig:config];
	return call;
}

-(Message*)newMessage {
	Message *msg = [[Message alloc]initWithConfig:config];
	return msg;
}


-(Folder*) getFolder:(NSString*)name {
	if (config.accountId == NULL) {
		//TODO raise exception
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"media/"];
	[url appendString:[config domain]];
	[url appendString:@"/"];
	[url appendString:name];
	[request httpGetWithURI:url];
	
	// TODO replace this with a notifier or selector...is very bad
	//[NSThread sleepForTimeInterval:10];
		NSString *result = request.response;
	NSLog(@" get Folder result = %@", result);
	id tempDict = [result JSONValue];
	NSArray *dictArray = [tempDict objectForKey:@"entry"];

	Folder *folder;
	if (dictArray != nil) {
		folder = [[Folder alloc] initWithConfig:config];
		folder.folderName = name;
		[folder fromJSON:dictArray];
		return folder;
	} else {
		NSLog(@"There was an error processing the folder");
		// TODO figure out how to throw error.
	}
	return nil;
}
-(Folder*) createFolder:(NSString*)name {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:name forKey:@"id"];
	
	//[signedRequest httpPostWithURI:uri vars:dict];
	NSString *url = [[config.endpoint stringByAppendingString:@"media/"] stringByAppendingString: config.domain];
	
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dict setObject:url forKey:@"url"];
	[dict setObject:body forKey:@"json"];
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dict];
	
	return [self getFolder:name];
}

-(Device*) getDevice:(NSString*)deviceId {
	if (config.accountId == NULL) {
		//TODO raise exception
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"devices/"];
	[url appendString:[config getActiveUserId]];	
	[url appendString:deviceId];
	[request httpGetWithURI:url];
	NSString *result = request.response;
	id tempDict = [result JSONValue];
	NSDictionary *dict = [tempDict objectForKey:@"entry"];
	Device *device;
	if (dict != nil) {
		device = [[Device alloc] initWithDictionary:dict ribbitConfig:config];
		return device;
	} else {
		NSLog(@"There was an error processing the device");
		// TODO figure out how to throw error.
	}
	return nil;
}

-(Device*) createDevice:(NSDictionary*)dict {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	
	//[signedRequest httpPostWithURI:uri vars:dict];
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary addEntriesFromDictionary:dict];
	
	
	NSString *url = [[config.endpoint stringByAppendingString:@"devices"] stringByAppendingString: [config getActiveUserId]];
	
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dictionary setObject:url forKey:@"url"];
	[dictionary setObject:body forKey:@"json"];
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dictionary];
	
	[self getDevice:[dict objectForKey:@"deviceId"]];
}

-(User*) createUser:(NSDictionary*)dict {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	
	//[signedRequest httpPostWithURI:uri vars:dict];
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary addEntriesFromDictionary:dict];
	NSString *url = [config.endpoint stringByAppendingString:@"users"];
	
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dictionary setObject:url forKey:@"url"];
	[dictionary setObject:body forKey:@"json"];
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dictionary];	
	// get user details from response
}

-(User*) getUser:(NSString*)userId {
	if (config.accountId == NULL) {
		//TODO raise exception
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"users/"];
	[url appendString:[config getActiveUserId]];	
	[request httpGetWithURI:url];
	NSString *result = request.response;
	
	id tempDict = [result JSONValue];
	NSDictionary *dict = [tempDict objectForKey:@"entry"];
	User *user;
	if (dict != nil) {
		user = [[User alloc] initFromDict:dict ribbitConfig:config];
		NSLog(@"user = %@", user);
		return user;
	} else {
		NSLog(@"There was an error processing the device");
		// TODO figure out how to throw error.
	}
	return user;
}

-(Call*) getCall:(NSString*)callId {
	if (config.accountId == NULL) {
		//TODO raise exception
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"calls/"];
	[url appendString:[config getActiveUserId]];	
	[url appendString:callId];
	[request httpGetWithURI:url];
	NSString *result = request.response;
	
	
	id tempDict = [result JSONValue];
	NSDictionary *dict = [tempDict objectForKey:@"entry"];
	Call *call;
	if (dict != nil) {
		call = [[Call alloc] initWithDictionary:dict ribbitConfig:config];
		return call;
	} else {
		NSLog(@"There was an error processing the call");
		// TODO figure out how to throw error.
	}
	return nil;
}

-(NSArray*)getCalls {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSString *uri = [@"calls/" stringByAppendingString:[config getActiveUserId]];
	[request httpGetWithURI:uri];
	NSString* result = request.response;
	
	id tempDict = [result JSONValue];
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	if (dictArray != nil) {
		NSMutableArray *calls = [[NSMutableArray alloc]init];
		int i;
		for (i=0; i< [dictArray count]; i++) {
			Call *temp = [[Call alloc]initWithDictionary:[dictArray objectAtIndex:i] ribbitConfig:config];
			[calls addObject:temp];
			[temp release];
		}
		return calls;
	} else {
		NSLog(@"There was an error processing the devices");
		// TODO figure out how to throw error.
	}
	return nil;
}


-(Message*) getMessage:(NSDictionary*)dict {
	return nil;
}

-(NSArray*)getDevices {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSString *uri = [@"devices/" stringByAppendingString:[config getActiveUserId]];
	[request httpGetWithURI:uri];
	NSString* result = request.response;
	
	id tempDict = [result JSONValue];
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	if (dictArray != nil) {
		NSMutableArray *devices = [[NSMutableArray alloc]init];
		int i;
		for (i=0; i< [dictArray count]; i++) {
			Device *temp = [[Device alloc]initWithDictionary:[dictArray objectAtIndex:i] ribbitConfig:config];
			[devices addObject:temp];
			[temp release];
		}
		return devices;
	} else {
		NSLog(@"There was an error processing the devices");
		// TODO figure out how to throw error.
	}
	return nil;
}

-(NSArray*)getServices {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"services/"];
	[url appendString:[config getActiveUserId]];
	[request httpGetWithURI:url];
	NSString* result = request.response;
	
	id tempDict = [result JSONValue];
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	if (dictArray != nil) {
		NSMutableArray *services = [[NSMutableArray alloc]init];
		int i;
		for (i=0; i< [dictArray count]; i++) {
			Service *temp = [[Service alloc]initWithDictionary:[dictArray objectAtIndex:i] ribbitConfig:config];
			[services addObject:temp];
			[temp release];
		}
		return services;
	} else {
		NSLog(@"There was an error processing the services");
		// TODO figure out how to throw error.
	}
	return nil;
}

-(NSArray*) getMessages{
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSString *uri = [@"messages/" stringByAppendingString:[config getActiveUserId]];
	[request httpGetWithURI:uri];
	NSString* result = request.response;
	
	id tempDict = [result JSONValue];
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	if (dictArray != nil) {
		NSMutableArray *messages = [[NSMutableArray alloc]init];
		int i;
		for (i=0; i< [dictArray count]; i++) {
			Message *temp = [[Message alloc]initWithDictionary:[dictArray objectAtIndex:i] ribbitConfig:config];
			[messages addObject:temp];
			[temp release];
		}
		return messages;
	} else {
		NSLog(@"There was an error processing the messages");
		// TODO figure out how to throw error.
	}
	return nil;
	
}

-(NSArray*) getUsers {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"users/"];
	//[url appendString:[config getActiveUserId]];
	[request httpGetWithURI:url];
	NSString* result = request.response;
	
	id tempDict = [result JSONValue];
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	NSMutableArray *users;
	if (dictArray != nil) {
		users = [[NSMutableArray alloc]init];
		int i;
		for (i=0; i< [dictArray count]; i++) {
			User *temp = [[User alloc]initFromDict:[dictArray objectAtIndex:i] ribbitConfig:config];
			[users addObject:temp];
			[temp release];
		}
		return users;
	} else {
		NSLog(@"There was an error processing the services");
		// TODO figure out how to throw error.
	}
	return users;
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

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"ticket_request= %@", ticket.request);
	NSLog(@"ticket_response= %@", ticket.response);
    NSLog(@"error= %@", error);
}


@end
