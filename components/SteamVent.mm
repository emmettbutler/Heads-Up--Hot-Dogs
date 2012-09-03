//
//  SteamVent.m
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "SteamVent.h"
#import "GameplayLayer.h"

@implementation SteamVent

-(SteamVent *)init:(NSValue *)s_common withLevelSpriteSheet:(NSValue *)s_level withPosition:(NSValue *)pos{
    winSize = [[CCDirector sharedDirector] winSize];

    self->common_sheet = (CCSpriteBatchNode *)[s_common pointerValue];
    self->level_sheet = (CCSpriteBatchNode *)[s_level pointerValue];
    self->position = [pos CGPointValue];
    self->mainSprite = [CCSprite spriteWithSpriteFrameName:@"Steam_Whole_1.png"];
    self->grateSprite = [CCSprite spriteWithSpriteFrameName:@"SteamVent.png"];
    self->blowInterval = (arc4random() % 650) + 400;
    self->force = 8;
    
    NSMutableArray *animFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 10; i++){
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [NSString stringWithFormat:@"Steam_Whole_%d.png", i]]];
    }
    CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:.1f];
    CCFiniteTimeAction *startAction = [[[CCAnimate alloc] initWithAnimation:animation restoreOriginalFrame:NO] retain];
    animFrames = [[NSMutableArray alloc] init];
    for(int i = 11; i <= 14; i++){
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [NSString stringWithFormat:@"Steam_Whole_%d.png", i]]];
    }
    animation = [CCAnimation animationWithFrames:animFrames delay:.1f];
    CCFiniteTimeAction *loopAction = [[CCRepeat actionWithAction:[[CCAnimate alloc] initWithAnimation:animation restoreOriginalFrame:NO] times:10] retain];
    animFrames = [[NSMutableArray alloc] init];
    for(int i = 15; i <= 18; i++){
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [NSString stringWithFormat:@"Steam_Whole_%d.png", i]]];
    }
    animation = [CCAnimation animationWithFrames:animFrames delay:.1f];
    CCFiniteTimeAction *endAction = [[[CCAnimate alloc] initWithAnimation:animation restoreOriginalFrame:NO] retain];
    
    CCCallFunc *flipBlowing = [CCCallFunc actionWithTarget:self selector:@selector(flipBlowing)];
    
    self->combinedAction = [[CCSequence actions:startAction, flipBlowing, loopAction, flipBlowing, endAction, nil] retain];
    
    [self->mainSprite setPosition:CGPointMake(self->position.x-3, self->position.y+110)];
    [self->grateSprite setPosition:self->position];
    [self->common_sheet addChild:self->mainSprite];
    [self->level_sheet addChild:self->grateSprite];
    
    [self->mainSprite setVisible:false];
    
    return self;
}

-(void)flipBlowing{
    if(self->isOn)
        self->isOn = false;
    else
        self->isOn = true;
}

-(void)startBlowing{
    if([self->mainSprite numberOfRunningActions] == 0){
        [self->mainSprite setVisible:true];
        [self->mainSprite runAction:self->combinedAction];
    }
}

-(void)blowFrank:(NSValue *)body{
    if(!self->isOn) return;
    b2Body *b = (b2Body *)[body pointerValue];
    bodyUserData *ud = (bodyUserData*)b->GetUserData();
    if(ud->sprite1.position.y < winSize.height - 40){
        if((ud->sprite1.position.x > self->position.x - 30 && ud->sprite1.position.x < self->position.x + 30)){
            if(b->GetLinearVelocity().y != b->GetLinearVelocity().y+self->force){
                b->SetLinearVelocity(b2Vec2(b->GetLinearVelocity().x+((((float) rand() / RAND_MAX) * 2) - 1), b->GetLinearVelocity().y+self->force));
                [ud->sprite1 stopAllActions];
                ud->deathSeqLock = false;
            }
        }
    }
}

-(int)getInterval{
    return self->blowInterval;
}

@end