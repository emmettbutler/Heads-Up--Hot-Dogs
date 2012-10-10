//
//  ASNewsFeedVC.m
//  ASNewsFeed
//
//  Created by Justin Gardner on 3/6/12.
//  Copyright (c) 2012 [adult swim]. All rights reserved.
//

#import "ASNewsFeedVC.h"
#import "ASNewsFeedTVC.h"

@implementation ASNewsFeedVC

@synthesize backgroundImage, headerImage, footerImage, closeButton, loadingImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //sets the shared news feed manager up for use in this class
        sharedNewsFeedManager = [ASNewsFeed sharedNewsFeedManager];
        //set the data source for capturing the finished pull feed observer
        [sharedNewsFeedManager setNewsFeedDataSource:self];
        
        //pull the feed from the internets
        [sharedNewsFeedManager pullFeed];
        
        deviceManager = [UIDeviceHardware deviceManager];
    }
    return self;
}

//observer defined in ASNewsFeed.h for letting the app know the data is loaded and parsed
- (void)newsFeedDidLoadWithDataSource:(NSMutableArray *)dataSource {
    if ([self.view.subviews containsObject:[[self view] viewWithTag:1]]) {
        [loadingImage removeFromSuperview];
    }

    //set up local news feed array with data
    newsFeedArray = nil;
    newsFeedArray = dataSource;
    [newsFeedArray retain];
    [dataSource release];
    
    CGRect tvcRect;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
 
    //release me later
    newsFeedTVC = [[ASNewsFeedTVC alloc] initWithDataSource:newsFeedArray];
    
    tvcRect = CGRectMake(0.0f, 0.0f, screenBounds.size.width, [newsFeedTVC view].frame.size.height);
    
    int orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == 1 || orientation == 2) {
        
    }
    //is landscape
    else {
        if (screenBounds.size.width == 320.0f) {
            tvcRect.size.width = 480.0;
        }
        //if ipad
        else {
            tvcRect.size.width = 1024.0f;
        }
        tvcRect.size.height = [newsFeedTVC view].frame.size.height - 200.0;
    }
    
    [[newsFeedTVC view] setFrame:tvcRect];
    //DLog(@"newsFeedTVC frame: %f, %f, %f, %f", [[newsFeedTVC view] frame].origin.x, [[newsFeedTVC view] frame].origin.y, [[newsFeedTVC view] frame].size.width, [[newsFeedTVC view] frame].size.height);
    [self.view insertSubview:[newsFeedTVC view] belowSubview:headerImage];
    
}

- (IBAction)closeNewsFeed {
    [sharedNewsFeedManager dismissNewsFeedVC];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == 1 || orientation == 2) {
        backgroundImage.image = [UIImage imageNamed:@"asnf-background.jpg"];
        headerImage.image = [UIImage imageNamed:@"asnf-header.png"];
        footerImage.image = [UIImage imageNamed:@"asnf-footer.png"];
    }
    else {
        backgroundImage.image = [UIImage imageNamed:@"asnf-background-h.jpg"];
        headerImage.image = [UIImage imageNamed:@"asnf-header-h.png"];
        footerImage.image = [UIImage imageNamed:@"asnf-footer-h.png"];
    }
    
    loadingImage.alpha = 0.7;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationRepeatCount:100];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    loadingImage.alpha = 1;
    [UIView commitAnimations];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[sharedNewsFeedManager newsFeedVCDelegate] newsFeedVCDidDisappear];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    [newsFeedTVC release];
    newsFeedTVC = nil;
    
    [sharedNewsFeedManager setNewsFeedDataSource:nil];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

//handles rotating while viewing news feed
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [[newsFeedTVC tableView] reloadData];
    
    int orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == 1 || orientation == 2) {
        backgroundImage.image = [UIImage imageNamed:@"asnf-background.jpg"];
        headerImage.image = [UIImage imageNamed:@"asnf-header.png"];
        footerImage.image = [UIImage imageNamed:@"asnf-footer.png"];
    }
    else {
        backgroundImage.image = [UIImage imageNamed:@"asnf-background-h.jpg"];
        headerImage.image = [UIImage imageNamed:@"asnf-header-h.png"];
        footerImage.image = [UIImage imageNamed:@"asnf-footer-h.png"];
    }
}

@end
