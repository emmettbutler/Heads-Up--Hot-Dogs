//
//  Level.m
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "Level.h"
#define NUM_LEVELS 2

@implementation Level

+(void)buildLevels{
    levelStructs = [[NSMutableArray alloc] initWithCapacity:NUM_LEVELS];
    // populate an array of structs with the correct level datas
}

-(id) init{
    return [self initWithBackground:[NSString stringWithString:@"bg_philly.png"] 
                             AndBGM:[NSString stringWithString:@""] 
                         AndGravity:[NSNumber numberWithInt:-10]];
}

-(id) initWithBackground:(NSString *)theBG AndBGM:(NSString *)theBGM{
    return [self initWithBackground:theBG AndBGM:theBGM AndGravity:[NSNumber numberWithInt:-10]];
}

-(id) initWithBackground:(NSString *)theBG AndBGM:(NSString *)theBGM AndGravity:(NSNumber *)theGravity {
    self = [super init];
    if (self){
        background = [CCSprite spriteWithFile:theBG];
        bgm = theBGM;
        gravity = theGravity.floatValue;
        // highScore init with stored value for level
    }
    return self;
}

-(id) initWithSlug:(NSString *)theSlug{
    // loop over levelStructs and init using the one with the given slug
}

-(void) playBGM{
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:bgm loop:YES];
}

@end
