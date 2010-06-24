//
//  FolderResource.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "FolderResource.h"


@implementation FolderResource

@synthesize resourceId;
@synthesize associatedApp;
@synthesize createdBy;
@synthesize createdOn;
@synthesize readUsers; 
@synthesize writeUsers;

-(id) init {
	self = [super init];
    self.readUsers = [[NSMutableArray alloc] init];
    self.writeUsers = [[NSMutableArray alloc] init];
	return (self);
}
-(id) initFromDict:(NSDictionary*)dict {
	[self init];
	self.createdBy = [dict objectForKey:@"createdBy"];
	NSString *dateString = [dict objectForKey:@"createdOn"];
	self.createdOn = [[NSDate alloc] initWithString:dateString];

	self.resourceId = [dict objectForKey:@"id"];
	int i;
	for (i = 0; i<[[dict objectForKey:@"readUsers"] count]; i++) {
		NSString *temp = [[dict objectForKey:@"readUsers"] objectAtIndex:i];
		[self.readUsers addObject:temp];
	}
	for (i = 0; i<[[dict objectForKey:@"writeUsers"] count]; i++) {
		NSString *temp = [[dict objectForKey:@"writeUsers"] objectAtIndex:i];
		[self.writeUsers addObject:temp];
	}
	
	return self;
}

-(NSString*) description {
	NSMutableString *text = [[NSMutableString alloc] init];
	[text appendString:self.resourceId];
	[text appendString:@"\n"];
	[text appendString:self.createdBy];

	return text;
}

@end
