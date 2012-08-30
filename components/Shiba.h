//
//  Shiba.h
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 NYU. All rights reserved.
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
    BOOL hasEatenDog;
    float destination, speed;
    CGSize winSize;
}

-(Shiba *)init:(NSValue *)s withWorld:(NSValue *)w;
-(void)walkAcross;
-(BOOL)dogIsInHitbox:(NSValue *)d;
-(BOOL)eatDog:(NSValue *)d;
-(BOOL)hasEatenDog;
-(void)updateSensorPosition;

@end
