//
//  AsyncImageView.m
//  ASNewsFeedTest
//
//  Created by Justin Gardner on 3/28/12.
//  Copyright (c) 2012 [adult swim]. All rights reserved.
//

#import "AsyncImageView.h"

static NSMutableDictionary *imageDictionary = nil;

@implementation AsyncImageView

- (void)loadImageFromURL:(NSURL*)url {
    if (connection!=nil) { [connection release]; }
    if (data!=nil) { [data release]; }
    if (urlData!=nil) {[urlData release]; }
    
    UIImage* retImage = [imageDictionary objectForKey:url];
    urlData = url;
    
    if (retImage == nil) {
            
        NSURLRequest* request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];
        connection = [[NSURLConnection alloc]
                      initWithRequest:request delegate:self];
        
        if (imageDictionary == nil) {
            imageDictionary = [NSMutableDictionary new];
        }
        
    }
    
    
    if ([[self subviews] count]>0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:retImage] autorelease];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
    
    [self addSubview:imageView];
    imageView.frame = self.bounds;
    [imageView setNeedsLayout];
    [self setNeedsLayout];
    
    //TODO error handling, what if connection is nil?
}

- (void)connection:(NSURLConnection *)theConnection
    didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
        data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}



- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    [connection release];
    connection = nil;
    
    if ([[self subviews] count]>0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
    
    [imageDictionary setObject:[UIImage imageWithData:data] forKey:urlData];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
    
    [self addSubview:imageView];
    imageView.frame = self.bounds;
    [imageView setNeedsLayout];
    [self setNeedsLayout];
    [data release];
    data = nil;
}

- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
    [super dealloc];
}

@end
