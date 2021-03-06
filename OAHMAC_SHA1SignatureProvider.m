//
//  OAHMAC_SHA1SignatureProvider.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OAHMAC_SHA1SignatureProvider.h"
#import <CommonCrypto/CommonHMAC.h>

#include "Base64Transcoder.h"

@implementation OAHMAC_SHA1SignatureProvider

- (NSString *)name 
{
    return @"HMAC-SHA1";
}

- (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret 
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    //Base64 Encoding
    
//    char base64Result[32];
//    size_t theResultLength = 32;
//    Base64EncodeData(result, 20, base64Result, &theResultLength);
//    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
//    
//    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
//
//    return [base64EncodedResult autorelease];
	
	//
	return [self Data_encodeBase64:[NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH]];
	
}
- (NSString*)Data_encodeBase64:(NSData*) data{
    char *ptr = NULL;
	NSString* result = nil;
	// Look for the total bytes needed on the output buffer
    size_t len = b64_encode([data bytes], [data length], ptr, 0);
	
	if(len > 0 && (ptr = malloc(len))) {
		//ptr = malloc(len);
		len = b64_encode([data bytes], [data length], ptr, len);
		result = [NSString stringWithCString: ptr length: len];
		free(ptr);
	}
	
    return result;
}

- (NSString *)signBody:(char *)body withSecret:(NSString *)secret {
	NSLog(@"start signBody");
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
	NSData *bodyData = [[NSData alloc] initWithBytes:body length:sizeof(body)];
    unsigned char result[20];
	    NSLog(@"signBody");
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [bodyData bytes], [bodyData length], result);
    NSLog(@"signBody before encoding");
    //Base64 Encoding
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    NSLog(@"signBody after encoding");    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];

    return [base64EncodedResult autorelease];
}


@end
