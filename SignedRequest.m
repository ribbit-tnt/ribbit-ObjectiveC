//
//  SignedRequest.m
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import "SignedRequest.h"
#import "RibbitConfig.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import	"OADataFetcher.h"
#import "OAServiceTicket.h"
#import "OAToken.h"
#import "JSON.h"
#import <CommonCrypto/CommonHMAC.h>


@implementation SignedRequest
@synthesize config, response, realm;

-(id)init {
	self = [super init];
	return (self);
}

-(id)initWithConfig:(RibbitConfig*)ribbitConfig {
	self = [super init];
	self.config = ribbitConfig;
	self.realm = @"\"http://oauth.ribbit.com\"";
	return (self);
}

-(id)initWithRealm:(NSString*)realmString andConfig:(RibbitConfig*)ribbitConfig {
	self = [super init];
	self.config = ribbitConfig;
	self.realm = realmString;
	return (self);
}

-(void) httpRequestWithDictionary:(NSDictionary*)dict {
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:config.consumerKey secret:config.secretKey];

	NSString *url = (NSString*)[dict objectForKey:@"url"];
	NSString *body_sig;
	NSString *body;
	NSMutableString *method;
	
	if ([dict objectForKey:@"method"] != nil) {
		method = [dict objectForKey:@"method"];
	} else {
		method = @"POST";
	}
	
	if ([dict objectForKey:@"json"] != nil) {
		body = [dict objectForKey:@"json"];
		body_sig = [self sign_for_oauth:[body UTF8String]];
	}

	////(void)NSLog(body);
	// Create the string for the auth header signature
	NSString *nonce = [SignedRequest generate_nonce];
	double timestamp = [SignedRequest current_millis];
	
	NSString *q = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%.0f&oauth_token=%@&xoauth_body_signature=%@&xoauth_body_signature_method=HMAC-SHA1",
				   [config consumerKey],
				   nonce,
				   timestamp,
				   [config accessToken],
				   body_sig];
	
	NSString *string_to_sign;
	NSString *format;
	
	if ([method isEqualToString:@"PUT"]) {
		string_to_sign = [NSString stringWithFormat:@"PUT&%@&%@",[SignedRequest URLEncode:url],[SignedRequest URLEncode:q]];
	} else if ([method isEqualToString:@"GET"]) {
		string_to_sign = [NSString stringWithFormat:@"GET&%@&%@",[SignedRequest URLEncode:url],[SignedRequest URLEncode:q]];
	} else if ([method isEqualToString:@"DELETE"]) {
		string_to_sign = [NSString stringWithFormat:@"DELETE&%@&%@",[SignedRequest URLEncode:url],[SignedRequest URLEncode:q]];
	} else {
		string_to_sign = [NSString stringWithFormat:@"POST&%@&%@",[SignedRequest URLEncode:url],[SignedRequest URLEncode:q]];
	}
		
	NSString *string_sig = [self sign_for_oauth:[string_to_sign UTF8String]];
	NSString *auth_header = [NSString stringWithFormat:@"OAuth realm=\"%@\",oauth_consumer_key=\"%@\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"%.0f\",oauth_nonce=\"%@\",oauth_signature=\"%@\",oauth_token=\"%@\",xoauth_body_signature=\"%@\",xoauth_body_signature_method=\"HMAC-SHA1\"",
							 [SignedRequest URLEncode:realm],
							 config.consumerKey,
							 timestamp,
							 nonce,
							 [SignedRequest URLEncode:string_sig],
							 [SignedRequest URLEncode:[config accessToken]],
							 [SignedRequest URLEncode:body_sig]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setTimeoutInterval:10]; 
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:method];
	
	[request addValue:auth_header forHTTPHeaderField: @"Authorization"];
	if ([dict objectForKey:@"Accept-Type"] == nil)
		[request addValue:@"application/json" forHTTPHeaderField: @"Accept"];
	else 
		[request addValue:[dict objectForKey:@"Accept-Type"] forHTTPHeaderField: @"Accept"];
	
	if ([dict objectForKey:@"Content-Type"] == nil)
		[request addValue:@"application/json" forHTTPHeaderField: @"Content-type"];
	else 
		[request addValue:[dict objectForKey:@"Content-Type"] forHTTPHeaderField: @"Content-type"];
	
	[request addValue:[[NSURL URLWithString:url] host] forHTTPHeaderField: @"Host"];
	[request addValue:@"Ribbit_ObjectiveC" forHTTPHeaderField: @"User-Agent"];
	
	//	if(cookies) [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
	
	NSNumber *length = [NSNumber numberWithUnsignedInteger:[body length]];
	NSString *postLength = [length stringValue];		
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
//	urlRequest = request;
//	[self start];
	
	[self getDataWithRequest:request delegate:self
					didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
					  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}


