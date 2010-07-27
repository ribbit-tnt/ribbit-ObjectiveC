//
//  Folder.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//
#import "SBJSON.h"
#import "Folder.h"
#import "SignedRequest.h"
#import "ASIHTTPRequest.h"


@implementation Folder

@synthesize folderName, files;

-(id)initWithConfig:(RibbitConfig*)ribbitConfig {
	self = [super init];
	self.config = ribbitConfig;
	self.files = [[NSMutableArray alloc] init];
	return self;
}

-(NSString*)getFileTextWithFilename:(NSString *)filename {
	if (config.accountId == NULL) {
		// TODO raise exception here
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"media/"];
	[url appendString:[config domain]];
	[url appendString:@"/"];
	if ([filename hasPrefix:[folderName stringByAppendingString:@"/"]]) {
		[url appendString:filename];
	} else {
		[url appendString:folderName];
		[url appendString:@"/"];
		[url appendString:filename];
	}
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:url forKey:@"url"];
	[dict setObject:@"GET" forKey:@"method"];
	[request httpRequestWithDictionary:dict];
	//[request httpGetWithURI:url];
	[url release];
	
	return request.response;
}

-(void)removeFolder {
	if (config.accountId == NULL) {
		// TODO raise exception here
	}
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"media/"];
	[url appendString:[config domain]];
	[url appendString:@"/"];
	[url appendString:[self folderName]];
	[request httpDeleteWithURI:url];
	[url release];
}
-(void)removeFileWithFilename:(NSString*)filename {
	if (config.accountId == NULL) {
		// TODO raise exception here
	}
	if (filename == nil || [filename length] == 0) {
		// TODO raise exception here
	}
	
	SignedRequest *request = [[SignedRequest alloc] initWithConfig:config];
	NSMutableString *url = [[NSMutableString alloc] initWithString:@"media/"];
	[url appendString:[config domain]];
	[url appendString:@"/"];
	
	if ([filename hasPrefix:[folderName stringByAppendingString:@"/"]]) {
		[url appendString:filename];
	} else {
		[url appendString:[self folderName]];
		[url appendString:@"/"];
		[url appendString:filename];
	}

	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setObject:url forKey:@"url"];
	[dictionary setObject:@"DELETE" forKey:@"method"];
	
//	[request httpRequestWithDictionary:dictionary];
	[request httpDeleteWithURI:url];
	
	// TODO remove from files collection.
	[files removeObject:filename];
}

-(void) fromJSON:(NSArray*)values {
	int i = 0;
	NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
	for (i; i<[values count]; i++) {
		FolderResource *resource = [[FolderResource alloc] init];
		[resource initFromDict:[values objectAtIndex:i]];
		[tempArray addObject:resource];
	}

	//[files addObjectsFromArray:tempArray];
	//[values release];	
}

-(void) uploadFile:(NSString*)fileName withData:(NSData*)data {
	NSMutableString *url = [[NSMutableString alloc] init];
	[url appendString:[[config.endpoint stringByAppendingString:@"media/"] stringByAppendingString: config.domain]];
	[url appendString:@"/"];
	[url appendString:folderName];
	[url appendString:@"/"];
	[url appendString:fileName];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:url forKey:@"url"];
	[dict setObject:data forKey:@"data"];
	[dict setObject:@"POST" forKey:@"method"];
	NSString *accept = [SignedRequest getAcceptTypeWithURI:url];
	[dict setObject:accept forKey:@"Content-Type"];
	
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dict];
	NSLog(@"response = %@", signedRequest.response);
}

-(void) downloadFile: (NSString*)filename andPath:(NSString*)path{
	NSMutableString *url = [[NSMutableString alloc] init];
	[url appendString:[[config.endpoint stringByAppendingString:@"media/"] stringByAppendingString: config.domain]];
	[url appendString:@"/"];
	[url appendString:folderName];
	[url appendString:@"/"];
	[url appendString:filename];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:url forKey:@"url"];
	[dict setObject:@"GET" forKey:@"method"];
	NSString *accept = [SignedRequest getAcceptTypeWithURI:url];
	[dict setObject:@"audio/wav" forKey:@"Accept-Type"];
	[dict setObject:path forKey:@"saveFilePath"];
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];
	[signedRequest httpRequestWithDictionary:dict];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:signedRequest.response];
	NSLog(@"returned");
	[request setDownloadDestinationPath:[dict objectForKey:@"saveFilePath"]];
	
	//[signedRequest httpGetWithURI:url];
	NSLog(@"response = %@", signedRequest.response);
}

@end