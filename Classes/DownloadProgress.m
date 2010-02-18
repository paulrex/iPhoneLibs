//
//  DownloadProgress.m
//
//  Created by Mahipal Raythattha on 1/10/10.
//  Copyright 2010. All rights reserved.
//

#import "DownloadProgress.h"

@implementation DownloadProgress

@synthesize content_length;
@synthesize spinner;
@synthesize alert_view;
@synthesize progress_bar;

- (id) init
{
    self = [super init];
    if (self)
    {
        alert_view = [[UIAlertView alloc] initWithTitle:nil message:@"\n\nConnecting...\n\n" delegate:self
                                          cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(136, 30);
        [spinner startAnimating];
        [alert_view addSubview:spinner];
        [spinner release];
        
        progress_bar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progress_bar.center = CGPointMake(136, 94);
        progress_bar.progress = 0.0;
        [alert_view addSubview:progress_bar];
        [progress_bar release];
        
        content_length = 0;
    }
    return self;
}

- (NSString *) message
{
    return [alert_view.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) setMessage: (NSString *) new_message
{
    
}

- (void) add_downloaded_length: (float) x
{
    // The content length must be properly set before calling this function.
    if (content_length <= 0)
        return;
    
    downloaded_length += x;
    progress_bar.progress = downloaded_length / content_length;
}

- (void) dealloc
{
    [spinner removeFromSuperview];
    [progress_bar removeFromSuperview];
    [alert_view release];
    [super dealloc];
}

@end
