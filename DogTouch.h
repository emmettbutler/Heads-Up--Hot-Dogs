//
//  DogTouch.h
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "box2d.h"

@interface DogTouch : NSObject {
    NSValue *dog;
    b2Vec2 location;
    NSValue *mouseJoint;
    NSNumber *hash;
    BOOL locationHasBeenSetThisTick;
}

-(DogTouch *)initWithBody:(NSValue *)b andMouseJoint:(NSValue *)j andWorld:(NSValue *)w andHash:(NSValue *)h;
-(b2MouseJoint *)createMouseJoint:(NSValue *)m withWorld:(NSValue *)w;
-(void)destroyMouseJoint:(NSValue *)w;
-(NSValue *)getMouseJoint;
-(NSNumber *)getHash;
-(void)moveTouch;
-(void)removeTouch:(NSValue *)w;

@end
