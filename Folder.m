//
//  Folder.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "Folder.h"
#import "SignedRequest.h"


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
	
	[request httpGetWithURI:url];
	[url release];
	//TODO replace this, very very bad
	[NSThread sleepForTimeInterval:15];
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
	
	if ([filename hasPrefix:[folderName stringByAppendingString:@"/"]]) {
		[url appendString:filename];
	} else {
		[url appendString:[self folderName]];
		[url appendString:@"/"];
		[url appendString:filename];
	}
	
	[request httpDeleteWithURI:url];
	[url release];
	// TODO remove from files collection.
}

-(void) fromJSON:(NSArray*)values {
	int i = 0;
	NSMutableArray *tempArray = [[[NSMutableArray alloc] init] autorelease];
	for (i; i<[values count]; i++) {
		FolderResource *resource = [[FolderResource alloc] init];
		[resource initFromDict:[values objectAtIndex:i]];
		[tempArray addObject:resource];
	}

	[files initWithArray:tempArray];
	[values release];	
}

@end