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
#define SPAWN_LIMIT_DECREMENT_DELAY 10
#define DROPPED_MAX 4

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

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
    [[CCDirector sharedDirector] replaceScene:[LoseLayer sceneWithData:(void*)_points]];
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
    } else {
        m_debugDraw = nil;
    }
    _world->SetDebugDraw(m_debugDraw);
}

-(void)timedDecrement{
    if(_spawnLimiter > 0){
        _spawnLimiter--;
    }
    if(_personSpawnDelayTime > 1){
        _personSpawnDelayTime -= 1;
    }
    if(_wienerSpawnDelayTime > 4){
        _wienerSpawnDelayTime -= 1;
    }
    if(_wienerKillDelay > 1){
        _wienerKillDelay -= 1;
    }
}

-(void)setAwake:(id)sender data:(void*)params {
    b2Body *body = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    NSNumber *awake = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];
    
    if(awake.intValue == 1){
        body->SetAwake(true);
    }
    else if(awake.intValue == 0){
        body->SetAwake(false);
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
    
    b2Vec2 force = b2Vec2(v.intValue, 0);
    body->ApplyLinearImpulse(force, body->GetPosition());
    
    if(body->GetLinearVelocity().x < vThresh && body->GetLinearVelocity().x > -1*vThresh){
        for(b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext()){
            fixtureUserData *fUd = (fixtureUserData *)f->GetUserData();
            if(fUd->tag >= 53 && fUd->tag <= 60){
                f->SetFriction(100);
            }
        }
    } else {
        for(b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext()){
            fixtureUserData *fUd = (fixtureUserData *)f->GetUserData();
            if(fUd->tag >= 53 && fUd->tag <= 60){
                f->SetFriction(0);
            }
        }
    }
}

-(void) spriteRunAction:(id)sender data:(void*)params{
    //takes a sprite and an optional action
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
        ccDrawLine(CGPointMake(p1.x*PTM_RATIO, p1.y*PTM_RATIO), CGPointMake(p2.x*PTM_RATIO, p2.y*PTM_RATIO));
	}
    
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

-(void)destroyWiener:(id)sender data:(void*)params {
    b2Body *dogBody = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
    
    CCSprite *dogSprite = (CCSprite *)sender;
    
    CCLOG(@"Destroying dog...");
    
    if(dogSprite.tag == 1){        
        dogBody->SetAwake(false);
        [dogSprite stopAllActions];
        [dogSprite removeFromParentAndCleanup:YES];
        _world->DestroyBody(dogBody);
        free(ud);
        dogBody->SetUserData(NULL);
        dogBody = nil;
        _droppedCount++;
    }
    
    CCLOG(@"done.");
}