-(NSString*) httpPostWithURI:(NSString *)uri username:(NSString*)username password:(NSString*)password {
	[self sendRequestWithURI:uri method:@"POST" 
						vars:nil username:username pass:password
				   outStream:nil acceptType:nil contentType:nil inStream:nil];
	return nil;
}
-(void) httpGetWithURI:(NSString *)uri {
	[self sendRequestWithURI:uri method:@"GET" 
						vars:NULL username:NULL pass:NULL 
				   outStream:NULL acceptType:[SignedRequest getAcceptTypeWithURI:uri] contentType:NULL inStream:NULL];
	
}
//-(void) httpPostWithURI:(NSString*)uri {
//	NSLog(@"httpPostWithURI no vars");
//	[self sendRequestWithURI:uri method:@"POST" 
//						vars:NULL username:NULL pass:NULL 
//				   outStream:NULL acceptType:NULL contentType:CONTENT_APPLICATION_JSON inStream:NULL];
//	
//}
-(void) httpDeleteWithURI:(NSString *)uri {
	[self sendRequestWithURI:uri method:@"DELETE" 
						vars:NULL username:NULL pass:NULL 
				   outStream:NULL acceptType:NULL contentType:NULL inStream:NULL];
	
}
-(void) httpPutWithURI:(NSString *)uri variables:(NSDictionary *)vars {
	[self sendRequestWithURI:uri method:@"PUT" 
						vars:vars username:NULL pass:NULL 
				   outStream:NULL acceptType:ACCEPT_APPLICATION_JSON contentType:CONTENT_APPLICATION_JSON	inStream:NULL];
	
}


-(void) sendRequestWithURI:(NSString*)uri method:(NSString*)method vars:(NSDictionary*)vars
				  username:(NSString*)username pass:(NSString*)pass outStream:(NSData*)outData acceptType:(NSString*)acceptType
			   contentType:(NSString*)contentType inStream:(NSData*)inData {
	NSLog(@"tt = %@", contentType);
	
	// Get full URL
	NSMutableString *fullUrl;
	if ([uri hasPrefix:@"http"]) 
		fullUrl = uri;
	else {
		fullUrl = [[NSMutableString alloc] initWithString:[config endpoint]];
		[fullUrl appendString:uri];
	}
	
	NSURL *url = [NSURL URLWithString:fullUrl];
	NSLog(@"full url = %@", url);
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:config.consumerKey secret:config.secretKey];
	
	// consider making this a helper function on RibbitConfig
	OAToken *accessToken = nil;
	if (config.accessToken != nil) {
		accessToken = [[OAToken alloc] initWithKey:config.accessToken secret:config.accessSecret];
	}
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:consumer 
																	  token:accessToken realm:@"http://oauth.ribbit.com" signatureProvider:nil];
	
	[request setHTTPMethod:method];
	NSLog(@" accept type %@", acceptType);
	NSLog(@" content type %@", contentType);
	if (acceptType != nil)
		[request addValue:acceptType forHTTPHeaderField:@"Accept"];
	if (contentType != nil)
		[request addValue:contentType forHTTPHeaderField:@"Content-type"];
	
	if (username != nil && pass != nil) {
		[request prepareWithUser:username password:pass];
	} else {
		[request prepare];
	}
	
	[request addValue:@"Ribbit-Objective-C" forHTTPHeaderField:@"User-Agent"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc]init];
	
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
	
	
}


