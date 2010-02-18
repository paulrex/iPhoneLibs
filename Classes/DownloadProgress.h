//
//  DownloadProgress.h
//
//  Created by Mahipal Raythattha on 1/10/10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DownloadProgress : NSObject
{
    float content_length;
    float downloaded_length;
    
    UIAlertView *alert_view;
    UIActivityIndicatorView *spinner;
    
    UIProgressView *progress_bar;
}

@property (nonatomic, assign) float content_length;
@property (nonatomic, retain) UIAlertView *alert_view;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UIProgressView *progress_bar;

@property (nonatomic, retain) NSString *message;

- (void) add_downloaded_length: (float) x;

@end
