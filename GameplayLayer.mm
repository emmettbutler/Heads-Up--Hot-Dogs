//
//  HelloWorldLayer.mm
//  Heads Up Hot Dogs
//
//  Created by Emmett Butler and Diego Garcia on 1/3/12.
//  Copyright Emmett and Diego 2012. All rights reserved.
//

// Import the interfaces
#import "GameplayLayer.h"
#import "TitleScene.h"
#import "LoseScene.h"

#define PTM_RATIO 32
#define DEGTORAD 0.0174532
#define FLOOR1_HT 0
#define FLOOR2_HT .4
#define FLOOR3_HT .8
#define FLOOR4_HT 1.2
#define DOG_SPAWN_MINHT 240
#define PERSON_SPAWN_START 3
#define WIENER_SPAWN_START 6
#define SPAWN_LIMIT_DECREMENT_DELAY 15
#define DROPPED_MAX 5
#define COP_RANGE 4

// HelloWorldLayer implementation
@implementation GameplayLayer

@synthesize personLower = _personLower;
@synthesize personUpper = _personUpper;
@synthesize policeArm = _policeArm;
@synthesize wiener = _wiener;
@synthesize target = _target;
@synthesize walkAction = _walkAction;
@synthesize walkFaceAction = _walkFaceAction;
@synthesize idleAction = _idleAction;
@synthesize deathAction = _deathAction;
@synthesize appearAction = _appearAction;
@synthesize idleFaceAction = _idleFaceAction;
@synthesize shotAction = _shotAction;
@synthesize shootAction = _shootAction;
@synthesize shootFaceAction = _shootFaceAction;
@synthesize armShootAction = _armShootAction;
@synthesize hitFace = _hitFace;

+(CCScene *) scene {
    CCScene *scene = [CCScene node];
    GameplayLayer *layer = [GameplayLayer node];
    [scene addChild: layer];
    return scene;
}

- (void)titleScene{
    CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[TitleLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

- (void)loseScene{
    NSMutableArray *loseParams = [[NSMutableArray alloc] initWithCapacity:2];
    [loseParams addObject:[NSNumber numberWithInteger:_points]];
    [loseParams addObject:[NSNumber numberWithInteger:time]];
    [[CCDirector sharedDirector] replaceScene:[LoseLayer sceneWithData:loseParams]];
}

-(void)resumeGame{
    [self removeChild:_pauseMenu cleanup:YES];
    [self removeChild:_pauseLayer cleanup:YES];
    [[CCDirector sharedDirector] resume];
    _pause = false;
}

// TODO - evaluate the possibility of putting as many of these utility functions as possible into an importable file
-(void)flipShootLock{
    if(_shootLock){
        _shootLock = NO;
    } else {
        _shootLock = YES;
    }
}

-(void) pauseButton{
    if(!_pause){
        _pause = true;
        [[CCDirector sharedDirector] pause];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _pauseLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 255, 125) width:390 height:270];
        _pauseLayer.position = ccp((winSize.width/2)-(_pauseLayer.contentSize.width/2), (winSize.height/2)-(_pauseLayer.contentSize.height/2));
        [self addChild:_pauseLayer z:80];

        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Resume Game" fontName:@"LostPet.TTF" fontSize:21.0];
        //CCMenuItem *resume = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(resumeGame)];
        label = [CCLabelTTF labelWithString:@"Paused" fontName:@"LostPet.TTF" fontSize:28.0];
        CCMenuItem *pauseTitle = [CCMenuItemLabel itemWithLabel:label];
        label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d", _points] fontName:@"LostPet.TTF" fontSize:18.0];
        CCMenuItem *score = [CCMenuItemLabel itemWithLabel:label];
        int seconds = time/60;
        int minutes = seconds/60;
        label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Time: %02d:%02d", minutes, seconds%60] fontName:@"LostPet.TTF" fontSize:18.0];
        CCMenuItem *timeItem = [CCMenuItemLabel itemWithLabel:label];
        
        _pauseMenu = [CCMenu menuWithItems:pauseTitle, score, timeItem, nil];
        [_pauseMenu setPosition:ccp(winSize.width/2, winSize.height/2)];
        [_pauseMenu alignItemsVertically];
        [self addChild:_pauseMenu z:81];
    }
}

-(void)introTutorialTextBox:(id)sender data:(void*)params {
    int boxY = 0;
        
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _introLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 255, 125) width:490 height:60];
    _introLayer.position = ccp((winSize.width/2)-(_introLayer.contentSize.width/2), boxY);
    [self addChild:_introLayer z:80];
        
    NSString *text = (NSString *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    tutorialLabel = [CCLabelTTF labelWithString:text fontName:@"LostPet.TTF" fontSize:16.0];
    [tutorialLabel setPosition:ccp(winSize.width/2, boxY+(_introLayer.contentSize.height/2))];
    [_introLayer addChild:tutorialLabel z:81];
}

-(void)tutorialBoxRemove{
    if(_introLayer != NULL){
        [self removeChild:_introLayer cleanup:YES];
        _introLayer = NULL;
    }
}

-(void)debugDraw{
    if(!m_debugDraw){
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        uint32 flags = 0;
        flags += b2DebugDraw::e_shapeBit;
        flags += b2DebugDraw::e_jointBit;
        flags += b2DebugDraw::e_aabbBit;
        flags += b2DebugDraw::e_pairBit;
        flags += b2DebugDraw::e_centerOfMassBit;
        m_debugDraw->SetFlags(flags);
        [[CCDirector sharedDirector] setDisplayFPS:YES];
    } else {
        m_debugDraw = nil;
        [[CCDirector sharedDirector] setDisplayFPS:NO];
    }
    _world->SetDebugDraw(m_debugDraw);
}

-(void)timedDecrement{
    if(!_intro){
        if(_spawnLimiter > 0){
            _spawnLimiter--;
        }
        if(_personSpawnDelayTime > 1){
            _personSpawnDelayTime -= 1;
        }
        if(_wienerSpawnDelayTime > 1){
            _wienerSpawnDelayTime -= 1;
        }
        if(_wienerKillDelay > 1){
            _wienerKillDelay -= 1;
        }
    }
    
}

-(void)setAwake:(id)sender data:(void*)params {
    b2Body *body = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    NSNumber *awake = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];

    if(body != NULL){
        if(awake.intValue == 1){
            body->SetAwake(true);
        }
        else if(awake.intValue == 0){
            body->SetAwake(false);
        }
    }
}

-(void)setRotation:(id)sender data:(void*)params {
    b2Body *body = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    NSNumber *angle = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];

    b2Vec2 pos = body->GetPosition();
    body->SetTransform(pos, angle.intValue);
}

-(void) applyForce:(id)sender data:(void*)params{
    int vThresh;

    b2Body *body = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    NSNumber *v = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];

    CCLOG(@"applyForce: called with vel: %d", v.intValue);

    vThresh = 1;

    //TODO - possibly use setActive() here instead of the kinda-hacky friction manipulation

    b2Vec2 force = b2Vec2(v.intValue, 0);
    body->ApplyLinearImpulse(force, body->GetPosition());

    if(body->GetLinearVelocity().x < vThresh && body->GetLinearVelocity().x > -1*vThresh){
        for(b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext()){
            fixtureUserData *fUd = (fixtureUserData *)f->GetUserData();
            if(fUd->tag >= F_BUSBDY && fUd->tag <= F_TOPBDY){
                f->SetFriction(100);
            }
        }
    } else {
        for(b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext()){
            fixtureUserData *fUd = (fixtureUserData *)f->GetUserData();
            if(fUd->tag >= F_BUSBDY && fUd->tag <= F_TOPBDY){
                f->SetFriction(0);
            }
        }
    }
}

-(void) spriteRunAnim:(id)sender data:(void*)params{
    //takes a sprite and an optional animation
    //if passed an action, run it. otherwise, stop all actions
    CCSprite *sprite = (CCSprite *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    [sprite stopAllActions];
    if([(NSMutableArray *) params count] > 1){
        CCAnimation *anim = (CCAnimation *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:1] pointerValue];
        CCAction *wFAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
        [sprite runAction:wFAction];
    }
}

-(void) draw {
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);

    _world->DrawDebugData();

    if(m_debugDraw){
        if(!_rayTouchingDog)
            glColor4ub(255, 0, 0, 255);
        else
            glColor4ub(0, 255, 0, 255);
        ccDrawLine(CGPointMake(policeRayPoint1.x*PTM_RATIO, policeRayPoint1.y*PTM_RATIO), CGPointMake(policeRayPoint2.x*PTM_RATIO, policeRayPoint2.y*PTM_RATIO));
    }

    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

