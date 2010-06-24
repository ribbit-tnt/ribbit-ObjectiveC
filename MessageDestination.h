//
//  MessageDestination.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Class to represent a Message recipient.
 */
@interface MessageDestination : NSObject {
	NSString *destination;
    NSString *status;
	
}

@property (nonatomic, retain) NSString *destination;
@property (nonatomic, retain) NSString *status;


@end
