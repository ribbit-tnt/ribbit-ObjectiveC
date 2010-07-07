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
@synthesize jsonerror, json, parser;

-(id) initWithConfig:(RibbitConfig*)ribbitConfig {
	[self setConfig:ribbitConfig];
	json = [SBJSON new];
	parser = [[SBJSON alloc] init];
	return self;
}

-(BOOL*)loginWithUsername:(NSString*)username password:(NSString*)password {
	[self logout];
	
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	
	NSString *response = [[NSString alloc]init];
	
	@try {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		[dict setObject:username forKey:@"username"];
		[dict setObject:password forKey:@"password"];
		[dict setObject:@"login" forKey:@"url"];
		
	//	[request httpRequestWithDictionary:dict];
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
		[dict setObject:@"request_token" forKey:@"url"];
		[dict setObject:@"POST" forKey:@"method"];
		[dict setObject:@"application/json" forKey:@"Content-Type"];
		[request httpRequestWithDictionary:dict];
		
		//[request httpPostWithURI:@"request_token"];
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
	[url release];
	
	// TODO replace this with a notifier or selector...is very bad
	//[NSThread sleepForTimeInterval:10];
	NSString *result = request.response;
	[request release];
	NSLog(@" get Folder result = %@", result);
	//SBJSON *parser = [[SBJSON alloc] init];
	
	//id tempDict = [result JSONValue];
	NSDictionary *tempDict = [parser objectWithString:result error:nil];
	
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	

	Folder *folder;
	if (dictArray != nil) {
		folder = [[[Folder alloc] initWithConfig:config] autorelease];
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
	
	jsonerror = nil;
	json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dict setObject:url forKey:@"url"];
	[dict setObject:body forKey:@"json"];
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dict];
	
	[json release];
	[dict release];
	[signedRequest release];
	
	return [self getFolder:name];
}

-(Device*) getDevice:(NSString*)deviceId {
	if (config.accountId == NULL) {
		//TODO raise exception
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"devices/"];
	[url appendString:[config getActiveUserId]];
	[url appendString:@"/"];
	[url appendString:deviceId];
	[request httpGetWithURI:url];
	NSString *result = request.response;
	
	NSDictionary *tempDict = [parser objectWithString:result error:nil];
	
	NSDictionary *dict = [tempDict objectForKey:@"entry"];
	
	[url release];
	[request release];
	
	Device *device;
	if (dict != nil) {
		device = [[[Device alloc] initWithDictionary:dict ribbitConfig:config] autorelease];
		return device;
	} else {
		NSLog(@"There was an error processing the device or no device for the value.");
	}
	return nil;
}

-(Device*) createDevice:(NSMutableDictionary*)dict {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	
	NSString *url = [[config.endpoint stringByAppendingString:@"devices/"] stringByAppendingString: [config getActiveUserId]];
	jsonerror = nil;
	json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dict setObject:url forKey:@"url"];
	[dict setObject:@"POST" forKey:@"method"];
	[dict setObject:body forKey:@"json"];
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dict];
	
	return [self getDevice:[dict objectForKey:@"id"]];
}

-(User*) createUser:(NSDictionary*)dict {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	
	//[signedRequest httpPostWithURI:uri vars:dict];
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary addEntriesFromDictionary:dict];
	NSString *url = [config.endpoint stringByAppendingString:@"users"];
	
	jsonerror = nil;
	json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dictionary setObject:url forKey:@"url"];
	[dictionary setObject:body forKey:@"json"];
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dictionary];	
	// get user details from response
	return nil;
}

