//
//  S.m
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "Shiba.h"
#import "GameplayLayer.h"

@implementation Shiba

-(Shiba *)init:(NSValue *)s withWorld:(NSValue *)w {
    winSize = [[CCDirector sharedDirector] winSize];

    self->world = (b2World *)[w pointerValue];
    self->spritesheet = (CCSpriteBatchNode *)[s pointerValue];
    self->mainSprite = [CCSprite spriteWithSpriteFrameName:@"Shiba_Walk_1.png"];
    
    self->speed = 50;
    
    NSMutableArray *animFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 10; i++){
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [NSString stringWithFormat:@"Shiba_Walk_%d.png", i]]];
    }
    CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:.1f];
    self->walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]];
    
    animFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 18; i++){
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [NSString stringWithFormat:@"Shiba_Eat_%d.png", i]]];
    }
    animation = [CCAnimation animationWithFrames:animFrames delay:.1f];
    self->eatAction = [[CCAnimate alloc] initWithAnimation:animation restoreOriginalFrame:NO];;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithFloat:FLOOR1_HT*PTM_RATIO]];
    [array addObject:[NSNumber numberWithFloat:FLOOR2_HT*PTM_RATIO]];
    [array addObject:[NSNumber numberWithFloat:FLOOR3_HT*PTM_RATIO]];
    [array addObject:[NSNumber numberWithFloat:FLOOR4_HT*PTM_RATIO]];
    int pick = arc4random() % [array count];
    // using this array for both floor heights and z-indices because f*ck NSDictionary
    NSNumber *floor = [array objectAtIndex:pick];
    array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithInt:FLOOR1_Z]];
    [array addObject:[NSNumber numberWithInt:FLOOR2_Z]];
    [array addObject:[NSNumber numberWithInt:FLOOR3_Z]];
    [array addObject:[NSNumber numberWithInt:FLOOR4_Z]];
    NSNumber *z = [array objectAtIndex:pick];
    array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithFloat:0 - self->mainSprite.contentSize.width / 2]];
    [array addObject:[NSNumber numberWithFloat:winSize.width + self->mainSprite.contentSize.width / 2]];
    NSNumber *x = [array objectAtIndex:arc4random() % [array count]];
    
    if(x.floatValue > winSize.width / 2){
        self->mainSprite.flipX = true;
    }
    
    //create the body
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(self->mainSprite.position.x/PTM_RATIO, self->mainSprite.position.y/PTM_RATIO);
    self->worldBody = self->world->CreateBody(&bodyDef);
    
    //create the grab box fixture
    b2PolygonShape sensorShape;
    sensorShape.SetAsBox(20.0/PTM_RATIO, 15.0/PTM_RATIO);
    b2FixtureDef sensorShapeDef;
    sensorShapeDef.shape = &sensorShape;
    sensorShapeDef.filter.categoryBits = 0x0000;
    sensorShapeDef.filter.maskBits = 0x0000;
    sensorShapeDef.isSensor = true;
    self->hitboxSensor = self->worldBody->CreateFixture(&sensorShapeDef);
    
    self->destination = abs(x.floatValue - (winSize.width + self->mainSprite.contentSize.width / 2));
    
    [self->mainSprite setPosition:CGPointMake(x.floatValue, floor.floatValue + self->mainSprite.contentSize.height / 2)];
    [self->spritesheet addChild:self->mainSprite z:z.intValue];
    [self->mainSprite runAction:[CCSequence actions:[CCMoveTo actionWithDuration:winSize.width/self->speed position:ccp(self->destination, self->mainSprite.position.y)], [CCCallFunc actionWithTarget:self selector:@selector(removeSprite)], nil]];
    [self->mainSprite runAction:self->walkAction];
    
    return self;
}

-(void)removeSprite{
    [self->mainSprite removeFromParentAndCleanup:YES];
    self->world->DestroyBody(self->worldBody);
}

-(BOOL)dogIsInHitbox:(NSValue *)d{
    b2Body *dogBody = (b2Body *)[d pointerValue];
    if(self->hitboxSensor->TestPoint(dogBody->GetPosition()))
        return true;
    return false;
}

-(void)updateSensorPosition{
    // TODO - destroy sprite and body when offscreen`
    
    float xPos = (float)(self->mainSprite.position.x + self->mainSprite.contentSize.width / 2)/PTM_RATIO;
    if(self->mainSprite.flipX)
        xPos = (float)(self->mainSprite.position.x - self->mainSprite.contentSize.width / 2)/PTM_RATIO;
    self->worldBody->SetTransform(b2Vec2(xPos, (self->mainSprite.position.y-10)/PTM_RATIO), self->worldBody->GetAngle());
}

-(void)destroyBody:(id)sender data:(NSValue *)b{
    b2Body *body = (b2Body *)[b pointerValue];
    bodyUserData *ud = (bodyUserData *)body->GetUserData();
    [ud->sprite1 removeFromParentAndCleanup:YES];
    self->world->DestroyBody(body);
}

-(BOOL)eatDog:(NSValue *)d{
    self->hasEatenDog = true;
    b2Body *dogBody = (b2Body *)[d pointerValue];
    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
    
    float distanceRemaining, spriteMove;
    if(self->mainSprite.flipX){
        distanceRemaining = self->mainSprite.position.x + self->mainSprite.contentSize.width / 2;
        spriteMove = -10.0;
    } else {
        distanceRemaining = winSize.width - self->mainSprite.position.x + self->mainSprite.contentSize.width / 2;
        spriteMove = 10.0;
    }
    
    [self->mainSprite setPosition:CGPointMake(self->mainSprite.position.x+spriteMove, self->mainSprite.position.y+10)];
    
    [self->mainSprite stopAllActions];
    [self->mainSprite runAction:self->eatAction];
    [self->mainSprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCMoveTo actionWithDuration:distanceRemaining/self->speed position:ccp(self->destination, self->mainSprite.position.y)], [CCCallFunc actionWithTarget:self selector:@selector(removeSprite)], nil]];
    
    [ud->sprite1 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.7], [CCCallFuncND actionWithTarget:self selector:@selector(destroyBody:data:) data:[[NSValue valueWithPointer:dogBody] retain]], nil]];
    
    return true;
}

-(BOOL)hasEatenDog{
    return self->hasEatenDog;
}   

@end