-(void) sendLoginRequestWithURI:(NSString*)uri username:(NSString*)username pass:(NSString*)pass  {
	
	// Get full URL
	NSMutableString *fullUrl;
	if ([uri hasPrefix:@"http"]) 
		fullUrl = [[NSMutableString alloc] initWithString:uri];
	else {
		fullUrl = [[NSMutableString alloc] initWithString:[config endpoint]];
		[fullUrl appendString:uri];
	}
	
	NSURL *url = [NSURL URLWithString:fullUrl];
	NSLog(@"full url = %@", url);
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:config.consumerKey secret:config.secretKey];
	
	// consider making this a helper function on RibbitConfig
	OAToken *accessToken = nil;
	if (config.accessToken != nil) {
		accessToken = [[OAToken alloc] initWithKey:config.accessToken secret:config.accessSecret];
	}
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:consumer 
																	  token:accessToken realm:@"http://oauth.ribbit.com" signatureProvider:nil];
	
	[request setHTTPMethod:@"POST"];
	
	[request prepareWithUser:username password:pass];

	[request addValue:@"Ribbit-Objective-C" forHTTPHeaderField:@"User-Agent"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc]init];
	
	[fetcher fetchDataWithRequest:request delegate:self username:username password:pass
				didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
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
		self.response = responseBody;
	} else {

	}
	
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"ticket_request= %@", ticket.request);
	NSLog(@"ticket_response= %@", ticket.response);
    NSLog(@"error= %@", error);
}



+(NSString*) getAcceptTypeWithURI:(NSString*)uri {
	NSString *acceptType = ACCEPT_APPLICATION_JSON;
	if ([uri hasSuffix:@".mp3"]) {
		acceptType = ACCEPT_AUDIO_MPEG;
	} else if ([uri hasSuffix:@".wav"]) {
		acceptType = ACCEPT_AUDIO_WAV;
	} else if ([uri hasSuffix:@".txt"]) {
		acceptType = ACCEPT_APPLICATION_OCTET;
	}
	return acceptType;
}

-(NSString*) signForOAuthWithText:(NSString*) textToSign consumer:(OAConsumer*)consumer access:(OAToken*)token {
	OAHMAC_SHA1SignatureProvider *hmaSigner = [[OAHMAC_SHA1SignatureProvider alloc] init];
	NSLog(@"signer = %@", hmaSigner);

//	NSLog(@"secret = %@", secret);
	NSString *signature = [hmaSigner signClearText:textToSign
                                      withSecret:[NSString stringWithFormat:@"%@&%@",
												//  [SignedRequest urlEncode:consumer.secret],
												  [consumer.secret URLEncodedString],
												//  [SignedRequest urlEncode:token.secret]]];
                                                  [token.secret URLEncodedString]]];
	
	return signature;
}

-(NSString*) signForOAuthWithBody:(NSString *) bodyToSign {
	NSString *secret = [config secretKey];
	NSString *accessSecret = [config accessSecret];
	OAHMAC_SHA1SignatureProvider *hmaSigner = [[OAHMAC_SHA1SignatureProvider alloc] init];
	NSMutableString *withSec = [[NSMutableString alloc] initWithString:secret];
	[withSec appendString:@"&"];
	[withSec appendString:accessSecret];
	NSLog(@" withSec = %@", withSec);

	return [hmaSigner signBody:bodyToSign withSecret:withSec];
}

