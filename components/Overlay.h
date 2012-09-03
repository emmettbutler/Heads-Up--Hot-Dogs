//
//  Overlay.h
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "box2d.h"

@interface Overlay : NSObject {
    CCSpriteBatchNode *spritesheet;
    b2Body *body;
    CCSprite *sprite;
    CCAction *action;
}

-(Overlay *)initWithDogBody:(NSValue *)b andSpriteSheet:(NSValue *)s;
-(Overlay *)initWithPersonBody:(NSValue *)b andSpriteSheet:(NSValue *)s;
-(Overlay *)initWithMuncherBody:(NSValue *)b andSpriteSheet:(NSValue *)s;
-(void)updatePosition;
-(CCSprite *)getSprite;
-(Overlay *)initWithSprite:(NSValue *)s andBody:(NSValue *)b;

@end