//
//  HelloWorldLayer.mm
//  Heads Up Hot Dogs
//
//  Created by Emmett Butler and Diego Garcia on 1/3/12.
//  Copyright Emmett and Diego 2012. All rights reserved.
//

#import "GameplayLayer.h"
#import "TitleScene.h"
#import "TestFlight.h"
#import "LoseScene.h"
#import "LevelSelectLayer.h"
#import "PointNotify.h"
#import "DogTouch.h"
#import "Overlay.h"

#define DEGTORAD 0.0174532
#define DOG_SPAWN_MINHT 240
#define VOMIT_VEL 666 // diego thinks this should be 666, i think 66.6 makes more sense
#define COP_RANGE 4
#define VOMIT_PROBABILITY 250
#define DOG_COUNTER_HT 295
#define OVERLAYS_STOP 2
#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#ifdef DEBUG
#define SPAWN_LIMIT_DECREMENT_DELAY 6
#define SPECIAL_DOG_PROBABILITY 29
#define DROPPED_MAX 20
#define WIENER_SPAWN_START 5
#else
#define SPAWN_LIMIT_DECREMENT_DELAY 2
#define SPECIAL_DOG_PROBABILITY 25
#define DROPPED_MAX 5
#define WIENER_SPAWN_START 5
#endif

@implementation GameplayLayer

@synthesize personLower = _personLower;
@synthesize personUpper = _personUpper;
@synthesize personUpperOverlay = _personUpperOverlay;
@synthesize rippleSprite = _rippleSprite;
@synthesize policeArm = _policeArm;
@synthesize wiener = _wiener;
@synthesize target = _target;

+(CCScene *) sceneWithSlug:(NSString *)levelSlug {
    
    CCScene *scene = [CCScene node];
    CCLOG(@"sceneWithData slug: %@", levelSlug);
    GameplayLayer *layer = [[GameplayLayer alloc] initWithSlug:levelSlug];
    layer->slug = levelSlug;
    [scene addChild: layer];
    return scene;
}

- (void)titleScene{
    if(_pause){
        [self resumeGame];
    }
#ifdef DEBUG
#else
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
#endif    
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

- (void)loseScene{
    [TestFlight passCheckpoint:@"Game Over"];
#ifdef DEBUG
#else
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
#endif
    NSMutableArray *loseParams = [[NSMutableArray alloc] initWithCapacity:6];
    [loseParams addObject:[NSNumber numberWithInteger:_points]];
    [loseParams addObject:[NSNumber numberWithInteger:time]];
    [loseParams addObject:[NSNumber numberWithInteger:_peopleGrumped]];
    [loseParams addObject:[NSNumber numberWithInteger:_dogsSaved]];
    [loseParams addObject:slug];
    [loseParams addObject:[NSValue valueWithPointer:level]];
    [[CCDirector sharedDirector] replaceScene:[LoseLayer sceneWithData:loseParams]];
}

-(void)reportAchievements{
    // achievement reporting (internally locked by the reporter object)
    if(_points >= 40000){
        [reporter reportAchievementIdentifier:@"points_40000" percentComplete:100];
    } else if(_points >= 20000){
        [reporter reportAchievementIdentifier:@"points_20000" percentComplete:100];
    } else if(_points >= 10000){
        [reporter reportAchievementIdentifier:@"points_10000" percentComplete:100];
    } else if(_points >= 5000){
        [reporter reportAchievementIdentifier:@"points_5000" percentComplete:100];
    }
    if(time/60 > 180 && _droppedCount == 0 && !_hasDroppedDog){
        [reporter reportAchievementIdentifier:@"nodrops_180" percentComplete:100];
    }
    else if(time/60 > 90 && _droppedCount == 0 && !_hasDroppedDog){
        [reporter reportAchievementIdentifier:@"nodrops_90" percentComplete:100];
    }
    if(_points > 30000 && !_hasDroppedDog){
        [reporter reportAchievementIdentifier:@"nodrops_30000" percentComplete:100];
    }
    if(_peopleGrumped > 100){
        [reporter reportAchievementIdentifier:@"grumps_100" percentComplete:100];
    }
}

-(void)resumeGame{
    [self removeChild:_pauseMenu cleanup:YES];
    [self removeChild:_pauseLayer cleanup:YES];
    [[CCDirector sharedDirector] resume];
#ifdef DEBUG
#else
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
#endif
    _pause = false;
}

-(void)restartScene{
    if(_pause){
        [self unschedule:@selector(tick:)];
        [self stopAllActions];
        [self removeAllChildrenWithCleanup:YES];
        [[CCDirector sharedDirector] resume];
    }
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer sceneWithSlug:level->slug]];
}

-(void)presentNewHighScoreNotify{
    NSLog(@"New high score!");
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"New Record!" fontName:@"LostPet.TTF" fontSize:30.0];
    label.position = ccp(0 - label.contentSize.width/2, winSize.height-label.contentSize.height/2);
    label.color = _color_pink;
    [self addChild:label];
    
    [label runAction:[CCSequence actions:[CCMoveTo actionWithDuration:.6 position:ccp(label.contentSize.width/2 + 10, label.position.y)],
                      [CCDelayTime actionWithDuration:1], [CCMoveTo actionWithDuration:.6 position:ccp(0 - label.contentSize.width/2, label.position.y)], nil]];
}

-(void)levelSelect{
    if(_pause){
        [self unschedule:@selector(tick:)];
        [self stopAllActions];
        [self removeAllChildrenWithCleanup:YES];
        [[CCDirector sharedDirector] resume];
    }
    // sometimes this causes a crash but I'm not sure why
    [[CCDirector sharedDirector] replaceScene:[LevelSelectLayer scene]];
}

-(void) pauseButton{
    if(!_pause){
        _pause = true;
        [[CCDirector sharedDirector] pause];
#ifdef DEBUG
#else
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
#endif
        _pauseLayer = [CCLayerColor layerWithColor:ccc4(190, 190, 190, 155) width:winSize.width height:winSize.height];
        _pauseLayer.anchorPoint = CGPointZero;
        [self addChild:_pauseLayer z:80];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Pause_BG.png"];
        sprite.position = ccp((sprite.contentSize.width/2)+10, winSize.height/2);
        [_pauseLayer addChild:sprite z:81];

        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Paused" fontName:@"LostPet.TTF" fontSize:27.0];
        label.color = _color_pink;
        CCMenuItem *pauseTitle = [CCMenuItemLabel itemWithLabel:label];
        pauseTitle.position = ccp((sprite.position.x+3), (sprite.position.y+sprite.contentSize.height/2)-20);
        [_pauseLayer addChild:pauseTitle z:81];

        NSInteger _overallTime = [standardUserDefaults integerForKey:@"overallTime"];
        CCLOG(@"Initial overall time: %d seconds", _overallTime);
        int totalTime = (time/60)+_overallTime;
        CCLOG(@"Total time: %d seconds", totalTime);
        int totalMinutes = totalTime/60;
        int totalHours = totalMinutes/60;

        label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d", _points] fontName:@"LostPet.TTF" fontSize:24.0];
        label.color = _color_pink;
        label.anchorPoint = ccp(90,90);
        CCMenuItem *score = [CCMenuItemLabel itemWithLabel:label];
        int seconds = time/60;
        int minutes = seconds/60;
        label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Time: %02d:%02d", minutes, seconds%60] fontName:@"LostPet.TTF" fontSize:24.0];
        label.color = _color_pink;
        CCMenuItem *timeItem = [CCMenuItemLabel itemWithLabel:label];
        label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total playtime: %02d:%02d:%02d", totalHours, totalMinutes%60, totalTime%60] fontName:@"LostPet.TTF" fontSize:24.0];
        label.color = _color_pink;
        CCMenuItem *totalTimeItem = [CCMenuItemLabel itemWithLabel:label];
        label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"People grumped: %d", _peopleGrumped] fontName:@"LostPet.TTF" fontSize:24.0];
        label.color = _color_pink;
        CCMenuItem *peopleItem = [CCMenuItemLabel itemWithLabel:label];
        label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Franks saved: %d", _dogsSaved] fontName:@"LostPet.TTF" fontSize:24.0];
        label.color = _color_pink;
        CCMenuItem *savedItem = [CCMenuItemLabel itemWithLabel:label];

        CCSprite *otherButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        otherButton.position = ccp((winSize.width-otherButton.contentSize.width+33), 208);
        [_pauseLayer addChild:otherButton z:81];
        label = [CCLabelTTF labelWithString:@"     RESTART    " fontName:@"LostPet.TTF" fontSize:23.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *title = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(restartScene)];
        
        otherButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        otherButton.position = ccp((winSize.width-otherButton.contentSize.width+33), 162);
        [_pauseLayer addChild:otherButton z:81];
        label = [CCLabelTTF labelWithString:@"     CONTINUE     " fontName:@"LostPet.TTF" fontSize:23.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *cont = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(resumeGame)];
        
        otherButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        otherButton.position = ccp((winSize.width-otherButton.contentSize.width+33), 116);
        [_pauseLayer addChild:otherButton z:81];
        label = [CCLabelTTF labelWithString:@"   LEVEL   " fontName:@"LostPet.TTF" fontSize:23.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *feedback = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(levelSelect)];
        
        CCMenu *quitButton = [CCMenu menuWithItems:cont, title, feedback, nil];
        [quitButton alignItemsVerticallyWithPadding:22];
        quitButton.position = ccp((winSize.width-89), winSize.height/2);
        [_pauseLayer addChild:quitButton z:82];

        _pauseMenu = [CCMenu menuWithItems: score, timeItem, peopleItem, savedItem, totalTimeItem, nil];
        [_pauseMenu setPosition:ccp(sprite.position.x, winSize.height/2-10)];
        [_pauseMenu alignItemsVerticallyWithPadding:5];
        [self addChild:_pauseMenu z:81];
        
        [TestFlight passCheckpoint:@"Pause Menu"];
    }
}

-(void)debugDraw{
    if(!m_debugDraw){
        m_debugDraw = new GLESDraw( PTM_RATIO );
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        flags += b2Draw::e_jointBit;
        flags += b2Draw::e_aabbBit;
        flags += b2Draw::e_pairBit;
        flags += b2Draw::e_centerOfMassBit;
        m_debugDraw->SetFlags(flags);
        [[CCDirector sharedDirector] setDisplayFPS:YES];
    } else {
        m_debugDraw = nil;
        [[CCDirector sharedDirector] setDisplayFPS:NO];
    }
    _world->SetDebugDraw(m_debugDraw);
}

-(void)timedDecrement{
    if(_wienerSpawnDelayTime > 1){
        _wienerSpawnDelayTime = _wienerSpawnDelayTime - .1;
    }
}

-(void)playGunshot{
#ifdef DEBUG
#else
    if(_sfxOn)
        [[SimpleAudioEngine sharedEngine] playEffect:@"gunshot 1.mp3" pitch:1 pan:0 gain:.4];
#endif
}

-(void)flipShootLock{
    if(_shootLock == true)
        _shootLock = false;
    else if(_shootLock == false)
        _shootLock = true;
}

-(void)removeSprite:(id)sender data:(NSValue *)s {
    CCSprite *sprite = (CCSprite *)[s pointerValue];
    [sprite removeFromParentAndCleanup:YES];
}

-(void)lockWiener:(id)sender data:(NSValue *)userData{
    bodyUserData *ud = (bodyUserData *)[userData pointerValue];
    ud->touchLock = true;
}

-(void)plusPoints:(id)sender data:(void*)params {
    NSNumber *xPos = (NSNumber *)[(NSMutableArray *) params objectAtIndex:0];
    NSNumber *yPos = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];
    NSNumber *points = (NSNumber *)[(NSMutableArray *) params objectAtIndex:2];
    NSValue *userdata = (NSValue *)[(NSMutableArray *) params objectAtIndex:3];
    bodyUserData *ud = (bodyUserData *)[userdata pointerValue];

    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"plusTen1.png"];
    sprite.position = ccp(xPos.intValue, yPos.intValue);
    [self addChild:sprite z:100];

    CCAction *removeAction = [CCCallFuncND actionWithTarget:self selector:@selector(removeSprite:data:) data:[[NSValue valueWithPointer:sprite] retain]];
    
    id seq;
    NSString *sound;
    
    switch(points.intValue){
        default:  seq = [CCSequence actions:ud->_not_dogContact, removeAction, nil];
            sound = @"25pts.mp3";
            break;
        case 10:  seq = [CCSequence actions:ud->_not_dogContact, removeAction, nil];
            sound = @"25pts.mp3";
            break;
        case 15:  seq = [CCSequence actions:ud->_not_dogContact, removeAction, nil];
            sound = @"50pts.mp3";
            break;
        case 25:  seq = [CCSequence actions:ud->_not_dogContact, removeAction, nil];
            sound = @"100pts.mp3";
            break;
        case 100: seq = [CCSequence actions:ud->_not_spcContact, removeAction, nil];
            sound = @"100pts.mp3";
            break;
    }
#ifdef DEBUG
#else
    if(_sfxOn)
        [[SimpleAudioEngine sharedEngine] playEffect:sound];
#endif
    [sprite runAction:seq];
}

-(void)runDogDeathAction:(NSValue *)body{
    CCLOG(@"Run death action");
    b2Body *dogBody = (b2Body *)[body pointerValue];
    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
    ud->deathSeqLock = true;
    id delay = [CCDelayTime actionWithDuration:ud->deathDelay];
    id lockAction = [CCCallFuncND actionWithTarget:self selector:@selector(lockWiener:data:) data:[[NSValue valueWithPointer:ud] retain]];
    id incAction = [CCCallFuncND actionWithTarget:self selector:@selector(incrementDroppedCount:data:) data:[[NSValue valueWithPointer:dogBody] retain]];
    NSMutableArray *wienerParameters = [[NSMutableArray alloc] initWithCapacity:2];
    [wienerParameters addObject:[NSValue valueWithPointer:dogBody]];
    [wienerParameters addObject:[NSNumber numberWithInt:0]];
    id sleepAction = [CCCallFuncND actionWithTarget:self selector:@selector(setAwake:data:) data:wienerParameters];
    id angleAction = [CCCallFuncND actionWithTarget:self selector:@selector(setRotation:data:) data:wienerParameters];
    id destroyAction = [CCCallFuncND actionWithTarget:self selector:@selector(destroyWiener:data:) data:[[NSValue valueWithPointer:dogBody] retain]];
    if(ud->altAction3)
        ud->deathSeq = [CCSequence actions: delay, sleepAction, angleAction, ud->altAction3, lockAction, incAction, ud->altAction, destroyAction, nil];
    else
        ud->deathSeq = [CCSequence actions: delay, sleepAction, angleAction, lockAction, incAction, ud->altAction, destroyAction, nil];
    [ud->sprite1 runAction:ud->deathSeq];
}

