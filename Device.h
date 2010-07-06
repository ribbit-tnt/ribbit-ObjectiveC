//
//  Device.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/13/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import "Resource.h"
#import <Foundation/Foundation.h>

@interface Device : Resource {
	NSString *deviceId, *label, *name, *carrier, *key, *verifyBy;
    BOOL *verified, *callme, *notifyvm, *notifytranscription, *attachmessage, *useWAV;
    BOOL *callbackreachme, *mailtext, *shared, *notifymissedcall, *answersecurity;
    BOOL *showcalled, *ringstatus, *autoAnswer, *allowCCF;
}

@property (nonatomic, retain) NSString *deviceId, *label, *name, *carrier, *key, *verifyBy;
@property BOOL *verified, *callme, *notifyvm, *notifytranscription, *attachmessage, *useWAV;
@property BOOL *callbackreachme, *mailtext, *shared, *notifymissedcall, *answersecurity;
@property BOOL *showcalled, *ringstatus, *autoAnswer, *allowCCF;

/**
 Initializes a Ribbit object with a RibbitConfig and a given dictionary
 @param dictionary the dictionary of settings to assign to the new object
 @param ribbitConfig RibbitConfig object
 @returns an initialized object
 */
-(id)initWithDictionary:(NSDictionary*)dictionary ribbitConfig:(RibbitConfig*)ribbitconfig;
/**
 Removes this device.
 */
-(void)removeDevice;
/**
 Updates a call with the given dictionary
 @param dictionary the dictionary of settings to update the call
 */
-(void) updateDeviceWithDictionary:(NSMutableDictionary*)dict;

/**
 Returns a NSString representing the device id
 @returns the device id
 */
-(NSString*)deviceId;

@end
