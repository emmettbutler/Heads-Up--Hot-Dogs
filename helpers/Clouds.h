//
//  Clouds.h
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "box2d.h"

@interface Clouds : NSObject {
    CCSpriteBatchNode *spritesheet;
    CCSprite *cloud1, *cloud2, *cloud3;
}

-(Clouds *)initWithSpritesheet:(NSValue *)s;

@end