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
    winSize = [[CCDirector sharedDirector] winSize];
    
    self->world = (b2World *)[w pointerValue];
    self->spritesheet = (CCSpriteBatchNode *)[s pointerValue];
    self->mainSprite = [CCSprite spriteWithSpriteFrameName:@"fireCracker_1.png"];
    self->position = b2Vec2(arc4random() % (int)(winSize.width/PTM_RATIO), (winSize.height+self->mainSprite.contentSize.height)/PTM_RATIO);
    self->riseSprite = @"fireCracker_28.png";
    self->fallSprite = @"fireCracker_1.png";
    self->isNowExploding = false;
    self->fallSpeed = .001;
    
    NSMutableArray *animFrames = [[NSMutableArray alloc] init];
    for(int i = 2; i <= 27; i++){
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                          [NSString stringWithFormat:@"fireCracker_%d.png", i]]];
    }
    CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:.1f];
    self->explodeAnimation = [[CCAnimate alloc] initWithAnimation:animation restoreOriginalFrame:NO];
    
    [self->mainSprite setPosition:CGPointMake(self->position.x*PTM_RATIO, self->position.y*PTM_RATIO)];
    [self->spritesheet addChild:self->mainSprite];
    
    return self;
}

-(void)setStillSprite{
    [self->mainSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fireCracker_2.png"]];
}

-(void)setPullUpSprite{
    [self->mainSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:self->riseSprite]];
}

-(void)createHitbox{
    //create the body
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(self->mainSprite.position.x/PTM_RATIO, self->mainSprite.position.y/PTM_RATIO);
    self->worldBody = self->world->CreateBody(&bodyDef);
    
    //create the grab box fixture
    b2PolygonShape sensorShape;
    sensorShape.SetAsBox((self->mainSprite.contentSize.width+10)/PTM_RATIO/2, (self->mainSprite.contentSize.height)/PTM_RATIO/2);
    b2FixtureDef sensorShapeDef;
    sensorShapeDef.shape = &sensorShape;
    sensorShapeDef.filter.categoryBits = 0x0000;
    sensorShapeDef.filter.maskBits = 0x0000;
    sensorShapeDef.isSensor = true;
    self->hitboxSensor = self->worldBody->CreateFixture(&sensorShapeDef);
}

-(void)dropDown{
    CCFiniteTimeAction *moveAction = [CCMoveTo actionWithDuration:.8 position:ccp(self->mainSprite.position.x, winSize.height - self->mainSprite.contentSize.height/2)];
    [self->mainSprite runAction:[CCSequence actions:moveAction, [CCCallFunc actionWithTarget:self selector:@selector(createHitbox)], [CCCallFunc actionWithTarget:self selector:@selector(setStillSprite)], nil]];
}

-(void)explode{
    self->isNowExploding = true;
    [self->mainSprite runAction:self->explodeAnimation];
}

-(void)pullUp{
    self->isNowExploding = false;
    CCFiniteTimeAction *moveAction = [CCMoveTo actionWithDuration:1.2 position:ccp(self->mainSprite.position.x, winSize.height + self->mainSprite.contentSize.height/2)];
    [self->mainSprite runAction:[CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(setPullUpSprite)], moveAction, nil]];
}

-(void)runSequence{
    [self->mainSprite runAction:[CCSequence actions:
                                 [CCCallFunc actionWithTarget:self selector:@selector(dropDown)],
                                 [CCDelayTime actionWithDuration:2],
                                 [CCCallFunc actionWithTarget:self selector:@selector(explode)],
                                 [CCDelayTime actionWithDuration:2.6],
                                 [CCCallFunc actionWithTarget:self selector:@selector(pullUp)],
                                 [CCCallFunc actionWithTarget:self selector:@selector(dealloc)], nil]];
}

-(BOOL)explosionHittingDog:(NSValue *)d {
    b2Body *dog = (b2Body *)[d pointerValue];
    if(self->isNowExploding)
        return self->hitboxSensor->TestPoint(dog->GetPosition());
    return false;
}

-(void)dealloc{
    self->world->DestroyBody(self->worldBody);
    [super dealloc];
}

@end
