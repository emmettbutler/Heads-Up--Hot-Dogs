//
//  ASNewsFeedTVC.m
//  ASNewsFeedTest
//
//  Created by Justin Gardner on 3/6/12.
//  Copyright (c) 2012 [adult swim]. All rights reserved.
//

#import "ASNewsFeedTVC.h"
#import "ASNewsFeed.h"
#import "ASNewsFeedTVCell.h"
#import "UIDeviceHardware.h"
#import "LearnMoreButton.h"
#import "AsyncImageView.h"

#define TITLE_HEIGHT 21.0f
#define DESCRIPTION_HEIGHT 54.0f
#define LABEL_WIDTH 279.0f

@implementation ASNewsFeedTVC

@synthesize newsFeedCell;

- (id)initWithDataSource:(NSMutableArray *)dataSource {
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        sharedNewsFeedManager = [ASNewsFeed sharedNewsFeedManager];
        deviceManager = [UIDeviceHardware deviceManager];
        
        //newsFeedArray = dataSource;
        newsFeedArray = nil;
        newsFeedArray = dataSource;
        [newsFeedArray retain];
        [dataSource release];
        
        NSLog(@"news - %@", newsFeedArray);
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.opaque = NO;
        self.tableView.backgroundView = nil;
        self.tableView.separatorColor = [UIColor clearColor];
        
        //NSLog(@"init: %f, %f, %f, %f", [self.tableView frame].origin.x, [self.tableView frame].origin.y, [self.tableView frame].size.width, [self.tableView frame].size.height);
        
        [[self tableView] reloadData];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)openURL:(id)sender {
    if ([sender isKindOfClass:[LearnMoreButton class]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[(LearnMoreButton *)sender urlString]]];
    }
}

