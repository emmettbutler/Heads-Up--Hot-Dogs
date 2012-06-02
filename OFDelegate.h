#pragma once

#import "OpenFeint/OpenFeintDelegate.h"

@interface OFDelegate : NSObject< OpenFeintDelegate >

- (void)dashboardWillAppear;
- (void)dashboardDidAppear;
- (void)dashboardWillDisappear;
- (void)dashboardDidDisappear;
- (void)userLoggedIn:(NSString*)userId;
- (BOOL)showCustomOpenFeintApprovalScreen;

@end
