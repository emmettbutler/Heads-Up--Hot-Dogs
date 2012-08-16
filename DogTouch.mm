//
//  DogTouch.m
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "DogTouch.h"
#import "GameplayLayer.h"


@implementation DogTouch

-(DogTouch *)initWithBody:(NSValue *)b andMouseJoint:(NSValue *)j andWorld:(NSValue *)w andHash:(NSNumber *)h{
    self->dog = b;
    self->hash = h;
    b2Body *body = (b2Body *)[b pointerValue];
    bodyUserData *ud = (bodyUserData *)body->GetUserData();
    
    [ud->sprite1 stopAllActions];
    ud->deathSeqLock = false;
    ud->grabbed = true;
    ud->aimedAt = false;
    ud->hasTouchedHead = false;
    body->SetAwake(false);
    body->SetTransform(body->GetPosition(), CC_DEGREES_TO_RADIANS(0));
    body->SetFixedRotation(true);
    body->SetAwake(true);
    
    b2MouseJointDef* mdstar = (b2MouseJointDef *)[j pointerValue];
    b2MouseJointDef md = *mdstar;
    b2World *world = (b2World *)[w pointerValue];
    b2MouseJoint *mj = (b2MouseJoint *)world->CreateJoint(&md);
    self->mouseJoint = [[NSValue valueWithPointer:mj] retain];
    
    return self;
}

-(b2MouseJoint *)createMouseJoint:(NSValue *)m withWorld:(NSValue *)w{
    b2MouseJointDef* mdstar = (b2MouseJointDef *)[m pointerValue];
    b2MouseJointDef md = *mdstar;
    b2World *world = (b2World *)[w pointerValue];
    b2MouseJoint *mj = (b2MouseJoint *)world->CreateJoint(&md);
    self->mouseJoint = [[NSValue valueWithPointer:mj] retain];
    return mj;
}

-(NSValue *)getMouseJoint{
    return self->mouseJoint;
}

-(NSNumber *)getHash{
    return self->hash;
}

@end