-(void)heartParticles:(NSValue *)loc{
    CCParticleSystem* heartParticles = [CCParticleFire node];
    ccColor4F startColor = {1, 1, 1, 1};
    ccColor4F endColor = {1, 1, 1, 0};
    heartParticles.startColor = startColor;
    heartParticles.endColor = endColor;
    heartParticles.texture = [[CCTextureCache sharedTextureCache] textureForKey:[NSString stringWithFormat:@"Heart_Particle_%d.png", (arc4random() % 3) + 1]];
    heartParticles.blendFunc = (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
    heartParticles.autoRemoveOnFinish = YES;
    heartParticles.startSize = 1.0f;
    heartParticles.speed = 90.0f;
    heartParticles.anchorPoint = ccp(0.5f,0.5f);
    heartParticles.position = [loc CGPointValue];
    heartParticles.duration = 0.1f;
    [self addChild:heartParticles z:60];
}

-(void)plusTwentyFive:(id)sender data:(void*)params {
    NSNumber *xPos = (NSNumber *)[(NSMutableArray *) params objectAtIndex:0];
    NSNumber *yPos = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];
    NSNumber *spec = (NSNumber *)[(NSMutableArray *) params objectAtIndex:2];
    NSValue *userdata = (NSValue *)[(NSMutableArray *) params objectAtIndex:3];
    bodyUserData *ud = (bodyUserData *)[userdata pointerValue];

    CCSprite *twentyFive;
    
    if(spec.intValue == 0)
        twentyFive = [CCSprite spriteWithSpriteFrameName:@"Plus_25_sm_1.png"];
    else twentyFive = [CCSprite spriteWithSpriteFrameName:@"Bonus_Plus250_sm_1.png"];
    twentyFive.position = ccp(xPos.intValue, yPos.intValue);
    [spriteSheetCommon addChild:twentyFive z:100];
    CCAction *removeAction = [CCCallFuncND actionWithTarget:self selector:@selector(removeSprite:data:) data:[[NSValue valueWithPointer:twentyFive] retain]];

    id seq;
    if(spec.intValue == 1)
        seq = [CCSequence actions:ud->_not_spcOnHead, removeAction, nil];
    else if(spec.intValue == 0)
        seq = [CCSequence actions:ud->_not_dogOnHead, removeAction, nil];
    
    [twentyFive runAction:seq];
}

-(void)plusOneHundred:(id)sender data:(void*)params {
    NSNumber *xPos = (NSNumber *)[(NSMutableArray *) params objectAtIndex:0];
    NSNumber *yPos = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];
    NSNumber *spec = (NSNumber *)[(NSMutableArray *) params objectAtIndex:2]; // 1 means a special dog
    NSValue *userdata = (NSValue *)[(NSMutableArray *) params objectAtIndex:3];
    bodyUserData *ud = (bodyUserData *)[userdata pointerValue];
    
    CCSprite *oneHundred = [CCSprite spriteWithSpriteFrameName:@"Plus_100_1.png"];
    oneHundred.position = ccp(xPos.intValue, yPos.intValue);
    [spriteSheetCommon addChild:oneHundred z:100];
    
    CCSprite *blast = [CCSprite spriteWithSpriteFrameName:@"CarryOff_Blast_1.png"];
    blast.position = ccp(xPos.intValue, yPos.intValue);
    if(xPos.intValue > winSize.width/2){
        blast.flipX = true;
    }
    [spriteSheetCommon addChild:blast z:95];
    CCAction *removeAction = [CCCallFuncND actionWithTarget:self selector:@selector(removeSprite:data:) data:[[NSValue valueWithPointer:oneHundred] retain]];
#ifdef DEBUG
#else
    if(_sfxOn)
        [[SimpleAudioEngine sharedEngine] playEffect:@"100pts.mp3"];
#endif
    id seq;
    if (spec.intValue == 1)
        seq = [CCSequence actions:ud->_not_spcLeaveScreen, removeAction, nil];
    else
        seq = [CCSequence actions:ud->_not_leaveScreen, removeAction, nil];
    [oneHundred runAction:seq];
    
    CCAction *removeAction2 = [CCCallFuncND actionWithTarget:self selector:@selector(removeSprite:data:) data:[[NSValue valueWithPointer:blast] retain]];
    id seq2 = [CCSequence actions:ud->_not_leaveScreenFlash, removeAction2, nil];
    [blast runAction:seq2];
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

-(void)explodeDog:(id)sender data:(NSValue *)body{
    b2Body *b = (b2Body *)[body pointerValue];
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    id incAction = [CCCallFuncND actionWithTarget:self selector:@selector(incrementDroppedCount:data:) data:[[NSValue valueWithPointer:b] retain]];
    id lockAction = [CCCallFuncND actionWithTarget:self selector:@selector(lockWiener:data:) data:[[NSValue valueWithPointer:ud] retain]];
    id destroyAction = [CCCallFuncND actionWithTarget:self selector:@selector(destroyWiener:data:) data:[[NSValue valueWithPointer:b] retain]];
    CCFiniteTimeAction *wienerExplodeAction = (CCFiniteTimeAction *)ud->altAction2;
    CCAction *shotSeq = [[CCSequence actions:lockAction, incAction, wienerExplodeAction, destroyAction, nil] retain];
    [ud->sprite1 runAction:shotSeq];
}

-(void)setRotation:(id)sender data:(void*)params {
    b2Body *body = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    NSNumber *angle = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];

    b2Vec2 pos = body->GetPosition();
    body->SetTransform(pos, angle.intValue);
}

