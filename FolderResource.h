//
//  FolderResource.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface FolderResource : NSObject {
	NSString *resourceId;
    NSString *associatedApp;
    NSString *createdBy;
    NSDate *createdOn;
    NSMutableArray *readUsers; 
    NSMutableArray *writeUsers;
}

@property (nonatomic, retain) NSString *resourceId;
@property (nonatomic, retain) NSString *associatedApp;
@property (nonatomic, retain) NSString *createdBy;
@property (nonatomic, retain) NSDate *createdOn;
@property (nonatomic, retain) NSMutableArray *readUsers; 
@property (nonatomic, retain) NSMutableArray *writeUsers;

/**
 Initializes a Ribbit folder resource with a RibbitConfig and a given dictionary
 @param dict the dictionary of settings to assign to the new object
 @returns an initialized object
 */
-(id) initFromDict:(NSDictionary*)dict;
@end
