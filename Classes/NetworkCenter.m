//
//  NetworkCenter.m
//  PigLibrary
//
//  Created by Mahipal Raythattha on 11/13/09.
//  Copyright 2009. All rights reserved.
//

#import "NetworkCenter.h"

#if kEnableJsonParsing
#import "JSON.h"
#endif

@implementation NetworkCenter

@synthesize delegate;

+ (NSURLRequest *) newRequestWithServer: (NSString *) serverAddress
                                 method: (NSString *) method
                                   data: (NSDictionary *) dataDictionary
{
    NSURL *serverURL = [[NSURL alloc] initWithString:serverAddress];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:serverURL
                                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                    timeoutInterval:10.0];
    [serverURL release];
    [request setHTTPMethod:method];
    
    if ([method isEqualToString:@"POST"] && (dataDictionary != nil))
    {
        NSString *boundary = @"------AaB03x";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableString *postString = [[NSMutableString alloc] init];
        
        NSArray *inputKeys = [dataDictionary allKeys];
        for (int i = 0; i < [inputKeys count]; i++)
        {
            [postString appendFormat:@"--%@\r\n", boundary];
            [postString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [inputKeys objectAtIndex:i]];
            [postString appendFormat:@"%@", [dataDictionary objectForKey:[inputKeys objectAtIndex:i]]];        
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

+ (void) postVariables: (NSDictionary *) requestVariables
              toServer: (NSString *) serverAddress
          withDelegate: (id) delegate
{
    NSURLRequest *request = [NetworkCenter newRequestWithServer:serverAddress method:@"POST" data:requestVariables];
    
    // This call will begin loading the data for the request immediately.
    [NSURLConnection connectionWithRequest:request delegate:delegate];
    [request release];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        connectionToInfoMapping = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                            0,
                                                            &kCFTypeDictionaryKeyCallBacks,
                                                            &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}


- (void) getJsonFromServer: (NSString *) serverAddress
{
    NSURLRequest *request = [NetworkCenter newRequestWithServer:serverAddress method:@"GET" data:nil];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    NSMutableDictionary *connectionDictionary = [[NSMutableDictionary alloc] init];
    [connectionDictionary setObject:[NSMutableData data] forKey:@"receivedData"];    
    CFDictionaryAddValue(connectionToInfoMapping, connection, connectionDictionary);
    [connectionDictionary release];
}

- (void) postVariables: (NSDictionary *) requestVariables
              toServer: (NSString *) serverAddress
{
    NSURLRequest *request = [NetworkCenter newRequestWithServer:serverAddress method:@"POST" data:requestVariables];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    NSMutableDictionary *connectionDictionary = [[NSMutableDictionary alloc] init];
    [connectionDictionary setObject:[NSMutableData data] forKey:@"receivedData"];    
    CFDictionaryAddValue(connectionToInfoMapping, connection, connectionDictionary);
    [connectionDictionary release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *r = (NSHTTPURLResponse *) response;    
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
    // TODO: Add failure method to delegate.

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

#if kEnableJsonParsing
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
#endif
    
    [responseString release];
    CFDictionaryRemoveValue(connectionToInfoMapping, connection);
    [connection release];
}    

@end