-(void)aimAtAimedDog:(NSValue *)body{
    b2Body *b = (b2Body *)[body pointerValue];
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    b2Body *aimedDog;
    double dy, dx, a;
    for(b2Body* aimedBody = _world->GetBodyList(); aimedBody; aimedBody = aimedBody->GetNext()){
        if(aimedBody->GetUserData() && aimedBody->GetUserData() != (void*)100){
            bodyUserData *aimedUd = (bodyUserData *)aimedBody->GetUserData();
            if((aimedUd->sprite1.tag == S_HOTDOG || aimedUd->sprite1.tag == S_SPCDOG) && aimedUd->aimedAt == true){
                aimedDog = aimedBody;
                dx = abs(b->GetPosition().x - aimedDog->GetPosition().x);
                dy = abs(b->GetPosition().y - aimedDog->GetPosition().y);
                a = acos(dx / sqrt((dx*dx) + (dy*dy)));
                ud->targetAngle = a;
                [ud->overlaySprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Target_Dog.png"]];
                ud->overlaySprite.position = CGPointMake(aimedDog->GetPosition().x*PTM_RATIO, aimedDog->GetPosition().y*PTM_RATIO);
                ud->overlaySprite.rotation = 6 * (time % 360);
                break;
            }
        }
    }
    b2JointEdge *j = b->GetJointList();
    if(j && j->joint->GetType() == e_revoluteJoint && ud->targetAngle != -1){
        b2RevoluteJoint *r = (b2RevoluteJoint *)j->joint;
        if(r->GetJointAngle() < ud->targetAngle)
            r->SetMotorSpeed(.5);
        else if(r->GetJointAngle() > ud->targetAngle)
            r->SetMotorSpeed(-.5);
    }
}

-(void)perFrameLevelDogEffects:(NSValue *)body{
    b2Body *b = (b2Body *)[body pointerValue];
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    // per-level dog movement changes
    if(level->slug == @"chicago" && !(time % 19) && b->GetPosition().y > FLOOR4_HT+.5){
        if(ud->sprite1.position.x > 40 && ud->sprite1.position.x < winSize.width - 40){
            if(![ud->shotSeq isDone]){
                if(b->GetLinearVelocity().x != b->GetLinearVelocity().x+windForce.x)
                    b->SetLinearVelocity(b2Vec2(b->GetLinearVelocity().x+windForce.x, b->GetLinearVelocity().y));
            }
        }
    } else if(level->slug == @"nyc" && !(time % 19)) {
        [vent1 blowFrank:[NSValue valueWithPointer:b]];
        [vent2 blowFrank:[NSValue valueWithPointer:b]];
    } else if(level->slug == @"london"){
        if(!ud->grabbed){
            if(_subwayForce && abs(_subwayForce) < 2){
                if(b->GetLinearVelocity().x != b->GetLinearVelocity().x+_subwayForce)
                b->SetLinearVelocity(b2Vec2(b->GetLinearVelocity().x+_subwayForce, b->GetLinearVelocity().y));
                if(_subwayForce > 0)
                    _subwayForce += .1;
                else
                    _subwayForce -= .1;
            } else _subwayForce = 0;
        }
    } else if(level->slug == @"china"){
        if(!ud->grabbed && [firecracker explosionHittingDog:[NSValue valueWithPointer:b]]){
            ud->exploding = true;
            b->SetActive(false);
            [self explodeDog:self data:[NSValue valueWithPointer:b]];
        }
    }
}

-(void)setFace:(NSValue *)body{
    b2Body *b = (b2Body *)[body pointerValue];
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    if(ud->dogsOnHead == 0){
        [ud->angryFace setVisible:NO];
        [ud->sprite2 setVisible:YES];
    } else {
        [ud->angryFace setVisible:YES];
        [ud->sprite2 setVisible:NO];
    }
}

-(void)countDogsOnHead:(NSValue *)_body{
    b2Body *b = (b2Body *)[_body pointerValue];
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    for(b2Fixture* fixture = b->GetFixtureList(); fixture; fixture = fixture->GetNext()){
        fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
        // detect if any people have dogs on or above their heads
        if(fUd->tag >= F_BUSSEN && fUd->tag <= F_TOPSEN){
            for(b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
                if(body->GetUserData() && body->GetUserData() != (void*)100){
                    bodyUserData *dogUd = (bodyUserData *)body->GetUserData();
                    if(!dogUd->sprite1) continue;
                    if(dogUd->sprite1.tag == S_HOTDOG || dogUd->sprite1.tag == S_SPCDOG){
                        b2Vec2 dogLocation = b2Vec2(body->GetPosition().x, body->GetPosition().y);
                        if(fixture->TestPoint(dogLocation) && dogUd->hasTouchedHead && !dogUd->grabbed &&
                           dogUd->collideFilter == ud->collideFilter){
                            ud->dogsOnHead++;
                            if(dogUd->sprite1.tag == S_SPCDOG)
                                ud->spcDogsOnHead++;
                            // if the dog is within the head sensor, then it is on a head
                            dogUd->_dog_isOnHead = true;
                        }
                    }
                }
            }
        }
    }
}

-(void)flipFGDark{
    if(_fgIsDark)
        _fgIsDark = false;
    else
        _fgIsDark = true;
}

-(void)movePerson:(NSValue *)body{
    b2Body *b = (b2Body *)[body pointerValue];
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    // move person across screen at the appropriate speed
    if((ud->timeWalking <= ud->stopTime || ud->timeWalking >= ud->stopTime + ud->stopTimeDelta)){
        if(b->GetLinearVelocity().x != ud->moveDelta){ b->SetLinearVelocity(b2Vec2(ud->moveDelta, 0)); }
        if(ud->timeWalking == ud->stopTime){
            if(ud->sprite1.tag != S_POLICE && ud->sprite1.tag != S_MUNCHR){
                [ud->sprite2 stopAllActions];
                [ud->sprite1 stopAllActions];
                [ud->ripples stopAllActions];
                [ud->angryFace stopAllActions];
                if(ud->_busman_willVomit){
                    [ud->angryFace setVisible:NO];
                    [ud->sprite2 setVisible:YES];
                    ud->_busman_isVomiting = true;
                    ud->stopTimeDelta = 250;
                    ud->heightOffset2 = 2.3;
                    ud->widthOffset = -.4;
                    if(ud->sprite1.flipX){
                        ud->widthOffset *= -1;
                    }
                    [ud->sprite2 runAction:ud->_vomitAction];
                    [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BusinessMan_Idle_1.png"]];
                    
                    float xBarf = b->GetPosition().x*PTM_RATIO - 40, yBarf = b->GetPosition().y*PTM_RATIO + 30, xVel = -1*VOMIT_VEL;
                    if(ud->sprite1.flipX){
                        xBarf = b->GetPosition().x*PTM_RATIO + 40;
                        xVel = VOMIT_VEL;
                    }
                    CGPoint barfPosition = CGPointMake(xBarf, yBarf);
                    
                    NSMutableArray *parameters = [[NSMutableArray alloc] init];
                    [parameters addObject:[NSValue valueWithCGPoint:barfPosition]];
                    [parameters addObject:[NSNumber numberWithInt:xVel]];
                    
                    id screenFlashAction = [CCSequence actions:
                                      [CCCallFuncND actionWithTarget:self selector:@selector(screenFlash:data:) data:[NSNumber numberWithInt:1]],
                                      [CCCallFuncND actionWithTarget:self selector:@selector(screenFlash:data:) data:[NSNumber numberWithInt:0]], nil];
                    id colorBGAction = [CCCallFuncND actionWithTarget:self selector:@selector(colorBG:data:) data:[NSNumber numberWithBool:true]];
                    id unColorBGAction = [CCCallFuncND actionWithTarget:self selector:@selector(colorBG:data:) data:[NSNumber numberWithBool:false]];
                    NSMutableArray *colorParams = [[NSMutableArray alloc] init];
                    [colorParams addObject:[NSNumber numberWithInt:1]];
                    [colorParams addObject:body];
                    id colorFGAction = [CCCallFuncND actionWithTarget:self selector:@selector(colorFG:data:) data:colorParams];
                    colorParams = [[NSMutableArray alloc] init];
                    [colorParams addObject:[NSNumber numberWithInt:0]]; // 137, 0, 0 
                    [colorParams addObject:[NSValue valueWithPointer:NULL]];
                    id unColorFGAction = [CCCallFuncND actionWithTarget:self selector:@selector(colorFG:data:) data:colorParams];
                    id flipDarkAction = [CCCallFunc actionWithTarget:self selector:@selector(flipFGDark)];
                    
                    [ud->sprite1 runAction:[CCSequence actions:screenFlashAction, flipDarkAction, colorBGAction, colorFGAction, [CCDelayTime actionWithDuration:2.9], [CCCallFuncND actionWithTarget:self selector:@selector(barfDogs:data:) data:parameters], flipDarkAction, unColorBGAction, unColorFGAction, screenFlashAction, nil]];
                } else {
                    [ud->sprite1 runAction:ud->idleAction];
                    [ud->ripples runAction:ud->idleRipple];
                }
            }
        }
        else if((ud->stopTime && ud->timeWalking == ud->stopTime + ud->stopTimeDelta) || ud->timeWalking == ud->restartTime){
            if(ud->sprite1.tag != S_MUNCHR){
                ud->_busman_isVomiting = false;
                [ud->sprite1 runAction:ud->defaultAction];
                [ud->ripples runAction:ud->walkRipple];
                [ud->sprite2 runAction:ud->altAction];
                if(ud->sprite1.tag != S_POLICE){
                    if([ud->sprite2 numberOfRunningActions] == 0)
                        [ud->sprite2 runAction:ud->altAction];
                }
                if(ud->_busman_willVomit){
                    ud->heightOffset2 = 2.9;
                    ud->widthOffset = 0;
                }
            } else {
                if(ud->timeWalking == ud->stopTime + ud->stopTimeDelta){
                    [ud->ripples runAction:ud->walkRipple];
                    [ud->sprite2 runAction:ud->altWalkFace];
                    [ud->angryFace runAction:ud->angryFaceWalkAction];
                    if(_droppedCount > 0 && !_gameOver){
                        [self counterExplode:self data:[NSNumber numberWithInt:0]];
                        _droppedCount--;
                        CCLOG(@"Dropped count: %d", _droppedCount);
                    }
                } else if(!ud->_muncher_hasDroppedDog){
                    [ud->sprite1 stopAction:ud->altAction2];
                    [ud->sprite2 stopAction:ud->altAction3];
                    [ud->angryFace stopAction:ud->dogOnHeadTickleAction];
                    CCLOG(@"muncher has not dropped dog");
                    if(!ud->animLock){
                        ud->animLock = true;
                        [ud->ripples runAction:ud->walkRipple];
                        [ud->sprite1 runAction:ud->defaultAction];
                        [ud->sprite2 runAction:ud->altAction];
                        [ud->angryFace runAction:ud->angryFaceWalkAction];
                    }
                }
            }
            if([ud->angryFace numberOfRunningActions] == 0)
                [ud->angryFace runAction:ud->angryFaceWalkAction];
        }
    } else if(b->GetLinearVelocity().x != 0){ b->SetLinearVelocity(b2Vec2(0, 0)); }
}

-(void)updateMuncher:(NSValue *)body{
    b2Body *b = (b2Body *)[body pointerValue];
    bodyUserData *ud = (bodyUserData *)b->GetUserData();
    if(ud->stopTime < 1000 && ud->stopTime > 0){
        BOOL touched = true;
        if(!((ud->timeWalking - ud->stopTime) % 20)){
            if(ud->tickleTimer < (ud->timeWalking - ud->stopTime)-30 && !ud->_muncher_hasDroppedDog){
                touched = false;
            }
        }
        if(!touched){
            ud->restartTime = ud->timeWalking + 1;
            ud->stopTimeDelta = 0;
            ud->touched = false;
            ud->rippleYOffset = ud->ogRippleYOffset;
            ud->rippleXOffset = ud->ogRippleXOffset;
        } else{
            if(ud->timeWalking == ud->stopTime + (ud->stopTimeDelta - ([ud->postStopAction duration]*60.0))){
                ud->_muncher_hasDroppedDog = true;
                ud->lowerYOffset = 9;
                if(ud->sprite1.flipX){
                    ud->lowerXOffset = -12;
                }
                else {
                    ud->lowerXOffset = 11;
                }
                NSMutableArray *animParams = [[NSMutableArray alloc] init];
                [animParams addObject:[NSValue valueWithPointer:ud->sprite1]];
                [animParams addObject:[NSValue valueWithPointer:ud->altWalk]];
                [ud->sprite1 runAction:[CCSequence actions:ud->postStopAction, [CCCallFuncND actionWithTarget:self selector:@selector(spriteRunAnim:data:) data:animParams], [CCCallFuncND actionWithTarget:self selector:@selector(clearLowerOffsets:data:) data:[[NSValue valueWithPointer:ud] retain]], nil]];
                [ud->sprite2 stopAllActions];
                [ud->angryFace stopAllActions];
                [ud->sprite2 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DogEater_DogGone_Head1.png"]];
                [ud->angryFace setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DogEater_DogGone_Head1.png"]];
            }
        }
    }
}

-(void)colorBG:(id)sender data:(NSNumber *)color{
    if([color boolValue]){
        [background setColor:satanColor];
    } else {
        [background setColor:ccc3(255, 255, 255)];
    }
}

-(void)colorFG:(id)sender data:(NSMutableArray *)params{
    NSNumber *color = [params objectAtIndex:0];
    NSValue *excludeBody = [params objectAtIndex:1];
    for(b2Body* b = _world->GetBodyList(); b; b = b->GetNext()){
        if(b->GetUserData() && b->GetUserData() != (void*)100){
            if([excludeBody pointerValue] == b) continue;
            bodyUserData *ud = (bodyUserData*)b->GetUserData();
            if((ud->sprite1.tag >= S_BUSMAN && ud->sprite1.tag <= S_TOPPSN) || ud->sprite1.tag == S_HOTDOG || ud->sprite1.tag == S_SPCDOG || ud->sprite1.tag == S_COPARM){
                if(color.intValue == 1){
                    [ud->sprite1 setColor:spcDogFlashColor];
                    [ud->sprite2 setColor:spcDogFlashColor];
                    [ud->angryFace setColor:spcDogFlashColor];
                    [ud->overlaySprite setColor:spcDogFlashColor];
                }
                else {
                    [ud->sprite1 setColor:ccc3(255,255,255)];
                    [ud->sprite2 setColor:ccc3(255,255,255)];
                    [ud->angryFace setColor:ccc3(255, 255, 255)];
                    [ud->overlaySprite setColor:ccc3(255,255,255)];
                }
            }
        }
    }
}

-(void)screenFlash:(id)sender data:(NSNumber *)light{
    if(light.intValue == 1){
        _flashLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 200) width:winSize.width height:winSize.height];
        [self addChild:_flashLayer z:-1];
    }
    else {
        [self removeChild:_flashLayer cleanup:YES];
        _flashLayer = NULL;
    }
}

-(void) spriteRunAnim:(id)sender data:(void*)params{
    //takes a sprite and an optional animation
    //if passed an action, run it. otherwise, stop all actions
    CCSprite *sprite = (CCSprite *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    if([(NSMutableArray *) params count] > 1){
        CCAction *action = (CCAction *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:1] pointerValue];
        [sprite runAction:action];
    }
}

-(void) draw {
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);

    _world->DrawDebugData();

    if(m_debugDraw){
        glColor4ub(255, 0, 0, 255);
        ccDrawLine(CGPointMake(policeRayPoint1.x*PTM_RATIO, policeRayPoint1.y*PTM_RATIO), CGPointMake(policeRayPoint2.x*PTM_RATIO, policeRayPoint2.y*PTM_RATIO));
        glColor4ub(0, 255, 0, 255);
        b2Joint *j = _world->GetJointList();
        if(j && j->GetType() == e_revoluteJoint){
            b2RevoluteJoint *r = (b2RevoluteJoint *)j;
            b2Body *body = j->GetBodyB();
            b2Vec2 lowerLimitPoint = b2Vec2(body->GetPosition() + 9 * b2Vec2(cosf(r->GetLowerLimit() ), sinf(r->GetLowerLimit())));
            b2Vec2 upperLimitPoint = b2Vec2(body->GetPosition() + 9 * b2Vec2(cosf(r->GetUpperLimit() ), sinf(r->GetUpperLimit())));
            ccDrawLine(CGPointMake(body->GetPosition().x*PTM_RATIO, body->GetPosition().y*PTM_RATIO), CGPointMake(lowerLimitPoint.x*PTM_RATIO, lowerLimitPoint.y*PTM_RATIO));
            ccDrawLine(CGPointMake(body->GetPosition().x*PTM_RATIO, body->GetPosition().y*PTM_RATIO), CGPointMake(upperLimitPoint.x*PTM_RATIO, upperLimitPoint.y*PTM_RATIO));
        }
    }
        
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

-(void)incrementDroppedCount:(id)sender data:(NSValue *)body{
    b2Body *b = (b2Body *)[body pointerValue];
    if(!b) return;
    if(b->GetPosition().x > winSize.width/PTM_RATIO || b->GetPosition().x < 0) return;
    if(_gameOver) return;
    if(_droppedCount < DROPPED_MAX && !_gameOver) _droppedCount++;
    CCLOG(@"Dropped count: %d", _droppedCount);
    [self counterExplode:self data:[NSNumber numberWithInt:1]];
}

-(void)clearLowerOffsets:(id)sender data:(NSValue *)userdata{
    bodyUserData *ud = (bodyUserData *)[userdata pointerValue];
    ud->lowerXOffset = 0;
    ud->lowerYOffset = 0;
}

-(void)playParticles:(id)sender data:(NSValue *)particles{
    [self addChild:(CCParticleSystem *)[particles pointerValue] z:100];
}

-(void)setSubwayForce:(id)sender data:(NSNumber *)force {
    _subwayForce = force.floatValue;
}

-(void)counterExplode:(id)sender data:(NSNumber *)increment{
    int inc = [increment intValue]; // 1 if dropped, 0 if regained
    NSMutableArray *counterAnimFrames = [[NSMutableArray alloc] init];
    ccColor4F startColorRed = {1, 0, 0, 1};
    ccColor4F startColorGrn = {0, 1, 0, 1};
    ccColor4F endColor = {1, 1, 1, 0};
    if(inc){
        for(int i = 1; i <= 6; i++){
            [counterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                          [NSString stringWithFormat:@"DogHud_X_%d.png", i]]];
        }
    } else {
        for(int i = 1; i <= 21; i++){
            [counterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                          [NSString stringWithFormat:@"DogBack_Anim_%d.png", i]]];
        }
        [counterAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DogHud_Dog.png"]];
    }
        
    CCSprite *sprite = (CCSprite *)[[dogIcons objectAtIndex:_droppedCount-1] pointerValue];
    CCAnimation *xAnim = [CCAnimation animationWithFrames:counterAnimFrames delay:.08f];
    CCFiniteTimeAction *xAction = [CCAnimate actionWithAnimation:xAnim restoreOriginalFrame:NO];
#ifdef DEBUG
#else
    CCParticleSystem* particles = [CCParticleExplosion node];
    particles.autoRemoveOnFinish = YES;
    particles.position = sprite.position;
    if(inc)
        particles.startColor = startColorRed;
    else 
        particles.startColor = startColorGrn;
    particles.endColor = endColor;
    particles.life = .0000000005;
    particles.startSize = .003;
    particles.startRadius = .0005;
    particles.endSize = .0005;
    particles.endRadius = .0005;
    particles.speed = 120;
    particles.duration = .05;
    
    [sprite runAction:[CCSequence actions:xAction, [CCCallFuncND actionWithTarget:self selector:@selector(playParticles:data:) data:[[NSValue valueWithPointer:particles] retain]], nil]];
#endif
}

-(void)destroyWiener:(id)sender data:(NSValue *)db {
    b2Body *dogBody = (b2Body *)[db pointerValue];
    if(!dogBody) return;
    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();

    CCSprite *dogSprite = (CCSprite *)sender;

    if(dogBody->GetPosition().x > winSize.width/PTM_RATIO || dogBody->GetPosition().x < 0) return;
    
    CCLOG(@"Destroying dog (tag %d)...", dogSprite.tag);

    if(dogSprite.tag == S_HOTDOG || dogSprite.tag == S_SPCDOG){
        _hasDroppedDog = true;
        dogBody->SetAwake(false);
        [dogSprite stopAllActions];
        [dogSprite removeFromParentAndCleanup:YES];
        [ud->howToPlaySprite removeFromParentAndCleanup:YES];
        [ud->overlaySprite removeFromParentAndCleanup:YES];
        _world->DestroyBody(dogBody);
#ifdef DEBUG
#else
        if(_sfxOn)
            [[SimpleAudioEngine sharedEngine] playEffect:@"hot dog disappear.mp3"];
#endif
    }
}

-(void)copFlipAim:(id)sender data:(NSValue *)cb {
    b2Body *copBody = (b2Body *)[cb pointerValue];
    bodyUserData *ud = (bodyUserData *)copBody->GetUserData();

    if(ud->aiming){
        ud->aiming = false;
        ud->_cop_hasShot = true;
    } else {
        ud->aiming = true;
    }
}

-(void)barfDogs:(id)sender data:(NSMutableArray *)a{
    CGPoint loc = [[a objectAtIndex:0] CGPointValue];
    NSNumber *xVel = [a objectAtIndex:1];
    
    float friction = 1, restitution = 1, delay = 1.9; // TODO - this is a blatant violation of DRY
    if(level->frictionMul)
        friction = level->frictionMul;
    if(level->restitutionMul){
        restitution = level->restitutionMul;
    }
    if(level->dogDeathDelay){
        delay = level->dogDeathDelay;
    }
    
    for(int i = 0; i < 4; i++){
        [[HotDog alloc] init:[NSValue valueWithPointer:spriteSheetCommon]
                                 withWorld:[NSValue valueWithPointer:_world]
                              withLocation:[NSValue valueWithCGPoint:CGPointMake(loc.x, loc.y+(i*15))]
                                withSpcDog:[NSValue valueWithPointer:NULL]
                                   withVel:[NSValue valueWithCGPoint:CGPointMake(xVel.intValue, .1)]
                            withDeathDelay:[NSNumber numberWithFloat:delay]
                             withDeathAnim:level->dogDeathAnimFrames
                           withFrictionMul:[NSNumber numberWithFloat:friction]
                        withRestitutionMul:[NSNumber numberWithFloat:restitution]];
    }
}

-(void)putDog:(id)sender data:(NSNumber *)type {
    int SIDE_BUFFER = 40;
    CGPoint location = CGPointMake(arc4random() % (int)(SIDE_BUFFER+(winSize.width-(2*SIDE_BUFFER))), DOG_SPAWN_MINHT+(arc4random() % (int)(winSize.height-DOG_SPAWN_MINHT)));
    
    spcDogData *dd = NULL;
    if (type.intValue == 1 && _peopleGrumped > 2){
        dd = level->specialDog;
    }
    
    float friction = 1, restitution = 1, delay = 1.9;
    if(level->frictionMul)
        friction = level->frictionMul;
    if(level->restitutionMul){
        restitution = level->restitutionMul;
    }
    if(level->dogDeathDelay){
        delay = level->dogDeathDelay;
    }
    
    HotDog *dog = [[HotDog alloc] init:[NSValue valueWithPointer:spriteSheetCommon]
                             withWorld:[NSValue valueWithPointer:_world]
                          withLocation:[NSValue valueWithCGPoint:location]
                            withSpcDog:[NSValue valueWithPointer:dd] // must be NULL sometimes
                               withVel:[NSValue valueWithCGPoint:CGPointMake(0, 0)] // must be NULL sometimes
                        withDeathDelay:[NSNumber numberWithFloat:delay]
                         withDeathAnim:level->dogDeathAnimFrames
                       withFrictionMul:[NSNumber numberWithFloat:friction]
                    withRestitutionMul:[NSNumber numberWithFloat:restitution]];
    
    b2Body *wienerBody = (b2Body *)[[dog getBody] pointerValue];
    bodyUserData *ud = (bodyUserData *)wienerBody->GetUserData();
    CCSprite *sprite = (CCSprite *)ud->sprite1;
    
    wienerBody->SetAwake(false);

    NSMutableArray *wienerAppearAnimFrames = [[NSMutableArray alloc] init];
    if(type.intValue == 1){
        for(int i = 1; i <= 6; i++){
            [wienerAppearAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"BonusAppear%d.png", i]]];
        }
    } else {
        for(int i = 1; i <= 10; i++){
            [wienerAppearAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Dog_Appear_%d.png", i]]];
        }
    }
    CCAnimation *dogAppearAnim = [CCAnimation animationWithFrames:wienerAppearAnimFrames delay:.08f];
    _appearAction = [CCAnimate actionWithAnimation:dogAppearAnim];
    
    //wake up the hot dog after the appear animation is done
    NSMutableArray *wakeParameters = [[NSMutableArray alloc] initWithCapacity:2];
    NSValue *v = [NSValue valueWithPointer:wienerBody];
    NSNumber *wake = [NSNumber numberWithInt:1];
    [wakeParameters addObject:v];
    [wakeParameters addObject:wake];
    CCCallFuncND *wakeAction = [CCCallFuncND actionWithTarget:self selector:@selector(setAwake:data:) data:wakeParameters];
    CCSequence *seq;
    seq = [CCSequence actions:_appearAction, wakeAction, nil];
    [sprite runAction:seq];
#ifdef DEBUG
#else
    if(_sfxOn)
        [[SimpleAudioEngine sharedEngine] playEffect:@"hot dog appear 1.mp3"];
#endif
}

