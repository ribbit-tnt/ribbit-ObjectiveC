//
//  RibbitPlatformTests.m
//
//  Created by James Williams on 6/14/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "TestCase.h"

@interface RibbitPlatformTests : TestCase {}
@end

@implementation RibbitPlatformTests
- (void)testStringFormatting {
	NSString *name = @"Earl";
	
	// create the string
	NSString *formattedString = [NSString stringWithFormat:@"My name is %@.", name];
	
	// test the substitution
	ASSERT_STRINGS_EQUAL(@"My name is Earl.", formattedString); 
}

- (void)testStringLength {
	NSString *alphabet = @"ABCDEFGHIJKLNOPQRSTUVWXYZ";
	
	// test the length
	ASSERT_INTEGERS_EQUAL(26, [alphabet length]); // uh oh, it failed?!
}

- (void)testPrefixAndSuffix {
	NSString *urlString = @"http://raptureinvenice.com";
	
	// test the url
	ASSERT_TRUE([urlString hasPrefix:@"http://"]);
	ASSERT_FALSE([urlString hasSuffix:@".html"]);
}

@end
