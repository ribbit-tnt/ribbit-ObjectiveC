//
//  CallLeg.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import "Resource.h"
#import <Foundation/Foundation.h>



@interface CallLeg : Resource {
	NSString *callID;
	NSString *callLegId;

    NSDate *startTime;
    NSDate *answerTime;
    NSDate *endTime;
    NSString *duration;
    NSString *mode;
    NSString *announce;
    bool *playing;
    bool *recording;
}
@property (nonatomic, retain) NSString *callID;
@property (nonatomic, retain) NSString *callLegId;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *answerTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, retain) NSString *duration;
@property (nonatomic, retain) NSString *mode;
@property (nonatomic, retain) NSString *announce;
@property (nonatomic) bool *playing;
@property (nonatomic) bool *recording;

/**
 Initializes a CallLeg object with a RibbitConfig and a given callId
 @param ribbitConfig RibbitConfig object
 @param callId the callId of the parent call
 @returns an initialized object
 */
-(id)initWithConfig:(RibbitConfig*)ribbitConfig callID:(NSString*)callId;
//-(void)transferLegTo:(NSString*)callId;
/**
 Updates a CallLeg with the given settings
 @param dictionary the call leg properties to set
 */
-(void)updateLegWithDictionary:(NSDictionary*)dictionary;

@end
