//
//  DogTouch.m
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "DogTouch.h"
#import "GameplayLayer.h"


@implementation DogTouch

-(DogTouch *)initWithBody:(NSValue *)b andMouseJoint:(NSValue *)j andWorld:(NSValue *)w andHash:(NSNumber *)h{
    self->dog = b;
    self->hash = h;
    self->world = w;
    
    b2Body *body = (b2Body *)[b pointerValue];
    bodyUserData *ud = (bodyUserData *)body->GetUserData();
    
    [ud->sprite1 stopAllActions];
    [ud->sprite1 setColor:ccc3(255, 255, 255)];
    [ud->countdownLabel setVisible:false];
    ud->deathSeqLock = false;
    ud->grabbed = true;
    ud->aimedAt = false;
    ud->hasTouchedHead = false;
    body->SetAwake(false);
    body->SetTransform(body->GetPosition(), CC_DEGREES_TO_RADIANS(0));
    body->SetFixedRotation(true);
    body->SetAwake(true);
    ud->_dog_hasBeenGrabbed = true;
    
    b2MouseJointDef* mdstar = (b2MouseJointDef *)[j pointerValue];
    
    b2World *_world = (b2World *)[self->world pointerValue];
    self->mouseJoint = (b2MouseJoint *)_world->CreateJoint(mdstar);
    self->mj = [[NSValue valueWithPointer:self->mouseJoint] retain];

    return self;
}

-(void)moveTouch:(NSValue *)l{
    b2Body *body = (b2Body *)[self->dog pointerValue];
    
    b2Vec2 *locationW = (b2Vec2 *)[l pointerValue];
    b2Vec2 locationWorld = *locationW;
    //self->mouseJoint->SetTarget(locationWorld);
    b2MouseJoint *joint = (b2MouseJoint *)[self->mj pointerValue];
    joint->SetTarget(locationWorld);
    
    bodyUserData *ud = (bodyUserData *)body->GetUserData();
    [ud->sprite1 stopAllActions];
    ud->deathSeq = nil;
    ud->deathSeqLock = false;
    
    for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
        fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
        if(fUd->tag == F_DOGCLD){
            b2Filter filter;
            // here, we set the dog's collision filter to disallow all collisions.
            // the original filter data has been saved in the fixture's ogCollideFilter field
            // so that on touch end, we can restore its original collision state
            filter = fixture->GetFilterData();
            filter.maskBits = 0x0000;
            fixture->SetFilterData(filter);
            break;
        }
    }
}

-(void)removeTouch{
    b2Filter filter;
    b2Body *body = (b2Body *)[self->dog pointerValue];
    bodyUserData *ud = (bodyUserData *)body->GetUserData();
    
    ud->grabbed = false;
    [ud->countdownLabel setVisible:false];
    body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x/5.0, body->GetLinearVelocity().y/5.0));
    body->SetFixedRotation(false);
    
    if(body->GetPosition().y < .8 && body->GetPosition().x < .5)
        body->SetTransform(b2Vec2(body->GetPosition().x, 1.8), 0);
    if(body->GetPosition().x < 1)
        body->SetTransform(b2Vec2(1.5, body->GetPosition().y), 0);
    
    b2World *_world = (b2World *)[self->world pointerValue];
    b2MouseJoint *joint = (b2MouseJoint *)[self->mj pointerValue];
    _world->DestroyJoint(joint);
    
    for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
        fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
        if(fUd->tag == F_DOGCLD){
            // here, we restore the fixture's original collision filter from that saved in
            // its ogCollideFilter field
            filter = fixture->GetFilterData();
            fUd->ogCollideFilters = fUd->ogCollideFilters | 0xffffff00;
            filter.maskBits = fUd->ogCollideFilters;
            filter.maskBits = filter.maskBits | FLOOR1;
            fixture->SetFilterData(filter);
            ud->collideFilter = filter.maskBits;
        }
    }
    
    if(ud->deathSeq != nil){
        [ud->sprite1 runAction:ud->deathSeq];
        [ud->countdownLabel setVisible:true];
        [ud->sprite1 runAction:ud->countdownAction];
        [ud->sprite1 runAction:ud->tintAction];
    }
}

-(b2MouseJoint *)getMouseJoint{
    return (b2MouseJoint *)[self->mj pointerValue];
}

-(NSNumber *)getHash{
    return self->hash;
}

-(BOOL)isFlaggedForDeletion{
    return self->toDeleteFlag;
}

-(void)flagForDeletion{
    self->toDeleteFlag = true;
}

-(void)dealloc{
    b2World *_world = (b2World *)[self->world pointerValue];
    b2MouseJoint *joint = (b2MouseJoint *)[self->mj pointerValue];
    _world->DestroyJoint(joint);
    [super dealloc];
}

@end
