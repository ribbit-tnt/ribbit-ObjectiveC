//
//  Folder.h
//  OAuthConsumer
//
//  Created by Ribbit Corporation on 5/12/10.
//  Copyright 2010 Ribbit Corporation. All rights reserved.
//


#import "Resource.h"
#import "FolderResource.h"
#import <Foundation/Foundation.h>


@interface Folder : Resource {
  NSString *folderName;
  NSMutableArray *files;
}

@property (nonatomic, retain) NSString *folderName;
@property (nonatomic, retain) NSMutableArray *files;

/**
 Initializes a Ribbit object with a RibbitConfig
 @param ribbitConfig RibbitConfig object
 @returns an initialized object
 */
-(id)initWithConfig:(RibbitConfig*)ribbitConfig;
/**
 Initialize a folder object from JSON.
 @param values an array of dictionary values
 */
-(void) fromJSON:(NSArray*)values;
/**
 Removes the file of the given name
 @param filename the name of the file to remove
 */
-(void) removeFileWithFilename:(NSString*) filename;

/**
 Retrieves the text of a file
 @param filename the name of the file to retrieve
 @returns the NSString contents of the file
 */
-(NSString*) getFileTextWithFilename:(NSString*) filename;
/**
 Removes this folder object.
 */
-(void) removeFolder;

@end
