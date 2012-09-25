//
//  HotDog.m
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "HotDog.h"

@implementation HotDog

-(HotDog *)init:(NSValue *)s withWorld:(NSValue *)w withLocation:(NSValue *)loc withSpcDog:(NSValue *)sd withVel:(NSValue *)v withDeathDelay:(NSNumber *)delay withDeathAnim:(NSMutableArray *)deathAnimFrames withFrictionMul:(NSNumber *)fric withRestitutionMul:(NSNumber *)rest{
    CGPoint location = [loc CGPointValue];
    CGPoint vel = [v CGPointValue];
    
    NSMutableArray *wienerDeathAnimFrames = [[NSMutableArray alloc] init];
    NSMutableArray *wienerFlashAnimFrames = [[NSMutableArray alloc] init];
    NSMutableArray *wienerShotAnimFrames = [[NSMutableArray alloc] init];
    NSString *fallSprite, *riseSprite, *mainSprite, *grabSprite;
    int floor, f, tag;
    float deathDelay;
    
    float scale = 1;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        scale = IPAD_SCALE_FACTOR_X*.85;
    }
    
    self->spritesheet = (CCSpriteBatchNode *)[s pointerValue];
    self->world = (b2World *)[w pointerValue];
    self->winSize = [CCDirector sharedDirector].winSize; // this needs to happen in initWithBody also probably
    
    // sd should be NULL if it's a normal dog, should be filled if it's a special dog
    spcDogData *dd = (spcDogData *)[sd pointerValue];  // pass in level->specialDog from main loop
    
    if(dd){
        riseSprite = dd->riseSprite;
        fallSprite = dd->fallSprite;
        mainSprite = dd->mainSprite;
        grabSprite = dd->grabSprite;
        deathDelay = .5;
        tag = S_SPCDOG;
        wienerDeathAnimFrames = dd->deathAnimFrames;
        wienerFlashAnimFrames = dd->flashAnimFrames;
        if(deathAnimFrames){
            wienerDeathAnimFrames = deathAnimFrames;
            wienerFlashAnimFrames = NULL;
        }
        wienerShotAnimFrames = dd->shotAnimFrames;
    }
    else {
        riseSprite = @"Dog_Rise.png";
        fallSprite = @"Dog_Fall.png";
        mainSprite = @"dog54x12.png";
        grabSprite = @"Dog_Grabbed.png";
        deathDelay = delay.floatValue;
        tag = S_HOTDOG;
        if(deathAnimFrames){ // pass in level->dogDeathAnimFrames from main loop
            for(int i = 0; i < [deathAnimFrames count]; i++){
                [wienerDeathAnimFrames addObject:[deathAnimFrames objectAtIndex:i]];
            }
            wienerFlashAnimFrames = NULL;
        } else {
            for(int i = 0; i < 8; i++){
                [wienerFlashAnimFrames addObject:
                    [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                    [NSString stringWithFormat:@"Dog_Die_1.png"]]];
                [wienerFlashAnimFrames addObject:
                    [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                    [NSString stringWithFormat:@"Dog_Die_2.png"]]];
            }
            for(int i = 1; i <= 7; i++){
                [wienerDeathAnimFrames addObject:
                    [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                    [NSString stringWithFormat:@"Dog_Die_%d.png", i]]];
            }
        }
        for(int i = 1; i <= 5; i++){
            [wienerShotAnimFrames addObject:
                [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                [NSString stringWithFormat:@"Dog_Shot_%d.png", i]]];
        }
    }
    //add base sprite to scene
    self->sprite1 = [[CCSprite spriteWithSpriteFrameName:mainSprite] retain];
    self->sprite1.scale = scale;
    [[self->sprite1 texture] setAliasTexParameters];
    self->sprite1.position = ccp(location.x, location.y);
    self->sprite1.tag = tag;
    [self->spritesheet addChild:self->sprite1 z:50]; //pass in spritesheetCommon
    
    CCAction *_flashAction;
    if(wienerFlashAnimFrames){
        CCAnimation *dogFlashAnim = [CCAnimation animationWithFrames:wienerFlashAnimFrames delay:.1f];
        _flashAction = [[CCAnimate alloc] initWithAnimation:dogFlashAnim];
    }
    
    CCAnimation *dogDeathAnim = [CCAnimation animationWithFrames:wienerDeathAnimFrames delay:.1f];
    CCAction *_deathAction = [[CCAnimate alloc] initWithAnimation:dogDeathAnim];
    
    CCAnimation *dogShotAnim = [CCAnimation animationWithFrames:wienerShotAnimFrames delay:.1f ];
    CCFiniteTimeAction *_shotAction = [[CCAnimate alloc] initWithAnimation:dogShotAnim restoreOriginalFrame:NO];
    
    //set up the userdata structures
    bodyUserData *ud = new bodyUserData();
    ud->sprite1 = self->sprite1;
    ud->_dog_fallSprite = fallSprite;
    ud->_dog_riseSprite = riseSprite;
    ud->_dog_mainSprite = mainSprite;
    ud->_dog_grabSprite = grabSprite;
    ud->altAction = _deathAction;
    ud->altAction2 = _shotAction;
    ud->howToPlaySpriteYOffset = 60;
    if(wienerFlashAnimFrames)
        ud->altAction3 = _flashAction;
    ud->deathDelay = deathDelay;
    ud->deathSeq = NULL;
    
    fixtureUserData *fUd1 = new fixtureUserData();
    fUd1->ogCollideFilters = 0;
    fUd1->tag = F_DOGGRB;
    
    //for the collision fixture userdata struct, randomly assign floor
    fixtureUserData *fUd2 = new fixtureUserData();
    floor = arc4random() % 4;
    f =  WALLS;
    if(floor == 1){
        f = f | FLOOR1;
    }
    else if(floor == 2){
        f = f | FLOOR2 | FLOOR1;
    }
    else if(floor == 3){
        f = f | FLOOR3 | FLOOR2 | FLOOR1;
    }
    else {
        f = f | FLOOR4 | FLOOR3 | FLOOR2 | FLOOR1;
    }
    fUd2->ogCollideFilters = f;
    fUd2->tag = F_DOGCLD;
    
    //create the body
    b2BodyDef wienerBodyDef;
    wienerBodyDef.type = b2_dynamicBody;
    wienerBodyDef.position.Set(location.x/PTM_RATIO, location.y/PTM_RATIO);
    wienerBodyDef.userData = ud;
    self->worldBody = self->world->CreateBody(&wienerBodyDef);
    
    //create the grab box fixture
    b2PolygonShape wienerGrabShape;
    wienerGrabShape.SetAsBox((self->sprite1.contentSize.width*self->sprite1.scaleX+50)/PTM_RATIO/2, (self->sprite1.contentSize.height*self->sprite1.scaleY+50)/PTM_RATIO/2);
    b2FixtureDef wienerGrabShapeDef;
    wienerGrabShapeDef.shape = &wienerGrabShape;
    wienerGrabShapeDef.filter.categoryBits = WIENER;
    wienerGrabShapeDef.filter.maskBits = 0x0000;
    wienerGrabShapeDef.userData = fUd1;
    self->worldBody->CreateFixture(&wienerGrabShapeDef);
    
    //create the collision fixture
    b2PolygonShape wienerShape;
    wienerShape.SetAsBox((self->sprite1.scaleX*self->sprite1.contentSize.width)/PTM_RATIO/2, (self->sprite1.contentSize.height*self->sprite1.scaleY)/PTM_RATIO/2);
    b2FixtureDef wienerShapeDef;
    wienerShapeDef.shape = &wienerShape;
    wienerShapeDef.density = 0.5f;
    wienerShapeDef.friction = 1.0f;
    if(fric) // pass in level->frictionMul
        wienerShapeDef.friction = 1.0f*fric.floatValue;
    wienerShapeDef.userData = fUd2;
    wienerShapeDef.filter.maskBits = f;
    wienerShapeDef.restitution = 0.2f;
    if(rest) // pass in level->restitutionMul
        wienerShapeDef.restitution = 0.2f*rest.floatValue;
    wienerShapeDef.filter.categoryBits = WIENER;
    self->worldBody->CreateFixture(&wienerShapeDef);
    
    self->worldBody->ApplyForce(b2Vec2(vel.x, vel.y), b2Vec2(self->worldBody->GetPosition().x-.3, self->worldBody->GetPosition().y+.2));
    
    return self;
}

