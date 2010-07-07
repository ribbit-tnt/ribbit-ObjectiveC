//
//  Message.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/9/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import "Resource.h"
#import "RibbitConfig.h"
#import "MessageDestination.h"
#import <Foundation/Foundation.h>

@interface Message : Resource {
	NSString *title;
    NSString *body;
    NSString *userId;
    NSString *sender;
    NSString *messageId;
    NSString *from;
    NSString *mediaUri;
    NSMutableArray *mediaItems;
    NSDate *time;
    BOOL *newMessage;
    BOOL *urgentMessage;
    NSString *folder;
    NSMutableArray *recipients;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSString *messageId;
@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *mediaUri;
@property (nonatomic, retain) NSMutableArray *mediaItems;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic) BOOL *newMessage;
@property (nonatomic) BOOL *urgentMessage;
@property (nonatomic, retain) NSString *folder;
@property (nonatomic, retain) NSMutableArray *recipients;

/**
 Initializes a Ribbit object with a RibbitConfig
 @param ribbitConfig RibbitConfig object
 @returns an initialized object
 */
-(id)initWithConfig:(RibbitConfig*)ribbitconfig;
/**
 Initializes a Ribbit object with a RibbitConfig and a given dictionary
 @param dictionary the dictionary of settings to assign to the new object
 @param ribbitConfig RibbitConfig object
 @returns an initialized object
 */
-(id)initWithDictionary:(NSDictionary*)dictionary ribbitConfig:(RibbitConfig*)ribbitconfig;
/**
 Adds a new recipient.
 @param recipient the recipient to add
 */
-(void)addRecipient:(MessageDestination*)recipient;
/**
 Sends an SMS message
 */
-(void)sendSMS;
/**
 Updates a message with the given dictionary
 @param dictionary the dictionary of settings to update the message
 */
-(void)updateMessageWithDictionary:(NSMutableDictionary*)dictionary;
@end
