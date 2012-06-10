//
//  AppDelegate.h
//  sandbox
//
//  Created by Emmett Butler on 1/3/12.
//  Copyright NYU 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@class OFDelegate;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    OFDelegate *ofDelegate;
}

@property (nonatomic, retain) UIWindow *window;

@end
