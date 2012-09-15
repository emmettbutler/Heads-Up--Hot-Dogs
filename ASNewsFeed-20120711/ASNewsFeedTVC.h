//
//  ASNewsFeedTVC.h
//  ASNewsFeedTest
//
//  Created by Justin Gardner on 3/6/12.
//  Copyright (c) 2012 [adult swim]. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDeviceHardware.h"

@class ASNewsFeed;
@class ASNewsFeedTVCell;

@interface ASNewsFeedTVC : UITableViewController {
    ASNewsFeed *sharedNewsFeedManager;
    
    NSMutableArray *newsFeedArray;
    
    UITableViewCell *newsFeedCell;
    
    UIDeviceHardware *deviceManager;
}

- (id)initWithDataSource:(NSMutableArray *)dataSource;

@property (nonatomic, assign) IBOutlet UITableViewCell *newsFeedCell;

@end
