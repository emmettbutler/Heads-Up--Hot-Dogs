//
//  HotDogManager.h
//  Heads Up
//
//  Created by Emmett Butler on 9/25/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//


@interface HotDogManager : NSObject {
    NSNumber *_pause;
}

+(HotDogManager *)sharedManager;
-(void)setPause:(NSNumber *)pause;
-(BOOL)isPaused;

@end