-(void)walkIn{
    int zIndex, armBodyXOffset, armBodyYOffset, yPos;
    int armJointYOffset, contactActionIndex;
    float density;

    NSNumber *floorBit = [floorBits objectAtIndex:arc4random() % [floorBits count]];
    int choice = arc4random() % level->characterProbSum;
    personStruct *p;
    for(NSValue *v in level->characters){
        p = (personStruct *)[v pointerValue];
        if(choice < p->frequency){
            break;
        }
        choice -= p->frequency;
    }
    personStruct *person = p;
    
    //first, see if a person should spawn
    if(_policeOnScreen && person->tag == S_POLICE){
        return;
    } else if(_muncherOnScreen && person->tag == S_MUNCHR){
        return;
    } else {
        for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
            if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
                bodyUserData *ud = (bodyUserData *)body->GetUserData();
                for(b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext()){
                    if(f->GetFilterData().maskBits == floorBit.intValue){
                        if(ud->sprite1.flipX != _personLower.flipX){
                            return;
                        }
                    }
                }
            }
        }
    }

    // cycle through a set of several possible mask/category bits for dog/person collision
    // this is so that a dog can be told only to collide with the person who it's touching already,
    // or to collide with all people. this breaks when there are more than 4 people onscreen
    if(_curPersonMaskBits >= 0x8000){
        _curPersonMaskBits = 0x1000;
    } else {
        _curPersonMaskBits *= 2;
    }
    
    //if we're not supposed to spawn , just skip all this
    NSNumber *xPos = [xPositions objectAtIndex:arc4random() % [xPositions count]];
    CCSprite *target;
    CCAction *_rippleWalkAction, *_rippleIdleAction;
    CCFiniteTimeAction *_vomitAction;
    NSMutableArray *armShootAnimFrames;

    density = 10;
    
    self.personLower = [CCSprite spriteWithSpriteFrameName:person->lowerSprite];
    self.personUpper = [CCSprite spriteWithSpriteFrameName:person->upperSprite];
    self.personUpperOverlay = [CCSprite spriteWithSpriteFrameName:person->upperOverlaySprite];
    if(person->rippleSprite){
        self.rippleSprite = [CCSprite spriteWithSpriteFrameName:person->rippleSprite];
        _rippleSprite.tag = person->tag;
    }
    _personLower.tag = person->tag;
    _personUpper.tag = person->tag;
    _personUpperOverlay.tag = person->tag;
    if(person->tag == 4){
        self.policeArm = [CCSprite spriteWithSpriteFrameName:person->armSprite];
        _policeArm.tag = person->armTag;
        armShootAnimFrames = [[NSMutableArray alloc] init];
    }
    
    if(floorBit.intValue == 1){
        zIndex = FLOOR1_Z;
        yPos = 76;
    }
    else if(floorBit.intValue == 2){
        zIndex = FLOOR2_Z;
        yPos = 89;
    }
    else if(floorBit.intValue == 4){
        zIndex = FLOOR3_Z;
        yPos = 102;
    }
    else{
        zIndex = FLOOR4_Z;
        yPos = 115;
    }

    NSMutableArray *notifiers = [PointNotify buildNotifiers];
    
    //create animations for walk, idle, and bobbing head
    CCAnimation *walkAnim = [CCAnimation animationWithFrames:person->walkAnimFrames delay:person->framerate/level->personSpeedMul];
    CCAction *_walkAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]] retain];
    [_personLower runAction:_walkAction];

    CCAnimation *idleAnim = [CCAnimation animationWithFrames:person->idleAnimFrames delay:.2f];
    CCAction *_idleAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:idleAnim restoreOriginalFrame:NO]] retain];

    CCAnimation *walkFaceAnim = [CCAnimation animationWithFrames:person->faceWalkAnimFrames delay:person->framerate/level->personSpeedMul];
    CCAction *_walkFaceAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkFaceAnim restoreOriginalFrame:NO]] retain];
    [_personUpper runAction:_walkFaceAction];

    CCAnimation *walkDogFaceAnim = [CCAnimation animationWithFrames:person->faceDogWalkAnimFrames delay:person->framerate/level->personSpeedMul];
    CCAction *_walkDogFaceAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkDogFaceAnim restoreOriginalFrame:NO]] retain];
    [_personUpperOverlay runAction:_walkDogFaceAction];
    
    if(person->vomitAnimFrames){
        CCAnimation *animation = [CCAnimation animationWithFrames:person->vomitAnimFrames delay:.12f];
        _vomitAction = [[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO] retain];
    }
    
    // if he has a ripple anim
    if(level->slug == @"japan"){
        if(person->rippleWalkAnimFrames){
            CCAnimation *rippleWalkAction = [CCAnimation animationWithFrames:person->rippleWalkAnimFrames delay:person->framerate/level->personSpeedMul];
            _rippleWalkAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:rippleWalkAction restoreOriginalFrame:NO]] retain];
            [_rippleSprite runAction:_rippleWalkAction];
        }
        if(person->rippleIdleAnimFrames){
            CCAnimation *rippleIdleAction = [CCAnimation animationWithFrames:person->rippleIdleAnimFrames delay:.2];
            _rippleIdleAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:rippleIdleAction restoreOriginalFrame:NO]] retain];
        }
    }
        
    CCAnimation *specialAnim, *specialFaceAnim, *specialAngryFaceAnim, *altFaceWalkAnim, *postStopAnim, *altWalkAnim;
    CCAction *_altWalkAction, *_altFaceWalkAction, *_specialFaceAction, *_specialAction, *_specialAngryFaceAction;
    CCFiniteTimeAction *_postStopAction;
    if(person->tag == S_POLICE){
        specialAnim = [CCAnimation animationWithFrames:person->specialAnimFrames delay:.08f];
        _specialAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:specialAnim restoreOriginalFrame:NO] times:1] retain];

        specialFaceAnim = [CCAnimation animationWithFrames:person->specialFaceAnimFrames delay:.1f];
        _specialFaceAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:specialFaceAnim restoreOriginalFrame:NO] times:1] retain];

        target = [CCSprite spriteWithSpriteFrameName:person->targetSprite];
        target.tag = S_CRSHRS;
        [spriteSheetCharacter addChild:target z:100];
    }
    else if(person->tag == S_MUNCHR){
        specialAnim = [CCAnimation animationWithFrames:person->specialAnimFrames delay:.1f];
        _specialAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:specialAnim restoreOriginalFrame:NO]] retain];
        
        specialFaceAnim = [CCAnimation animationWithFrames:person->specialFaceAnimFrames delay:.1f];
        _specialFaceAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:specialFaceAnim restoreOriginalFrame:NO]] retain];
        
        specialAngryFaceAnim = [CCAnimation animationWithFrames:person->specialFaceAnimFrames delay:.1f];
        _specialAngryFaceAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:specialAngryFaceAnim restoreOriginalFrame:NO]] retain];
        
        altWalkAnim = [CCAnimation animationWithFrames:person->altWalkAnimFrames delay:.1f];
        _altWalkAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:altWalkAnim restoreOriginalFrame:NO]] retain];
        
        altFaceWalkAnim = [CCAnimation animationWithFrames:person->altFaceWalkAnimFrames delay:.1f];
        _altFaceWalkAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:altFaceWalkAnim restoreOriginalFrame:NO]] retain];
        
        postStopAnim = [CCAnimation animationWithFrames:person->postStopAnimFrames delay:.07f];
        _postStopAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:postStopAnim restoreOriginalFrame:NO] times:1] retain];
    }

    //put the sprites in place
    _personLower.position = ccp(xPos.intValue, yPos);
    _personUpper.position = ccp(xPos.intValue, yPos);
    _personUpperOverlay.position = ccp(xPos.intValue, yPos);
    [spriteSheetCharacter addChild:_personLower z:zIndex];
    [spriteSheetCharacter addChild:_personUpper z:zIndex+2];
    [spriteSheetCharacter addChild:_personUpperOverlay z:zIndex+2];
    if(person->rippleSprite && level->slug == @"japan"){
        _rippleSprite.position = ccp(xPos.intValue, yPos);
        [spriteSheetCharacter addChild:_rippleSprite z:zIndex+3];
    }
    if(person->tag == S_POLICE){
        _policeArm.position = ccp(xPos.intValue, yPos);
        [spriteSheetCharacter addChild:_policeArm z:zIndex-2];
    }
    
    int moveDelta, lowerArmAngle, upperArmAngle;
    float rippleXOffset;
    
    //set secondary values based on the direction of the walk
    if((xPos.intValue > winSize.width/2)){
        moveDelta = -1*person->moveDelta;
        rippleXOffset = person->rippleXOffset;
        if(person->flipSprites){
            _personLower.flipX = YES;
            _personUpper.flipX = YES;
            _personUpperOverlay.flipX = YES;
        } else { /*_rippleSprite.flipX = YES;*/ }
        if(person->tag == S_POLICE){
            lowerArmAngle = 132;
            upperArmAngle = 175;
            armBodyXOffset = 8;
            armBodyYOffset = 42;
            armJointYOffset = 40;
            _policeArm.flipX = YES;
            _policeArm.flipY = YES;
        }
    } else {
        moveDelta = person->moveDelta;
        rippleXOffset = -1 * person->rippleXOffset;
        if(!person->flipSprites){
            _personLower.flipX = YES;
            _personUpper.flipX = YES;
            _personUpperOverlay.flipX = YES;
            _rippleSprite.flipX = YES;
        } else { _rippleSprite.flipX = YES; }
        if(person->tag == S_POLICE){
            lowerArmAngle = 0;
            upperArmAngle = 55;
            armBodyXOffset = 8;
            armBodyYOffset = 39;
            armJointYOffset = 44;
            _policeArm.flipX = YES;
        }
    }
    
    switch (person->pointValue){
        case 10: contactActionIndex = 0;
            break;
        case 15: contactActionIndex = 1;
            break;
        case 25: contactActionIndex = 2;
            break;
        default: contactActionIndex = 1;
            break;
    }

    //set up userdata structs
    bodyUserData *ud = new bodyUserData();
    ud->sprite1 = _personLower;
    ud->sprite2 = _personUpper;
    ud->angryFace = _personUpperOverlay;
    if(level->slug == @"japan" && person->rippleSprite){
        ud->ripples = _rippleSprite;
        ud->walkRipple = _rippleWalkAction;
        ud->idleRipple = _rippleIdleAction;
        ud->rippleXOffset = rippleXOffset;
        ud->ogRippleXOffset = rippleXOffset;
        ud->rippleYOffset = person->rippleYOffset;
        ud->ogRippleYOffset = person->rippleYOffset;
    }
    if(person->vomitAnimFrames && arc4random() % VOMIT_PROBABILITY == 1){
        ud->_busman_willVomit = true;
        ud->_vomitAction = _vomitAction;
    }
    ud->defaultAction = _walkAction;
    ud->angryFaceWalkAction = _walkDogFaceAction;
    ud->altWalk = _altWalkAction;
    ud->altWalkFace = _altFaceWalkAction;
    ud->heightOffset2 = person->heightOffset;
    ud->altAction = _walkFaceAction;
    ud->postStopAction = _postStopAction;
    ud->idleAction = _idleAction;
    ud->collideFilter = _curPersonMaskBits;
    ud->moveDelta = moveDelta*level->personSpeedMul;
    ud->pointValue = person->pointValue;
    ud->howToPlaySpriteYOffset = 195;
    // point notifiers
    ud->_not_dogContact = (CCFiniteTimeAction *)[(NSValue *)[notifiers objectAtIndex:contactActionIndex] pointerValue];
    ud->_not_dogOnHead = (CCFiniteTimeAction *)[(NSValue *)[notifiers objectAtIndex:3] pointerValue];
    ud->_not_leaveScreen = (CCFiniteTimeAction *)[(NSValue *)[notifiers objectAtIndex:4] pointerValue];
    ud->_not_leaveScreenFlash = (CCFiniteTimeAction *)[(NSValue *)[notifiers objectAtIndex:5] pointerValue];
    ud->_not_spcContact = (CCFiniteTimeAction *)[(NSValue *)[notifiers objectAtIndex:6] pointerValue];
    ud->_not_spcOnHead = (CCFiniteTimeAction *)[(NSValue *)[notifiers objectAtIndex:7] pointerValue];
    ud->_not_spcLeaveScreen = (CCFiniteTimeAction *)[(NSValue *)[notifiers objectAtIndex:8] pointerValue];
    if(person->tag == S_BUSMAN){
        ud->stopTime = 100 + (arc4random() % 80);
        ud->stopTimeDelta = 100 + (arc4random() % 80);
    }
    else if(person->tag == S_POLICE || person->tag == S_MUNCHR){
        ud->altAction2 = _specialAction;
        ud->altAction3 = _specialFaceAction;
        ud->stopTime = 9999; // huge number init so that cops don't freeze on enter
        if(person->tag == S_POLICE){
            ud->overlaySprite = target;
            ud->stopTimeDelta = 60; // frames
            ud->_cop_hasShot = false;
            ud->aimFace = @"Cop_Head_Aiming_1.png";
        } else if (person->tag == S_MUNCHR){
            //ud->howToPlaySpriteXOffset = 40;
            //ud->howToPlaySpriteYOffset = 20;
            ud->dogOnHeadTickleAction = _specialAngryFaceAction;
        }
    }
    ud->restartTime = ud->stopTime + ud->stopTimeDelta;
    
    if(_fgIsDark){
        [ud->sprite1 setColor:spcDogFlashColor];
        [ud->sprite2 setColor:spcDogFlashColor];
        [ud->angryFace setColor:spcDogFlashColor];
        [ud->overlaySprite setColor:spcDogFlashColor];
    }
        
    int fTag = person->fTag;
    
    fixtureUserData *fUd1 = new fixtureUserData();
    fUd1->tag = fTag;

    fixtureUserData *fUd2 = new fixtureUserData();
    fUd2->tag = 50+fTag;

    fixtureUserData *fUd3 = new fixtureUserData();
    fUd3->tag = 100+fTag;

    //create the body/bodies and fixtures for various collisions
    b2BodyDef personBodyDef;
    personBodyDef.type = b2_dynamicBody;
    personBodyDef.position.Set(xPos.floatValue/PTM_RATIO, yPos/PTM_RATIO);
    personBodyDef.userData = ud;
    personBodyDef.fixedRotation = true;
    b2Body *_personBody = _world->CreateBody(&personBodyDef);

    //fixture for head hitbox
    b2PolygonShape personShape;
    personShape.SetAsBox(person->hitboxWidth/PTM_RATIO, person->hitboxHeight/PTM_RATIO, b2Vec2(person->hitboxCenterX, person->hitboxCenterY), 0);
    b2FixtureDef personShapeDef;
    personShapeDef.shape = &personShape;
    personShapeDef.density = 0;
    personShapeDef.friction = person->friction;
    if(level->frictionMul)
        personShapeDef.friction = person->friction*level->frictionMul;
    personShapeDef.restitution = person->restitution;
    personShapeDef.userData = fUd1;
    personShapeDef.filter.categoryBits = _curPersonMaskBits;
    personShapeDef.filter.maskBits = WIENER;
    _personBody->CreateFixture(&personShapeDef);
    
    //fixture for body
    b2PolygonShape personBodyShape;
    if(person->tag != S_MUNCHR)
        personBodyShape.SetAsBox(_personLower.contentSize.width/PTM_RATIO/2,(_personLower.contentSize.height)/PTM_RATIO/2);
    else 
        personBodyShape.SetAsBox((_personLower.contentSize.width+30)/PTM_RATIO/2,(_personLower.contentSize.height)/PTM_RATIO/2);
    b2FixtureDef personBodyShapeDef;
    personBodyShapeDef.shape = &personBodyShape;
    personBodyShapeDef.density = density;
    personBodyShapeDef.friction = 0;
    personBodyShapeDef.restitution = 0;
    personBodyShapeDef.filter.categoryBits = BODYBOX;
    personBodyShapeDef.userData = fUd2;
    personBodyShapeDef.filter.maskBits = floorBit.intValue;
    _personBody->CreateFixture(&personBodyShapeDef);

    //sensor above heads for point gathering
    b2PolygonShape personHeadSensorShape;
    personHeadSensorShape.SetAsBox(person->sensorWidth,person->sensorHeight,b2Vec2(person->hitboxCenterX, person->hitboxCenterY+(person->sensorHeight/2)), 0);
    b2FixtureDef personHeadSensorShapeDef;
    personHeadSensorShapeDef.shape = &personHeadSensorShape;
    personHeadSensorShapeDef.userData = fUd3;
    personHeadSensorShapeDef.isSensor = true;
    personHeadSensorShapeDef.filter.categoryBits = SENSOR;
    personHeadSensorShapeDef.filter.maskBits = WIENER;
    _personBody->CreateFixture(&personHeadSensorShapeDef);

    if(person->tag == S_POLICE){
        //create the cop's arm body if we need to
        for(int i = 1; i <= 2; i++){
            [armShootAnimFrames addObject:
                [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                [NSString stringWithFormat:@"Cop_Arm_Shoot_%d.png", i]]];
        }

        CCAnimation *armShootAnim = [CCAnimation animationWithFrames:armShootAnimFrames delay:.08f];
        CCFiniteTimeAction *_armShootAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:armShootAnim restoreOriginalFrame:YES] times:1] retain];

        bodyUserData *ud = new bodyUserData();
        ud->sprite1 = _policeArm;
        ud->altAction = _armShootAction;

        b2BodyDef armBodyDef;
        armBodyDef.type = b2_dynamicBody;
        armBodyDef.position.Set(((_personBody->GetPosition().x*PTM_RATIO)+(_policeArm.contentSize.width/2)+armBodyXOffset)/PTM_RATIO,
                                ((_personBody->GetPosition().y*PTM_RATIO)+(armBodyYOffset))/PTM_RATIO);
        armBodyDef.userData = ud;
        b2Body *_policeArmBody = _world->CreateBody(&armBodyDef);

        fixtureUserData *fUd = new fixtureUserData();
        b2PolygonShape armShape;
        armShape.SetAsBox(_policeArm.contentSize.width/PTM_RATIO/2, _policeArm.contentSize.height/PTM_RATIO/2);
        b2FixtureDef armShapeDef;
        armShapeDef.shape = &armShape;
        armShapeDef.density = 1;
        fUd->tag = F_COPARM;
        armShapeDef.userData = fUd;
        armShapeDef.filter.maskBits = 0x0000;
        _policeArmBody->CreateFixture(&armShapeDef);

        //"shoulder" joint
        b2RevoluteJointDef armJointDef;
        armJointDef.Initialize(_personBody, _policeArmBody,
                                b2Vec2(_personBody->GetPosition().x,
                                        ((_personBody->GetPosition().y*PTM_RATIO)+armJointYOffset)/PTM_RATIO));
        armJointDef.enableMotor = true;
        armJointDef.enableLimit = true;
        armJointDef.motorSpeed = 0.0f;
        armJointDef.maxMotorTorque = 10000.0f;
        armJointDef.lowerAngle = CC_DEGREES_TO_RADIANS(lowerArmAngle);
        armJointDef.upperAngle = CC_DEGREES_TO_RADIANS(upperArmAngle);
        _world->CreateJoint(&armJointDef);
    }
    CCLOG(@"Spawned person with tag %d", fTag);
}

