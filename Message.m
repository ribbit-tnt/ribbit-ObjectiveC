//
//  Message.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/9/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "Message.h"
#import "SignedRequest.h"
#import "SBJSON.h"


@implementation Message

@synthesize title;
@synthesize body;
@synthesize userId;
@synthesize sender;
@synthesize messageId;
@synthesize from;
@synthesize mediaUri;
@synthesize mediaItems;
@synthesize time;
@synthesize newMessage;
@synthesize urgentMessage;
@synthesize folder;
@synthesize recipients;



-(id)initWithConfig:(RibbitConfig*)ribbitconfig {
	[super init];
	[self setConfig:ribbitconfig];
	self.recipients = [[NSMutableArray alloc] init];
	return self;
}

-(id)initWithDictionary:(NSDictionary*)dictionary ribbitConfig:(RibbitConfig*)ribbitconfig {
	[super init];
	self.config = ribbitconfig;
	messageId = [dictionary objectForKey:@"id"];
    title = [dictionary objectForKey:@"title"];
    userId = [dictionary objectForKey:@"userId"];
    sender = [dictionary objectForKey:@"sender"];
	from = [dictionary objectForKey:@"from"];
    mediaUri = [dictionary objectForKey:@"mediaUri"];
    time = [dictionary objectForKey:@"time"];
    folder = [dictionary objectForKey:@"folder"];
	newMessage = (BOOL*)[dictionary objectForKey:@"newMessage"];
	urgentMessage = (BOOL*)[dictionary objectForKey:@"urgentMessage"];
	
	self.recipients = [[NSMutableArray alloc] initWithObjects:nil];
	self.mediaItems = [[NSMutableArray alloc] initWithObjects:nil];
	
	NSArray *recipientArray = [[NSArray alloc] arrayByAddingObjectsFromArray:[dictionary objectForKey:@"recipients"]];
	int i;
	for (i=0; i < [recipientArray count]; i++) {
		NSDictionary *dict = [[NSDictionary alloc] initWithDictionary: [recipientArray objectAtIndex:i]];
		MessageDestination *dest = [[MessageDestination alloc] init];
		dest.status = [dict objectForKey:@"status"];
		dest.destination = [dict objectForKey:@"destination"];
		[recipients addObject:dest];
		[dict release];
	}
	
	[mediaItems arrayByAddingObjectsFromArray:[dictionary objectForKey:@"mediatItems"]];
	
	[dictionary release];
	return self;
}

-(void)addRecipient:(MessageDestination*)recipient {
	[recipients addObject:recipient];
}

-(void)sendSMS {
	if (config.accountId == NULL) {
		// raise exception here, TODO figure out exact format
	}
	NSMutableArray *dests;
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	@try {
		// collect ids
		dests = [[NSMutableArray alloc] init];
		int i;
		for(i = 0; i < [recipients count]; i++) {
			MessageDestination *dest = [recipients objectAtIndex:i];
			NSLog(@"destination %@", dest.destination);
			[dests addObject:dest.destination];
		}
		
		[dict setObject:dests forKey:@"recipients"];
		
		if (body != nil && [body length] > 0) {
			[dict setObject:body forKey:@"body"];
		}
		if (sender != nil && [sender length] > 0) {
			[dict setObject:sender forKey:@"sender"];
		}
		if (title != nil && [title length] > 0) {
			[dict setObject:title forKey:@"title"];
		}
	}
	@catch (NSException * e) {
		//
		NSLog(@"error = %@", e);
	}
	@finally {
		//
	}
	
	SignedRequest *signedRequest = [[SignedRequest alloc] initWithConfig:config];

	NSString *url = [[[config.endpoint stringByAppendingString:@"messages/"] stringByAppendingString: [config getActiveUserId]]stringByAppendingString:@"/outbox"];
	
	[dict setObject:url forKey:@"url"];
	NSError *jsonerror;
	SBJSON *json = [SBJSON new];
	
	NSString *body = [json stringWithObject:dict error:&jsonerror];
	[dict setObject:body forKey:@"json"];

	[signedRequest httpRequestWithDictionary:dict];
	NSLog(@"sendSMS = %@", signedRequest.response);
}


@end
