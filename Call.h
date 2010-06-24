//
//  Call.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import "Resource.h"
#import "RibbitConfig.h"
#import "CallLeg.h"
#import <Foundation/Foundation.h>


@interface Call : Resource {
	//CallStatus *status
    NSMutableArray *legs;
    NSString *callURI;
    NSString *callID;
    NSString *callerId;
    NSString *mode;
    NSString *announce;
    NSDate *startTime;
    NSDate *endTime;
    NSString *duration;
    BOOL *success;
    BOOL *active;
    BOOL *recording;
    BOOL *outbound;
    NSMutableArray *recordings;
	
	NSURLRequest *urlRequest;
	NSURLResponse *response;
	NSError *error;
	NSData *responseData;
	id delegate;
	SEL didFinishSelector;
	SEL didFailSelector;
}

@property (nonatomic, retain) NSMutableArray *legs;
@property (nonatomic, retain) NSString *callURI;
@property (nonatomic, retain) NSString *callID;
@property (nonatomic, retain) NSString *callerId;
@property (nonatomic, retain) NSString *mode;
@property (nonatomic, retain) NSString *announce;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, retain) NSString *duration;
@property (nonatomic) BOOL *success;
@property (nonatomic) BOOL *active;
@property (nonatomic) BOOL *recording;
@property (nonatomic) BOOL *outbound;
@property (nonatomic, retain) NSMutableArray *recordings;

/**
 Initializes a Ribbit object with a RibbitConfig
 @param ribbitConfig RibbitConfig object
 @returns an initialized object
 */
-(id)initWithConfig:(RibbitConfig*)ribbitConfig;
/**
 Initializes a Ribbit object with a RibbitConfig and a given dictionary
 @param dictionary the dictionary of settings to assign to the new object
 @param ribbitConfig RibbitConfig object
 @returns an initialized object
 */
-(id)initWithDictionary:(NSDictionary*)dictionary ribbitConfig:(RibbitConfig*)ribbitconfig;
/**
 Adds a CallLeg to the list of legs to be called when the call is initiated.
 @param leg the call leg to call
 */
-(void)addLeg:(CallLeg*)leg;
/**
 Starts a n-legged call.
 */
-(void)startCall;
/**
 Updates a call with the given dictionary
 @param dictionary the dictionary of settings to update the call
 */
-(void)updateCallWithDictionary:(NSDictionary*)dictionary;
/**
 Drops a call.
 */
-(void)dropCall;

@end
