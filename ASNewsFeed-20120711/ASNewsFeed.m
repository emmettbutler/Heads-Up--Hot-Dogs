//
//  NewsFeed.m
//  News Feed
//
//  Created by Justin Gardner on 10/25/11.
//  Copyright (c) 2011 [adult swim]. All rights reserved.
//

#import "ASNewsFeed.h"
#import "CustomBadge.h"
#import "ASNewsFeedVC.h"
#import "UIDeviceHardware.h"

@interface ASNewsFeed (PrivateMethods)
//feed loading, reading, and parsing from the url
- (void)loadNewsFeed;
- (void)parseNewsFeed;
- (int)setupDataSource;

//feed saving and retrieval from the app's disk
- (void)archiveFeed;
- (void)archiveNewItemsAmount;
- (NSMutableDictionary *)loadArchivedFeed;
- (int)loadArchivedNewItemsAmount;

//feed display methods
- (void)updateBadge;

@end

@implementation ASNewsFeed

@synthesize badge, newsFeedUrl, appId, newsFeedData, newsFeedDict, newItemsAmount, newsFeedDataSource, newsFeedVCDelegate, newsFeedVC, internalDataSource;

#pragma mark - Singleton Stuff

static ASNewsFeed *sharedNewsFeedManager = nil;

- (id)init {
    self = [super init];
    
    if (self) {
        [sharedNewsFeedManager setBadge:[CustomBadge customBadgeWithString:nil withStringColor:[UIColor whiteColor]  withInsetColor:[UIColor redColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor whiteColor] withScale:1.0 withShining:NO]];
        
        [sharedNewsFeedManager setAppId:@""];
        
        [sharedNewsFeedManager setNewsFeedUrl:@"http://www.adultswim.com/mobile/tools/feeds/news.plist"];
    }
    
    return self;
}

+ (ASNewsFeed *)sharedNewsFeedManager {
    @synchronized(self) {
        if (sharedNewsFeedManager == nil) {
            self = [[self alloc] init]; // assignment not done here
        }
    }
    
    return sharedNewsFeedManager;
}

