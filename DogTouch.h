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
    b2MouseJoint *mouseJoint;
    NSNumber *hash;
    BOOL toDeleteFlag;
    NSValue *world;
}

-(DogTouch *)initWithBody:(NSValue *)b andMouseJoint:(NSValue *)j andWorld:(NSValue *)w andHash:(NSValue *)h;
-(b2MouseJoint *)createMouseJoint:(NSValue *)m withWorld:(NSValue *)w;
-(void)destroyMouseJoint:(NSValue *)w;
-(b2MouseJoint *)getMouseJoint;
-(NSNumber *)getHash;
-(void)moveTouch:(NSValue *)l;
-(void)removeTouch;;
-(BOOL)isFlaggedForDeletion;
-(void)flagForDeletion;

@end
