//
//  DownloadProgress.h
//
//  Created by Mahipal Raythattha on 1/10/10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadProgress : NSObject
{
    // Progress tracking variables.
    float                   contentLength;
    float                   downloadedLength;
    
    // UIView components
    UIAlertView             *alertView;
    UIActivityIndicatorView *spinner;
    
    UIProgressView          *progressBar;
}

@property (nonatomic, assign) float     contentLength;

// These properties are not synthesized by the compiler.
// The accessor functions are manually written to allow access to the alertView.
@property (nonatomic, retain) NSString  *message;
@property (nonatomic, assign) BOOL      visible;

// This function is designed for use with any NSNetworkConnection delegate.

// First, examine the headers returned in connectionDidReceiveResponse:
// (see NetworkCenter.m for example) to get the full content length.
// Use that to set the contentLength instance variable of this object.

// Each call to connectionDidReceiveData will have one chunk of data,
// with corresponding length. Call this function with that data's length.
// This object will track progress and display it to the user with a progress bar.
- (void) addDownloadedLength: (float) x;

@end