-(void)destroyWiener:(id)sender data:(void*)params {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    b2Body *dogBody = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();

    CCSprite *dogSprite = (CCSprite *)sender;

    CCLOG(@"Destroying dog (tag %d)...", dogSprite.tag);

    if(dogSprite.tag == S_HOTDOG){
        dogBody->SetAwake(false);
        [dogSprite stopAllActions];
        [dogSprite removeFromParentAndCleanup:YES];
        [ud->overlaySprite removeFromParentAndCleanup:YES];
        
        if(_mouseJoint){
            _world->DestroyJoint(_mouseJoint);
            _mouseJoint = NULL;
        }
        
        _world->DestroyBody(dogBody);

        free(ud);
        dogBody->SetUserData(NULL);
        dogBody = nil;

        if(!_intro){
            CCSprite *dogDroppedIcon = [CCSprite spriteWithSpriteFrameName:@"WienerCount_X.png"];
            dogDroppedIcon.position = ccp(winSize.width-_droppedSpacing, 305);
            [self addChild:dogDroppedIcon z:72];
            _droppedCount++;
            _droppedSpacing += 14;
        } else if(_intro && !_dogHasDied){
            _dogHasDied = true;
            _firstDeathTime = time;
            
            winUpDelay = [CCDelayTime actionWithDuration:7];
            winDownDelay = [CCDelayTime actionWithDuration:1];
            removeWindow = [CCCallFuncN actionWithTarget:self selector:@selector(tutorialBoxRemove)];
            
            NSMutableArray *textBoxParameters = [[NSMutableArray alloc] initWithCapacity:1];
            [textBoxParameters addObject:[NSValue valueWithPointer:[NSString stringWithString:@"Oh man, it died!"]]];
            id tutorialWindow1 = [CCCallFuncND actionWithTarget:self selector:@selector(introTutorialTextBox:data:) data:textBoxParameters];
            
            id windowSeq = [CCSequence actions:tutorialWindow1, winUpDelay, removeWindow, nil];
            [self runAction:windowSeq];
        }
    }

    CCLOG(@"done.");
}

-(void)copFlipAim:(id)sender data:(void*)params {
    b2Body *copBody = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    bodyUserData *ud = (bodyUserData *)copBody->GetUserData();

    if(ud->aiming){
        ud->aiming = false;
    } else {
        ud->aiming = true;
    }
}

-(void)dogFlipAimedAt:(id)sender data:(void*)params {
    b2Body *dogBody = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
    
    if(ud->aimedAt){
        ud->aimedAt = false;
    } else {
        ud->aimedAt = true;
    }
}

-(void)putDog:(id)sender data:(void*)params {
    int floor, f;
    CGPoint location = [(NSValue *)[(NSMutableArray *) params objectAtIndex: 0] CGPointValue];

    //add base sprite to scene
    self.wiener = [CCSprite spriteWithSpriteFrameName:@"dog54x12.png"];
    _wiener.position = ccp(location.x, location.y);
    _wiener.tag = S_HOTDOG;
    [self addChild:_wiener];

    CCSprite *target = [CCSprite spriteWithSpriteFrameName:@"cop_target.png"];
    target.position = ccp(location.x, location.y);
    target.tag = S_CRSHRS;
    target.visible = false;
    [self addChild:target];

    //create death animation
    NSMutableArray *wienerDeathAnimFrames = [[NSMutableArray alloc] initWithCapacity:9];
    for(int i = 1; i <= 9; i++){
        [wienerDeathAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Dog_Die_%d.png", i]]];
    }
    dogDeathAnim = [CCAnimation animationWithFrames:wienerDeathAnimFrames delay:.1f];
    self.deathAction = [[CCAnimate alloc] initWithAnimation:dogDeathAnim];
    [wienerDeathAnimFrames release];

    //create shot animation
    NSMutableArray *wienerShotAnimFrames = [[NSMutableArray alloc] initWithCapacity:5];
    for(int i = 1; i <= 5; i++){
        [wienerShotAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Dog_Shot_%d.png", i]]];
    }
    dogShotAnim = [CCAnimation animationWithFrames:wienerShotAnimFrames delay:.1f ];
    self.shotAction = [[CCAnimate alloc] initWithAnimation:dogShotAnim restoreOriginalFrame:NO];
    [wienerShotAnimFrames release];

    //create appear animation
    NSMutableArray *wienerAppearAnimFrames = [[NSMutableArray alloc] initWithCapacity:10];
    for(int i = 1; i <= 10; i++){
        [wienerAppearAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Dog_Appear_%d.png", i]]];
    }
    dogAppearAnim = [CCAnimation animationWithFrames:wienerAppearAnimFrames delay:.08f];
    self.appearAction = [CCAnimate actionWithAnimation:dogAppearAnim];
    [wienerAppearAnimFrames release];

    //set up the userdata structures
    bodyUserData *ud = new bodyUserData();
    ud->sprite1 = _wiener;
    ud->altAction = _deathAction;
    ud->altAction2 = _shotAction;
    //TODO - remove the overlay sprite here since it's now the cop's deal
    ud->overlaySprite = target;
    ud->aimedAt = false;

    fixtureUserData *fUd1 = new fixtureUserData();
    fUd1->ogCollideFilters = 0;
    fUd1->tag = F_DOGGRB;

    //for the collision fixture userdata struct, randomly assign floor
    fixtureUserData *fUd2 = new fixtureUserData();
    floor = arc4random() % 4;
    f = 0xfffff000; //any person
    if(floor == 1){
        f = f | FLOOR1;
    }
    else if(floor == 2){
        f = f | FLOOR2;
    }
    else if(floor == 3){
        f = f | FLOOR3;
    }
    else {
        f = f | FLOOR4;
    }
    fUd2->ogCollideFilters = f;
    fUd2->tag = F_DOGCLD;

    //create the body
    b2BodyDef wienerBodyDef;
    wienerBodyDef.type = b2_dynamicBody;
    wienerBodyDef.position.Set(location.x/PTM_RATIO, location.y/PTM_RATIO);
    wienerBodyDef.userData = ud;
    wienerBody = _world->CreateBody(&wienerBodyDef);

    //create the grab box fixture
    b2PolygonShape wienerGrabShape;
    wienerGrabShape.SetAsBox((_wiener.contentSize.width+50)/PTM_RATIO/2, (_wiener.contentSize.height+50)/PTM_RATIO/2);
    b2FixtureDef wienerGrabShapeDef;
    wienerGrabShapeDef.shape = &wienerGrabShape;
    wienerGrabShapeDef.filter.categoryBits = WIENER;
    wienerGrabShapeDef.filter.maskBits = 0x0000;
    wienerGrabShapeDef.userData = fUd1;
    _wienerFixture = wienerBody->CreateFixture(&wienerGrabShapeDef);

    //create the collision fixture
    b2PolygonShape wienerShape;
    wienerShape.SetAsBox(_wiener.contentSize.width/PTM_RATIO/2, _wiener.contentSize.height/PTM_RATIO/2);
    b2FixtureDef wienerShapeDef;
    wienerShapeDef.shape = &wienerShape;
    wienerShapeDef.density = 0.5f;
    wienerShapeDef.friction = 1.0f;
    wienerShapeDef.userData = fUd2;
    wienerShapeDef.filter.maskBits = f;
    wienerShapeDef.restitution = 0.3f;
    wienerShapeDef.filter.categoryBits = WIENER;
    _wienerFixture = wienerBody->CreateFixture(&wienerShapeDef);

    wienerBody->SetAwake(false);

    //wake up the hot dog after the appear animation is done
    wakeParameters = [[NSMutableArray alloc] initWithCapacity:2];
    NSValue *v = [NSValue valueWithPointer:wienerBody];
    NSNumber *wake = [NSNumber numberWithInt:1];
    [wakeParameters addObject:v];
    [wakeParameters addObject:wake];
    CCCallFuncND *wakeAction = [CCCallFuncND actionWithTarget:self selector:@selector(setAwake:data:) data:wakeParameters];
    CCSequence *seq = [CCSequence actions:_appearAction, wakeAction, nil];
    [_wiener runAction:seq];

    CCLOG(@"Spawned wiener with maskBits: %d", wienerShapeDef.filter.maskBits);
}

-(void) walkInPauseContinue:(id)sender data:(void*)params{
    //get the passed body, and from it get the sprite and the animation for the head
    b2Body *body = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    NSValue *anim = [NSValue valueWithPointer:((bodyUserData *)body->GetUserData())->altAnimation];
    NSValue *spr = [NSValue valueWithPointer:((bodyUserData *)body->GetUserData())->sprite2];

    //get velocity and idle action from args
    NSNumber *v = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];
    CCSequence *idleAction = (CCSequence *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:2] pointerValue];

    //action calls spriteRunAnim with only a sprite (stops all actions on head sprite)
    headParams = [[NSMutableArray alloc] initWithCapacity:1];
    [headParams addObject:spr];
    CCCallFuncND *headIdle = [CCCallFuncND actionWithTarget:self selector:@selector(spriteRunAnim:data:) data:headParams];

    //action calls spriteRunAnim with both sprite and action to run (starts head walking animation)
    headParams = [[NSMutableArray alloc] initWithCapacity:2];
    [headParams addObject:spr];
    [headParams addObject:anim];
    CCCallFuncND *headWalk = [CCCallFuncND actionWithTarget:self selector:@selector(spriteRunAnim:data:) data:headParams];

    //set up walking / animation actions
    CCCallFuncND *walkAction = [CCCallFuncND actionWithTarget:self selector:@selector(applyForce:data:) data:(NSMutableArray *) params];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:(((float)(arc4random() % 2000))/1000)];
    movementParameters = [[NSMutableArray alloc] initWithCapacity:2];
    NSNumber *opposite = [NSNumber numberWithInt:v.intValue*-1];
    [movementParameters addObject:(NSValue *)[(NSMutableArray *) params objectAtIndex:0]];
    [movementParameters addObject:opposite];
    CCCallFuncND *pauseAction = [CCCallFuncND actionWithTarget:self selector:@selector(applyForce:data:) data:movementParameters];
    //push forward, wait, stop, stop head animation, start idle body anim, when idle anim ends start head anim, start walk anim, push forward
    CCSequence *walkInPauseContinue = [CCSequence actions: walkAction, delay, pauseAction, headIdle, idleAction, headWalk, walkAction, nil];
    [sender runAction:walkInPauseContinue];
}