-(NSString*) normalizeURL:(NSString*)urlString {
	NSURL *url = nil;
	@try {
		url = [[NSURL alloc] initWithString:urlString];
	}
	@catch (NSException * e) {
		@throw [NSException
				exceptionWithName:@"URLFormatException"
				reason:@"Failed to normalize url"
				userInfo:nil]; 
	}
	NSLog(@"%@", [url absoluteURL]);
	//NSMutableString *sb = [[NSMutableString alloc] init];
	NSLog(@"%@", [url scheme]);
	// Evaluate later if we have to normalize in Objective-C
	return urlString;
}

-(NSString*)sign_for_oauth:(const char*)data {
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	const char *key = [[NSString stringWithFormat:@"%@&%@", [config secretKey],[config accessSecret]] UTF8String];
	//const char *key = [[NSString stringWithFormat:@"%@&%@",[RibbitPlatform secretKey],@"dbb9bfc64a0a60025105e4ffe6a31430"] UTF8String];
	
	CCHmac(kCCHmacAlgSHA1, key, strlen(key), data, strlen(data), result);
	return [SignedRequest Data_encodeBase64:[NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH]];
}

+ (NSString*)generate_nonce {
	//int length = 6; // e. 91FF5DF9-8E31-465E-80AD-C8A39DAA9277 8+4+4+4+12
	// this should be quite random enough.
	NSMutableString *nonce = [NSMutableString stringWithCapacity:37];
	int i;
	for(i=0;i<8;i++)
		[nonce appendString:[self random_char]];
	[nonce appendString:@"-"];
	for(i=0;i<4;i++)
		[nonce appendString:[self random_char]];
	[nonce appendString:@"-"];
	for(i=0;i<4;i++)
		[nonce appendString:[self random_char]];
	[nonce appendString:@"-"];
	for(i=0;i<4;i++)
		[nonce appendString:[self random_char]];
	[nonce appendString:@"-"];
	for(i=0;i<12;i++)
		[nonce appendString:[self random_char]];
	
	return nonce;
}

+ (NSString*)random_char {
	NSString *possible = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghijklmnopqrstuvwxyz";
	NSRange range;
	do { range.location = (rand() & 63); } while(range.location >= [possible length]);
	range.length = 1;
	return [possible substringWithRange:range];
}


+ (double)current_millis {
	double seconds = [[NSDate date] timeIntervalSince1970];
	return seconds;
}

