//
//  Firecracker.m
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "Firecracker.h"
#import "GameplayLayer.h"
#import <SimpleAudioEngine.h>
#import "HotDogManager.h"

@implementation Firecracker

-(Firecracker *)init:(NSValue *)w withSpritesheet:(NSValue *)s {
    winSize = [[CCDirector sharedDirector] winSize];
    float scaleX = 1, scaleY = 1;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        scaleX = IPAD_SCALE_FACTOR_X;
        scaleY = IPAD_SCALE_FACTOR_Y;
    }
    
    self->world = (b2World *)[w pointerValue];
    self->spritesheet = (CCSpriteBatchNode *)[s pointerValue];
    self->mainSprite = [CCSprite spriteWithSpriteFrameName:@"fireCracker_1.png"];
    self->mainSprite.scaleX = scaleX;
    self->mainSprite.scaleY = scaleY;
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
    sensorShape.SetAsBox(((self->mainSprite.scaleX*self->mainSprite.contentSize.width))/PTM_RATIO/2, ((self->mainSprite.scaleY*self->mainSprite.contentSize.height))/PTM_RATIO/2);
    b2FixtureDef sensorShapeDef;
    sensorShapeDef.shape = &sensorShape;
    sensorShapeDef.filter.categoryBits = 0x0000;
    sensorShapeDef.filter.maskBits = 0x0000;
    sensorShapeDef.isSensor = true;
    self->hitboxSensor = self->worldBody->CreateFixture(&sensorShapeDef);
}

-(void)dropDown{
    CCFiniteTimeAction *moveAction = [CCMoveTo actionWithDuration:.6 position:ccp(self->mainSprite.position.x, winSize.height - (self->mainSprite.contentSize.height*self->mainSprite.scaleY)/2)];
    [self->mainSprite runAction:[CCSequence actions:moveAction, [CCCallFunc actionWithTarget:self selector:@selector(createHitbox)], [CCCallFunc actionWithTarget:self selector:@selector(setStillSprite)], nil]];
}

-(void)flipExploding{
    if(self->isNowExploding)
        self->isNowExploding = false;
    else
        self->isNowExploding = true;
}

-(void)explode{
    [self->mainSprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1], [CCCallFunc actionWithTarget:self selector:@selector(flipExploding)], nil]];
    [self->mainSprite runAction:self->explodeAnimation];
}

-(void)setHasKilledDog{
    self->hasKilledDog = true;
}

-(void)pullUp{
    self->isNowExploding = false;
    CCFiniteTimeAction *moveAction = [CCMoveTo actionWithDuration:.6 position:ccp(self->mainSprite.position.x, winSize.height + (self->mainSprite.contentSize.height*self->mainSprite.scaleY)/2)];
    [self->mainSprite runAction:[CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(setPullUpSprite)], moveAction, nil]];
}

-(void)playSFX{
#ifdef DEBUG
#else
    if([[HotDogManager sharedManager] sfxOn]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"firecracker.mp3"];
    }
#endif
}

-(void)runSequence{
    [self->mainSprite runAction:[CCSequence actions:
                                 [[CCCallFunc actionWithTarget:self selector:@selector(dropDown)] retain],
                                 [CCDelayTime actionWithDuration:2],
                                 [[CCCallFunc actionWithTarget:self selector:@selector(playSFX)] retain],
                                 [[CCCallFunc actionWithTarget:self selector:@selector(explode)] retain],
                                 [CCDelayTime actionWithDuration:2.6],
                                 [[CCCallFunc actionWithTarget:self selector:@selector(pullUp)] retain],
                                 [CCCallFunc actionWithTarget:self selector:@selector(dealloc)], nil]];
}

-(BOOL)explosionHittingDog:(NSValue *)d {
    b2Body *dog = (b2Body *)[d pointerValue];
    if(!self->hasKilledDog && self->isNowExploding){
        BOOL touching = self->hitboxSensor->TestPoint(dog->GetPosition());
        if(touching)
            self->hasKilledDog = true;
        return touching;
    }
    return false;
}

-(void)dealloc{
    self->world->DestroyBody(self->worldBody);
    [super dealloc];
}

@end
