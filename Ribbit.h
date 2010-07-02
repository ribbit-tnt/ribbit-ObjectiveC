//
//  Ribbit.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/7/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import "RibbitConfig.h"
#import "Call.h"
#import "Resource.h"
#import "Message.h"
#import "Device.h"
#import "User.h"
#import "JSON.h"
#import "SBJSON.h"
#import "Folder.h"
#import <Foundation/Foundation.h>


/**
 Class to represent a Ribbit object.
 */
@interface Ribbit : Resource {
	NSError *jsonerror;
	SBJSON *json;
	SBJSON *parser;
}
@property (retain) SBJSON *json;
@property (retain) SBJSON *parser;
@property (retain) NSError *jsonerror;
/**
 Initializes a Ribbit object with a RibbitConfig
 @param ribbitConfig RibbitConfig object
 @returns an initialized object
 */
-(id) initWithConfig:(RibbitConfig*)ribbitConfig;

/**
 Logs in using 2.5-legged OAuth with a username and password
 @param username the user's username
 @param password the user's password
 */
-(BOOL*)loginWithUsername:(NSString*)username password:(NSString*)password;

/**
 Logs out the user.
 */
-(void)logout;
//-(BOOL)checkAuthenticatedUser;
//-(NSString*)createUserAuthenticationWithURL:(NSString*) url;

/**
 Gets a folder object for the given name
 @param name the name of the folder to retrieve
 @returns a Folder object
 */
-(Folder*) getFolder:(NSString*)name;

/**
 Creates a folder object for the given name
 @param name the name of the folder to create
 @returns a Folder object
 */
-(Folder*) createFolder:(NSString*)name;
/**
 Gets a Device object for the given name
 @param deviceId the id of the device to retrieve
 @returns a Device object
 */
-(Device*) getDevice:(NSString*)deviceId;
/** 
 Creates a User object from a dictionary
 @param dictionary the dictionary describing the user to create
 @returns a User object
 */
-(User*) createUser:(NSDictionary*)dict;

/**
 Gets a User object for the given name
 @param userId the id of the user to retrieve
 @returns a User object
 */
-(User*) getUser:(NSString*)userId;

/**
 Gets a Call object for the given name
 @param callId the id of the call to retrieve
 @returns a Call object
 */
-(Call*) getCall:(NSString*)callId;

/**
 Gets a Message object for the given dictionary
 @param dict the dictionary describing the message to retrieve
 @returns a Message object
 */
-(Message*) getMessage:(NSDictionary*)dict;

/**
 Gets an array of existing calls
 @param dict the dictionary describing the calls to retrieve
 @returns an array of calls
 */
-(NSArray*) getCalls:(NSDictionary*)dict;

/**
 Gets an array of existing devices
 @returns an array of devices
 */
-(NSArray*) getDevices;

/**
 Gets an array of existing messages
 @returns an array of messages
 */
-(NSArray*) getMessagesFromFolder:(NSString*)folderName;

/**
 Gets an array of available services
 @returns an array of services
 */
-(NSArray*) getServices;

/**
 Gets an array of available users
 @returns an array of users
 */
-(NSArray*) getUsers;

/**
 Creates a new Call object.
 */
-(Call*) newCall;

/**
 Creates a new Message object.
 */
-(Message*) newMessage;
/**
 Creates a new device for the given dictionary
 @param dict the dictionary describing the device to create
 */
-(Device*) createDevice:(NSDictionary*)dict;
/**
  Asks the REST server to create an authentication request token, and returns a URL to which a user should navigate in order to approve it
  @param callbackUrl A URL to which the user should be returned
  @return A url to which a user should navigate to approve the application
 */
-(NSString*)createUserAuthenticationURLWithCallback:(NSString *)callbackURL;
/**
  Checks a previously created request token to see if has been accepted, and if so, configures the user session to use a valid access token and secret. At this point, Ribbit.isLoggedIn will be true.
  @return true if the user has accepted the request, false or an exception if they have not completed the approval
 */
-(BOOL) checkAuthenticatedUser;
@end
