//
//  NetworkCenter.h
//  PigLibrary
//
//  Created by Mahipal Raythattha on 11/13/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEnableJsonParsing 0

@protocol NetworkCenterDelegate <NSObject>

@optional

- (void) connectionReturnedJson: (NSDictionary *) return_dictionary;

@end

// This object can handle multiple network connections.
// It comes with various utility methods for communication via HTTP requests.

@interface NetworkCenter : NSObject
{
    id<NetworkCenterDelegate> delegate;
    CFMutableDictionaryRef connectionToInfoMapping;
}

@property (nonatomic, assign) id<NetworkCenterDelegate> delegate;

// Allocates and returns a new NSURLRequest with the specified variables.
// Currently, the dataDictionary is only supported for POST requests.
// TODO: Support dataDictionary for GET requests via URL encoding of variables.
+ (NSURLRequest *) newRequestWithServer: (NSString *) serverAddress
                                 method: (NSString *) method
                                   data: (NSDictionary *) dataDictionary;

// Creates and POSTs a request to the given address, setting a delegate if given.
+ (void) postVariables: (NSDictionary *) requestVariables
              toServer: (NSString *) serverAddress
          withDelegate: (id) delegate;

// Standard initialization method.
- (id) init;

// Sends a GET request to the given address, expecting a JSON response.
// Upon receipt, this object will call the connectionReturnedJson method of its delegate.
- (void) getJsonFromServer: (NSString *) serverAddress;

// Sends a POST request to the given address, with requestVariables attached.
// If JSON response is received, this object calls the delegate's connectionReturnedJson method.
- (void) postVariables: (NSDictionary *) requestVariables
              toServer: (NSString *) serverAddress;

@end
