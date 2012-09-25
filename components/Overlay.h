//
//  Overlay.h
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "box2d.h"

@interface Overlay : NSObject {
    CCSpriteBatchNode *spritesheet;
    b2Body *body;
    CCSprite *sprite;
    CCAction *action;
    CGSize winSize;
}

-(Overlay *)initWithDogBody:(NSValue *)b andSpriteSheet:(NSValue *)s;
-(Overlay *)initWithPersonBody:(NSValue *)b andSpriteSheet:(NSValue *)s;
-(Overlay *)initWithMuncherBody:(NSValue *)b andSpriteSheet:(NSValue *)s;
-(void)updatePosition;
-(void)updatePosition:(NSNumber *)numTouches withDroppedCount:(NSNumber *)count;
-(CCSprite *)getSprite;
-(Overlay *)initWithSprite:(NSValue *)s andBody:(NSValue *)b;

@end