-(void)wienerCallback:(id)sender data:(NSNumber *)thisType {
    CCLOG(@"Dogs onscreen: %d", _dogsOnscreen);
    
    if(_dogsOnscreen < _maxDogsOnScreen && !_gameOver){
        if(thisType.intValue == 1 && _peopleGrumped > 2){
            NSMutableArray *params = [[NSMutableArray alloc] init];
            
            id screenLightenAction = [CCCallFuncND actionWithTarget:self selector:@selector(screenFlash:data:) data:[[NSNumber numberWithInt:1] retain]];
            [params addObject:[NSNumber numberWithInt:1]];
            [params addObject:[NSValue valueWithPointer:NULL]];
            id darkenFGAction = [CCCallFuncND actionWithTarget:self selector:@selector(colorFG:data:) data:params];
            params = [[NSMutableArray alloc] init];
            [params addObject:[NSNumber numberWithInt:0]];
            [params addObject:[NSValue valueWithPointer:NULL]];
            id lightenFGAction = [CCCallFuncND actionWithTarget:self selector:@selector(colorFG:data:) data:params];
            id screenDarkenAction = [CCCallFuncND actionWithTarget:self selector:@selector(screenFlash:data:) data:[[NSNumber numberWithInt:0] retain]];
            id delay2 = [CCDelayTime actionWithDuration:.2];
            id sequence2 = [CCSequence actions: screenLightenAction, darkenFGAction, delay2, lightenFGAction, screenDarkenAction, nil];
            [self runAction:sequence2];
        }
        [self putDog:self data:thisType];
    }

    id delay = [CCDelayTime actionWithDuration:_wienerSpawnDelayTime];
    id callBackAction = [CCCallFuncND actionWithTarget: self selector: @selector(wienerCallback:data:) data:[[NSNumber numberWithInt:arc4random() % (int)SPECIAL_DOG_PROBABILITY] retain]];
    id sequence = [CCSequence actions: delay, callBackAction, nil];
    [self runAction:sequence];
}

-(void)spawnCallback{
    [self walkIn];

    id delay = [CCDelayTime actionWithDuration:1];
    id callBackAction = [CCCallFunc actionWithTarget: self selector: @selector(spawnCallback)];
    id sequence = [CCSequence actions: delay, callBackAction, nil];
    [self runAction:sequence];
}

-(id) initWithSlug:(NSString *)levelSlug {
    if( (self=[super init])) {
        winSize = [CCDirector sharedDirector].winSize;
        
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        self.isTouchEnabled = YES;
        
        reporter = [[AchievementReporter alloc] init];
        [reporter loadAchievements];
        
        _introDone = [standardUserDefaults integerForKey:@"introDone"];
        [standardUserDefaults setInteger:1 forKey:@"introDone"];
        
        NSMutableArray *levelStructs = [LevelSelectLayer buildLevels:[NSNumber numberWithInt:1]];
        for(int i = 0; i < [levelStructs count]; i++){
            level = (levelProps *)[[levelStructs objectAtIndex:i] pointerValue];
            if(level->slug == levelSlug){
                break;
            }
        }
        
        level->characters = [CharBuilder buildCharacters:level->slug];
        level->characterProbSum = 0;
        for(NSValue *v in level->characters){
            personStruct *p = (personStruct *)[v pointerValue];
            level->characterProbSum += p->frequency;
        }
        
        _savedHighScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", level->slug]];
        
        b2Vec2 gravity;
        gravity = b2Vec2(0.0f, -30.0);
        if(level->gravity)
            gravity = b2Vec2(0.0f, level->gravity);
        _world = new b2World(gravity);
        
        for(int i = 1; i < 4; i++){
            [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"Heart_Particle_%d.png", i]];
        }
        
        // spritesheets setup
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_common.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", level->spritesheet]];
        
        spriteSheetCommon = [CCSpriteBatchNode batchNodeWithFile:@"sprites_common.png"];
        spriteSheetCharacter = [CCSpriteBatchNode batchNodeWithFile:@"sprites_characters.png"];
        spriteSheetLevel = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", level->spritesheet]];
        
        bgSprites = [[NSMutableArray alloc] init];
        
        [self addChild:spriteSheetLevel];
        for(NSValue *v in level->bgComponents){
            bgComponent *bgc = (bgComponent *)[v pointerValue];
            if(bgc->sprite){
                [bgSprites addObject:[NSValue valueWithPointer:bgc->sprite]];
                [self addChild:bgc->sprite];
            }
        }
        [self addChild:spriteSheetCharacter];
        [self addChild:spriteSheetCommon];
        
        if(level->slug == @"nyc"){
            vent1 = [[SteamVent alloc] init:[NSValue valueWithPointer:spriteSheetCommon] withLevelSpriteSheet:[NSValue valueWithPointer:spriteSheetLevel] withPosition:[NSValue valueWithCGPoint:CGPointMake(340, 37)]];
            vent2 = [[SteamVent alloc] init:[NSValue valueWithPointer:spriteSheetCommon] withLevelSpriteSheet:[NSValue valueWithPointer:spriteSheetLevel] withPosition:[NSValue valueWithCGPoint:CGPointMake(140, 37)]];
        } else if(level->slug == @"chicago"){
            bgComponent *bgc = (bgComponent *)[[level->bgComponents objectAtIndex:0] pointerValue];
            CCAnimation *anim = [CCAnimation animationWithFrames:bgc->anim1 delay:.1f];
            _flag1LeftAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]] retain];
            anim = [CCAnimation animationWithFrames:bgc->anim2 delay:.1f];
            _flag1RightAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]] retain];
            
            bgc = (bgComponent *)[[level->bgComponents objectAtIndex:1] pointerValue];
            anim = [CCAnimation animationWithFrames:bgc->anim1 delay:.1f];
            _flag2LeftAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]] retain];
            anim = [CCAnimation animationWithFrames:bgc->anim2 delay:.1f];
            _flag2RightAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]] retain];
            
            bgc = (bgComponent *)[[level->bgComponents objectAtIndex:2] pointerValue];
            anim = [CCAnimation animationWithFrames:bgc->anim1 delay:.1f];
            _dustAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]] retain];
        } else if (level->slug == @"london"){
            id startForceAction = [CCCallFuncND actionWithTarget:self selector:@selector(setSubwayForce:data:) data:[[NSNumber numberWithFloat:-1.0] retain]];
            id stopForceAction = [CCCallFuncND actionWithTarget:self selector:@selector(setSubwayForce:data:) data:[[NSNumber numberWithFloat:1.0] retain]];
            bgComponent *bgc = (bgComponent *)[[level->bgComponents objectAtIndex:0] pointerValue];
            window1CycleAction = [[CCSequence actions:startForceAction, bgc->startingAction, bgc->loopingAction, stopForceAction, bgc->stoppingAction, nil] retain];
            bgc = (bgComponent *)[[level->bgComponents objectAtIndex:1] pointerValue];
            window2CycleAction = [[CCSequence actions:bgc->startingAction, bgc->loopingAction, bgc->stoppingAction, nil] retain];
            bgc = (bgComponent *)[[level->bgComponents objectAtIndex:2] pointerValue];
            window3CycleAction = [[CCSequence actions:bgc->startingAction, bgc->loopingAction, bgc->stoppingAction, nil] retain];
            bgc = (bgComponent *)[[level->bgComponents objectAtIndex:3] pointerValue];
            window4CycleAction = [[CCSequence actions:bgc->startingAction, bgc->loopingAction, bgc->stoppingAction, nil] retain];
        }

        background = [CCSprite spriteWithSpriteFrameName:level->bg];
        background.anchorPoint = CGPointZero;
        
