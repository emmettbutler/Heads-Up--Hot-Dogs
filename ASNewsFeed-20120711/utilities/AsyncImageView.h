//
//  AsyncImageView.h
//  ASNewsFeedTest
//
//  Created by Justin Gardner on 3/28/12.
//  Copyright (c) 2012 [adult swim]. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIView {
    NSURLConnection* connection;
    NSMutableData* data;
    NSURL *urlData;
}

- (void)loadImageFromURL:(NSURL*)url; 

@end