-(void)walkAcross:(id)sender data:(void *)params{
    CCCallFuncND *walkAction = [CCCallFuncND actionWithTarget:self selector:@selector(applyForce:data:) data:(NSMutableArray *) params];
    CCSequence *walkAcross = [CCSequence actions: walkAction, nil];
    [sender runAction:walkAcross];
}

-(void)walkIn:(id)sender data:(void *)params {
    int xVel, velocityMul, zIndex, fTag, armOffset, lowerArmAngle, upperArmAngle, armBodyXOffset, armBodyYOffset;
    int armJointXOffset, armJointYOffset;
    float hitboxHeight, hitboxWidth, hitboxCenterX, hitboxCenterY, density, restitution, friction, heightOffset;
    NSString *ogHeadSprite;
    BOOL spawn;

    CGSize winSize = [CCDirector sharedDirector].winSize;

    spawn = YES;
    // cycle through a set of several possible mask/category bits for dog/person collision
    // this is so that a dog can be told only to collide with the person who it's touching already,
    // or to collide with all people. this breaks when there are more than 4 people onscreen
    if(_curPersonMaskBits >= 0x8000){
        _curPersonMaskBits = 0x1000;
    } else {
        _curPersonMaskBits *= 2;
    }
    NSNumber *floorBit = [floorBits objectAtIndex:arc4random() % [floorBits count]];
    NSNumber *character = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];

    //first, see if a person should spawn
    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
            bodyUserData *ud = (bodyUserData *)body->GetUserData();
            if(ud->sprite1.tag >= S_BUSMAN && ud->sprite1.tag <= S_TOPPSN){
                if(ud->sprite1.tag == S_POLICE && character.intValue == 4){
                    spawn = NO;
                }
                for(b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext()){
                    if(f->GetFilterData().maskBits == floorBit.intValue){
                        if(ud->sprite1.flipX != _personLower.flipX){
                            spawn = NO;
                        }
                    }
                }
            }
        }
    }

    //if we're not supposed to spawn , just skip all this
    if(spawn){
        NSNumber *xPos = (NSNumber *)[(NSMutableArray *) params objectAtIndex:0];
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        NSMutableArray *idleAnimFrames = [NSMutableArray array];
        NSMutableArray *faceWalkAnimFrames = [NSMutableArray array];
        NSMutableArray *faceDogWalkAnimFrames = [NSMutableArray array];
        NSMutableArray *shootAnimFrames;
        NSMutableArray *shootFaceAnimFrames;
        NSMutableArray *armShootAnimFrames;
        CCSprite *target;

        switch(character.intValue){
            case 3: //businessman
                self.personLower = [CCSprite spriteWithSpriteFrameName:@"BusinessMan_Walk_1.png"];
                self.personUpper = [CCSprite spriteWithSpriteFrameName:@"BusinessHead_NoDog_1.png"];
                self.hitFace = [NSString stringWithString:@"BusinessHead_Dog_1.png"];
                ogHeadSprite = [NSString stringWithString:@"BusinessHead_NoDog_1.png"];
                _personLower.tag = S_BUSMAN;
                _personUpper.tag = S_BUSMAN;
                hitboxWidth = 22.0;
                hitboxHeight = .0001;
                hitboxCenterX = 0;
                hitboxCenterY = 4;
                velocityMul = 300;
                density = 10.0f;
                restitution = .8f; //bounce
                friction = 0.3f;
                fTag = F_BUSHED;
                heightOffset = 2.9f;
                for(int i = 1; i <= 6; i++){
                    [walkAnimFrames addObject:
                     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                      [NSString stringWithFormat:@"BusinessMan_Walk_%d.png", i]]];
                }
                for(int i = 1; i <= 2; i++){
                    [idleAnimFrames addObject:
                     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                      [NSString stringWithFormat:@"BusinessMan_Idle_%d.png", i]]];
                }
                for(int i = 1; i <= 3; i++){
                    [faceWalkAnimFrames addObject:
                     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                      [NSString stringWithFormat:@"BusinessHead_NoDog_%d.png", i]]];
                }
                for(int i = 1; i <= 3; i++){
                    [faceDogWalkAnimFrames addObject:
                     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                      [NSString stringWithFormat:@"BusinessHead_Dog_%d.png", i]]];
                }
                break;
            case 4: //police
                shootAnimFrames = [NSMutableArray array];
                shootFaceAnimFrames = [NSMutableArray array];
                armShootAnimFrames = [NSMutableArray array];
                self.personLower = [CCSprite spriteWithSpriteFrameName:@"Cop_Run_1.png"];
                self.personUpper = [CCSprite spriteWithSpriteFrameName:@"Cop_Head_NoDog_1.png"];
                self.hitFace = [NSString stringWithString:@"Cop_Head_Dog_1.png"];
                self.policeArm = [CCSprite spriteWithSpriteFrameName:@"cop_arm.png"];
                ogHeadSprite = [NSString stringWithString:@"Cop_Head_NoDog_1.png"];
                _policeArm.tag = S_COPARM;
                _personLower.tag = S_POLICE;
                _personUpper.tag = S_POLICE;
                hitboxWidth = 22.0;
                hitboxHeight = .0001;
                hitboxCenterX = 0;
                hitboxCenterY = 4.1;
                velocityMul = 350;
                density = 6.0f;
                restitution = .5f; //bounce
                friction = 4.0f;
                fTag = F_COPHED;
                heightOffset = 2.9f;
                lowerArmAngle = 0;
                upperArmAngle = 55;
                armBodyXOffset = 8;
                armBodyYOffset = 40;
                armJointXOffset = 15;
                armJointYOffset = 40;
                target = [CCSprite spriteWithSpriteFrameName:@"cop_target.png"];
                for(int i = 1; i <= 8; i++){
                    [walkAnimFrames addObject:
                     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                      [NSString stringWithFormat:@"Cop_Run_%d.png", i]]];
                }
                [idleAnimFrames addObject:
                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                  [NSString stringWithString:@"Cop_Idle.png"]]];
                for(int i = 1; i <= 4; i++){
                    [faceWalkAnimFrames addObject:
                     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                      [NSString stringWithFormat:@"Cop_Head_NoDog_%d.png", i]]];
                }
                for(int i = 1; i <= 4; i++){
                    [faceDogWalkAnimFrames addObject:
                     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                      [NSString stringWithFormat:@"Cop_Head_Dog_%d.png", i]]];
                }
                for(int i = 1; i <= 2; i++){
                    [shootAnimFrames addObject:
                     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                      [NSString stringWithFormat:@"Cop_Shoot_%d.png", i]]];
                }
                for(int i = 1; i <= 2; i++){
                    [shootFaceAnimFrames addObject:
                     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                      [NSString stringWithFormat:@"Cop_Head_Shoot_%d.png", i]]];
                }
                break;
        }

        //set secondary values based on the direction of the walk
        if(xPos.intValue > winSize.width - 10){
            xVel = -1*velocityMul;
            if(character.intValue == 4){
                armOffset = 38;
                armBodyXOffset = -6;
                armJointXOffset = -10;
                lowerArmAngle = 125;
                upperArmAngle = 175;
                _policeArm.flipX = YES;
                _policeArm.flipY = YES;
            }
        }
        else {
            _personLower.flipX = YES;
            _personUpper.flipX = YES;
            if(character.intValue == 4){
                _policeArm.flipX = YES;
                armOffset = 30;
            }
            xVel = 1*velocityMul;
        }
        if(floorBit.intValue == 1){
            zIndex = 42;
        }
        else if(floorBit.intValue == 2){
            zIndex = 32;
        }
        else if(floorBit.intValue == 4){
            zIndex = 22;
        }
        else{
            zIndex = 12;
        }

        //create animations for walk, idle, and bobbing head
        walkAnim = [[CCAnimation animationWithFrames:walkAnimFrames delay:.08f] retain];
        self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]];
        [_personLower runAction:_walkAction];

        idleAnim = [CCAnimation animationWithFrames:idleAnimFrames delay:.2f];
        self.idleAction = [CCAnimate actionWithAnimation:idleAnim];
        CCRepeat *repeatAction = [CCRepeat actionWithAction:_idleAction times:10];
        CCSequence *sequence = [CCSequence actions:_idleAction, repeatAction, nil];

        walkFaceAnim = [[CCAnimation animationWithFrames:faceWalkAnimFrames delay:.08f] retain];
        self.walkFaceAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkFaceAnim restoreOriginalFrame:NO]];
        [_personUpper runAction:_walkFaceAction];
        
        walkDogFaceAnim = [[CCAnimation animationWithFrames:faceDogWalkAnimFrames delay:.08f] retain];

        if(character.intValue == 4){
            shootAnim = [[CCAnimation animationWithFrames:shootAnimFrames delay:.08f] retain];
            self.shootAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:shootAnim restoreOriginalFrame:NO] times:1];
            
            shootFaceAnim = [[CCAnimation animationWithFrames:shootFaceAnimFrames delay:.08f] retain];
            self.shootFaceAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:shootFaceAnim restoreOriginalFrame:YES] times:1];
            
            target.tag = S_CRSHRS;
            [self addChild:target];
        }

        //put the sprites in place
        _personLower.position = ccp(xPos.intValue, 123);
        _personUpper.position = ccp(xPos.intValue, 123);
        [spriteSheet addChild:_personLower z:zIndex];
        [spriteSheet addChild:_personUpper z:zIndex+2];
        if(character.intValue == 4){
            _policeArm.position = ccp(xPos.intValue, 123);
            [spriteSheet addChild:_policeArm z:zIndex-2];
        }

        //set up userdata structs
        bodyUserData *ud = new bodyUserData();
        ud->sprite1 = _personLower;
        ud->sprite2 = _personUpper;
        ud->defaultAnim = walkAnim;
        ud->altWalkAnim = walkDogFaceAnim;
        ud->heightOffset2 = heightOffset;
        ud->ogSprite2 = ogHeadSprite;
        ud->altSprite2 = _hitFace;
        ud->altAction = _walkFaceAction;
        ud->altAnimation = walkFaceAnim;
        ud->aiming = false;
        if(character.intValue == 4){
            ud->altAction2 = _shootAction;
            ud->altAction3 = _shootFaceAction;
            ud->overlaySprite = target;
        }

        fixtureUserData *fUd1 = new fixtureUserData();
        fUd1->tag = fTag;

        fixtureUserData *fUd2 = new fixtureUserData();
        fUd2->tag = 50+fTag;

        //create the body/bodies and fixtures for various collisions
        b2BodyDef personBodyDef;
        personBodyDef.type = b2_dynamicBody;
        personBodyDef.position.Set(xPos.floatValue/PTM_RATIO, 123.0f/PTM_RATIO);
        personBodyDef.userData = ud;
        personBodyDef.fixedRotation = true;
        _personBody = _world->CreateBody(&personBodyDef);

        //fixture for head hitbox
        b2PolygonShape personShape;
        personShape.SetAsBox(hitboxWidth/PTM_RATIO, hitboxHeight/PTM_RATIO, b2Vec2(hitboxCenterX, hitboxCenterY), 0);
        b2FixtureDef personShapeDef;
        personShapeDef.shape = &personShape;
        personShapeDef.density = 0;
        personShapeDef.friction = friction;
        personShapeDef.restitution = restitution;
        personShapeDef.userData = fUd1;
        personShapeDef.filter.categoryBits = _curPersonMaskBits;
        CCLOG(@"personMaskBits: %d", _curPersonMaskBits);
        personShapeDef.filter.maskBits = WIENER;
        _personFixture = _personBody->CreateFixture(&personShapeDef);

        //fixture for body
        b2PolygonShape personBodyShape;
        personBodyShape.SetAsBox(_personLower.contentSize.width/PTM_RATIO/2,(_personLower.contentSize.height)/PTM_RATIO/2);
        b2FixtureDef personBodyShapeDef;
        personBodyShapeDef.shape = &personBodyShape;
        personBodyShapeDef.density = density;
        personBodyShapeDef.friction = 0;
        personBodyShapeDef.restitution = 0;
        personBodyShapeDef.filter.categoryBits = BODYBOX;
        personBodyShapeDef.userData = fUd2;
        personBodyShapeDef.filter.maskBits = floorBit.intValue;
        _personFixture = _personBody->CreateFixture(&personBodyShapeDef);

        if(character.intValue == 4){
            //create the cop's arm body if we need to
            for(int i = 1; i <= 2; i++){
                [armShootAnimFrames addObject:
                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                  [NSString stringWithFormat:@"Cop_Arm_Shoot_%d.png", i]]];
            }

            armShootAnim = [[CCAnimation animationWithFrames:armShootAnimFrames delay:.08f] retain];
            self.armShootAction = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:armShootAnim restoreOriginalFrame:YES] times:1];

            bodyUserData *ud = new bodyUserData();
            ud->sprite1 = _policeArm;
            ud->altAction = _armShootAction;

            b2BodyDef armBodyDef;
            armBodyDef.type = b2_dynamicBody;
            armBodyDef.position.Set((_personLower.position.x+(_policeArm.contentSize.width/2)+armBodyXOffset)/PTM_RATIO,
                                    (_personLower.position.y+(armBodyYOffset))/PTM_RATIO);
            armBodyDef.userData = ud;
            _policeArmBody = _world->CreateBody(&armBodyDef);

            fixtureUserData *fUd = new fixtureUserData();
            b2PolygonShape armShape;
            armShape.SetAsBox(_policeArm.contentSize.width/PTM_RATIO/2, _policeArm.contentSize.height/PTM_RATIO/2);
            b2FixtureDef armShapeDef;
            armShapeDef.shape = &armShape;
            armShapeDef.density = 0.0001;
            fUd->tag = F_COPARM;
            armShapeDef.userData = fUd;
            armShapeDef.filter.maskBits = 0x0000;
            _policeArmFixture = _policeArmBody->CreateFixture(&armShapeDef);

            //"shoulder" joint
            b2RevoluteJointDef armJointDef;
            armJointDef.Initialize(_personBody, _policeArmBody,
                                   b2Vec2((_personLower.position.x+(armJointXOffset))/PTM_RATIO,
                                          (_personLower.position.y+(armJointYOffset))/PTM_RATIO));
            armJointDef.enableMotor = true;
            armJointDef.enableLimit = true;
            armJointDef.motorSpeed = 0.0f;
            armJointDef.maxMotorTorque = 10000.0f;
            armJointDef.lowerAngle = CC_DEGREES_TO_RADIANS(lowerArmAngle);
            armJointDef.upperAngle = CC_DEGREES_TO_RADIANS(upperArmAngle);

            policeArmJoint = (b2RevoluteJoint*)_world->CreateJoint(&armJointDef);
        }

        //call the appropriate walking function
        movementParameters = [[NSMutableArray alloc] initWithCapacity:4];
        NSNumber *v = [NSNumber numberWithInt:xVel];
        NSValue *b = [NSValue valueWithPointer:_personBody];
        NSValue *idle = [NSValue valueWithPointer:sequence];
        [movementParameters addObject:b];
        [movementParameters addObject:v];
        [movementParameters addObject:idle];
        if(character.intValue != 4){
            [self walkInPauseContinue:_personLower data:movementParameters];
        } else {
            [self walkAcross:_personLower data:movementParameters];
        }
        CCLOG(@"Spawned person with tag %d", fTag);
    } //the end of the if(spawn) conditional
}

