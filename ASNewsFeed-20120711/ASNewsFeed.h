//
//  NewsFeed.h
//  News Feed
//
//  Created by Justin Gardner on 10/25/11.
//  Copyright (c) 2011 [adult swim]. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIDefs.h"

@class CustomBadge;
@class ASNewsFeedVC;

typedef enum {
    BadgePositionLeftTop,
    BadgePositionLeftBottom,
    BadgePositionRightTop,
    BadgePositionRightBottom
} BadgePosition;

//protocol for dismissing addSingleIssueVC with or w/o data
@protocol ASNewsFeedDataSource <NSObject>
@required
- (void)newsFeedDidLoadWithDataSource:(NSArray *)dataSource;
@end

@protocol ASNewsFeedVCDelegate <NSObject>
@required
- (void)newsFeedVCDidDisappear;
@end

@interface ASNewsFeed : NSObject {
    id <ASNewsFeedDataSource> newsFeedDataSource;
    id <ASNewsFeedVCDelegate> newsFeedVCDelegate;
    
@private
    //url for the news feed plist on adultswim servers
    NSString *newsFeedUrl;
    
    NSString *appId;
    //data object for temporarily holding the loaded plist data
    NSMutableData *newsFeedData;
    //dictionary constructed from the news feed plist
    NSMutableDictionary *newsFeedDict;
    //internal array for checking device/app restricted news plists
    NSMutableArray *internalDataSource;
    
    ASNewsFeedVC *newsFeedVC;
    
    //the apple style badge notification
    CustomBadge *badge;
    //integer of the amount of new items display for the badge
    int newItemsAmount;
    BOOL feedLoading;
}

@property (nonatomic, assign) id <ASNewsFeedDataSource> newsFeedDataSource;
@property (nonatomic, assign) id <ASNewsFeedVCDelegate> newsFeedVCDelegate;

@property (nonatomic, retain) NSString *newsFeedUrl;
@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSMutableData *newsFeedData;
@property (nonatomic, retain) NSMutableDictionary *newsFeedDict;
@property (nonatomic, retain) NSMutableArray *internalDataSource;

@property (nonatomic, retain) ASNewsFeedVC *newsFeedVC;

@property (nonatomic, retain) CustomBadge *badge;
@property (nonatomic) int newItemsAmount;

//the shared news feed manager accessed by the app. a singleton.
+ (ASNewsFeed *)sharedNewsFeedManager;

//configures the news feed with different values
//1. feedUrl - sets the url for the news feed.  is set to the default url when sharedNewsFeedManager is initialized. pass nil to leave it that way
//2. appId - sets what app is currently using this feed.  this is for us to broadcast specific news items to specific apps.
- (void)configureNewsFeedWithUrl:(NSString *)feedUrl appId:(NSString *)idStr;

//attaches apple style badge notification to a layer of the app's choice
//1. layer - the CALayer to attach the badge to
//2. position - which corner of the layer to place the badge
- (void)attachBadgeToLayer:(CALayer *)layer atPosition:(BadgePosition)badgePos;

//instructs the news feed to load the feed from the url
- (void)pullFeed;

//marks all items as read and clears the newsItemAmount var and updates the badge view
- (void)markItemsAsRead;

//loads the news feed view controller nib based on what device you're viewing the app on
- (void)initializeNewsFeedVC;

//returns a reference to the news feed view controller
- (id)getNewsFeedVC;

//calls the dismiss function for the news feed view controller
- (void)dismissNewsFeedVC;

@end
