//
//  HotDog.h
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GameplayLayer.h"
#import "UIDefs.h"

@interface HotDog : NSObject {
    b2World *world;
    CCSpriteBatchNode *spritesheet;
    CGSize winSize;
    b2Body *worldBody;
    
    CCSprite *sprite1;
    NSString *_dog_fallSprite, *_dog_riseSprite, *_dog_grabSprite, *_dog_mainSprite;
    CCAction *deathSeq, *shotSeq, *altAction, *altAction2, *altAction3;
    float deathDelay;
    BOOL touched, exploding, touchLock, aimedAt, grabbed, deathSeqLock, animLock, hasTouchedHead, _dog_isOnHead;
    int collideFilter;
}

-(HotDog *)init:(NSValue *)s withWorld:(NSValue *)w withLocation:(NSValue *)loc withSpcDog:(NSValue *)sd withVel:(NSValue *)v withDeathDelay:(NSNumber *)delay withDeathAnim:(NSMutableArray *)deathAnimFrames withFrictionMul:(NSNumber *)fric withRestitutionMul:(NSNumber *)rest;
-(HotDog *)initWithBody:(NSValue *)b;
-(NSValue *)getBody;
-(void)setDogDisplayFrame;
-(void)setOnHeadCollisionFilters;
-(void)setOffHeadCollisionFilters;

@end