-(void)wienerCallback:(id)sender data:(void *)params {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [self putDog:self data:params];

    wienerParameters = [[NSMutableArray alloc] initWithCapacity:1];
    NSValue *location = [NSValue valueWithCGPoint:CGPointMake(arc4random() % (int)winSize.width, DOG_SPAWN_MINHT+(arc4random() % (int)(winSize.height-DOG_SPAWN_MINHT)))];
    [wienerParameters addObject:location];

    id delay = [CCDelayTime actionWithDuration:_wienerSpawnDelayTime];
    id callBackAction = [CCCallFuncND actionWithTarget: self selector: @selector(wienerCallback:data:) data:wienerParameters];
    id sequence = [CCSequence actions: delay, callBackAction, nil];
    [self runAction:sequence];
}

-(void)spawnCallback:(id)sender data:(void *)params {
    NSNumber *xPos = (NSNumber *)[(NSMutableArray *) params objectAtIndex:0];
    NSNumber *characterTag = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];

    NSNumber *xPosition = [xPositions objectAtIndex:arc4random() % [xPositions count]];
    xPos = [NSNumber numberWithInt:xPosition.intValue];

    characterTag = [characterTags objectAtIndex:arc4random() % ([characterTags count]-_spawnLimiter)];

    [self walkIn:self data:params];

    personParameters = [[NSMutableArray alloc] initWithCapacity:3];
    [personParameters addObject:xPos];
    [personParameters addObject:characterTag];

    id delay = [CCDelayTime actionWithDuration:_personSpawnDelayTime];
    id callBackAction = [CCCallFuncND actionWithTarget: self selector: @selector(spawnCallback:data:) data:personParameters];
    id sequence = [CCSequence actions: delay, callBackAction, nil];
    [self runAction:sequence];
}

