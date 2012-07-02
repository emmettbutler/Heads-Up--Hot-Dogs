//
//  AppDelegate.h
//  sandbox
//
//  Created by Emmett Butler on 1/3/12.
//  Copyright NYU 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimpleAudioEngine.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    NSUserDefaults *standardUserDefaults;
}

@property (nonatomic, retain) UIWindow *window;

@end
