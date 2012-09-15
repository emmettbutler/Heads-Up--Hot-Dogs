//
//  ASNewsFeedVC.h
//  ASNewsFeed
//
//  Created by Justin Gardner on 3/6/12.
//  Copyright (c) 2012 [adult swim]. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASNewsFeed.h"
#import "UIDeviceHardware.h"

@class ASNewsFeedTVC;

@interface ASNewsFeedVC : UIViewController <ASNewsFeedDataSource> {
    //custom table view controller for the news feed
    ASNewsFeedTVC *newsFeedTVC;
    
    //the shared news feed manager object
    ASNewsFeed *sharedNewsFeedManager;
    
    //an array to hold the news feed info
    NSMutableArray *newsFeedArray;
    
    //background image of the news feed view controller
    UIImageView *backgroundImage;
    UIImageView *headerImage;
    UIImageView *footerImage;
    UIButton *closeButton;
    UIImageView *loadingImage;
    
    UIDeviceHardware *deviceManager;
}

@property (nonatomic, assign) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, assign) IBOutlet UIImageView *headerImage;
@property (nonatomic, assign) IBOutlet UIImageView *footerImage;
@property (nonatomic, assign) IBOutlet UIButton *closeButton;
@property (nonatomic, assign) IBOutlet UIImageView *loadingImage;

- (IBAction)closeNewsFeed;

@end