-(id) init {
    if( (self=[super init])) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
        // uncomment this to test the intro sequence / reset high score
        [standardUserDefaults setInteger:0 forKey:@"introDone"];
        //[standardUserDefaults setInteger:0 forKey:@"highScore"];
        [standardUserDefaults synchronize];

        //basic game/box2d/cocos2d initialization
        self.isAccelerometerEnabled = YES;
        self.isTouchEnabled = YES;
        time = 0;
        _pause = false;
        _intro = true;
        _dogHasHitGround = false;
        _lastTouchTime = 0;
        _curPersonMaskBits = 0x1000;
        _spawnLimiter = [characterTags count] - ([characterTags count]-1);
        _personSpawnDelayTime = PERSON_SPAWN_START;
        _wienerSpawnDelayTime = WIENER_SPAWN_START;
        _wienerKillDelay = 4.0f;
        _points = 0;
        _shootLock = NO;
        _droppedSpacing = 33;
        _droppedCount = 0;
        _currentRayAngle = 0;
        b2Vec2 gravity = b2Vec2(0.0f, -30.0f);
        _world = new b2World(gravity, true);
        //create spriteFrameCache from sprite sheet
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_default.png"];
        [self addChild:spriteSheet];
        //contact listener init
        personDogContactListener = new PersonDogContactListener();
        _world->SetContactListener(personDogContactListener);
        
        // if the intro has already been completed, don't do it again
        NSInteger introDone = [standardUserDefaults integerForKey:@"introDone"];
        NSLog(@"IntroDone: %d", introDone);
        if(introDone == 1)
            _intro = false;
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"bg_philly.png"];
        background.anchorPoint = CGPointZero;
        [self addChild:background z:-10];

        //HUD objects
        CCSprite *droppedLeftEnd = [CCSprite spriteWithSpriteFrameName:@"WienerCount_LeftEnd.png"];;
        droppedLeftEnd.position = ccp(winSize.width-100, 305);
        [self addChild:droppedLeftEnd z:70];
        CCSprite *droppedRightEnd = [CCSprite spriteWithSpriteFrameName:@"WienerCount_RightEnd.png"];;
        droppedRightEnd.position = ccp(winSize.width-23, 305);
        [self addChild:droppedRightEnd z:70];
        for(int i = 33; i < 103; i += 14){
            CCSprite *dogIcon = [CCSprite spriteWithSpriteFrameName:@"WienerCount_Wiener.png"];
            dogIcon.position = ccp(winSize.width-i, 305);
            [self addChild:dogIcon z:70];
        }

        //CCSprite *scoreBG = [CCSprite spriteWithSpriteFrameName:@".png"];;
        //scoreBG.position = ccp(winSize.width-22, 305);
        //[self addChild:scoreBG z:100];

        //labels for score
        scoreText = [[NSString alloc] initWithFormat:@"%d", _points];
        scoreLabel = [CCLabelTTF labelWithString:scoreText fontName:@"LostPet.TTF" fontSize:18];
        scoreLabel.color = ccc3(245, 222, 179);
        scoreLabel.position = ccp(winSize.width-42, 280);
        [self addChild: scoreLabel];
        
        //TODO - uncomment the conditional, it's commented out for testing only
        //if(!_intro){
            NSInteger highScore = [standardUserDefaults integerForKey:@"highScore"];
            CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HI: %d", highScore] fontName:@"LostPet.TTF" fontSize:18.0];
            highScoreLabel.color = ccc3(245, 222, 179);
            highScoreLabel.position = ccp(winSize.width/2, 305);
            [self addChild: highScoreLabel];
        //}

        _pauseButton = [CCSprite spriteWithSpriteFrameName:@"Pause_Button.png"];;
        _pauseButton.position = ccp(20, 305);
        [self addChild:_pauseButton z:70];
        _pauseButtonRect = CGRectMake((_pauseButton.position.x-(_pauseButton.contentSize.width)/2), (_pauseButton.position.y-(_pauseButton.contentSize.height)/2), (_pauseButton.contentSize.width), (_pauseButton.contentSize.height));
        
        //debug labels
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Debug draw" fontName:@"LostPet.TTF" fontSize:18.0];
        CCMenuItem *debug = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(debugDraw)];
        CCMenu *menu = [CCMenu menuWithItems:debug, nil];
        [menu setPosition:ccp(40, winSize.height-50)];
        [menu alignItemsVertically];
        [self addChild:menu];

        //initialize global arrays for possible x,y positions and charTags
        floorBits = [[NSMutableArray alloc] initWithCapacity:4];;
        for(int i = 1; i <= 8; i *= 2){
            [floorBits addObject:[NSNumber numberWithInt:i]];
        }
        xPositions = [[NSMutableArray alloc] initWithCapacity:2];
        // TODO - widen both these and the floors so we can't see people dropping in from the sides
        [xPositions addObject:[NSNumber numberWithInt:winSize.width]];
        [xPositions addObject:[NSNumber numberWithInt:0]];
        characterTags = [[NSMutableArray alloc] initWithCapacity:2];
        for(int i = S_BUSMAN; i <= S_POLICE; i++){ // to allow for more characters, pick a value > S_POLICE && < S_TOPPSN
            [characterTags addObject:[NSNumber numberWithInt:i]];
        }
        movementParameters = [[NSMutableArray alloc] initWithCapacity:2];

        fixtureUserData *fUd = new fixtureUserData();
        fUd->tag = F_GROUND;

        //set up the floors
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        groundBodyDef.userData = (void *)100;
        _groundBody = _world->CreateBody(&groundBodyDef);
        b2PolygonShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        groundBoxDef.filter.categoryBits = FLOOR1;
        groundBoxDef.userData = fUd;
        groundBox.SetAsEdge(b2Vec2(0,FLOOR1_HT), b2Vec2(winSize.width/PTM_RATIO, FLOOR1_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR2;
        groundBox.SetAsEdge(b2Vec2(0,FLOOR2_HT), b2Vec2(winSize.width/PTM_RATIO, FLOOR2_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR3;
        groundBox.SetAsEdge(b2Vec2(0,FLOOR3_HT), b2Vec2(winSize.width/PTM_RATIO, FLOOR3_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR4;
        groundBox.SetAsEdge(b2Vec2(0,FLOOR4_HT), b2Vec2(winSize.width/PTM_RATIO, FLOOR4_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

        //set up the walls
        b2BodyDef wallsBodyDef;
        wallsBodyDef.position.Set(0,0);
        _wallsBody = _world->CreateBody(&wallsBodyDef);
        b2PolygonShape wallsBox;
        b2FixtureDef wallsBoxDef;
        wallsBoxDef.shape = &wallsBox;
        wallsBoxDef.filter.categoryBits = WALLS;
        wallsBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        _wallsFixture = _wallsBody->CreateFixture(&wallsBoxDef);
        wallsBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        _wallsBody->CreateFixture(&wallsBoxDef);
        wallsBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
        _wallsBody->CreateFixture(&wallsBoxDef);

        //schedule callbacks for dogs, people, and game value decrements
        personParameters = [[NSMutableArray alloc] initWithCapacity:2];
        NSNumber *xPos = [NSNumber numberWithInt:winSize.width];
        NSNumber *character = [NSNumber numberWithInt:3];
        [personParameters addObject:xPos];
        [personParameters addObject:character];
        [self spawnCallback:self data:personParameters];

        NSMutableArray *wienerParams = [[NSMutableArray alloc] initWithCapacity:1];
        NSValue *location = [NSValue valueWithCGPoint:CGPointMake(200, 200)];
        [wienerParams addObject:location];
        [self wienerCallback:self data:wienerParams];

        CCDelayTime *delay = [CCDelayTime actionWithDuration:SPAWN_LIMIT_DECREMENT_DELAY];
        CCCallFunc *decrementLimitAction = [CCCallFunc actionWithTarget:self selector:@selector(timedDecrement)];
        CCSequence *sequence = [CCSequence actions: delay, decrementLimitAction, nil];
        CCSequence *s = [CCRepeatForever actionWithAction:sequence];
        [self runAction:s];

        [self schedule: @selector(tick:)];
    }
    return self;
}

//the "GAME LOOP"
-(void) tick: (ccTime) dt {
    int32 velocityIterations = 3;
    int32 positionIterations = 1;

    CGSize winSize = [CCDirector sharedDirector].winSize;

    if(_pause){
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Pause" fontName:@"LostPet.TTF" fontSize:18.0];
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(pause)];
        label = [CCLabelTTF labelWithString:@"Menu" fontName:@"LostPet.TTF" fontSize:18.0];
        CCMenuItem *debug = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(debugDraw)];
        CCMenu *menu = [CCMenu menuWithItems:button, debug, nil];
        [menu setPosition:ccp(40, winSize.height-30)];
        [menu alignItemsVertically];
        [self addChild:menu];
        return;
    }

    time++;

    //the "LOSE CONDITION"
    if(_droppedCount >= DROPPED_MAX){
        [self loseScene];
    }
    
    if(_dogHasDied && time - _firstDeathTime == 800 && _intro){
        winUpDelay = [CCDelayTime actionWithDuration:4];
        winDownDelay = [CCDelayTime actionWithDuration:.5];
        removeWindow = [CCCallFuncN actionWithTarget:self selector:@selector(tutorialBoxRemove)];
        
        NSMutableArray *textBoxParameters = [[NSMutableArray alloc] initWithCapacity:1];
        [textBoxParameters addObject:[NSValue valueWithPointer:[NSString stringWithString:@"There's another! Quick, save it!"]]];
        id tutorialWindow1 = [CCCallFuncND actionWithTarget:self selector:@selector(introTutorialTextBox:data:) data:textBoxParameters];
        
        textBoxParameters = [[NSMutableArray alloc] initWithCapacity:1];
        [textBoxParameters addObject:[NSValue valueWithPointer:[NSString stringWithString:@"Put it somewhere safe..."]]];
        id tutorialWindow2 = [CCCallFuncND actionWithTarget:self selector:@selector(introTutorialTextBox:data:) data:textBoxParameters];
        
        textBoxParameters = [[NSMutableArray alloc] initWithCapacity:1];
        [textBoxParameters addObject:[NSValue valueWithPointer:[NSString stringWithString:@"Touch a dog and drag it to place it somewhere safe"]]];
        id tutorialWindow3 = [CCCallFuncND actionWithTarget:self selector:@selector(introTutorialTextBox:data:) data:textBoxParameters];
        
        id tutorialSeq = [CCSequence actions:tutorialWindow1, winUpDelay, removeWindow, winDownDelay, tutorialWindow2, winUpDelay, removeWindow,
                          winDownDelay, tutorialWindow3, winUpDelay, removeWindow, nil];
        [self runAction:tutorialSeq];
    }

    _world->Step(dt, velocityIterations, positionIterations);

    //score and dropped count
    [scoreLabel setString:[NSString stringWithFormat:@"%d", _points]];
    [droppedLabel setString:[NSString stringWithFormat:@"%d", _droppedCount]];

    PersonDogContact pdContact;

    //collision detection happens in this loop
    std::vector<PersonDogContact>::iterator pos;
    for(pos = personDogContactListener->contacts.begin();
        pos != personDogContactListener->contacts.end(); ++pos)
    {
        b2Body *pBody;
        b2Body *dogBody;
        pdContact = *pos;

        if(pdContact.fixtureA->GetBody() != NULL){
            dogBody = pdContact.fixtureA->GetBody();
        }

        if(dogBody){
            fixtureUserData *fBUd = (fixtureUserData *)pdContact.fixtureB->GetUserData();
            if(fBUd->tag >= F_BUSHED && fBUd->tag <= F_TOPHED){
                if(_intro && time - _lastTouchTime < 80){
                    _intro = false;
                    [standardUserDefaults setInteger:1 forKey:@"introDone"];
                    [standardUserDefaults synchronize];
                }
                pBody = pdContact.fixtureB->GetBody();
                CCLOG(@"Dog/Person Collision - Y Vel: %0.2f", dogBody->GetLinearVelocity().x);
                bodyUserData *pUd = (bodyUserData *)pBody->GetUserData();
                CCAnimation *faceDogWalkAnim = (CCAnimation *)pUd->altWalkAnim;
                CCAction *faceDogWalkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:faceDogWalkAnim restoreOriginalFrame:NO]];
                if(abs(pBody->GetLinearVelocity().x) > 1){
                    [pUd->sprite2 stopAllActions];
                    [pUd->sprite2 runAction:faceDogWalkAction];
                } else {
                    [pUd->sprite2 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:(NSString *)pUd->altSprite2]];
                }
                b2Filter dogFilter, personFilter;
                for(b2Fixture* fixture = pBody->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    if(fUd->tag >= F_BUSHED && fUd->tag <= F_TOPHED){
                        personFilter = fixture->GetFilterData();
                    }
                }
                for(b2Fixture* fixture = dogBody->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    if(fUd->tag == F_DOGCLD){
                        dogFilter = fixture->GetFilterData();
                        // only allow the dog to collide with the person it's on
                        // by setting its mask bits to the person's category bits
                        dogFilter.maskBits = personFilter.categoryBits;
                        fixture->SetFilterData(dogFilter);
                    }
                }
                int particle = (arc4random() % 3) + 1;
                bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
                CCNode *contactNode = (CCNode *)ud->sprite1;
                CGPoint position = contactNode.position;
                CCParticleSystem* heartParticles = [CCParticleFire node];
                ccColor4F startColor = {1, 1, 1, 1};
                ccColor4F endColor = {1, 1, 1, 0};
                heartParticles.startColor = startColor;
                heartParticles.endColor = endColor;
                heartParticles.texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"Heart_Particle_%d.png", particle]];
                heartParticles.blendFunc = (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
                heartParticles.autoRemoveOnFinish = YES;
                heartParticles.startSize = 1.0f;
                heartParticles.speed = 90.0f;
                heartParticles.anchorPoint = ccp(0.5f,0.5f);
                heartParticles.position = position;
                heartParticles.duration = 0.1f;
                [self addChild:heartParticles z:60];
                if(!_intro){
                    switch(pUd->sprite1.tag){
                        case 3: _points += 100; break;
                        case 4: _points += 300; break;
                        default: _points += 100; break;
                    }
                }
            }
            else if (fBUd->tag == F_GROUND){
                if(_intro && !_dogHasHitGround){
                    _dogHasHitGround = true;
                    
                    winUpDelay = [CCDelayTime actionWithDuration:4];
                    winDownDelay = [CCDelayTime actionWithDuration:.5];
                    removeWindow = [CCCallFuncN actionWithTarget:self selector:@selector(tutorialBoxRemove)];
                    
                    NSMutableArray *textBoxParameters = [[NSMutableArray alloc] initWithCapacity:1];
                    [textBoxParameters addObject:[NSValue valueWithPointer:[NSString stringWithString:@"Whoa, what was that? A hot dog?"]]];
                    id tutorialWindow1 = [CCCallFuncND actionWithTarget:self selector:@selector(introTutorialTextBox:data:) data:textBoxParameters];
                
                    id windowSeq = [CCSequence actions:winDownDelay, tutorialWindow1, winUpDelay, removeWindow, nil];
                    [self runAction:windowSeq];
                }
                if(dogBody->GetLinearVelocity().y < .1){
                    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
                    CCAction *wienerDeathAction = (CCAction *)ud->altAction;

                    id delay = [CCDelayTime actionWithDuration:_wienerKillDelay];
                    wienerParameters = [[NSMutableArray alloc] initWithCapacity:2];
                    [wienerParameters addObject:[NSValue valueWithPointer:dogBody]];
                    [wienerParameters addObject:[NSNumber numberWithInt:0]];
                    id sleepAction = [CCCallFuncND actionWithTarget:self selector:@selector(setAwake:data:) data:wienerParameters];
                    id angleAction = [CCCallFuncND actionWithTarget:self selector:@selector(setRotation:data:) data:wienerParameters];
                    wienerParameters = [[NSMutableArray alloc] initWithCapacity:1];
                    [wienerParameters addObject:[NSValue valueWithPointer:dogBody]];
                    id destroyAction = [CCCallFuncND actionWithTarget:self selector:@selector(destroyWiener:data:) data:wienerParameters];
                    id sequence = [CCSequence actions: delay, sleepAction, angleAction, wienerDeathAction, destroyAction, nil];
                    [ud->sprite1 stopAllActions];
                    [ud->sprite1 runAction:sequence];
                    CCLOG(@"Run death action");
                }
            }
        }
    }
    personDogContactListener->contacts.clear();

    b2RayCastInput input;
    float closestFraction = 1; //start with end of line as policeRayPoint2
    b2Vec2 intersectionNormal(0,0);
    float rayLength = COP_RANGE;
    b2Vec2 intersectionPoint(0,0);

    //any non-collision actions that apply to multiple onscreen entities happen here
    for(b2Body* b = _world->GetBodyList(); b; b = b->GetNext()){
        if(b->GetUserData() && b->GetUserData() != (void*)100){
            bodyUserData *ud = (bodyUserData*)b->GetUserData();
            if(ud->overlaySprite != NULL){
                if(ud->sprite1.tag == S_POLICE){
                    ud->overlaySprite.position = CGPointMake(policeRayPoint2.x*PTM_RATIO, policeRayPoint2.y*PTM_RATIO);
                }
                else {
                    ud->overlaySprite.position = CGPointMake((b->GetPosition().x)*PTM_RATIO,
                                                            (b->GetPosition().y)*PTM_RATIO);
                }
            }
            if(ud->sprite2 != NULL){
                ud->sprite2.position = CGPointMake((b->GetPosition().x)*PTM_RATIO,
                                                   (b->GetPosition().y+ud->heightOffset2)*PTM_RATIO);
                ud->sprite2.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            if(ud->sprite1 != NULL){
                if(ud->sprite1.tag == S_HOTDOG){
                    //things for hot dogs
                    if(b->IsAwake()){
                        if(!_mouseJoint){
                            if(b->GetLinearVelocity().y > 1.5){
                                [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"Dog_Rise.png"]]];
                            } else if (b->GetLinearVelocity().y < -1.5){
                                [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"Dog_Fall.png"]]];
                            } else {
                                [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"dog54x12.png"]]];
                            }
                        } else if(_mouseJoint->GetBodyB() == b){
                            [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"Dog_Grabbed.png"]]];
                        }
                        if(b->GetContactList() == 0){
                            for(b2Fixture* fixture = b->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                                fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                                if(fUd->tag == F_DOGCLD){
                                    b2Filter dogFilter = fixture->GetFilterData();
                                    dogFilter.maskBits = fUd->ogCollideFilters;
                                    fixture->SetFilterData(dogFilter);
                                }
                            }
                        }
                        for(b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext()) {
                            fixtureUserData *fUd = (fixtureUserData *)f->GetUserData();
                            b2RayCastOutput output;
                            if(fUd->tag == F_DOGCLD){
                                if(!f->RayCast(&output, input)){
                                    _rayTouchingDog = false;
                                    continue;
                                }
                                if(output.fraction < closestFraction && !_shootLock){
                                    CCLOG(@"Ray touched dog fixture with fraction %d", (int)output.fraction*1);

                                    _shootLock = YES;

                                    b2Body *copBody = NULL, *copArmBody = NULL;
                                    bodyUserData *copUd = NULL, *armUd = NULL;
                                    b2Body *dogBody = b;

                                    closestFraction = output.fraction;
                                    _rayTouchingDog = true;
                                    intersectionNormal = output.normal;
                                    intersectionPoint = policeRayPoint1 + closestFraction * (policeRayPoint2 - policeRayPoint1);

                                    for(b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
                                        if(body->GetUserData() && body->GetUserData() != (void*)100){
                                            if(body->GetPosition().x < winSize.width && body->GetPosition().x > 0 &&
                                               body->GetPosition().y < winSize.height && body->GetPosition().y > 0){
                                                copUd = (bodyUserData*)body->GetUserData();
                                                if(copUd->sprite1 != NULL && copUd->sprite1.tag == S_POLICE){
                                                    copBody = body;
                                                }
                                                if(copUd->sprite1 != NULL && copUd->sprite1.tag == S_COPARM){
                                                    copArmBody = body;
                                                }
                                            }

                                        }
                                    }

                                    if(copBody && copBody->GetUserData() && copArmBody && copArmBody->GetUserData()){
                                        copUd = (bodyUserData *)copBody->GetUserData();

                                        copUd->targetAngle = -1;

                                        NSMutableArray *walkParameters = [[NSMutableArray alloc] initWithCapacity:2];
                                        NSValue *cBody = [NSValue valueWithPointer:copBody];
                                        [walkParameters addObject:cBody];
                                        [walkParameters addObject:[NSNumber numberWithInteger:0]];
                                        id stopWalkingAction = [CCCallFuncND actionWithTarget:self selector:@selector(setAwake:data:) data:walkParameters];

                                        CCFiniteTimeAction *copShootAnimAction = (CCFiniteTimeAction *)copUd->altAction2;
                                        CCAnimation *copWalkAnim = (CCAnimation *)copUd->defaultAnim;
                                        walkParameters = [[NSMutableArray alloc] initWithCapacity:2];
                                        [walkParameters addObject:[NSValue valueWithPointer:copUd->sprite1]];
                                        [walkParameters addObject:[NSValue valueWithPointer:copWalkAnim]];
                                        id walkAnimateAction = [CCCallFuncND actionWithTarget:self selector:@selector(spriteRunAnim:data:) data:walkParameters];

                                        walkParameters = [[NSMutableArray alloc] initWithCapacity:2];
                                        NSNumber *vel= [NSNumber numberWithInteger:-350];
                                        if(copUd->sprite1.flipX == true){
                                            vel = [NSNumber numberWithInteger:350];
                                        }
                                        [walkParameters addObject:cBody];
                                        [walkParameters addObject:vel];
                                        id startWalkingAction = [CCCallFuncND actionWithTarget:self selector:@selector(applyForce:data:) data:walkParameters];

                                        walkParameters = [[NSMutableArray alloc] initWithCapacity:2];
                                        [walkParameters addObject:cBody];
                                        [walkParameters addObject:[NSNumber numberWithInteger:1]];
                                        id wakeUpAction = [CCCallFuncND actionWithTarget:self selector:@selector(setAwake:data:) data:walkParameters];

                                        NSMutableArray *aimParameters = [[NSMutableArray alloc] initWithCapacity:2];
                                        NSValue *dBody = [NSValue valueWithPointer:dogBody];
                                        [aimParameters addObject:cBody];
                                        [aimParameters addObject:dBody];

                                        id unlockAction = [CCCallFuncN actionWithTarget:self selector:@selector(flipShootLock)];

                                        aimParameters = [[NSMutableArray alloc] initWithCapacity:1];
                                        [aimParameters addObject:cBody];
                                        id copFlipAimingAction = [CCCallFuncND actionWithTarget:self selector:@selector(copFlipAim:data:) data:aimParameters];

                                        CCDelayTime *delay = [CCDelayTime actionWithDuration:1];

                                        id copSeq = [CCSequence actions:stopWalkingAction, copFlipAimingAction, delay, copShootAnimAction, copFlipAimingAction, wakeUpAction, startWalkingAction, walkAnimateAction, unlockAction, nil];
                                        [copUd->sprite1 stopAllActions];
                                        [copUd->sprite1 runAction:copSeq];
                                        
                                        CCFiniteTimeAction *faceShootAction = (CCFiniteTimeAction *)copUd->altAction3;
                                        NSMutableArray *walkFaceParameters = [[NSMutableArray alloc] initWithCapacity:2];
                                        [walkFaceParameters addObject:[NSValue valueWithPointer:(CCSprite *)copUd->sprite2]];
                                        [walkFaceParameters addObject:[NSValue valueWithPointer:(CCAction *)copUd->altAnimation]];
                                        id faceWalkAction = [CCCallFuncND actionWithTarget:self selector:@selector(spriteRunAnim:data:) data:walkFaceParameters];
                                        [copUd->sprite2 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"Cop_Head_Aiming_1.png"]]];
                                        
                                        id copHeadSeq = [CCSequence actions:delay, faceShootAction, faceWalkAction, nil];
                                        [copUd->sprite2 stopAllActions];
                                        [copUd->sprite2 runAction:copHeadSeq];
                                        
                                        [copUd->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"Cop_Idle.png"]]];

                                        armUd = (bodyUserData *)copArmBody->GetUserData();
                                        CCFiniteTimeAction *armShootAnimAction = (CCFiniteTimeAction *)armUd->altAction;
                                        id armSeq = [CCSequence actions:delay, armShootAnimAction, nil];
                                        [armUd->sprite1 stopAllActions];
                                        [armUd->sprite1 runAction:armSeq];

                                        //ud->overlaySprite.visible = true;
                                        //dogBody->SetAwake(false);
                                        //dogBody->SetActive(false);

                                        NSMutableArray *destroyParameters = [[NSMutableArray alloc] initWithCapacity:1];
                                        [destroyParameters addObject:dBody];
                                        id destroyAction = [CCCallFuncND actionWithTarget:self selector:@selector(destroyWiener:data:) data:destroyParameters];
                                        
                                        NSMutableArray *aimedAtParameters = [[NSMutableArray alloc] initWithCapacity:1];
                                        [aimedAtParameters addObject:dBody];
                                        id dogFlipAimedAtAction = [CCCallFuncND actionWithTarget:self selector:@selector(dogFlipAimedAt:data:) data:aimedAtParameters];

                                        CCFiniteTimeAction *wienerExplodeAction = (CCFiniteTimeAction *)ud->altAction2;
                                        id dogSeq = [CCSequence actions:dogFlipAimedAtAction, delay, wienerExplodeAction, destroyAction, nil];
                                        [ud->sprite1 stopAllActions];
                                        [ud->sprite1 runAction:dogSeq];

                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                else if(ud->sprite1.tag == S_POLICE){
                    //cop arm rotation
                    if(!ud->aiming){
                        //if not aiming, make sure there are no world dogs with aimedAt on
                        for(b2Body* aimedBody = _world->GetBodyList(); aimedBody; aimedBody = aimedBody->GetNext()){
                            if(aimedBody->GetUserData() && aimedBody->GetUserData() != (void*)100){
                                bodyUserData *aimedUd = (bodyUserData *)aimedBody->GetUserData();
                                if(aimedUd->sprite1.tag == S_HOTDOG && aimedUd->aimedAt == true){
                                    aimedUd->aimedAt = false;
                                }
                            }
                        }
                        b2JointEdge *j = b->GetJointList();
                        if(j){
                            if(j->joint->GetType() == e_revoluteJoint){
                                b2RevoluteJoint *r = (b2RevoluteJoint *)j->joint;
                                r->SetMotorSpeed(ud->armSpeed);
                            }
                        }
                        ud->armSpeed = 3 * cosf(.1 * time);
                    } else {
                        b2Body *aimedDog;
                        double dy, dx, a;
                        for(b2Body* aimedBody = _world->GetBodyList(); aimedBody; aimedBody = aimedBody->GetNext()){
                            if(aimedBody->GetUserData() && aimedBody->GetUserData() != (void*)100){
                                bodyUserData *aimedUd = (bodyUserData *)aimedBody->GetUserData();
                                if(aimedUd->sprite1.tag == S_HOTDOG && aimedUd->aimedAt == true){
                                    // TODO - this only works for forward-facing cops, do the math and make it work for both
                                    // TODO - have target follow dog if dog is in range
                                    aimedDog = aimedBody;
                                    dx = abs(b->GetPosition().x - aimedDog->GetPosition().x);
                                    dy = abs(b->GetPosition().y - aimedDog->GetPosition().y);
                                    a = acos(dx / sqrt((dx*dx) + (dy*dy)));
                                    ud->targetAngle = a;
                                    break;
                                }
                            }
                        }
                        
                        b2JointEdge *j = b->GetJointList();
                        if(j){
                            if(j->joint->GetType() == e_revoluteJoint && ud->targetAngle != -1){
                                b2RevoluteJoint *r = (b2RevoluteJoint *)j->joint;
                                NSLog(@"Shoulder angle: %0.20f", r->GetJointAngle());
                                NSLog(@"Angle between shoulder and dog: %0.2f", ud->targetAngle);

                                if(r->GetJointAngle() < ud->targetAngle)
                                    r->SetMotorSpeed(.5);
                                else if(r->GetJointAngle() > ud->targetAngle)
                                    r->SetMotorSpeed(-.5);
                            }
                        }
                    }
                }
                else if(ud->sprite1.tag == S_COPARM){
                    //things for cop's arm and raycasting
                    //TODO - make all global components of cop raycasting into instance variables to allow maybe multiple cops onscreen
                    policeRayPoint1 = b->GetPosition();
                    policeRayPoint2 = policeRayPoint1 + rayLength * b2Vec2(cosf(b->GetAngle()), sinf(b->GetAngle()));
                    input.p1 = policeRayPoint1;
                    input.p2 = policeRayPoint2;
                    input.maxFraction = 1;
                }
                //boilerplate - update sprite positions to match their physics bodies
                ud->sprite1.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
                ud->sprite1.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
                //destroy any sprite/body pair that's offscreen
                // TODO - points for dogs that leave the screen on a person's head
                if(ud->sprite1.position.x > winSize.width + 60 || ud->sprite1.position.x < -60 ||
                   ud->sprite1.position.y > winSize.height || ud->sprite1.position.y < -20){
                    if(_mouseJoint && _mouseJoint->GetBodyB() == b){
                        _world->DestroyJoint(_mouseJoint);
                        _mouseJoint = NULL;
                    }
                    _world->DestroyBody(b);
                    CCLOG(@"Body removed");
                    [ud->sprite1 removeFromParentAndCleanup:YES];
                    if(ud->sprite2 != NULL){
                        [ud->sprite2 removeFromParentAndCleanup:YES];
                    }
                    if(ud->overlaySprite != NULL){
                        [ud->overlaySprite removeFromParentAndCleanup:YES];
                    }
                    ud = NULL;
                }
            }
        }
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint != NULL) return;

    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    if(CGRectContainsPoint(_pauseButtonRect, location)){
        if(!_pause)
            [self pauseButton];
        else
            [self resumeGame];
    }

    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);

    _touchedDog = NO;
    int b = 0;

    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
            bodyUserData *ud = (bodyUserData *)body->GetUserData();
            if(ud->sprite1.tag == S_HOTDOG){
                for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    if (fixture->TestPoint(locationWorld)){
                        CCLOG(@"Touching hotdog");
                        b2MouseJointDef md;
                        md.bodyA = _groundBody;
                        md.bodyB = body;
                        md.target = locationWorld;
                        md.collideConnected = true;
                        md.maxForce = 10000.0f * body->GetMass();

                        _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
                        body->SetAwake(true);
                        body->SetFixedRotation(true);
                        CCLOG(@"Fixture user data->tag: %d", fUd->tag);

                        _touchedDog = YES;
                        b = 1;
                        break;
                    }
                    else {
                        _touchedDog = NO;
                    }
                }
                if(b == 1){
                    break;
                }
            }
        }
    }
    CCLOG(@"Touched Dog: %d", _touchedDog);
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_mouseJoint == NULL) return;

    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);

    //CCLOG(@"Grab @ (%0.2f, %0.2f)", locationWorld.x*PTM_RATIO, locationWorld.y*PTM_RATIO);

    b2Filter filter;
    _mouseJoint->SetTarget(locationWorld);
    b2Body *body = _mouseJoint->GetBodyB();
    bodyUserData *ud = (bodyUserData *)body->GetUserData();
    CCSprite *sprite = ud->sprite1;

    for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
        fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
        if(fUd->tag == F_DOGCLD){
            filter = fixture->GetFilterData();
            filter.maskBits = 0x0000;
            fixture->SetFilterData(filter);
        }
    }

    //don't stop the explosion action!
    if(!ud->aimedAt){
        [sprite stopAllActions];
    }
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint != NULL) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }

    b2Filter filter;

    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);

    for (b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL  && body->GetUserData() != (void*)100) {
            for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                bodyUserData *ud = (bodyUserData *)body->GetUserData();
                if(ud->sprite1.tag == S_HOTDOG){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    _lastTouchTime = time;
                    if (fixture->TestPoint(locationWorld)) {
                        body->SetLinearVelocity(b2Vec2(0, 0));
                        body->SetFixedRotation(false);
                    } else if(_introLayer != NULL){
                        [self removeChild:_introLayer cleanup:YES];
                    }
                    if(fUd->tag == F_DOGCLD){
                        filter = fixture->GetFilterData();
                        filter.maskBits = fUd->ogCollideFilters;
                        CCLOG(@"Dog filter mask: %d", fixture->GetFilterData().maskBits);
                        fixture->SetFilterData(filter);
                        CCLOG(@"Dog filter mask: %d", fixture->GetFilterData().maskBits);

                    }
                }
            }
        }
    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }

    b2Filter filter;

    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);

    for (b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL  && body->GetUserData() != (void*)100) {
            for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                bodyUserData *ud = (bodyUserData *)body->GetUserData();
                if(ud->sprite1.tag == S_HOTDOG){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    _lastTouchTime = time;
                    if (fixture->TestPoint(locationWorld)) {
                        body->SetLinearVelocity(b2Vec2(0, 0));
                        body->SetFixedRotation(false);
                    } else if(_introLayer != NULL){
                        [self removeChild:_introLayer cleanup:YES];
                    }
                    if(fUd->tag == F_DOGCLD){
                        filter = fixture->GetFilterData();
                        filter.maskBits = fUd->ogCollideFilters;
                        CCLOG(@"Dog filter mask: %d", fixture->GetFilterData().maskBits);
                        fixture->SetFilterData(filter);
                        CCLOG(@"Dog filter mask: %d", fixture->GetFilterData().maskBits);

                    }
                }
            }
        }
    }
}

- (void) dealloc {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];

    self.personLower = nil;
    self.personUpper = nil;
    self.idleFaceAction = nil;
    self.walkFaceAction = nil;
    self.wiener = nil;
    self.target = nil;

    [scoreText release];
    [droppedText release];
    [floorBits release];
    [xPositions release];
    [characterTags release];
    [wienerParameters release];
    [personParameters release];
    [movementPatterns release];
    [movementParameters release];
    [headParams release];
    [_deathAction release];
    [_shotAction release];


    delete personDogContactListener;

    delete _world;
    _world = NULL;

    [super dealloc];
}
@end
