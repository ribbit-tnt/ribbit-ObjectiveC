//
//  Resource.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "Resource.h"


@implementation Resource

@synthesize config;
+(NSString*) convertMapToQueryString:(NSDictionary*)dict {
	//startIndex, count, filterBy, filterValue
	
	NSMutableString *temp = [[[NSMutableString alloc]init]autorelease];
	[temp appendString:@"?"];
	NSArray *allKeys = [dict allKeys];
	
	int i;
	for(i = 0; i<[allKeys count]; i++) {
		NSString *key = (NSString*)[allKeys objectAtIndex:i];
		NSObject *value = [dict objectForKey:key];
		[temp appendString:key];
		[temp appendString:@"="];
		[temp appendString:value];
		
		if (i < [allKeys count] -1) {
			[temp appendString:@"&"];
		}
	}
	return temp;
}
@end