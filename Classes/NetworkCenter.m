//
//  NetworkCenter.m
//  PigLibrary
//
//  Created by Mahipal Raythattha on 11/13/09.
//  Copyright 2009. All rights reserved.
//

#import "NetworkCenter.h"
#import "JSON.h"

@implementation NetworkCenter

@synthesize delegate;

+ (NSURLRequest *) new_request_with_server: (NSString *) server_string and_method: (NSString *) method
                                  and_data: (NSDictionary *) data_dictionary
{
    NSURL *server_url = [[NSURL  alloc] initWithString:server_string];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:server_url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    [server_url release];
    [request setHTTPMethod:method];
    
    if ([method isEqualToString:@"POST"] && (data_dictionary != nil))
    {
        NSString *boundary = @"------AaB03x";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableString *postString = [[NSMutableString alloc] init];
        
        NSArray *inputKeys = [data_dictionary allKeys];
        for (int i = 0; i < [inputKeys count]; i++)
        {
            [postString appendFormat:@"--%@\r\n", boundary];
            [postString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [inputKeys objectAtIndex:i]];
            [postString appendFormat:@"%@", [data_dictionary objectForKey:[inputKeys objectAtIndex:i]]];        
            [postString appendFormat:@"\r\n"];
        }
        [postString appendFormat:@"--%@--\r\n", boundary];
        
        NSMutableData *postData = [NSMutableData data];
        [postData appendData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];
        [postString release];
    }
    return request;
}

+ (void) post_variables: (NSDictionary *) requestVariables to_address: (NSString *) serverAddress with_delegate: (id) delegate
{
    NSURLRequest *request = [NetworkCenter new_request_with_server:serverAddress and_method:@"POST" and_data:requestVariables];
    
    [NSURLConnection connectionWithRequest:request delegate:delegate];
    [request release];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        connectionToInfoMapping = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks,
                                                            &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}


- (void) get_json_from_server: (NSString *) server_string
{
    NSURLRequest *request = [NetworkCenter new_request_with_server:server_string and_method:@"GET" and_data:nil];    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    NSMutableDictionary *connectionDictionary = [[NSMutableDictionary alloc] init];
    [connectionDictionary setObject:[NSMutableData data] forKey:@"receivedData"];    
    CFDictionaryAddValue(connectionToInfoMapping, connection, connectionDictionary);
    [connectionDictionary release];
}

- (void) post_variables: (NSDictionary *) request_variables to_address: (NSString *) server_address
{
    NSURLRequest *request = [NetworkCenter new_request_with_server:server_address and_method:@"POST" and_data:request_variables];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    NSMutableDictionary *connectionDictionary = [[NSMutableDictionary alloc] init];
    [connectionDictionary setObject:[NSMutableData data] forKey:@"receivedData"];    
    CFDictionaryAddValue(connectionToInfoMapping, connection, connectionDictionary);
    [connectionDictionary release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    DebugLog(@"response = %@", response);
    NSHTTPURLResponse *r = (NSHTTPURLResponse *) response;
    DebugLog(@"status code = %d", [r statusCode]);
    DebugLog(@"%@", [r allHeaderFields]);
    
    if ([r statusCode] != 200)
    {
        [connection cancel];
        CFDictionaryRemoveValue(connectionToInfoMapping, connection);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableDictionary *connectionInfo = (NSMutableDictionary *) CFDictionaryGetValue(connectionToInfoMapping, connection);
    [[connectionInfo objectForKey:@"receivedData"] appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DebugLog(@"error = %@", error);
    
    NSMutableDictionary *connectionInfo = (NSMutableDictionary *) CFDictionaryGetValue(connectionToInfoMapping, connection);
    [[connectionInfo objectForKey:@"receivedData"] setData:nil];
    
    // Fail silently.

    /*
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                         message:[NSString stringWithFormat:@"%@", error]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
     */
    
    CFDictionaryRemoveValue(connectionToInfoMapping, connection);
    [connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *connectionInfo = (NSMutableDictionary *) CFDictionaryGetValue(connectionToInfoMapping, connection);
    
    NSString *responseString = [[NSString alloc] initWithData:[connectionInfo objectForKey:@"receivedData"]
                                                     encoding:NSUTF8StringEncoding];

    SBJSON *jsonParser = [SBJSON new];
    
    NSError *parseError;
    NSDictionary *returnDictionary = (NSDictionary *) [jsonParser objectWithString:responseString error:&parseError];
    
    if (returnDictionary == nil)
    {
        DebugLog(@"%@", responseString);
        DebugLog(@"%@", [parseError userInfo]);
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(connection_returned_json:)])
        [self.delegate connection_returned_json:returnDictionary];
    
    CFDictionaryRemoveValue(connectionToInfoMapping, connection);
    [connection release];
}    

@end