- (void)closeNewsFeed:(id)sender {
    [sharedNewsFeedManager dismissNewsFeedVC];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [newsFeedArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"ASNewsFeedTVC";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ASNewsFeedTVCell" owner:self options:nil];
        cell = newsFeedCell;
        self.newsFeedCell = nil;
    }
    else {
        AsyncImageView *oldImage = (AsyncImageView*)
        [cell.contentView viewWithTag:999];
        [oldImage removeFromSuperview];
    }
    
    UILabel *title, *description, *date;
    //UIImageView *image;
    LearnMoreButton *learnMoreButton;
    
    title = (UILabel *)[cell viewWithTag:2];
    title.text = [[newsFeedArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    description = (UILabel *)[cell viewWithTag:5];
    description.text = [[newsFeedArray objectAtIndex:indexPath.row] objectForKey:@"description"];
    
    date = (UILabel *)[cell viewWithTag:1];
    date.text = [[newsFeedArray objectAtIndex:indexPath.row] objectForKey:@"date"];
    
    CGRect frame;
    frame.size.width=175; frame.size.height=78;
    frame.origin.x=0; frame.origin.y=0;
    AsyncImageView *asyncImage = [[[AsyncImageView alloc] initWithFrame:frame] autorelease];
    
    asyncImage.tag = 999;
    NSURL *url = [NSURL URLWithString:[[newsFeedArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
    [asyncImage loadImageFromURL:url];
    
    [[cell viewWithTag:4] addSubview:asyncImage];
       
    learnMoreButton = (LearnMoreButton *)[cell viewWithTag:6];
    learnMoreButton.urlString = [[newsFeedArray objectAtIndex:indexPath.row] objectForKey:@"url"];
    [learnMoreButton addTarget:self action:@selector(openURL:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize constraint = CGSizeMake(LABEL_WIDTH, 20000.0f);
    //NSLog(@"constraint size - %f, %f", constraint.width, constraint.height);
    
    //frame is relative to the container
    //NSLog(@"\ntitle:\nx: %f\ny: %f\nwidth: %f\nheight: %f", [title frame].origin.x, [title frame].origin.y, [title frame].size.width, [title frame].size.height);
    //NSLog(@"description pos - %f, %f", [description frame].origin.x, description.frame.origin.y);
    
    //size of the title and description with line breaks and all that
    CGSize titleSize = [[title text] sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGSize descriptionSize = [[description text] sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    //NSLog(@"\ntitleSize:\nwidth: %f\nheight: %f", titleSize.width, titleSize.height);
    //NSLog(@"\ndescriptionSize:\nwidth: %f\nheight: %f", descriptionSize.width, descriptionSize.height);
    
    //resize the title based on the titleSize
    CGRect newFrame = title.frame;
    newFrame.size.height = titleSize.height;
    title.frame = newFrame;
    
    //resize the description based on the descriptionSize and the titleSize
    newFrame = description.frame;
    newFrame.size.height = descriptionSize.height;
    newFrame.origin.y = description.frame.origin.y + (titleSize.height - TITLE_HEIGHT);
    description.frame = newFrame;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *titleText = [[newsFeedArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    NSString *descriptionText = [[newsFeedArray objectAtIndex:indexPath.row] objectForKey:@"description"];
    
    CGSize constraint = CGSizeMake(LABEL_WIDTH, 20000.0f);
    
    CGSize titleSize = [titleText sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGSize descriptionSize = [descriptionText sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat titleHeight = MIN(titleSize.height, 400.0f);
    CGFloat descriptionHeight = MIN(descriptionSize.height, 400.0f);
    
    CGFloat totalHeight = titleHeight + descriptionHeight + 229.0f - TITLE_HEIGHT - DESCRIPTION_HEIGHT;
    
    if (titleSize.height > TITLE_HEIGHT) {
        totalHeight += TITLE_HEIGHT;
    }
    
    //NSLog(@"totalHeight - %f", totalHeight);
    
    return totalHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat portraitWidth;
    CGFloat portraitHeight;
    CGFloat landscapeWidth;
    CGFloat landscapeHeight;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    //if iphone
    if (screenBounds.size.width == 320.0f) {
        portraitWidth = 320.0f;
        portraitHeight = 95.0f;
        landscapeWidth = 480.0f;
        landscapeHeight = 68.0f;
    }
    //if ipad
    else {
        portraitWidth = 768.0f;
        portraitHeight = 188.0f;
        landscapeWidth = 1024.0f;
        landscapeHeight = 129.0f;
    }
    
    /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.2")) {
        if ([deviceManager isIpad]) {
            portraitWidth = 768.0f;
            portraitHeight = 188.0f;
            landscapeWidth = 1024.0f;
            landscapeHeight = 129.0f;
        }
    }*/
    
    CGFloat width;
    CGFloat height;
    
    int orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == 1 || orientation == 2) {
        width = portraitWidth;
        height = portraitHeight;
    }
    else {
        width = landscapeWidth;
        height = landscapeHeight;
    }
    
    CGRect myImageRect = CGRectMake(0.0f, 0.0f, width, height);
    
    UIView *blankView = [[[UIView alloc] initWithFrame:myImageRect] autorelease];
    blankView.backgroundColor = [UIColor clearColor];
    
    return blankView;
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat portraitHeight;
    CGFloat landscapeHeight;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    //if iphone
    if (screenBounds.size.width == 320.0f) {
        portraitHeight = 95.0f;
        landscapeHeight = 68.0f;
    }
    //if ipad
    else {
        portraitHeight = 188.0f;
        landscapeHeight = 129.0f;
    }
    
    /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.2")) {
        if ([deviceManager isIpad]) {
            portraitHeight = 188.0f;
            landscapeHeight = 129.0f;
        }
    }*/
    
    CGFloat height;
    
    int orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == 1 || orientation == 2) {
        height = portraitHeight;
    }
    else {
        height = landscapeHeight;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect myImageRect;
    
    CGFloat portraitWidth;
    CGFloat portraitHeight;
    CGFloat landscapeWidth;
    CGFloat landscapeHeight;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    //if iphone
    if (screenBounds.size.width == 320.0f) {
        portraitWidth = 320.0f;
        portraitHeight = 38.0f;
        landscapeWidth = 480.0f;
        landscapeHeight = 36.0f;
    }
    //if ipad
    else {
        portraitWidth = 768.0f;
        portraitHeight = 103.0f;
        landscapeWidth = 1024.0f;
        landscapeHeight = 81.0f;
    }
    
    /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.2")) {
        if ([deviceManager isIpad]) {
            portraitWidth = 768.0f;
            portraitHeight = 103.0f;
            landscapeWidth = 1024.0f;
            landscapeHeight = 81.0f;
        }
    }*/
    
    CGFloat width;
    CGFloat height;
    
    int orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == 1 || orientation == 2) {
        width = portraitWidth;
        height = portraitHeight;
    }
    else {
        width = landscapeWidth;
        height = landscapeHeight;
    }
    
    myImageRect = CGRectMake(0.0f, 0.0f, width, height);

    UIView *blankView = [[[UIView alloc] initWithFrame:myImageRect] autorelease];
    blankView.backgroundColor = [UIColor clearColor];
    
    return blankView;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat portraitHeight;
    CGFloat landscapeHeight;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    //if iphone
    if (screenBounds.size.width == 320.0f) {
        portraitHeight = 38.0f;
        landscapeHeight = 36.0f;
    }
    //if ipad
    else {
        portraitHeight = 103.0f;
        landscapeHeight = 81.0f;
    }
    
    /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.2")) {
        if ([deviceManager isIpad]) {
            portraitHeight = 103.0f;
            landscapeHeight = 81.0f;
        }
    }*/
    
    CGFloat height;
    
    int orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == 1 || orientation == 2) {
        height = landscapeHeight;
    }
    else {
        height = portraitHeight;
    }
    
    return height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
