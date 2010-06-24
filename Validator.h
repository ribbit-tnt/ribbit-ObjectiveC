//
//  Validator.h
//  OAuthConsumer
//
//  Created by James Williams on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface Validator : NSObject {

}

+(bool)isValidWithDate:(NSDate*)date;
+(bool)isValidWithString:(NSString*)value;
+(bool)isValidWithStringIfDefined:(NSString*)value;
+(bool)isValidWithDateIfDefined:(NSDate*)value;
+(bool)isValidWithBoolIfDefined:(BOOL*)value;

@end