-(User*) getUser:(NSString*)userId {
	if (config.accountId == NULL) {
		//TODO raise exception
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"users/"];
	[url appendString:userId];	
	
	NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
	[d setObject:url forKey:@"url"];
	[d setObject:@"GET" forKey:@"method"];
	[d setObject:[SignedRequest getAcceptTypeWithURI:url] forKey:@"Accept-Type"];
	
	//[request httpRequestWithDictionary:d];
	[request httpGetWithURI:url];

	NSString *result = request.response;
	
	//SBJSON *parser = [[SBJSON alloc] init];
	
	//id tempDict = [result JSONValue];
	NSDictionary *tempDict = [parser objectWithString:result error:nil];
	
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
	return nil;
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

-(NSArray*)getCalls:(NSDictionary*)dict {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *uri = [[NSMutableString alloc] init];
	[uri appendString:[@"calls/" stringByAppendingString:[config getActiveUserId]]];
	[uri appendString:[Resource convertMapToQueryString:dict]];

	[request httpGetWithURI:uri];
	NSString* result = request.response;
	
	NSDictionary *tempDict = [parser objectWithString:result error:nil];

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
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *uri = [[NSMutableString alloc] init];
	[uri appendString:[@"messages/" stringByAppendingString:[config getActiveUserId]]];
	[uri appendString:@"/"];
	[uri appendString:[dict objectForKey:@"folderName"]];
	[uri appendString:@"/"];
	[uri appendString:[dict objectForKey:@"id"]];
	
	[request httpGetWithURI:uri];
	NSString* result = request.response;
	 
	NSDictionary *tempDict = [parser objectWithString:result error:nil];
	 
	NSDictionary *dictionary = (NSDictionary*)[tempDict objectForKey:@"entry"];
	Message *message = [[Message alloc] initWithDictionary:dictionary ribbitConfig:config];
	return message;
}

-(NSArray*)getDevices {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSString *uri = [@"devices/" stringByAppendingString:[config getActiveUserId]];
	[request httpGetWithURI:uri];
	NSString* result = request.response;
	
	NSDictionary *tempDict = [parser objectWithString:result error:nil];
	
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
	
	//SBJSON *parser = [[SBJSON alloc] init];
	
	//id tempDict = [result JSONValue];
	NSDictionary *tempDict = [parser objectWithString:result error:nil];
	
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	[dictArray retain];
	NSLog(@"get services here");
	if (dictArray != nil) {
		NSMutableArray *services = [[NSMutableArray alloc]init];
		int i;
		for (i=0; i< [dictArray count]; i++) {
			Service *temp = [[Service alloc]initWithDictionary:[dictArray objectAtIndex:i] ribbitConfig:config];
			[services addObject:temp];
			[temp release];
		}
		//NSLog(@"get services here3");
		return services;
	} else {
		NSLog(@"There was an error processing the services");
		// TODO figure out how to throw error.
	}
	return nil;
}


-(NSArray*) getMessagesWithDictionary:(NSMutableDictionary*)dict {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	NSString *folderName = [dict objectForKey:@"folderName"];
	[dict removeObjectForKey:@"folderName"];
	
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *uri = [[NSMutableString alloc] init];
	[uri appendString:@"messages/"];
	[uri appendString:[config getActiveUserId]];
	[uri appendString:@"/"];
	[uri appendString:folderName];
	[uri appendString:[Resource convertMapToQueryString:dict]];
	
	[request httpGetWithURI:uri];
	NSString* result = request.response;
	
	NSDictionary *tempDict = [parser objectWithString:result error:nil];
	
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	if (dictArray != nil) {
		NSMutableArray *messages = [[NSMutableArray alloc]init];
		int i;
		for (i=0; i< [dictArray count]; i++) {
			//NSLog(@"dictArray = %@", [dictArray objectAtIndex:i]);
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

-(NSArray*) getMessagesFromFolder:(NSString*)folderName{
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *uri = [[NSMutableString alloc] init];
	[uri appendString:@"messages/"];
	[uri appendString:[config getActiveUserId]];
	[uri appendString:@"/"];
	[uri appendString:folderName];
	
	[request httpGetWithURI:uri];
	NSString* result = request.response;
	
	//SBJSON *parser = [[SBJSON alloc] init];
	
	//id tempDict = [result JSONValue];
	NSDictionary *tempDict = [parser objectWithString:result error:nil];
	
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	if (dictArray != nil) {
		NSMutableArray *messages = [[NSMutableArray alloc]init];
		int i;
		for (i=0; i< [dictArray count]; i++) {
			//NSLog(@"dictArray = %@", [dictArray objectAtIndex:i]);
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
	[request httpGetWithURI:url];
	
	//NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	//[dict setObject:url forKey:@"url"];
	//[dict setObject:@"GET" forKey:@"method"];
	//[dict setObject:[SignedRequest getAcceptTypeWithURI:url] forKey:@"Accept-Type"];
	
	//[request httpRequestWithDictionary:dict];
	NSString* result = request.response;
	
	//SBJSON *parser = [[SBJSON alloc] init];
	
	//id tempDict = [result JSONValue];
	NSDictionary *tempDict = [parser objectWithString:result error:nil];
	
	//id tempDict = [result JSONValue];
	NSArray *dictArray = [tempDict objectForKey:@"entry"];
	[dictArray retain];

	NSMutableArray *users;
	NSLog(@"dictArray = %@",dictArray);
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
	return nil;
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	//	NSLog(@"data = %@", data);
	//NSLog(@"my Data: %.*s", [data length], [data bytes]);
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