+ (NSString*)Data_encodeBase64:(NSData*) data
{
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

+ (NSString*)URLEncode:(NSString*)data {
	NSMutableString * aux = [NSMutableString stringWithCapacity:5];
	NSInteger tamano = [data length];
	int i;
	for (i=0 ; i< tamano ; i++) {
		unichar achar = [data characterAtIndex:i];
		switch (achar) {
			case '$':
				[aux appendString:@"%24"]; // Dollar
				break;
			case '&':
				[aux appendString:@"%26"]; // Ampersand
				break;
			case '+':
				[aux appendString:@"%2B"]; // Plus
				break;
			case ',':
				[aux appendString:@"%2C"]; // Comma
				break;
			case '/':
				[aux appendString:@"%2F"]; // Forward slash/Virgule
				break;
			case ':':
				[aux appendString:@"%3A"]; // Colon
				break;
			case ';':
				[aux appendString:@"%3B"]; // Semi-colon
				break;
			case '=':
				[aux appendString:@"%3D"]; // Equals
				break;
			case '?':
				[aux appendString:@"%3F"]; // Question mark
				break;
			case '!':
				[aux appendString:@"%21"]; // Exclamation mark
				break;
			case '@':
				[aux appendString:@"%40"]; // 'At' symbol
				break;
			case '{':
				[aux appendString:@"%40"]; // Left Curly Brace
				break;
			case '}':
				[aux appendString:@"%7D"]; // Right Curly Brace
				break;
			case '|':
				[aux appendString:@"%7C"]; // Vertical Bar/Pipe
				break;
			case '\\':
				[aux appendString:@"%5C"]; // Backslash
				break;
			case '^':
				[aux appendString:@"%5E"]; // Caret
				break;
			case '~':
				[aux appendString:@"%7E"]; // Tilde
				break;
			case '[':
				[aux appendString:@"%5B"]; // Left Square Bracket
				break;
			case ']':
				[aux appendString:@"%5D"]; // Right Square Bracket
				break;
			case '`':
				[aux appendString:@"%60"]; // Grave Accent
				break;
			case '%':
				[aux appendString:@"%25"]; // Percent character
				break;
			case '#':
				[aux appendString:@"%23"]; // 'Pound' character
				break;
			case '"':
				[aux appendString:@"%22"]; // Quotation marks
				break;
			case '<':
				[aux appendString:@"%3C"]; // 'Less Than' symbol
				break;
			case '>':
				[aux appendString:@"%3E"]; // 'Greater Than' symbol
				break;
			case ' ':
				[aux appendString:@"%20"]; // Space
				break;
			case '\n':
				[aux appendString:@"%20"]; // line feed
				break;
			case '\r':
				[aux appendString:@"%20"]; // carriage return
				break;
			case '\t':
				[aux appendString:@"%20"]; // tab
				break;
				
			default:
				[aux appendFormat:@"%c",achar];
				break;
		}
	}
	return aux;    
}

+ (NSString*)titleForHTTPReturnNumber:(NSInteger)errorNum {
	switch (errorNum) {
		case 200: return @"OK";
		case 201: return @"Created";
		case 202: return @"Accepted";
		case 204: return @"No Content";
		case 400: return @"Bad Request";
		case 401: return @"Unauthorized";
		case 403: return @"Forbidden";
		case 404: return @"Not Found";
		case 405: return @"Method Not Allowed";
		case 409: return @"Conflict";
		case 412: return @"Precondition Failed";
		case 500: return @"Internal Server Error";
		default: return @"Unknown";
	}
}

+ (NSDate*)ribbitUTCToDate:(NSString*)ribbitUTC {
	if(ribbitUTC) {
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'ZZZ"];
		NSDate *formatterDate = [inputFormatter dateFromString:[ribbitUTC stringByAppendingString:@"+0000"]];
		[inputFormatter release];
		return formatterDate;
	} else {
		return nil;
	}
}

+ (NSDate*)ribbitUTCToTime:(NSString*)ribbitUTC {
	if(ribbitUTC) {
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"'HH:mm:ssZZZ"];
		NSDate *formatterDate = [inputFormatter dateFromString:[ribbitUTC stringByAppendingString:@"+0000"]];
		[inputFormatter release];
		return formatterDate;
	} else {
		return nil;
	}
}
- (void)getDataWithRequest:(NSMutableURLRequest *)aRequest 
					delegate:(id)aDelegate 
		   didFinishSelector:(SEL)finishSelector 
			 didFailSelector:(SEL)failSelector 
{
    urlRequest = aRequest;
    delegate = aDelegate;
    didFinishSelector = finishSelector;
    didFailSelector = failSelector;
    
	//    [request prepare];
    
    responseData = [NSURLConnection  sendSynchronousRequest:urlRequest
                                         returningResponse:&urlResponse
                                                     error:&error];
	[NSThread sleepForTimeInterval:10];
//	NSURLConnection *conx = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//	[conx start];
	
	
//	NSLog(@"response data = %@", responseData);
//	NSLog(@"my Data: %.*s", [responseData length], [responseData bytes]);
	
    if (error != nil) {
        OAServiceTicket *ticket= [[OAServiceTicket alloc] initWithRequest:urlRequest
                                                                 response:urlResponse
                                                               didSucceed:NO];
        [delegate performSelector:didFailSelector
                       withObject:ticket
                       withObject:error];
		
    } else {
        OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:urlRequest
                                                                  response:urlResponse
                                                                didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];
        [delegate performSelector:didFinishSelector
                       withObject:ticket
                       withObject:responseData];
    }   
}

@end
