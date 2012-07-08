//
//  PointNotify.m
//  Heads Up
//
//  Created by Emmett Butler on 7/7/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "PointNotify.h"


@implementation PointNotify

+(NSMutableArray *)buildNotifiers {
    NSMutableArray *notifiers = [[NSMutableArray alloc] initWithCapacity:7];

    // set up point notifiers
    NSMutableArray *plusTenAnimFrames = [[NSMutableArray alloc] initWithCapacity:11];
    for(int i = 1; i <= 11; i++){
        [plusTenAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"plusTen%d.png", i]]];
    }
    CCAction *plus10Action = [[CCRepeat actionWithAction:
                               [CCAnimate actionWithAnimation:
                                [CCAnimation animationWithFrames:plusTenAnimFrames delay:.04f] restoreOriginalFrame:NO] times:1] retain];
    [plusTenAnimFrames release];

    NSMutableArray *plus15AnimFrames = [[NSMutableArray alloc] initWithCapacity:13];
    for(int i = 1; i <= 11; i++){
        [plus15AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"PlusFifteen%d.png", i]]];
    }
    CCAction *plus15Action = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:plus15AnimFrames delay:.04f] restoreOriginalFrame:NO] times:1] retain];
    [plus15AnimFrames release];

    NSMutableArray *plus25BigAnimFrames = [[NSMutableArray alloc] initWithCapacity:13];
    for(int i = 1; i <= 12; i++){
        [plus25BigAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"plusTwentyFive%d.png", i]]];
    }
    CCAction *plus25BigAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:plus25BigAnimFrames delay:.04f] restoreOriginalFrame:NO] times:1] retain];
    [plus25BigAnimFrames release];

    NSMutableArray *plus25AnimFrames = [[NSMutableArray alloc] initWithCapacity:13];
    for(int i = 1; i <= 13; i++){
        [plus25AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Plus_25_sm_%d.png", i]]];
    }
    CCAction *plus25Action = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:plus25AnimFrames delay:.04f] restoreOriginalFrame:NO] times:1] retain];
    [plus25AnimFrames release];

    NSMutableArray *plus100AnimFrames = [[NSMutableArray alloc] initWithCapacity:18];
    for(int i = 1; i <= 17; i++){
        [plus100AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Plus_100_%d.png", i]]];
    }
    CCAction *plus100Action = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:plus100AnimFrames delay:.06f] restoreOriginalFrame:NO] times:1] retain];
    [plus100AnimFrames release];

    NSMutableArray *bonusVaporTrailAnimFrames = [[NSMutableArray alloc] initWithCapacity:18];
    for(int i = 1; i <= 13; i++){
        [bonusVaporTrailAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CarryOff_Blast_%d.png", i]]];
    }
    CCAction *bonusVaporTrailAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:bonusVaporTrailAnimFrames delay:.07f] restoreOriginalFrame:NO] times:1] retain];
    [bonusVaporTrailAnimFrames release];

    NSMutableArray *bonusPlus250AnimFrames = [[NSMutableArray alloc] initWithCapacity:11];
    for(int i = 1; i <= 11; i++){
        [bonusPlus250AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Bonus_Plus250_sm_%d.png", i]]];
    }
    CCAction *bonusPlus250Action = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:bonusPlus250AnimFrames delay:.04f] restoreOriginalFrame:NO] times:1] retain];
    [bonusPlus250AnimFrames release];

    NSMutableArray *bonusPlus100AnimFrames = [[NSMutableArray alloc] initWithCapacity:12];
    for(int i = 1; i <= 11; i++){
        [bonusPlus100AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Bonus_Plus_Hundred_%d.png", i]]];
    }
    CCAction *bonusPlus100Action = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:bonusPlus100AnimFrames delay:.07f] restoreOriginalFrame:NO] times:1] retain];
    [bonusPlus100AnimFrames release];

    NSMutableArray *bonusPlus1000AnimFrames = [[NSMutableArray alloc] initWithCapacity:13];
    for(int i = 1; i <= 13; i++){
        [bonusPlus1000AnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Bonus_Plus_1000_%d.png", i]]];
    }
    CCAction *bonusPlus1000Action = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:bonusPlus1000AnimFrames delay:.07f] restoreOriginalFrame:NO] times:1] retain];
    [bonusPlus1000AnimFrames release];

    [notifiers addObject:[NSValue valueWithPointer:plus10Action]];
    [notifiers addObject:[NSValue valueWithPointer:plus15Action]];
    [notifiers addObject:[NSValue valueWithPointer:plus25BigAction]];
    [notifiers addObject:[NSValue valueWithPointer:plus25Action]];
    [notifiers addObject:[NSValue valueWithPointer:plus100Action]];
    [notifiers addObject:[NSValue valueWithPointer:bonusVaporTrailAction]];
    [notifiers addObject:[NSValue valueWithPointer:bonusPlus250Action]];
    [notifiers addObject:[NSValue valueWithPointer:bonusPlus100Action]];
    [notifiers addObject:[NSValue valueWithPointer:bonusPlus1000Action]];

    return notifiers;
}

@end
