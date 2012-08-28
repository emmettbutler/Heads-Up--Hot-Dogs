//
//  Firecracker.m
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "Firecracker.h"


@implementation Firecracker

-(Firecracker *)init:(NSValue *)w withSpritesheet:(NSValue *)s {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    self->world = (b2World *)[w pointerValue];
    self->spritesheet = (CCSpriteBatchNode *)[s pointerValue];
    self->mainSprite = [CCSprite spriteWithSpriteFrameName:@"fireCracker_1"];
    self->position = b2Vec2(arc4random() % (int)(winSize.width/PTM_RATIO), winSize.height/PTM_RATIO);
    
    NSMutableArray *animFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 28; i++){
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                          [NSString stringWithFormat:@"fireCracker_%d.png", i]]];
    }
    CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:.1f];
    self->explodeAnimation = [[CCAnimate alloc] initWithAnimation:animation];
    
    [self->spritesheet addChild:self->mainSprite];
    
    bodyUserData *ud = new bodyUserData();
    ud->sprite1 = self->mainSprite;
    
    //create the body
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(0, 0);
    bodyDef.userData = ud;
    self->worldBody = self->world->CreateBody(&bodyDef);
    
    //create the grab box fixture
    b2PolygonShape sensorShape;
    sensorShape.SetAsBox((self->mainSprite.contentSize.width+50)/PTM_RATIO/2, (self->mainSprite.contentSize.height+50)/PTM_RATIO/2);
    b2FixtureDef sensorShapeDef;
    sensorShapeDef.shape = &sensorShape;
    sensorShapeDef.filter.categoryBits = WIENER;
    sensorShapeDef.filter.maskBits = 0x0000;
    sensorShapeDef.isSensor = true;
    self->hitboxSensor = self->worldBody->CreateFixture(&sensorShapeDef);
    
    return self;
}

-(void)dropDown{

}

-(void)explode{

}

-(void)pullUp{

}

-(BOOL)explosionHittingDog:(NSValue *)d {
    b2Body *dog = (b2Body *)[d pointerValue];
}

@end
