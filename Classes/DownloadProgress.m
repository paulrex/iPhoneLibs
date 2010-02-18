//
//  DownloadProgress.m
//
//  Created by Mahipal Raythattha on 1/10/10.
//  Copyright 2010. All rights reserved.
//

#import "DownloadProgress.h"

@implementation DownloadProgress

@synthesize contentLength;

- (id) init
{
    self = [super init];
    if (self)
    {
        alertView = [[UIAlertView alloc] initWithTitle:nil
                                                message:@"\n\nConnecting...\n\n"
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:nil];
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(136, 30);
        [spinner startAnimating];
        [alertView addSubview:spinner];
        [spinner release];
        
        progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressBar.center = CGPointMake(136, 94);
        progressBar.progress = 0.0;
        [alertView addSubview:progressBar];
        [progressBar release];
        
        contentLength = 0;
    }
    return self;
}

- (void) addDownloadedLength: (float) x
{
    // The content length must be properly set before calling this function.
    if (contentLength <= 0)
        return;
    
    downloadedLength += x;
    progressBar.progress = downloadedLength / contentLength;
}

// Below: manually written accessor functions.
- (NSString *) message
{
    return [alertView.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) setMessage: (NSString *) newMessage
{
    NSString *formattedMessage = [[NSString alloc] initWithFormat:@"\n\n%@\n\n", newMessage];
    alertView.message = formattedMessage;
    [formattedMessage release];
}

- (BOOL) visible
{
    return alertView.visible;
}

- (void) setVisible: (BOOL) newVisibility
{
    // Check to see if we need to do anything.
    if (alertView.visible && newVisibility) return;
    if (!alertView.visible && !newVisibility) return;
    
    // If so, show / hide the alertView as needed.
    if (newVisibility) [alertView show];
    if (!newVisibility) [alertView dismissWithClickedButtonIndex:-1 animated:YES];
}


- (void) dealloc
{
    [spinner removeFromSuperview];
    [progressBar removeFromSuperview];
    [alertView release];
    [super dealloc];
}

@end