#ifdef DEBUG
        //debug labels
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Debug draw" fontName:@"LostPet.TTF" fontSize:18.0];
        CCMenuItem *debug = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(debugDraw)];
        CCMenu *menu = [CCMenu menuWithItems:debug, nil];
        [menu setPosition:ccp(40, winSize.height-90)];
        CCLOG(@"Debug draw added");
        [self addChild:menu z:1000];
#else
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:level->bgm loop:YES];
        [spriteSheetLevel addChild:background z:-10];
#endif

        //basic game/box2d/cocos2d initialization
        _curPersonMaskBits = 0x1000;
        _wienerSpawnDelayTime = WIENER_SPAWN_START;
        _maxDogsOnScreen = 6;
        _levelMaxDogs = 6;
        if(level->maxDogs){
            _levelMaxDogs = level->maxDogs;
            _maxDogsOnScreen = level->maxDogs - 3;
        }
        _levelSpawnInterval = 3.5;
        if(level->spawnInterval){
            _levelSpawnInterval = level->spawnInterval;
        }
        _shootLock = NO;

        //contact listener init
        personDogContactListener = new PersonDogContactListener();
        _world->SetContactListener(personDogContactListener);
        
        // color definitions
        _color_pink = ccc3(255, 62, 166);
        spcDogFlashColor = ccc3(80, 80, 80);
        satanColor = ccc3(137, 0, 0);
            
        [standardUserDefaults synchronize];

        //HUD objects
        CCSprite *droppedBG = [CCSprite spriteWithSpriteFrameName:@"DogHud_BG.png"];;
        droppedBG.position = ccp(winSize.width/2-5, DOG_COUNTER_HT);
        [spriteSheetCommon addChild:droppedBG z:70];
        dogIcons = [[NSMutableArray alloc] initWithCapacity:DROPPED_MAX+1];
        for(int i = 200; i < 200+(23*DROPPED_MAX); i += 23){
            CCSprite *dogIcon = [CCSprite spriteWithSpriteFrameName:@"DogHud_Dog.png"];
            dogIcon.position = ccp(winSize.width-i, DOG_COUNTER_HT);
            [spriteSheetCommon addChild:dogIcon z:70];
            [dogIcons addObject:[NSValue valueWithPointer:dogIcon]];
        }

        CCSprite *scoreBG = [CCSprite spriteWithSpriteFrameName:@"Score_BG.png"];;
        scoreBG.position = ccp(winSize.width-80, DOG_COUNTER_HT);
        [spriteSheetCommon addChild:scoreBG z:70];

        //labels for score
        NSString *scoreText = [[NSString alloc] initWithFormat:@"%06d", _points];
        scoreLabel = [CCLabelTTF labelWithString:scoreText fontName:@"LostPet.TTF" fontSize:34];
        [[scoreLabel texture] setAliasTexParameters];
        scoreLabel.color = _color_pink;
        scoreLabel.position = ccp(winSize.width-80, DOG_COUNTER_HT-3);
        [self addChild: scoreLabel z:72];

        NSInteger highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", level->slug]];
        _sfxOn = [standardUserDefaults integerForKey:@"sfxon"];
        
        CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HI: %d", highScore] fontName:@"LostPet.TTF" fontSize:18.0];
        highScoreLabel.color = _color_pink;
        [[highScoreLabel texture] setAliasTexParameters];
        highScoreLabel.position = ccp(winSize.width-50, 268);
        [self addChild: highScoreLabel];

        _pauseButton = [CCSprite spriteWithSpriteFrameName:@"Pause_Button.png"];;
        _pauseButton.position = ccp(20, 305);
        [spriteSheetCommon addChild:_pauseButton z:70];
        _pauseButtonRect = CGRectMake((_pauseButton.position.x-(_pauseButton.contentSize.width)/2), (_pauseButton.position.y-(_pauseButton.contentSize.height)/2), (_pauseButton.contentSize.width+10), (_pauseButton.contentSize.height+10));

        //initialize global arrays for possible x,y positions and charTags
        floorBits = [[NSMutableArray alloc] initWithCapacity:4];;
        for(int i = 1; i <= 8; i *= 2){
            [floorBits addObject:[NSNumber numberWithInt:i]];
        }
        xPositions = [[NSMutableArray alloc] initWithCapacity:2];
        [xPositions addObject:[NSNumber numberWithInt:winSize.width+30]];
        [xPositions addObject:[NSNumber numberWithInt:-30]];
        
        // allocate array to hold mouse joints for mutliple touches
        dogTouches = [[NSMutableArray alloc] init];
        
        fixtureUserData *fUd = new fixtureUserData();
        fUd->tag = F_GROUND;

        //set up the floors
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        groundBodyDef.userData = (void *)100;
        _groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        groundBoxDef.filter.categoryBits = FLOOR1;
        groundBoxDef.userData = fUd;
        groundBox.Set(b2Vec2(-30,FLOOR1_HT), b2Vec2((winSize.width+60)/PTM_RATIO, FLOOR1_HT));
        _groundBody->CreateFixture(&groundBoxDef);

        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR2;
        groundBox.Set(b2Vec2(-30,FLOOR2_HT), b2Vec2((winSize.width+60)/PTM_RATIO, FLOOR2_HT));
        _groundBody->CreateFixture(&groundBoxDef);

        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR3;
        groundBox.Set(b2Vec2(-30,FLOOR3_HT), b2Vec2((winSize.width+60)/PTM_RATIO, FLOOR3_HT));
        _groundBody->CreateFixture(&groundBoxDef);

        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR4;
        groundBox.Set(b2Vec2(-30,FLOOR4_HT), b2Vec2((winSize.width+60)/PTM_RATIO, FLOOR4_HT));
        _groundBody->CreateFixture(&groundBoxDef);

        fixtureUserData *fUd2 = new fixtureUserData();
        fUd2->tag = F_WALLS;

        //set up the walls
        b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
        b2Vec2 lowerRightCorner = b2Vec2(winSize.width/PTM_RATIO, 0);
        b2Vec2 upperLeftCorner = b2Vec2(0, winSize.height/PTM_RATIO);
        b2Vec2 upperRightCorner = b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO);
        b2BodyDef wallsBodyDef;
        wallsBodyDef.position.Set(0,0);
        b2Body *_wallsBody = _world->CreateBody(&wallsBodyDef);
        b2EdgeShape wallsBox;
        b2FixtureDef wallsBoxDef;
        wallsBoxDef.shape = &wallsBox;
        wallsBoxDef.filter.categoryBits = WALLS;
        wallsBoxDef.userData = fUd2;
        wallsBox.Set(lowerLeftCorner, upperLeftCorner);
        _wallsBody->CreateFixture(&wallsBoxDef);
        wallsBox.Set(upperLeftCorner, upperRightCorner);
        _wallsBody->CreateFixture(&wallsBoxDef);
        wallsBox.Set(upperRightCorner, lowerRightCorner);
        _wallsBody->CreateFixture(&wallsBoxDef);

        [TestFlight passCheckpoint:@"Game Started"];
        
        //schedule callbacks for dogs, people, and game value decrements
        [self spawnCallback];
        [self wienerCallback:self data:[[NSNumber numberWithInt:arc4random() % 10] retain]];
        [self schedule: @selector(tick:)];
    }
    return self;
}

