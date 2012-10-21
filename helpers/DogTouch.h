//
//  DogTouch.h
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "box2d.h"

@interface DogTouch : NSObject {
    NSValue *dog, *mj, *world;
    b2Vec2 location;
    b2MouseJoint *mouseJoint;
    NSNumber *hash;
    BOOL toDeleteFlag;
}

-(DogTouch *)initWithBody:(NSValue *)b andMouseJoint:(NSValue *)j andWorld:(NSValue *)w andHash:(NSValue *)h;
-(b2MouseJoint *)getMouseJoint;
-(NSNumber *)getHash;
-(void)moveTouch:(NSValue *)l topFloor:(float)topFloor;
-(void)removeTouch:(float)topFloor;
-(BOOL)isFlaggedForDeletion;
-(void)flagForDeletion;

@end