-(void)putDog:(id)sender data:(void*)params {
    int floor, f;
    CGPoint location = [(NSValue *)[(NSMutableArray *) params objectAtIndex: 0] CGPointValue];
    
    //add base sprite to scene
    self.wiener = [CCSprite spriteWithSpriteFrameName:@"dog54x12.png"];
    _wiener.position = ccp(location.x, location.y);
    _wiener.tag = 1;
    [self addChild:_wiener];
    
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
    ud->ogSprite2 = [NSString stringWithString:@"dog54x12.png"];
    ud->altSprite2 = [NSString stringWithString:@"Dog_Rise.png"];
    ud->altSprite3 = [NSString stringWithString:@"Dog_Fall.png"];
    
    fixtureUserData *fUd1 = new fixtureUserData();
    fUd1->ogCollideFilters = 0;
    fUd1->tag = 0;
    
    //for the collision fixture userdata struct, randomly assign floor
    fixtureUserData *fUd2 = new fixtureUserData();
    floor = arc4random() % 4;
    //TODO - replace "person" here with the equivalent of "ALL PEOPLE"
    f = 0xfffff000;
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
    fUd2->tag = 1;
    
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
    
    //action calls spriteRunAction with only a sprite (stops all actions on head sprite)
    headParams = [[NSMutableArray alloc] initWithCapacity:1];
    [headParams addObject:spr];
    CCCallFuncND *headIdle = [CCCallFuncND actionWithTarget:self selector:@selector(spriteRunAction:data:) data:headParams];
    
    //action calls spriteRunAction with both sprite and action to run (starts head walking animation)
    headParams = [[NSMutableArray alloc] initWithCapacity:2];
    [headParams addObject:spr];
    [headParams addObject:anim];
    CCCallFuncND *headWalk = [CCCallFuncND actionWithTarget:self selector:@selector(spriteRunAction:data:) data:headParams];

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

-(void)walkIn:(id)sender data:(void *)params {
    int xVel, velocityMul, zIndex, fTag, armOffset, lowerArmAngle, upperArmAngle, armBodyXOffset, armBodyYOffset;
    int armJointXOffset, armJointYOffset;
    float hitboxHeight, hitboxWidth, hitboxCenterX, hitboxCenterY, density, restitution, friction, heightOffset;
    NSString *ogHeadSprite;
    BOOL spawn;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    spawn = YES;
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
            if(ud->sprite1.tag >= 3 && ud->sprite1.tag <= 10){
                if(ud->sprite1.tag == 4 && character.intValue == 4){
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
        
        switch(character.intValue){
            case 3: //businessman
                self.personLower = [CCSprite spriteWithSpriteFrameName:@"BusinessMan_Walk_1.png"];
                self.personUpper = [CCSprite spriteWithSpriteFrameName:@"BusinessHead_NoDog_1.png"];
                self.hitFace = [NSString stringWithString:@"BusinessHead_Dog_1.png"];
                ogHeadSprite = [NSString stringWithString:@"BusinessHead_NoDog_1.png"];
                _personLower.tag = 3;
                _personUpper.tag = 3;
                hitboxWidth = 22.0;
                hitboxHeight = .0001;
                hitboxCenterX = 0;
                hitboxCenterY = 4;
                velocityMul = 300;
                density = 10.0f;
                restitution = .8f; //bounce
                friction = 0.3f; 
                fTag = 3;
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
                break;
            case 4: //police
                self.personLower = [CCSprite spriteWithSpriteFrameName:@"Cop_Run_1.png"];
                self.personUpper = [CCSprite spriteWithSpriteFrameName:@"Cop_Head_NoDog_1.png"];
                self.hitFace = [NSString stringWithString:@"Cop_Head_Dog_1.png"];
                self.policeArm = [CCSprite spriteWithSpriteFrameName:@"cop_arm.png"];
                ogHeadSprite = [NSString stringWithString:@"Cop_Head_NoDog_1.png"];
                _policeArm.tag = 11;
                _personLower.tag = 4;
                _personUpper.tag = 4;
                hitboxWidth = 22.0;
                hitboxHeight = .0001;
                hitboxCenterX = 0;
                hitboxCenterY = 4.1;
                velocityMul = 350;
                density = 6.0f;
                restitution = .5f;
                friction = 4.0f;
                fTag = 4;
                heightOffset = 2.9f;
                lowerArmAngle = 0;
                upperArmAngle = 55;
                armBodyXOffset = 8;
                armBodyYOffset = 40;
                armJointXOffset = 15;
                armJointYOffset = 40;
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
            zIndex = 400;
        }
        else if(floorBit.intValue == 2){
            zIndex = 300;
        }
        else if(floorBit.intValue == 4){
            zIndex = 200;
        }
        else{
            zIndex = 100;
        }
        
        //create animations for walk, idle, and bobbing head
        walkAnim = [CCAnimation animationWithFrames:walkAnimFrames delay:.08f];
        self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]];
        [_personLower runAction:_walkAction];
        
        idleAnim = [CCAnimation animationWithFrames:idleAnimFrames delay:.2f];
        self.idleAction = [CCAnimate actionWithAnimation:idleAnim];
        CCRepeat *repeatAction = [CCRepeat actionWithAction:_idleAction times:10];
        CCSequence *sequence = [CCSequence actions:_idleAction, repeatAction, nil];
        
        walkFaceAnim = [[CCAnimation animationWithFrames:faceWalkAnimFrames delay:.08f] retain];
        self.walkFaceAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkFaceAnim restoreOriginalFrame:NO]];
        [_personUpper runAction:_walkFaceAction];
        
        //TODO - set up a range of z indices so multisprites work nicely
        
        //put the sprites in place
        _personLower.position = ccp(xPos.intValue, 123);
        _personUpper.position = ccp(xPos.intValue, 123);
        [spriteSheet addChild:_personLower z:zIndex];
        [spriteSheet addChild:_personUpper z:zIndex];
        if(character.intValue == 4){
            _policeArm.position = ccp(xPos.intValue, 123);
            [spriteSheet addChild:_policeArm z:zIndex-1];
        }
        
        //set up userdata structs
        bodyUserData *ud = new bodyUserData();
        ud->sprite1 = _personLower;
        ud->sprite2 = _personUpper;
        ud->heightOffset2 = heightOffset;
        ud->ogSprite2 = ogHeadSprite;
        ud->altSprite2 = _hitFace;
        ud->altAction = _walkFaceAction;
        ud->altAnimation = walkFaceAnim;
        
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
            bodyUserData *ud = new bodyUserData();
            ud->sprite1 = _policeArm;
            
            _policeArm.tag = 12;
            
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
            fUd->tag = 11;
            armShapeDef.userData = fUd;
            armShapeDef.filter.maskBits = 0x0000;
            _policeArmFixture = _policeArmBody->CreateFixture(&armShapeDef);
            
            //"shoulder"
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
        [self walkInPauseContinue:_personLower data:movementParameters];
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
        
        //basic game/box2d/cocos2d initialization
        self.isAccelerometerEnabled = YES;
        self.isTouchEnabled = YES;
        time = 0;
        _curPersonMaskBits = 0x1000;
        _spawnLimiter = [characterTags count] - ([characterTags count]-1);
        _personSpawnDelayTime = 8.0f;
        _wienerSpawnDelayTime = 8.0f;
        _wienerKillDelay = 8.0f;
        _points = 0;
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
        
        CCSprite *background = [CCSprite spriteWithFile:@"bg_philly.png"];
        background.anchorPoint = CGPointZero;
        [self addChild:background z:-1];
        
        //labels for score and dropped count
        //TODO - these will definitely change eventually
        scoreText = [[NSString alloc] initWithFormat:@"%d", _points];
        scoreLabel = [CCLabelTTF labelWithString:scoreText fontName:@"Marker Felt" fontSize:18];
        scoreLabel.position = ccp(winSize.width-100, 310);
        [self addChild: scoreLabel];
        
        droppedText = [[NSString alloc] initWithFormat:@"%d", _droppedCount];
        droppedLabel = [CCLabelTTF labelWithString:scoreText fontName:@"Marker Felt" fontSize:18];
        droppedLabel.position = ccp(winSize.width-100, 280);
        [self addChild: droppedLabel];
        
        //debug labels
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Title screen" fontName:@"Marker Felt" fontSize:18.0];
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(titleScene)];
        label = [CCLabelTTF labelWithString:@"Debug draw" fontName:@"Marker Felt" fontSize:18.0];
        CCMenuItem *debug = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(debugDraw)];
        CCMenu *menu = [CCMenu menuWithItems:button, debug, nil];
        [menu setPosition:ccp(40, winSize.height-30)];
        [menu alignItemsVertically];
        [self addChild:menu];
        
        //initialize global arrays for possible x,y positions and charTags
        floorBits = [[NSMutableArray alloc] initWithCapacity:4];;
        for(int i = 1; i <= 8; i *= 2){
            [floorBits addObject:[NSNumber numberWithInt:i]];
        }
        xPositions = [[NSMutableArray alloc] initWithCapacity:2];
        [xPositions addObject:[NSNumber numberWithInt:winSize.width]];
        [xPositions addObject:[NSNumber numberWithInt:0]];
        characterTags = [[NSMutableArray alloc] initWithCapacity:2];
        for(int i = 3; i <= 4; i++){
            [characterTags addObject:[NSNumber numberWithInt:i]];
        }
        movementParameters = [[NSMutableArray alloc] initWithCapacity:2];
        
        fixtureUserData *fUd = new fixtureUserData();
        fUd->tag = 100;
        
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
    time++;
    armSpeed = 3 * cosf(.1 * time);
    
    //the "LOSE CONDITION"
    if(_droppedCount == DROPPED_MAX){
        [self loseScene];
    }
    
	_world->Step(dt, velocityIterations, positionIterations);
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    //cop arm rotation
    for(b2Joint* j = _world->GetJointList(); j; j = j->GetNext()){
        if(j->GetType() == e_revoluteJoint){
            b2RevoluteJoint *r = (b2RevoluteJoint *)j;
            r->SetMotorSpeed(armSpeed);
        }
    }
    
    //score and dropped count
    //TODO - dropped count may not be digital
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
            if(fBUd->tag >= 3 && fBUd->tag <= 10){
                pBody = pdContact.fixtureB->GetBody();
                CCLOG(@"Dog/Person Collision - Y Vel: %0.2f", dogBody->GetLinearVelocity().x);
                b2Filter dogFilter, personFilter;
                for(b2Fixture* fixture = pBody->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    if(fUd->tag >= 3 && fUd->tag <= 10){
                        personFilter = fixture->GetFilterData();
                    }
                }
                for(b2Fixture* fixture = dogBody->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    if(fUd->tag == 1){
                        dogFilter = fixture->GetFilterData();
                        dogFilter.maskBits = personFilter.categoryBits;
                        fixture->SetFilterData(dogFilter);
                    }
                }
                _points += 10;
            } 
            else if (fBUd->tag == 100){
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
    float closestFraction = 1; //start with end of line as p2
    b2Vec2 intersectionNormal(0,0);
    float rayLength = 6;
    b2Vec2 intersectionPoint(0,0);
    
    //any non-collision actions that apply to multiple onscreen entities happen here
	for(b2Body* b = _world->GetBodyList(); b; b = b->GetNext()){
		if(b->GetUserData()){
            if(b->GetUserData() != (void*)100){
                bodyUserData *ud = (bodyUserData*)b->GetUserData();
                if(ud->sprite2 != NULL){
                    ud->sprite2.position = CGPointMake((b->GetPosition().x)*PTM_RATIO,
                                                       (b->GetPosition().y+ud->heightOffset2)*PTM_RATIO);
                    ud->sprite2.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
                }
                if(ud->sprite1 != NULL){
                    if(ud->sprite1.tag == 1){
                        //things for hot dogs
                        if(b->IsAwake()){
                            if(b->GetLinearVelocity().y > 1.5){
                                NSString *altSprite2 = (NSString *)ud->altSprite2;
                                [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:altSprite2] ];
                            } else if (b->GetLinearVelocity().y < -1.5){
                                NSString *altSprite3 = (NSString *)ud->altSprite3;
                                [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:altSprite3] ];
                            } else {
                                NSString *ogSprite2 = (NSString *)ud->ogSprite2;
                                [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ogSprite2] ];
                            }
                            //CCLOG(@"hotdog contacts: %d", (int)b->GetContactList());
                            if(b->GetContactList() == 0){
                                for(b2Fixture* fixture = b->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                                    if(fUd->tag == 1){
                                        b2Filter dogFilter = fixture->GetFilterData();
                                        dogFilter.maskBits = fUd->ogCollideFilters;
                                        fixture->SetFilterData(dogFilter);
                                    }
                                }
                            }
                            for(b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext()) {
                                b2RayCastOutput output;
                                if(!f->RayCast(&output, input))
                                    _rayTouchingDog = false;
                                if(output.fraction < closestFraction){
                                    closestFraction = output.fraction;
                                    _rayTouchingDog = true;
                                    intersectionNormal = output.normal;
                                    intersectionPoint = p1 + closestFraction * (p2 - p1);
                                }
                            }
                        }
                    }
                    else if(ud->sprite1.tag == 12){
                        //things for cop's arm
                        p1 = b->GetPosition();
                        p2 = p1 + rayLength * b2Vec2(cosf(b->GetAngle()), sinf(b->GetAngle()));
                        input.p1 = p1;
                        input.p2 = p2;
                        input.maxFraction = 1;
                    }
                    //boilerplate - update sprite positions to match their physics bodies
                    ud->sprite1.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
                    ud->sprite1.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
                    //destroy any sprite/body pair that's offscreen
                    //TODO - this causes a crash when dogs are dragged offscreen
                    if(ud->sprite1.position.x > winSize.width + 60 || ud->sprite1.position.x < -60 ||
                       ud->sprite1.position.y > winSize.height || ud->sprite1.position.y < -20){
                        _world->DestroyBody(b);
                        CCLOG(@"Body removed");
                        [ud->sprite1 removeFromParentAndCleanup:YES];
                        if(ud->sprite2 != NULL){
                            [ud->sprite2 removeFromParentAndCleanup:YES];
                        }
                        ud = NULL;
                    }
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
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _touchedDog = NO;
    int b = 0;
    
    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
            bodyUserData *ud = (bodyUserData *)body->GetUserData();
            if(ud->sprite1.tag == 1){
                for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    if (fixture->TestPoint(locationWorld)) {
                        [ud->sprite1 stopAllActions];
                    
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
        if(fUd->tag == 1){
            filter = fixture->GetFilterData();
            filter.maskBits = 0x0000;
            fixture->SetFilterData(filter);
        }
    }
    
    [sprite stopAllActions];
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
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
                if(ud->sprite1.tag == 1){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    if (fixture->TestPoint(locationWorld)) {
                        body->SetLinearVelocity(b2Vec2(0, 0));
                        body->SetFixedRotation(false);
                    }
                    if(fUd->tag == 1){
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
                if(ud->sprite1.tag == 1){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    if (fixture->TestPoint(locationWorld)) {
                        body->SetLinearVelocity(b2Vec2(0, 0));
                        body->SetFixedRotation(false);
                    }
                    if(fUd->tag == 1){
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
    
    
    delete personDogContactListener;
    
    delete _world;
	_world = NULL;
    
	[super dealloc];
}
@end
