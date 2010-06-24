//
//  Service.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import "Resource.h"
#import "RibbitConfig.h"
#import <Foundation/Foundation.h>

@interface Service : Resource {
	NSString *serviceId;
	BOOL *active;
	NSString *status;
	BOOL *voicemail;
	NSString *serviceType;
	NSArray *folders;
}
@property (nonatomic, retain) NSString *serviceId;
@property (nonatomic) BOOL *active;
@property (nonatomic, retain) NSString *status;
@property (nonatomic) BOOL *voicemail;
@property (nonatomic, retain) NSString *serviceType;
@property (nonatomic, retain) NSArray *folders;

/**
 Initializes a Ribbit object with a RibbitConfig and a given dictionary
 @param dictionary the dictionary of settings to assign to the new object
 @param ribbitConfig RibbitConfig object
 @returns an initialized object
 */
-(id)initWithDictionary:(NSDictionary*)dictionary ribbitConfig:(RibbitConfig*)ribbitconfig;
/**
 Sets the folders on this service.
 @param folders the folders to assign to this service.
 todo implement
 */
-(void)setServiceFoldersWithFolders:(NSArray*)folders;
/**
 Clears the folders from this service.
 @todo implement
 */
-(void)clearServiceFolders;
/**
 Set the service as the voicemail transcription provider
 @param status the status to set
 */
-(void)setAsVoicemailTranscriptionProviderWithStatus:(BOOL)status;

@end
