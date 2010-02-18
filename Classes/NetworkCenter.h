//
//  NetworkCenter.h
//  PigLibrary
//
//  Created by Mahipal Raythattha on 11/13/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkCenterDelegate <NSObject>

@optional

- (void) connection_returned_json: (NSDictionary *) return_dictionary;

@end


@interface NetworkCenter : NSObject
{
    id<NetworkCenterDelegate> delegate;
    CFMutableDictionaryRef connectionToInfoMapping;
}

@property (nonatomic, assign) id<NetworkCenterDelegate> delegate;

+ (NSURLRequest *) new_request_with_server: (NSString *) server_string
                                and_method: (NSString *) method
                                  and_data: (NSDictionary *) data_dictionary;

+ (void) post_variables: (NSDictionary *) requestVariables
             to_address: (NSString *) serverAddress
          with_delegate: (id) delegate;

- (id) init;
- (void) get_json_from_server: (NSString *) server_string;
- (void) post_variables: (NSDictionary *) request_variables to_address: (NSString *) server_address;

@end