//the "GAME LOOP"
-(void) tick: (ccTime) dt {
    int32 velocityIterations = 2;
    int32 positionIterations = 1;
    
    if(!_scoreNotifyLock && _savedHighScore > 0 && _savedHighScore < _points){
        _scoreNotifyLock = true;
        [self presentNewHighScoreNotify];
    }
    
    for(int i = 0; i < [dogTouches count]; i++){
        DogTouch *dt = (DogTouch *)[[dogTouches objectAtIndex:i] pointerValue];
        if([dt isFlaggedForDeletion] || _gameOver)
            [dogTouches removeObject:[dogTouches objectAtIndex:i]];
    }
    
    if(!_policeOnScreen)
        _shootLock = 0;
    
    if(_points > 19000 && !(time % 300) && _wienerSpawnDelayTime > .1){
        _wienerSpawnDelayTime -= .05;
    } else if(_points > 14000 && _wienerSpawnDelayTime != _levelSpawnInterval - 2.9){
        _maxDogsOnScreen = _levelMaxDogs;
        _wienerSpawnDelayTime = _levelSpawnInterval - 2.9;
    } else if(_points > 12000 && _wienerSpawnDelayTime != _levelSpawnInterval - 2.7) {
        _wienerSpawnDelayTime = _levelSpawnInterval - 2.7;
        _maxDogsOnScreen = _levelMaxDogs - 1;
    } else if(_points > 7000 && _wienerSpawnDelayTime != _levelSpawnInterval - 2.5) {
        _wienerSpawnDelayTime = _levelSpawnInterval - 2.5;
        _maxDogsOnScreen = _levelMaxDogs - 2;
    } else if(_points > 5000 && _wienerSpawnDelayTime != _levelSpawnInterval - 2) {
        _wienerSpawnDelayTime = _levelSpawnInterval - 2;
    } else if(_points > 2000 && _wienerSpawnDelayTime != _levelSpawnInterval - 1) {
        _wienerSpawnDelayTime = _levelSpawnInterval - 1;
    } else if(_points > 1000 && _wienerSpawnDelayTime != _levelSpawnInterval) {
        _wienerSpawnDelayTime = _levelSpawnInterval;
    }
    
    if(_droppedCount <= DROPPED_MAX && _droppedCount >= 0){
        for(NSValue *v in dogIcons){
            CCSprite *icon = (CCSprite *)[v pointerValue];
            if([dogIcons indexOfObject:v] < _droppedCount && [icon numberOfRunningActions] == 0){
                [icon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DogHud_X_6.png"]];
            } else if([icon numberOfRunningActions] == 0){
                [icon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"DogHud_Dog.png"]];
            }
        }
    }

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
    
    if(_flashLayer){
        [_flashLayer setOpacity:255 - (190+((5*time) % 255))];
    }

    time++;
    
    [self reportAchievements];
    [shiba updateSensorPosition];
    
    if(level->hasShiba && !(time % 500) && arc4random() % 3 == 1){
        shiba = [[Shiba alloc] init:[NSValue valueWithPointer:spriteSheetCharacter] withWorld:[NSValue valueWithPointer:_world]];
    }
    
    // level-specific repetitive actions
    if(level->slug == @"philly"){
        
    } else if(level->slug == @"nyc"){
        for(NSValue *v in bgSprites){
            CCSprite *sprite = (CCSprite *)[v pointerValue];
            if(sprite.tag && sprite.tag == 1)
                [sprite setOpacity:255.00 * cosf(.01 * time)];
        }
        if(!(time % [vent1 getInterval])){
            [vent1 startBlowing];
        } if(!(time % [vent2 getInterval])){
            [vent2 startBlowing];
        }
    } else if (level->slug == @"london" && !(time % 500)){
        bgComponent *bgc = (bgComponent *)[[level->bgComponents objectAtIndex:0] pointerValue];
        if([bgc->sprite numberOfRunningActions] == 0){
            [bgc->sprite runAction:window1CycleAction];
            bgc = (bgComponent *)[[level->bgComponents objectAtIndex:1] pointerValue];
            [bgc->sprite runAction:window2CycleAction];
            bgc = (bgComponent *)[[level->bgComponents objectAtIndex:2] pointerValue];
            [bgc->sprite runAction:window3CycleAction];
            bgc = (bgComponent *)[[level->bgComponents objectAtIndex:3] pointerValue];
            [bgc->sprite runAction:window4CycleAction];
        }
    } else if(level->slug == @"china"){
        if(!(time % 250) && arc4random() % 2  == 1){
            firecracker = [[Firecracker alloc] init:[NSValue valueWithPointer:_world] withSpritesheet:[NSValue valueWithPointer:spriteSheetCommon]];
            [firecracker runSequence];
        }
    } else if(level->slug == @"chicago" && !(time % 19)){
        float maxWind = 3.2;
        float windX = maxWind * cosf(.01 * time);
        //float windX = (float)(arc4random() % 5);
        CCLOG(@"wind: %0.2f", windX);
        windForce = b2Vec2(windX, .2);
        CCSprite *flag1 = (CCSprite *)[[bgSprites objectAtIndex:0] pointerValue];
        CCSprite *flag2 = (CCSprite *)[[bgSprites objectAtIndex:1] pointerValue];
        CCSprite *dust = (CCSprite *)[[bgSprites objectAtIndex:2] pointerValue];
        [dust setOpacity:(abs(windX) * (255/maxWind))];
        if(windX < .70 && windX > -.70){
            [flag1 stopAllActions];
            [flag1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Flag_Flap_6.png"]];
            [flag2 stopAllActions];
            [flag2 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Flag_Flap_6.png"]];
            [dust stopAllActions];
        }
        else if(windX > 0.0 && [flag1 numberOfRunningActions] == 0){
            [flag1 runAction:_flag1RightAction];
            [flag2 runAction:_flag2RightAction];
            [dust setVisible:true];
            [dust setFlipX:true];
            [dust runAction:_dustAction];
        }
        else if(windX < 0.0 && [flag1 numberOfRunningActions] == 0){ 
            [flag1 runAction:_flag1LeftAction];
            [flag2 runAction:_flag2LeftAction];
            [dust setVisible:true];
            [dust setFlipX:false];
            [dust runAction:_dustAction];
        }
    } else if(level->slug == @"space" && !(time % 100)){
        float maxGrav = 40.0f;
        float g = -1.0*(arc4random() % (int)(maxGrav - 1)) - 1;
        for(NSValue *v in bgSprites){
            CCSprite *gravi = (CCSprite *)[v pointerValue];
            if((g / (-1*maxGrav))*10 > [bgSprites indexOfObject:v])
                [gravi setVisible:true];
            else
                [gravi setVisible:false];
        }
        _world->SetGravity(b2Vec2(0, g));
    }

    //the "LOSE CONDITION"
    if(_droppedCount >= DROPPED_MAX){
        if(!_gameOver){
#ifdef DEBUG
#else
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            if(_sfxOn)
                [[SimpleAudioEngine sharedEngine] playEffect:@"game over sting.mp3"];
#endif
            CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Lvl_TextBox.png"];
            sprite.position = ccp(winSize.width/2, winSize.height/2);
            [self addChild:sprite];
        
            CCLabelTTF *gameOverLabel = [CCLabelTTF labelWithString:@"You lost five franks!" fontName:@"LostPet.TTF" fontSize:23.0];
            gameOverLabel.color = _color_pink;
            [[gameOverLabel texture] setAliasTexParameters];
            gameOverLabel.position = ccp(winSize.width/2, winSize.height/2+10);
            [self addChild:gameOverLabel];
        
            gameOverLabel = [CCLabelTTF labelWithString:@"Better luck next time..." fontName:@"LostPet.TTF" fontSize:23.0];
            gameOverLabel.color = _color_pink;
            [[gameOverLabel texture] setAliasTexParameters];
            gameOverLabel.position = ccp(winSize.width/2, winSize.height/2-10);
            [self addChild:gameOverLabel];
        
            [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3], [CCCallFunc actionWithTarget:self selector:@selector(loseScene)], nil]];
        
            _gameOver = true;
        }
    }
    
    _world->Step(dt, velocityIterations, positionIterations);

    //score and dropped count
    [scoreLabel setString:[NSString stringWithFormat:@"%06d", _points]];

    PersonDogContact pdContact;

    //collision detection happens in this loop
    std::vector<PersonDogContact>::iterator pos;
    for(pos = personDogContactListener->contacts.begin();
        pos != personDogContactListener->contacts.end(); ++pos)
    {
        b2Body *pBody, *dogBody;
        pdContact = *pos;

        if(pdContact.fixtureA->GetBody() != NULL){
            dogBody = pdContact.fixtureA->GetBody();
        }

        if(dogBody){
            bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
            fixtureUserData *fBUd = (fixtureUserData *)pdContact.fixtureB->GetUserData();
            if(fBUd->tag >= F_BUSHED && fBUd->tag <= F_TOPHED){
                [self heartParticles:[NSValue valueWithCGPoint:ud->sprite1.position]];
#ifdef DEBUG
#else
                if(_sfxOn)
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hot dog on head.mp3" pitch:1 pan:0 gain:.3];
#endif
                // a dog is definitely on a head when it collides with that head
                ud->_dog_isOnHead = true;
                pBody = pdContact.fixtureB->GetBody();
                bodyUserData *pUd = (bodyUserData *)pBody->GetUserData();
                b2Filter dogFilter;
                if(!dogBody) continue;
                for(b2Fixture* fixture = dogBody->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                    fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                    if(fUd->tag == F_DOGCLD){
                        dogFilter = fixture->GetFilterData();
                        // only allow the dog to collide with the person it's on
                        // by setting its mask bits to the person's category bits 
                        dogFilter.maskBits = pUd->collideFilter;
                        fixture->SetFilterData(dogFilter);
                        ud->collideFilter = dogFilter.maskBits;
                        break;
                    }
                }
                if(!ud->hasTouchedHead && !_gameOver){
                    NSMutableArray *plusPointsParams = [[NSMutableArray alloc] initWithCapacity:4];
                    [plusPointsParams addObject:[NSNumber numberWithInt:pBody->GetPosition().x*PTM_RATIO]];
                    [plusPointsParams addObject:[NSNumber numberWithInt:(pBody->GetPosition().y+4.7)*PTM_RATIO]];
                    int p;
                    if(ud->sprite1.tag == S_SPCDOG)
                        p = 100;
                    else 
                        p = pUd->pointValue;
                    [plusPointsParams addObject:[NSNumber numberWithInt:p]];
                    [plusPointsParams addObject:[NSValue valueWithPointer:pUd]];
                    _points += p;
                    [self plusPoints:self data:plusPointsParams];
                }
                ud->hasTouchedHead = true;
                if(!pUd->_person_hasTouchedDog){
                    pUd->_person_hasTouchedDog = true;
                    _peopleGrumped++;
                }
            } else if (fBUd->tag == F_GROUND){
                // dog is definitely not on a head if it's touching the floor
                ud->_dog_isOnHead = false;
                ud->hasTouchedHead = false;
                ud->hasTouchedGround = true;
                ud->touchLock = false;
                //ud->grabbed = false;
                if(ud->shotSeq && !ud->touchLock)
                    [ud->sprite1 stopAction:ud->shotSeq];
                if(!ud->deathSeqLock){
                    [self runDogDeathAction:[NSValue valueWithPointer:dogBody]];
                }
                ud->aimedAt = false;
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
    _dogsOnscreen = 0;
    
    for(b2Body* b = _world->GetBodyList(); b; b = b->GetNext()){
        if(b->GetUserData() && b->GetUserData() != (void*)100){
            bodyUserData *ud = (bodyUserData*)b->GetUserData();
            //boilerplate - update sprite positions to match their physics bodies
            ud->sprite1.position = CGPointMake((b->GetPosition().x * PTM_RATIO)+ud->lowerXOffset, (b->GetPosition().y * PTM_RATIO)+ud->lowerYOffset);
            ud->sprite1.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            if((ud->sprite1.position.x > winSize.width+(ud->sprite1.contentSize.width/2) || ud->sprite1.position.x < 0-(ud->sprite1.contentSize.width/2))
               && !ud->hasLeftScreen && !_gameOver){
                ud->hasLeftScreen = true;
                _points += ud->dogsOnHead * 100;
                _points += ud->spcDogsOnHead * 1000;
                if(ud->dogsOnHead != 0){
                    CCSprite *oneHundred = [CCSprite spriteWithSpriteFrameName:@"Bonus_Plus_1000_8.png"];
                    NSMutableArray *plus100Params = [[NSMutableArray alloc] initWithCapacity:4];
                    if(ud->sprite1.position.x > winSize.width/2){
                        [plus100Params addObject:[NSNumber numberWithInt:winSize.width-(oneHundred.contentSize.width/2)-10]];
                        [plus100Params addObject:[NSNumber numberWithInt:(b->GetPosition().y+4.7)*PTM_RATIO]];
                    }
                    else{
                        [plus100Params addObject:[NSNumber numberWithInt:(oneHundred.contentSize.width/2)]];
                        [plus100Params addObject:[NSNumber numberWithInt:(b->GetPosition().y+4.7)*PTM_RATIO]];
                    }
                    if(ud->spcDogsOnHead > 0)
                        [plus100Params addObject:[NSNumber numberWithInt:1]];
                    else
                        [plus100Params addObject:[NSNumber numberWithInt:0]];
                    [plus100Params addObject:[NSValue valueWithPointer:ud]];
                    [self plusOneHundred:self data:plus100Params];
                }
            }
            
            //destroy any sprite/body pair that's offscreen
            if(ud->sprite1.position.x > winSize.width + 80 || ud->sprite1.position.x < -80 ||
               ud->sprite1.position.y > winSize.height + 700 || ud->sprite1.position.y < -40){
                [ud->sprite1 stopAllActions];
                [ud->sprite2 stopAllActions];
                [ud->overlaySprite stopAllActions];
                // points for dogs that leave the screen on a person's head
                if(ud->sprite1.tag >= S_BUSMAN && ud->sprite1.tag <= S_TOPPSN){
                    if(ud->sprite1.tag == S_POLICE){
                        _shootLock = 0;
                    }
                }
                if(b->GetJointList()){
                    _world->DestroyJoint(b->GetJointList()->joint);
                }
                if(ud->sprite1.tag == S_HOTDOG || ud->sprite1.tag == S_SPCDOG){
                    _dogsSaved++;
                }
                CCLOG(@"Body removed - tag %d", ud->sprite1.tag);
                [ud->sprite1 removeFromParentAndCleanup:YES];
                if(ud->sprite2 != NULL){
                    [ud->sprite2 removeFromParentAndCleanup:YES];
                }
                if(ud->angryFace != NULL){
                    [ud->angryFace removeFromParentAndCleanup:YES];
                }
                if(ud->overlaySprite != NULL){
                    [ud->overlaySprite removeFromParentAndCleanup:YES];
                }
                if(ud->howToPlaySprite != NULL){
                    [ud->howToPlaySprite removeFromParentAndCleanup:YES];
                }
                _world->DestroyBody(b);
                ud = NULL;
                continue;
            }
            
            if(!b) continue;
            
            if(ud->sprite1.tag == S_HOTDOG &&  b->GetPosition().y <= FLOOR4_HT && (ud->sprite1.position.x > winSize.width || ud->sprite1.position.x < 0)){
                [ud->sprite1 removeFromParentAndCleanup:YES];
                ud->sprite1 = NULL;
                _world->DestroyBody(b);
            }
            
            if(ud->overlaySprite != NULL){
                if(ud->sprite1.tag == S_POLICE){
                    if(!ud->aiming){
                        [ud->overlaySprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Target_NoDog.png"]];
                        ud->overlaySprite.position = CGPointMake(policeRayPoint2.x*PTM_RATIO, policeRayPoint2.y*PTM_RATIO);
                        ud->overlaySprite.rotation = 3 * (time % 360);
                        if(ud->_cop_hasShot){
                            [ud->overlaySprite removeFromParentAndCleanup:YES];
                            ud->overlaySprite = NULL;
                        }
                    }
                }
                else {
                    ud->overlaySprite.position = CGPointMake(((b->GetPosition().x)*PTM_RATIO),
                                                            ((b->GetPosition().y)*PTM_RATIO));
                }
            }
            if(ud->sprite2 != NULL){
                ud->sprite2.position = CGPointMake((b->GetPosition().x+ud->widthOffset)*PTM_RATIO,
                                                   (b->GetPosition().y+ud->heightOffset2)*PTM_RATIO);
                ud->sprite2.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            if(ud->angryFace != NULL){
                ud->angryFace.position = CGPointMake((b->GetPosition().x)*PTM_RATIO,
                                                   (b->GetPosition().y+ud->heightOffset2)*PTM_RATIO);
                ud->angryFace.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            if(ud->ripples != NULL){
                ud->ripples.position = CGPointMake((b->GetPosition().x+ud->rippleXOffset)*PTM_RATIO,
                                                   (b->GetPosition().y+ud->rippleYOffset)*PTM_RATIO);
                ud->ripples.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            if(ud->sprite1 != NULL){
                if(ud->sprite1.tag == S_MUNCHR){
                    _muncherOnScreen = YES;
                    if(ud->hasLeftScreen)
                        _muncherOnScreen = NO;
                    [self updateMuncher:[NSValue valueWithPointer:b]];
                }
                if(!b) continue;
                if(ud->sprite1.tag == S_COPARM){
                    policeRayPoint1 = b->GetPosition();
                    policeRayPoint2 = policeRayPoint1 + rayLength * b2Vec2(cosf(b->GetAngle()), sinf(b->GetAngle()));
                    input.p1 = policeRayPoint1;
                    input.p2 = policeRayPoint2;
                    input.maxFraction = 1;
                } else if(ud->sprite1.tag >= S_BUSMAN && ud->sprite1.tag <= S_TOPPSN){
                    if(_peopleGrumped <= OVERLAYS_STOP){
                        Overlay *overlay;
                        if(!ud->howToPlaySprite){
                            overlay = [[Overlay alloc] initWithPersonBody:[NSValue valueWithPointer:b] andSpriteSheet:[NSValue valueWithPointer:spriteSheetCommon]];
                            ud->howToPlaySprite = [overlay getSprite];
                        } else {
                            overlay = [[Overlay alloc] initWithSprite:[NSValue valueWithPointer:ud->howToPlaySprite] andBody:[NSValue valueWithPointer:b]];
                            [overlay updatePosition:[NSNumber numberWithInt:[dogTouches count]]];
                        }
                    }
                    ud->dogsOnHead = 0;
                    ud->spcDogsOnHead = 0;
                    ud->timeWalking++;
                    [self movePerson:[NSValue valueWithPointer:b]];
                    [self countDogsOnHead:[NSValue valueWithPointer:b]];
                    if(!ud->_busman_isVomiting){
                        [self setFace:[NSValue valueWithPointer:b]];
                    }
                    if(!(time % 40) && ud->dogsOnHead && !_gameOver){
                        // get some points if a dog is on a head
                        if(!b) continue;
                        _points += ud->dogsOnHead * 25;
                        _points += ud->spcDogsOnHead * 250;
                        NSMutableArray *plus25Params = [[NSMutableArray alloc] initWithCapacity:4];
                        [plus25Params addObject:[NSNumber numberWithInt:b->GetPosition().x*PTM_RATIO]];
                        [plus25Params addObject:[NSNumber numberWithInt:(b->GetPosition().y+4.7)*PTM_RATIO]];
                        if(ud->spcDogsOnHead > 0)
                            [plus25Params addObject:[NSNumber numberWithInt:1]];
                        else
                            [plus25Params addObject:[NSNumber numberWithInt:0]];
                        [plus25Params addObject:[NSValue valueWithPointer:ud]];
                        [self plusTwentyFive:self data:plus25Params];
                    }
                    if(ud->sprite1.tag == S_POLICE){
                        if(!b) continue;
                        _policeOnScreen = YES;
                        if(ud->hasLeftScreen)
                            _policeOnScreen = NO;
                        // cop arm rotation
                        if(!ud->aiming){
                            b2JointEdge *j = b->GetJointList();
                            if(j && j->joint->GetType() == e_revoluteJoint){
                                b2RevoluteJoint *r = (b2RevoluteJoint *)j->joint;
                                r->SetMotorSpeed(8 * cosf(.07 * time));
                            }
                        } else {
                            [self aimAtAimedDog:[NSValue valueWithPointer:b]];
                        }
                    }
                }
                else if(ud->sprite1.tag == S_HOTDOG || ud->sprite1.tag == S_SPCDOG){
                    Overlay *overlay;
                    if(_peopleGrumped <= OVERLAYS_STOP && level->slug != @"japan" && ud->sprite1.tag != S_SPCDOG){
                        if(!ud->howToPlaySprite){
                            overlay = [[Overlay alloc] initWithDogBody:[NSValue valueWithPointer:b] andSpriteSheet:[NSValue valueWithPointer:spriteSheetCommon]];
                            ud->howToPlaySprite = [overlay getSprite];
                        } else {
                            overlay = [[Overlay alloc] initWithSprite:[NSValue valueWithPointer:ud->howToPlaySprite] andBody:[NSValue valueWithPointer:b]];
                            [overlay updatePosition];
                        }
                    } else { [ud->howToPlaySprite setVisible:false]; }
                    HotDog *dog = [[HotDog alloc] initWithBody:[NSValue valueWithPointer:b]];
                    if(ud->sprite1.position.x > 0 && ud->sprite1.position.x < winSize.width)
                        _dogsOnscreen++;
                    if(_numWorldTouches <= 0){
                        if(ud->grabbed) // don't mark any dog as held if there are no touches
                            ud->grabbed = false;
                    }
                    if(!b) continue;
                    //things for hot dogs
                    if(b->IsAwake()){
                        [dog setDogDisplayFrame];
                        // a hacky way to ensure that dogs are registered as not on a head
                        // this works because it measures when a dog is below the level of the lowest head
                        // and then flips the _dog_isOnHead bit - however it does make the design more brittle
                        // since it breaks when we make very short characters
                        if(b->GetPosition().y - 1 < FLOOR4_HT)
                            ud->_dog_isOnHead = false;
                        if(ud->_dog_isOnHead)
                            [dog setOnHeadCollisionFilters];
                        else
                            [dog setOffHeadCollisionFilters];
                        [self perFrameLevelDogEffects:[NSValue valueWithPointer:b]];
                        
                        if([shiba dogIsInHitbox:[NSValue valueWithPointer:b]] && ![shiba hasEatenDog]){
                            if(!ud->grabbed && [shiba eatDog:[NSValue valueWithPointer:b]]){
                                [self incrementDroppedCount:self data:[NSValue valueWithPointer:b]];
                            }
                        }
                        // start cop shooting logic
                        for(b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext()) {
                            fixtureUserData *fUd = (fixtureUserData *)f->GetUserData();
                            b2RayCastOutput output;
                            if(fUd->tag == F_DOGCLD){
                                if(!f->RayCast(&output, input, 0)){ continue; }
                                bodyUserData *dogUd = (bodyUserData *)b->GetUserData();
                                b2Body *dogBody = b;
                                if(output.fraction < closestFraction && output.fraction > .1){
                                    if(!_shootLock && !dogUd->grabbed && dogBody->GetPosition().x < winSize.width/PTM_RATIO && dogBody->GetPosition().x > 0){
                                        CCLOG(@"Ray touched dog fixture with fraction %0.2f", output.fraction);
                                        _shootLock = YES;

                                        closestFraction = output.fraction;
                                        intersectionNormal = output.normal;
                                        intersectionPoint = policeRayPoint1 + closestFraction * (policeRayPoint2 - policeRayPoint1);
                                        
                                        b2Body *copBody = NULL, *copArmBody = NULL;
                                        bodyUserData *copUd = NULL, *armUd = NULL;
                                        
                                        for(b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
                                            if(body->GetUserData() && body->GetUserData() != (void*)100){
                                                if(body->GetPosition().x < winSize.width && body->GetPosition().x > 0 &&
                                                   body->GetPosition().y < winSize.height && body->GetPosition().y > 0){
                                                    copUd = (bodyUserData*)body->GetUserData();
                                                    if(copUd->sprite1 != NULL && copUd->sprite1.tag == S_POLICE){
                                                        copBody = body;
                                                        copUd = (bodyUserData *)copBody->GetUserData();
                                                    }
                                                    if(copUd->sprite1 != NULL && copUd->sprite1.tag == S_COPARM){
                                                        copArmBody = body;
                                                    }
                                                }
                                            }
                                        }
                                        if(!copBody || !copBody->GetUserData()) continue;
                                        copUd = (bodyUserData *)copBody->GetUserData();
                                        if(!copUd->_cop_hasShot && copArmBody && copArmBody->GetUserData()){
                                            NSValue *dBody = [[NSValue valueWithPointer:dogBody] retain];

                                            CCDelayTime *delay = [CCDelayTime actionWithDuration:((float)copUd->stopTimeDelta-10)/60];
                                            copUd->stopTime = copUd->timeWalking + 1;
                                            copUd->aiming = true;
                                            
                                            //////////////////////////  COP BODY SHOOTING  /////////////////////////

                                            [copUd->sprite1 stopAllActions];
                                            [copUd->ripples stopAllActions];
                                            [copUd->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Cop_Idle.png"]];
                                            [copUd->ripples setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Cop_Ripple_Idle.png"]];
                                            CCFiniteTimeAction *bodyShootAnimAction = (CCFiniteTimeAction *)copUd->altAction2;
                                            CCSequence *bodySeq = [CCSequence actions:delay, bodyShootAnimAction, nil];
                                            if([copUd->sprite2 numberOfRunningActions] == 0)
                                                [copUd->sprite2 runAction:bodySeq];

                                            
                                            //////////////////////////  COP FACE SHOOTING  //////////////////////////
                                            
                                            [copUd->sprite2 stopAllActions]; // override for possible race condition in the normal stopping logic?
                                            [copUd->sprite2 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:copUd->aimFace]];
                                            CCFiniteTimeAction *faceShootAnimAction = (CCFiniteTimeAction *)copUd->altAction3;
                                            CCSequence *faceSeq = [CCSequence actions:delay, faceShootAnimAction, nil];
                                            if([copUd->sprite2 numberOfRunningActions] == 0)
                                                [copUd->sprite2 runAction:faceSeq];
                                            
                                            //////////////////////////  COP ARM SHOOTING  //////////////////////////
                                            
                                            armUd = (bodyUserData *)copArmBody->GetUserData();
                                            CCFiniteTimeAction *armShootAnimAction = (CCFiniteTimeAction *)armUd->altAction;
                                            CCCallFunc *shot = [CCCallFunc actionWithTarget:self selector:@selector(playGunshot)];
                                            id armSeq = [CCSequence actions:delay, shot, armShootAnimAction, nil];
                                            if([armUd->sprite1 numberOfRunningActions] == 0)
                                                [armUd->sprite1 runAction:armSeq];
                                            
                                            
                                            ///////////////////////////  DOG SHOOTING  //////////////////////////
                                            
                                            ud->aimedAt = true;
                                            ud->shotSeq = [[CCSequence actions:delay, [CCCallFuncND actionWithTarget:self selector:@selector(explodeDog:data:) data:dBody], nil] retain];
                                            if([ud->sprite1 numberOfRunningActions] == 0) 
                                                [ud->sprite1 runAction:ud->shotSeq];
                                            
                                            id lockSeq = [CCSequence actions:delay,
                                                          [CCCallFunc actionWithTarget:self selector:@selector(flipShootLock)],
                                                          [CCCallFuncND actionWithTarget:self selector:@selector(copFlipAim:data:) data:[[NSValue valueWithPointer:copBody] retain]],
                                                          nil];
                                            [self runAction:lockSeq];
                                            
                                            copUd->_cop_hasShot = true;
                                            
                                            break;
                                        }
                                    }
                                }
                            }
                        } // end cop shooting stuff
                    }
                }
            }
        }
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_gameOver) return;
    
    b2Vec2 locationWorld1, locationWorld2;
    NSSet *allTouches = [event allTouches];
    int count = [allTouches count];
    UITouch *touch2 = NULL;
    locationWorld2 = b2Vec2(-1, -1);
    
    UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
    CGPoint touchLocation1 = [touch1 locationInView: [touch1 view]];
    touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
    CCLOG(@"Touching point %0.2f x %0.2f", touchLocation1.x, touchLocation1.y);
    locationWorld1 = b2Vec2(touchLocation1.x/PTM_RATIO, touchLocation1.y/PTM_RATIO);
    
    if(count > 1){
        touch2 = [[allTouches allObjects] objectAtIndex:1];
        CGPoint touchLocation2 = [touch2 locationInView: [touch2 view]];
        touchLocation2 = [[CCDirector sharedDirector] convertToGL: touchLocation2];
        locationWorld2 = b2Vec2(touchLocation2.x/PTM_RATIO, touchLocation2.y/PTM_RATIO);
    }
    
    b2MouseJointDef md;
    md.bodyA = _groundBody;
    NSNumber *hash;
    
    _numWorldTouches = count;
    int dogsTouched = 0;
    BOOL touched1 = false, touched2 = false;
    
    if (count <= 2){
        CCLOG(@"%d touches", count);
        if(CGRectContainsPoint(_pauseButtonRect, touchLocation1)){
            if(!_pause){
#ifdef DEBUG
#else
                if(_sfxOn)
                    [[SimpleAudioEngine sharedEngine] playEffect:@"pause 3.mp3"];
#endif
                [self pauseButton];
            }
            else{
                [self resumeGame];
            }
            return;
        }
        for(int i = 0; i < count; i++){ // for each touch
            for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
                if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
                    bodyUserData *ud = (bodyUserData *)body->GetUserData();
                    if(ud->sprite1.tag == S_MUNCHR && !ud->_muncher_hasDroppedDog){
                        for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                            fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                            if(fUd->tag < F_BUSSEN){
                                if(fixture->TestPoint(locationWorld1)){
                                    CCLOG(@"Touching muncher!");
                                    ud->touched = true;
                                    ud->stopTime = ud->timeWalking + 1;
                                    ud->stopTimeDelta = 170;
                                    ud->animLock = false;
                                
                                    [ud->sprite1 stopAllActions];
                                    if([ud->sprite1 numberOfRunningActions] == 0)
                                        [ud->sprite1 runAction:ud->altAction2];
                                
                                    [ud->sprite2 stopAllActions];
                                    if([ud->sprite2 numberOfRunningActions] == 0)
                                        [ud->sprite2 runAction:ud->altAction3];
                                
                                    [ud->angryFace stopAllActions];
                                    if([ud->angryFace numberOfRunningActions] == 0){
                                        [ud->angryFace runAction:ud->dogOnHeadTickleAction];
                                    }
                                    
                                    ud->rippleYOffset = -1.325;
                                    if(ud->sprite1.flipX){
                                        ud->rippleXOffset = 7.0/PTM_RATIO;
                                    }
                                    else {
                                        ud->rippleXOffset = -6.0/PTM_RATIO;
                                    }
                                    [ud->ripples stopAllActions];
                                    if([ud->ripples numberOfRunningActions] == 0){
                                        [ud->ripples runAction:ud->idleRipple];
                                    }
                                }
                            }
                        }
                    }
                    else if((ud->sprite1.tag == S_HOTDOG || ud->sprite1.tag == S_SPCDOG) && !ud->touchLock){ // loop over all hot dogs
                        for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                            // if the dog is not already grabbed and one of the touches is on it, make the joint
                            if (!ud->grabbed && ((fixture->TestPoint(locationWorld1) && !touched1) || (fixture->TestPoint(locationWorld2) && !touched2))){
                                dogsTouched++;
                                
                                md.bodyB = body;
                                md.collideConnected = true;
                                md.maxForce = 10000.0f * body->GetMass();

                                if(fixture->TestPoint(locationWorld1)){
                                    md.target = locationWorld1;
                                    hash = [[NSNumber numberWithInt:[touch1 hash]]retain];
                                    CCLOG(@"touch hash: %d", [touch1 hash]);
                                    touched1 = true;
                                }
                                else if(touch2 && _numWorldTouches >= 2 && locationWorld2.x > 0 && fixture->TestPoint(locationWorld2)){
                                    md.target = locationWorld2;
                                    CCLOG(@"touch hash: %d", [touch2 hash]);
                                    hash = [[NSNumber numberWithInt:[touch2 hash]]retain];
                                    touched2 = true;
                                }
                                
                                BOOL b = false;
                                for(NSValue *t in dogTouches){
                                    DogTouch *touch = (DogTouch *)[t pointerValue];
                                    if([touch getHash].intValue == hash.intValue){
                                        b = true;
                                    }
                                }
                                if(b) break;
                                
                                DogTouch *touch = [[DogTouch alloc] initWithBody:[[NSValue valueWithPointer:body]retain] andMouseJoint:[NSValue valueWithPointer:&md] andWorld:[[NSValue valueWithPointer:_world]retain] andHash:hash];
                                [dogTouches addObject:[NSValue valueWithPointer:touch]];

                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_gameOver) return;
    
    NSSet *allTouches = [event allTouches];
    int count = [allTouches count];
    b2Vec2 *locations = new b2Vec2[count];
    b2Vec2 locationWorld2 = b2Vec2(-1, -1);
    UITouch *touch2 = NULL;
    
    UITouch *touch1 = [[[allTouches allObjects] objectAtIndex:0] retain];
    CGPoint touchLocation1 = [touch1 locationInView: [touch1 view]];
    touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
    b2Vec2 locationWorld1 = b2Vec2(touchLocation1.x/PTM_RATIO, touchLocation1.y/PTM_RATIO);
    locations[0] = locationWorld1;
    
    if(count > 1){
        touch2 = [[[allTouches allObjects] objectAtIndex:1] retain];
        CGPoint touchLocation2 = [touch2 locationInView: [touch2 view]];
        touchLocation2 = [[CCDirector sharedDirector] convertToGL: touchLocation2];
        locationWorld2 = b2Vec2(touchLocation2.x/PTM_RATIO, touchLocation2.y/PTM_RATIO);
        locations[1] = locationWorld2;
    }
    
    for(NSValue *v in dogTouches){
        DogTouch *dt = (DogTouch *)[v pointerValue];
        NSNumber *hash = [[dt getHash] retain];
        if(hash.intValue == [touch1 hash]){
            [dt moveTouch:[[NSValue valueWithPointer:&locations[0]]retain]];
        } else if(count >= 2 && touch2 && hash.intValue == [touch2 hash]){
            [dt moveTouch:[[NSValue valueWithPointer:&locations[1]]retain]];
        }
    }
    
    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
            bodyUserData *ud = (bodyUserData *)body->GetUserData();
            if(ud->sprite1.tag == S_MUNCHR && ud->touched){
                for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                    for(int i = 0; i < count; i++){
                        fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                        if(fixture->TestPoint(locations[i]) && fUd->tag < F_BUSSEN){
                            if(ud->tickleTimer < ud->stopTimeDelta)
                                ud->tickleTimer++;
                            else ud->tickleTimer = 0;
                        }
                    }
                }
            }
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_gameOver) return;

    _numWorldTouches -= [touches count];
    
    for(UITouch *touch in touches){
        for(NSValue *v in dogTouches){
            DogTouch *dt = (DogTouch *)[v pointerValue];
            NSNumber *hash = [[dt getHash] retain];
            if([touch hash] == hash.intValue){
                [dt removeTouch];
                [dt flagForDeletion];
            }
        }
        for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
            if (body->GetUserData() && body->GetUserData() != (void*)100) {
                bodyUserData *ud = (bodyUserData *)body->GetUserData();
                if(ud->sprite1.tag == S_MUNCHR && ud->touched && !ud->_muncher_hasDroppedDog){
                    ud->restartTime = ud->timeWalking + 1;
                    ud->stopTimeDelta = 0;
                    ud->touched = false;
                }
            }
        }
    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self ccTouchesEnded:touches withEvent:event];
}

- (void) dealloc {
    [self unschedule:@selector(tick:)];
    [self stopAllActions];
    [self removeAllChildrenWithCleanup:YES];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_common.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_characters.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:[NSString stringWithFormat:@"%@.plist", level->spritesheet]];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];

    self.personLower = nil;
    self.personUpper = nil;
    self.wiener = nil;
    self.target = nil;

    [floorBits release];
    [xPositions release];

    delete personDogContactListener;
    delete _world;

    [super dealloc];
}
@end
