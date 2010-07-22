//
//  SignedRequest.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import "RibbitConfig.h"
#import "OAConsumer.h"
#import	"OAToken.h"
#import <Foundation/Foundation.h>


#define ENCODING  @"UTF-8"
#define ACCEPT_APPLICATION_JSON	@"application/json"
#define CONTENT_APPLICATION_JSON	@"application/json"
#define ACCEPT_APPLICATION_OCTET	@"application/octet-stream"
#define CONTENT_APPLICATION_OCTET	@"application/octet-stream"
#define ACCEPT_AUDIO_MPEG	@"audio/mpeg"
#define ACCEPT_AUDIO_WAV	@"audio/wav"


@interface SignedRequest : NSObject {
	RibbitConfig *config;
	NSString *realm;
	
	NSNumber *timestamp;
	NSString *response;
	NSMutableData *data;
	
	NSURLRequest *urlRequest;
	NSURLResponse *urlResponse;
	NSError *error;
	NSData *responseData;
	id delegate;
	SEL didFinishSelector;
	SEL didFailSelector;

}
@property (nonatomic, retain) RibbitConfig *config;
@property (nonatomic, retain) NSString *realm;
@property (nonatomic, retain) NSString *response;

-(id)init;
-(id)initWithConfig:(RibbitConfig*)ribbitConfig;
-(id)initWithRealm:(NSString*)realmString andConfig:(RibbitConfig*)ribbitConfig;
//Refactor of requests
-(void)httpRequestWithDictionary:(NSDictionary*)dict;



-(void)httpGetWithURI:(NSString*)uri;
-(void)httpDeleteWithURI:(NSString*)uri;
	
-(void) sendRequestWithURI:(NSString*)uri method:(NSString*)method vars:(NSDictionary*)vars
					   username:(NSString*)username pass:(NSString*)pass outStream:(NSData*)outData acceptType:(NSString*)acceptType
					   contentType:(NSString*)contentType inStream:(NSData*)inData;
-(void) sendLoginRequestWithURI:(NSString *)uri username:(NSString *)username pass:(NSString *)pass;
+(NSString*) getAcceptTypeWithURI:(NSString*)uri;
+ (NSString*)Data_encodeBase64:(NSData*) data;
-(NSString*) normalizeURL:(NSString *)urlString;
-(NSString*) signForOAuthWithBody:(NSString *) bodyToSign;
-(NSString*) signForOAuthWithText:(NSString*) textToSign consumer:(OAConsumer*)consumer access:(OAToken*)token;
-(void)getDataWithRequest:(NSMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector; 

+ (NSDate*)ribbitUTCToTime:(NSString*)ribbitUTC;
+ (NSDate*)ribbitUTCToDate:(NSString*)ribbitUTC;
+ (NSString*)titleForHTTPReturnNumber:(NSInteger)errorNum;
+ (NSString*)URLEncode:(NSString*)data;
+ (NSString*)Data_encodeBase64:(NSData*)data;
+ (NSString*)generate_nonce;
+ (NSString*)random_char;
+ (double)current_millis;
-(NSString*)sign_for_oauth:(const char*)data;

@end
