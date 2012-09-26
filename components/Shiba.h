//
//  Shiba.h
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface Shiba : NSObject {
    b2World *world;
    CCSprite *mainSprite;
    CCAction *walkAction;
    b2Body *worldBody;
    CCFiniteTimeAction *eatAction;
    CCSpriteBatchNode *spritesheet;
    b2Fixture *hitboxSensor;
    BOOL hasEatenDog, hasEntered;
    float destination, speed, scale;
    CGPoint offset;
    CGSize winSize;
}

-(Shiba *)init:(NSValue *)s withWorld:(NSValue *)w withFloorHeights:(NSMutableArray *)floorHeights;
-(BOOL)dogIsInHitbox:(NSValue *)d;
-(BOOL)eatDog:(NSValue *)d;
-(BOOL)hasEatenDog;
-(void)updateSensorPosition;
-(void)stopAllActions;

@end