+ (id)alloc {
    @synchronized(self) {
        if (sharedNewsFeedManager == nil) {
            sharedNewsFeedManager = [super alloc];
            
            return sharedNewsFeedManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

#pragma mark - View methods

- (void)initializeNewsFeedVC {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [sharedNewsFeedManager setNewsFeedVC:[[[ASNewsFeedVC alloc] initWithNibName:@"ASNewsFeedVC_iPhone" bundle:nil] autorelease]];
    } else {
        [sharedNewsFeedManager setNewsFeedVC:[[[ASNewsFeedVC alloc] initWithNibName:@"ASNewsFeedVC_iPad" bundle:nil] autorelease]];
    }
}

- (id)getNewsFeedVC {
    return [sharedNewsFeedManager newsFeedVC];
}

- (void)dismissNewsFeedVC {
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        
        [[sharedNewsFeedManager newsFeedVC] dismissModalViewControllerAnimated:YES];
    }
    else {
        [[sharedNewsFeedManager newsFeedVC] dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Configuration methods

- (void)configureNewsFeedWithUrl:(NSString *)feedUrl appId:(NSString *)idStr {
    [sharedNewsFeedManager setNewsFeedUrl:feedUrl];
    [sharedNewsFeedManager setAppId:idStr];
}

- (void)attachBadgeToLayer:(CALayer *)layer atPosition:(BadgePosition)badgePos {
    //determines position for the badge
    switch (badgePos) {
        case BadgePositionRightTop:
            [[sharedNewsFeedManager badge] setCenter:CGPointMake([layer bounds].origin.x + [layer bounds].size.width, [layer bounds].origin.y)];
            
            break;
            
        case BadgePositionRightBottom:
            [[sharedNewsFeedManager badge] setCenter:CGPointMake([layer bounds].origin.x + [layer bounds].size.width, [layer bounds].origin.y + [layer bounds].size.height)];
            
            break;
            
        case BadgePositionLeftTop:
            [[sharedNewsFeedManager badge] setCenter:CGPointMake([layer bounds].origin.x, [layer bounds].origin.y)];
            
            break;
            
        case BadgePositionLeftBottom:
            [[sharedNewsFeedManager badge] setCenter:CGPointMake([layer bounds].origin.x, [layer bounds].origin.y + [layer bounds].size.height)];
            
            break;
            
        default:
            [[sharedNewsFeedManager badge] setCenter:CGPointMake([layer bounds].origin.x + [layer bounds].size.width, [layer bounds].origin.y)];
            
            break;
    }
    
    [sharedNewsFeedManager updateBadge];
    
    [layer addSublayer:[[sharedNewsFeedManager badge] layer]];
}

#pragma mark - Feed loading, reading, parsing methods

- (void)pullFeed {
    if (!feedLoading) {
        feedLoading = YES;
        [sharedNewsFeedManager loadNewsFeed];
    }
    
}

- (void)loadNewsFeed {
    // Create the request.
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[sharedNewsFeedManager newsFeedUrl]]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:15.0];
    // create the connection with the request and start loading the data
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // Calls parseNewsFeed when it loaded successfully
        [sharedNewsFeedManager setNewsFeedData:[NSMutableData data]];
    } else {
        //NSLog(@"Feed load - connection failed");
    }
}

- (void)parseNewsFeed {
    //properties for the property list serialization
    NSError *error = nil;
    NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
    
    //load archived feed for comparison
    NSMutableDictionary *loadedNewsFeedDict = [sharedNewsFeedManager loadArchivedFeed];
    //set up temp dict to hold the url loaded feed
    NSMutableDictionary *readNewsFeedDict = [NSMutableDictionary dictionaryWithDictionary:(NSMutableDictionary *)[NSPropertyListSerialization propertyListWithData:[sharedNewsFeedManager newsFeedData] options:(NSPropertyListReadOptions)NSPropertyListImmutable format:&format error:&error]];
    
    //turn the plist into a dictionary.  Only has one key/value pair initially (items / "all nodes in the feed")
    [sharedNewsFeedManager setNewsFeedDict:(NSMutableDictionary *)[NSPropertyListSerialization propertyListWithData:[sharedNewsFeedManager newsFeedData] options:(NSPropertyListReadOptions)NSPropertyListImmutable format:&format error:&error]];
    
    int newItemsAmountFromDataSource = [sharedNewsFeedManager setupDataSource];
    
    //determines how to save and display the loaded feed
    //if there's no previously archived news feed
    if (!loadedNewsFeedDict) {
        //NSLog(@"no previous news feed");
        
        //save the feed to the app's disk
        [sharedNewsFeedManager archiveFeed];
        
        //get the amount of items in the feed. (it's the first time you load the feed so all are new)
        [sharedNewsFeedManager setNewItemsAmount:newItemsAmountFromDataSource];
        
        //archive the new items amount
        [sharedNewsFeedManager archiveNewItemsAmount];
    }
    //if there's been a previously archived news feed
    else {
        //if archived dict and the news feed loaded are the same
        if ([loadedNewsFeedDict isEqualToDictionary:readNewsFeedDict]) {
            //NSLog(@"feed is the same");
            
            //get the news items amount from the archive
            [sharedNewsFeedManager setNewItemsAmount:[sharedNewsFeedManager loadArchivedNewItemsAmount]];
        }
        //if archived dict and the new feed loaded in are different
        else {
            //NSLog(@"feed is different");
            
            //save the feed to the app's disk
            [sharedNewsFeedManager archiveFeed];
            
            //archived array from the loaded dictionary
            NSMutableArray *loadedArray = [NSMutableArray arrayWithArray:[loadedNewsFeedDict objectForKey:@"items"]];
            //array from the newly read dictionary
            NSMutableArray *readArray = [NSMutableArray arrayWithArray:internalDataSource];
            
            //remove the items in read array that are already in loaded array
            [readArray removeObjectsInArray:loadedArray];
            
            int loadedAmnt = [sharedNewsFeedManager loadArchivedNewItemsAmount];
            
            //if the archived amount is greater than the amount in the new feed, use the archive number
            if (loadedAmnt > [readArray count]) {
                [sharedNewsFeedManager setNewItemsAmount:loadedAmnt];
            }
            else {
                [sharedNewsFeedManager setNewItemsAmount:[readArray count]];
            }
            
            //archive the new items amount
            [sharedNewsFeedManager archiveNewItemsAmount];
        }
    }
    
    [sharedNewsFeedManager updateBadge];
    
    //clear out the newsFeedData and internalDataSource
    [sharedNewsFeedManager setNewsFeedData:nil];
}

- (int)setupDataSource {
    //create an arrayed version of the news feed
    NSArray *newsFeedArray = [NSArray arrayWithArray:[[sharedNewsFeedManager newsFeedDict] objectForKey:@"items"]];
    
    [sharedNewsFeedManager setInternalDataSource:[[NSMutableArray alloc] init]];
    
    for (int i = 0; i < [newsFeedArray count]; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        for (NSString *key in [newsFeedArray objectAtIndex:i]) {
            [dict setObject:[[newsFeedArray objectAtIndex:i] objectForKey:key] forKey:key];
            //NSLog(@"key - %@", key);
            
            if ([key isEqualToString:@"devices"]) {
                NSString *devices = [NSString stringWithString:[[newsFeedArray objectAtIndex:i] objectForKey:key]];
                //NSLog(@"devices - %@", [devices lowercaseString]);
                
                if ([devices isEqualToString:@""]) {
                    //NSLog(@"for all devices");
                    goto inner;
                }
                
                NSString *currentDevice = [NSString stringWithString:[[UIDevice currentDevice] model]];
                currentDevice = [currentDevice stringByReplacingOccurrencesOfString:@" Simulator" withString:@""];
                currentDevice = [currentDevice stringByReplacingOccurrencesOfString:@" touch" withString:@""];
                currentDevice = [currentDevice stringByReplacingOccurrencesOfString:@" Touch" withString:@""];
                //NSLog(@"currentDevice - %@", currentDevice);
                
                NSRange textRange = [[devices lowercaseString] rangeOfString:[currentDevice lowercaseString]];
                
                if (textRange.location == NSNotFound) {
                    //NSLog(@"not for this device");
                    dict = nil;
                    [key release];
                    key = nil;
                    goto outer; // goes to after the dict is added to the datasource, but before the dict is released
                }
            }
            
            if ([key isEqualToString:@"apps"]) {
                NSString *apps = [NSString stringWithString:[[newsFeedArray objectAtIndex:i] objectForKey:key]];
                //NSLog(@"apps - %@", apps);
                
                if ([apps isEqualToString:@""]) {
                    //NSLog(@"for all apps");
                    goto inner;
                }
                
                NSString *currentApp = [NSString stringWithString:[sharedNewsFeedManager appId]];
                //NSLog(@"currentApp - %@", currentApp);
                
                NSRange textRange = [[apps lowercaseString] rangeOfString:[currentApp lowercaseString]];
                
                if (textRange.location == NSNotFound) {
                    //NSLog(@"not for this app");
                    dict = nil;
                    [key release];
                    key = nil;
                    goto outer; // goes to after the dict is added to the datasource, but before the dict is released
                }
            }
            
            inner:;
        
            [key release];
            key = nil;
        }
        
        [internalDataSource addObject:dict];
        [dict release];
        dict = nil;
        
        outer:;
    }
    
    newsFeedArray = nil;
    //NSLog(@"datasource = %@", internalDataSource);
    
    //call the delegate for alerting that the feed loaded
    [[sharedNewsFeedManager newsFeedDataSource] newsFeedDidLoadWithDataSource:internalDataSource];
    
    return [internalDataSource count];
}

#pragma mark - Feed Save/Load methods

- (void)encodeWithCoder:(NSCoder *)aCoder {
    //For each instance variable, archive it under its variable name
    [aCoder encodeObject:[sharedNewsFeedManager newsFeedDict] forKey:@"newsFeedDict"];
    [aCoder encodeInt:[sharedNewsFeedManager newItemsAmount] forKey:@"newItemsAmount"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    [super init];
    
    //For each instance variable that is archived, we decode it,
    //and pass it to our setters. Where it is retained
    [sharedNewsFeedManager setNewsFeedDict:[aDecoder decodeObjectForKey:@"newsFeedDict"]];
    [sharedNewsFeedManager setNewItemsAmount:[aDecoder decodeIntForKey:@"newItemsAmount"]];
    
    return self;
}

- (void)archiveFeed {
    //Get list of document directories in sandbox
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    //Append passed in file name to that directory, return it
    NSString *newsFeedPath = [documentDirectory stringByAppendingPathComponent:@"NewsFeed.data"];
    //create a temp dictionary for archiving the data
    NSMutableDictionary *newsFeedTempDict = [NSMutableDictionary dictionaryWithDictionary:[sharedNewsFeedManager newsFeedDict]];
    
    //archive it to file
    [NSKeyedArchiver archiveRootObject:newsFeedTempDict toFile:newsFeedPath];
    
    //NSLog(@"feed archived");
}

- (void)archiveNewItemsAmount {
    //Get list of document directories in sandbox
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    //Append passed in file name to that directory, return it
    NSString *newsFeedItemsAmountPath = [documentDirectory stringByAppendingPathComponent:@"NewsFeedItemAmount.data"];
    //create a temp integer for archiving the data
    int newsFeedTempItemAmount = [sharedNewsFeedManager newItemsAmount];
    
    //archive new items amount to file
    [NSKeyedArchiver archiveRootObject:[NSNumber numberWithInt:newsFeedTempItemAmount] toFile:newsFeedItemsAmountPath];
    
    //NSLog(@"newItemsAmount archived");
}

- (NSMutableDictionary *)loadArchivedFeed {
    //Get list of document directories in sandbox
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    //Append passed in file name to that directory, return it
    NSString *newsFeedPath = [documentDirectory stringByAppendingPathComponent:@"NewsFeed.data"];
    //create a temp dictionary for storing the loaded data
    NSMutableDictionary *newsFeedTempDict = [NSKeyedUnarchiver unarchiveObjectWithFile:newsFeedPath];
    
    //if there's a news feed that's been saved before
    //unarchive it into the newsFeedDict
    if (newsFeedTempDict) {
        //NSLog(@"loaded archived files: newsFeedTempDict");
        
        return newsFeedTempDict;
    }
    //otherwise return null
    else {
        //NSLog(@"no news feed to load");
        
        return nil;
    }
}

- (int)loadArchivedNewItemsAmount {
    //Get list of document directories in sandbox
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    //Append passed in file name to that directory, return it
    NSString *newsFeedItemsAmountPath = [documentDirectory stringByAppendingPathComponent:@"NewsFeedItemAmount.data"];
    //create a temp number object for storing the loaded data
    NSNumber *newsFeedTempItemAmount = [NSKeyedUnarchiver unarchiveObjectWithFile:newsFeedItemsAmountPath];
    
    //if there's a news feed that's been saved before
    //unarchive it into the newsFeedDict
    if (newsFeedTempItemAmount) {
        //NSLog(@"loaded archived files: newsFeedTempItemAmount");
        
        return [newsFeedTempItemAmount intValue];
    }
    //otherwise return 0
    else {
        //NSLog(@"no new items amount to load");
        
        return 0;
    }
}

#pragma mark - Feed Display methods

- (void)updateBadge {
    //set the badge text to the amount of items unread and update the badge's display
    [[sharedNewsFeedManager badge] setBadgeText:[NSString stringWithFormat:@"%d", [sharedNewsFeedManager newItemsAmount]]];
    [[sharedNewsFeedManager badge] setNeedsDisplay];
    
    //if the amount of new items is 0 or less, hide the badge, else show it
    if ([sharedNewsFeedManager newItemsAmount] <= 0) {
        [[sharedNewsFeedManager badge] setHidden:YES];
    }
    else {
        [[sharedNewsFeedManager badge] setHidden:NO];
    }
}

- (void)markItemsAsRead {
    [sharedNewsFeedManager setNewItemsAmount:0];
    
    [sharedNewsFeedManager updateBadge];
    
    [sharedNewsFeedManager archiveNewItemsAmount];
}

#pragma mark - NSURL connection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [[sharedNewsFeedManager newsFeedData] setLength:0];
    //NSLog(@"didReceiveResponse : %@", [sharedNewsFeedManager newsFeedData]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [[sharedNewsFeedManager newsFeedData] appendData:data];
    //NSLog(@"didReceiveData : %@", [sharedNewsFeedManager newsFeedData]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the connection, and the data object
    [connection release];
    
    feedLoading = NO;
    
    // inform the user
    //NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // do something with the data
    //NSLog(@"Feed load succeeded! Received %d bytes of data", [[sharedNewsFeedManager newsFeedData] length]);
    
    [sharedNewsFeedManager parseNewsFeed];
    
    // release the connection
    [connection release];
    
    feedLoading = NO;
}

- (void)dealloc {
    NSLog(@"dealloc");
    [[sharedNewsFeedManager newsFeedDict] release];
    sharedNewsFeedManager.newsFeedDict = nil;
    [[sharedNewsFeedManager newsFeedData] release];
    sharedNewsFeedManager.newsFeedData = nil;
    [internalDataSource release];
    internalDataSource = nil;
    
    [super dealloc];
}

@end

