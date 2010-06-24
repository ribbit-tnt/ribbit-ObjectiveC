//
//  Resource.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import	"RibbitConfig.h"
#import <Foundation/Foundation.h>

@interface Resource : NSObject {

	RibbitConfig *config;
	
}
@property (nonatomic, retain) RibbitConfig *config;

@end