-(HotDog *)initWithBody:(NSValue *)b{
    self->worldBody = (b2Body *)[b pointerValue];
    self->winSize = [CCDirector sharedDirector].winSize;
    return self;
}

-(void)setDogDisplayFrame{
    b2Body *b = self->worldBody;
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    if(!ud->grabbed){
        if(!ud->aimedAt && !ud->exploding){
            if(b->GetLinearVelocity().y > 1.5){
                [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ud->_dog_riseSprite]];
            } else if (b->GetLinearVelocity().y < -1.5){
                [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ud->_dog_fallSprite]];
            } else {
                [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ud->_dog_mainSprite]];
            }
        }
    } else {
        [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ud->_dog_grabSprite]];
    }
}

-(void)setOffHeadCollisionFilters{
    // TODO - make this exit early to reduce lag
    b2Body *b = self->worldBody;
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    for(b2Fixture* fixture = b->GetFixtureList(); fixture; fixture = fixture->GetNext()){
        fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
        if(fUd->tag == F_DOGCLD){
            // this is the case in which a dog is not on a person's head.
            // we set the filters to their original value (all people, floor, and walls)
            b2Filter dogFilter = fixture->GetFilterData();
            dogFilter.maskBits = fUd->ogCollideFilters;
            if(b->GetPosition().y > self->winSize.height/PTM_RATIO)
                dogFilter.maskBits = 0xfffff000;
            else if(b->GetPosition().y < self->winSize.height/PTM_RATIO)
                dogFilter.maskBits = dogFilter.maskBits | WALLS;
            fixture->SetFilterData(dogFilter);
            ud->collideFilter = dogFilter.maskBits;
            break;
        }
    }
}

-(void)setOnHeadCollisionFilters{
    b2Body *b = self->worldBody;
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    for(b2Fixture* fixture = b->GetFixtureList(); fixture; fixture = fixture->GetNext()){
        fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
        if(fUd->tag == F_DOGCLD){
            // this is the case in which a dog is not on a person's head.
            // we set the filters to their original value (all people, floor, and walls)
            b2Filter dogFilter = fixture->GetFilterData();
            dogFilter.maskBits = dogFilter.maskBits & 0xffef;
            fixture->SetFilterData(dogFilter);
            ud->collideFilter = dogFilter.maskBits;
            break;
        }
    }
}

-(NSValue *)getBody{
    return [NSValue valueWithPointer:self->worldBody];
}

@end