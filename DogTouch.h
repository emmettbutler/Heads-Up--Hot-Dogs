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
}

-(DogTouch *)initWithBody:(NSValue *)b;
-(b2MouseJoint *)createMouseJoint:(NSValue *)m withWorld:(NSValue *)w;
-(void)destroyMouseJoint:(NSValue *)w;

@end
