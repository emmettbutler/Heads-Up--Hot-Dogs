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

#define PTM_RATIO 32
#define DEGTORAD 0.0174532
#define FLOOR1_HT 0
#define FLOOR2_HT .4
#define FLOOR3_HT .8
#define FLOOR4_HT 1.2
#define DOG_SPAWN_MINHT 240
#define COP_RANGE 4
#define DOG_COUNTER_HT 295
#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#ifdef DEBUG
#define SPAWN_LIMIT_DECREMENT_DELAY 6
#define SPECIAL_DOG_PROBABILITY 30
#define DROPPED_MAX 20
#define WIENER_SPAWN_START 5
#else
#define SPAWN_LIMIT_DECREMENT_DELAY 2
#define SPECIAL_DOG_PROBABILITY 30
#define DROPPED_MAX 5
#define WIENER_SPAWN_START 5
#endif

@implementation GameplayLayer

@synthesize personLower = _personLower;
@synthesize personUpper = _personUpper;
@synthesize personUpperOverlay = _personUpperOverlay;
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

-(IBAction)launchFeedback{
    [TestFlight passCheckpoint:@"Feedback Clicked"];
    [TestFlight openFeedbackView];
}

-(void) pauseButton{
    if(!_pause){
        _pause = true;
        [[CCDirector sharedDirector] pause];
#ifdef DEBUG
#else
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
#endif
        CGSize winSize = [[CCDirector sharedDirector] winSize];
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
        label = [CCLabelTTF labelWithString:@"     TITLE     " fontName:@"LostPet.TTF" fontSize:23.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *title = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(titleScene)];
        
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
        label = [CCLabelTTF labelWithString:@"   FEEDBACK   " fontName:@"LostPet.TTF" fontSize:23.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *feedback = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(launchFeedback)];
        
        CCMenu *quitButton = [CCMenu menuWithItems:cont, title, feedback, nil];
        [quitButton alignItemsVerticallyWithPadding:22];
        quitButton.position = ccp((winSize.width-label.contentSize.width+53), winSize.height/2);
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
            sound = [NSString stringWithString:@"25pts.mp3"];
            break;
        case 10:  seq = [CCSequence actions:ud->_not_dogContact, removeAction, nil];
            sound = [NSString stringWithString:@"25pts.mp3"];
            break;
        case 15:  seq = [CCSequence actions:ud->_not_dogContact, removeAction, nil];
            sound = [NSString stringWithString:@"50pts.mp3"];
            break;
        case 25:  seq = [CCSequence actions:ud->_not_dogContact, removeAction, nil];
            sound = [NSString stringWithString:@"100pts.mp3"];
            break;
        case 100: seq = [CCSequence actions:ud->_not_spcContact, removeAction, nil];
            sound = [NSString stringWithString:@"100pts.mp3"];
            break;
    }
#ifdef DEBUG
#else
    [[SimpleAudioEngine sharedEngine] playEffect:sound];
#endif
    [sprite runAction:seq];
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
    CGSize winSize = [[CCDirector sharedDirector] winSize];
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

-(void)setRotation:(id)sender data:(void*)params {
    b2Body *body = (b2Body *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    NSNumber *angle = (NSNumber *)[(NSMutableArray *) params objectAtIndex:1];

    b2Vec2 pos = body->GetPosition();
    body->SetTransform(pos, angle.intValue);
}

-(void)colorFG:(id)sender data:(NSNumber *)dark{
    for(b2Body* b = _world->GetBodyList(); b; b = b->GetNext()){
        if(b->GetUserData() && b->GetUserData() != (void*)100){
            bodyUserData *ud = (bodyUserData*)b->GetUserData();
            if((ud->sprite1.tag >= S_BUSMAN && ud->sprite1.tag <= S_TOPPSN) || ud->sprite1.tag == S_HOTDOG || ud->sprite1.tag == S_SPCDOG || ud->sprite1.tag == S_COPARM){
                if(dark.intValue == 1){
                    [ud->sprite1 setColor:ccc3(80,80,80)];
                    [ud->sprite2 setColor:ccc3(80,80,80)];
                    [ud->overlaySprite setColor:ccc3(80,80,80)];
                }
                else {
                    [ud->sprite1 setColor:ccc3(255,255,255)];
                    [ud->sprite2 setColor:ccc3(255,255,255)];
                    [ud->overlaySprite setColor:ccc3(255,255,255)];
                }
            }
        }
    }
}

-(void)screenFlash:(id)sender data:(NSNumber *)light{
    CGSize winSize = [[CCDirector sharedDirector] winSize];

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
    CGSize winSize = [CCDirector sharedDirector].winSize;
    b2Body *b = (b2Body *)[body pointerValue];
    if(!b) return;
    if(b->GetPosition().x > winSize.width/PTM_RATIO || b->GetPosition().x < 0) return;
    if(_gameOver) return;
    if(_droppedCount < DROPPED_MAX && !_gameOver) _droppedCount++;
    NSLog(@"Dropped count: %d", _droppedCount);
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
    CGSize winSize = [CCDirector sharedDirector].winSize;
    b2Body *dogBody = (b2Body *)[db pointerValue];
    if(!dogBody) return;
    bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();

    CCSprite *dogSprite = (CCSprite *)sender;

    if(dogBody->GetPosition().x > winSize.width/PTM_RATIO || dogBody->GetPosition().x < 0) return;
    
    CCLOG(@"Destroying dog (tag %d)...", dogSprite.tag);

    if(dogSprite.tag == S_HOTDOG || dogSprite.tag == S_SPCDOG){
        dogBody->SetAwake(false);
        [dogSprite stopAllActions];
        [dogSprite removeFromParentAndCleanup:YES];
        [ud->overlaySprite removeFromParentAndCleanup:YES];
        _world->DestroyBody(dogBody);
        
        free(ud);
        ud = NULL;
        dogBody->SetUserData(NULL);
        dogBody = nil;
#ifdef DEBUG
#else
        [[SimpleAudioEngine sharedEngine] playEffect:@"hot dog disappear.mp3"];
#endif
    }
}

-(void)copFlipAim:(id)sender data:(NSValue *)cb {
    b2Body *copBody = (b2Body *)[cb pointerValue];
    bodyUserData *ud = (bodyUserData *)copBody->GetUserData();

    if(ud->aiming){
        ud->aiming = false;
    } else {
        ud->aiming = true;
    }
}

-(void)putDog:(id)sender data:(NSNumber *)type {
    int floor, f, tag;
    float deathDelay;
    NSString *fallSprite, *riseSprite, *mainSprite, *grabSprite;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int sideBuffer = 10;
    CGPoint location = CGPointMake(arc4random() % (int)(sideBuffer+(winSize.width-(2*sideBuffer))), DOG_SPAWN_MINHT+(arc4random() % (int)(winSize.height-DOG_SPAWN_MINHT)));
    
    NSMutableArray *wienerDeathAnimFrames = [[NSMutableArray alloc] init];
    NSMutableArray *wienerFlashAnimFrames = [[NSMutableArray alloc] init];
    NSMutableArray *wienerShotAnimFrames = [[NSMutableArray alloc] init];
    NSMutableArray *wienerAppearAnimFrames = [[NSMutableArray alloc] init];
    
    spcDogData *dd = (spcDogData *)level->specialDog;
    
    switch(type.intValue){
        case S_SPCDOG:
            riseSprite = dd->riseSprite;
            fallSprite = dd->fallSprite;
            mainSprite = dd->mainSprite;
            grabSprite = dd->grabSprite;
            deathDelay = .1;
            tag = S_SPCDOG;
            wienerDeathAnimFrames = dd->deathAnimFrames;
            wienerShotAnimFrames = dd->shotAnimFrames;
            wienerFlashAnimFrames = dd->flashAnimFrames;
            for(int i = 1; i <= 6; i++){
                [wienerAppearAnimFrames addObject:
                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                  [NSString stringWithFormat:@"BonusAppear%d.png", i]]];
            }
            break;
        default:
            riseSprite = [NSString stringWithString:@"Dog_Rise.png"];
            fallSprite = [NSString stringWithString:@"Dog_Fall.png"];
            mainSprite = [NSString stringWithString:@"dog54x12.png"];
            grabSprite = [NSString stringWithString:@"Dog_Grabbed.png"];
            deathDelay = 2.7;
            tag = S_HOTDOG;
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
            for(int i = 1; i <= 5; i++){
                [wienerShotAnimFrames addObject:
                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                  [NSString stringWithFormat:@"Dog_Shot_%d.png", i]]];
            }
            for(int i = 1; i <= 10; i++){
                [wienerAppearAnimFrames addObject:
                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                  [NSString stringWithFormat:@"Dog_Appear_%d.png", i]]];
            }
            break;
    }
    //add base sprite to scene
    self.wiener = [CCSprite spriteWithSpriteFrameName:mainSprite];
    _wiener.position = ccp(location.x, location.y);
    _wiener.tag = tag;
    [spriteSheetCommon addChild:_wiener z:50];
    
    CCAnimation *dogFlashAnim = [CCAnimation animationWithFrames:wienerFlashAnimFrames delay:.1f];
    CCAction *_flashAction = [[CCAnimate alloc] initWithAnimation:dogFlashAnim];
    
    dogDeathAnim = [CCAnimation animationWithFrames:wienerDeathAnimFrames delay:.1f];
    CCAction *_deathAction = [[CCAnimate alloc] initWithAnimation:dogDeathAnim];
    
    dogAppearAnim = [CCAnimation animationWithFrames:wienerAppearAnimFrames delay:.08f];
    _appearAction = [CCAnimate actionWithAnimation:dogAppearAnim];
    
    dogShotAnim = [CCAnimation animationWithFrames:wienerShotAnimFrames delay:.1f ];
    _shotAction = [[CCAnimate alloc] initWithAnimation:dogShotAnim restoreOriginalFrame:NO];
    
    _id_counter++;

    //set up the userdata structures
    bodyUserData *ud = new bodyUserData();
    ud->sprite1 = _wiener;
    ud->_dog_fallSprite = fallSprite;
    ud->_dog_riseSprite = riseSprite;
    ud->_dog_mainSprite = mainSprite;
    ud->_dog_grabSprite = grabSprite;
    ud->altAction = _deathAction;
    ud->altAction2 = _shotAction;
    ud->altAction3 = _flashAction;
    ud->unique_id = _id_counter;
    ud->deathDelay = deathDelay;
    ud->deathSeq = NULL;
    ud->deathSeqLock = false;
    ud->aimedAt = false;
    ud->hasTouchedHead = false;
    ud->hasLeftScreen = false;
    ud->touchLock = false;
    ud->_dog_isOnHead = false;

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
    wienerShapeDef.friction = 1.0f*level->frictionMul;
    wienerShapeDef.userData = fUd2;
    wienerShapeDef.filter.maskBits = f;
    wienerShapeDef.restitution = 0.2f*level->restitutionMul;
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
    CCSequence *seq;
    seq = [CCSequence actions:_appearAction, wakeAction, nil];
    [_wiener runAction:seq];
#ifdef DEBUG
#else
    [[SimpleAudioEngine sharedEngine] playEffect:@"hot dog appear 1.mp3"];
#endif
    CCLOG(@"Spawned wiener with maskBits: %d", wienerShapeDef.filter.maskBits);
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

    CGSize winSize = [CCDirector sharedDirector].winSize;
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
    NSMutableArray *armShootAnimFrames;

    density = 10;
    
    CCLOG(@"lowerSprite; %@", person->lowerSprite);
    self.personLower = [CCSprite spriteWithSpriteFrameName:person->lowerSprite];
    self.personUpper = [CCSprite spriteWithSpriteFrameName:person->upperSprite];
    self.personUpperOverlay = [CCSprite spriteWithSpriteFrameName:person->upperOverlaySprite];
    _personLower.tag = person->tag;
    _personUpper.tag = person->tag;
    _personUpperOverlay.tag = person->tag;
    if(person->tag == 4){
        self.policeArm = [CCSprite spriteWithSpriteFrameName:person->armSprite];
        _policeArm.tag = person->armTag;
        armShootAnimFrames = [[NSMutableArray alloc] init];
    }
    
    if(floorBit.intValue == 1){
        zIndex = 42;
        yPos = 76;
    }
    else if(floorBit.intValue == 2){
        zIndex = 32;
        yPos = 89;
    }
    else if(floorBit.intValue == 4){
        zIndex = 22;
        yPos = 102;
    }
    else{
        zIndex = 12;
        yPos = 115;
    }

    NSMutableArray *notifiers = [PointNotify buildNotifiers];
    
    //create animations for walk, idle, and bobbing head
    walkAnim = [CCAnimation animationWithFrames:person->walkAnimFrames delay:person->framerate/level->personSpeedMul];
    _walkAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]] retain];
    [_personLower runAction:_walkAction];

    idleAnim = [CCAnimation animationWithFrames:person->idleAnimFrames delay:.2f];
    _idleAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:idleAnim restoreOriginalFrame:NO]] retain];

    walkFaceAnim = [CCAnimation animationWithFrames:person->faceWalkAnimFrames delay:person->framerate/level->personSpeedMul];
    _walkFaceAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkFaceAnim restoreOriginalFrame:NO]] retain];
    [_personUpper runAction:_walkFaceAction];

    walkDogFaceAnim = [CCAnimation animationWithFrames:person->faceDogWalkAnimFrames delay:person->framerate/level->personSpeedMul];
    CCAction *_walkDogFaceAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkDogFaceAnim restoreOriginalFrame:NO]] retain];
    [_personUpperOverlay runAction:_walkDogFaceAction];

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
    if(person->tag == S_POLICE){
        _policeArm.position = ccp(xPos.intValue, yPos);
        [spriteSheetCharacter addChild:_policeArm z:zIndex-2];
    }
    
    int moveDelta;
    
    //set secondary values based on the direction of the walk
    if((xPos.intValue > winSize.width/2)){
        moveDelta = -1*person->moveDelta;
        if(person->flipSprites){
            _personLower.flipX = YES;
            _personUpper.flipX = YES;
            _personUpperOverlay.flipX = YES;
        }
        if(person->tag == S_POLICE){
            lowerArmAngle = 132;
            upperArmAngle = 175;
            armBodyXOffset = 8;
            armBodyYOffset = 42;
            armJointYOffset = 40;
            _policeArm.flipX = YES;
            _policeArm.flipY = YES;
        }
    }
    else {
        moveDelta = person->moveDelta;
        if(!person->flipSprites){
            _personLower.flipX = YES;
            _personUpper.flipX = YES;
            _personUpperOverlay.flipX = YES;
        }
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
    ud->defaultAction = _walkAction;
    ud->angryFaceWalkAction = _walkDogFaceAction;
    ud->altWalk = _altWalkAction;
    ud->altWalkFace = _altFaceWalkAction;
    ud->heightOffset2 = person->heightOffset;
    ud->altAction = _walkFaceAction;
    ud->postStopAction = _postStopAction;
    ud->idleAction = _idleAction;
    ud->altAnimation = walkFaceAnim;
    ud->collideFilter = _curPersonMaskBits;
    ud->moveDelta = moveDelta*level->personSpeedMul;
    ud->lowerXOffset = 0;
    ud->lowerYOffset = 0;
    ud->aiming = false;
    ud->animLock = false;
    ud->hasLeftScreen = false;
    ud->_person_hasTouchedDog = false;
    ud->pointValue = person->pointValue;
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
            ud->aimFace = [NSString stringWithString:@"Cop_Head_Aiming_1.png"];
        } else if (person->tag == S_MUNCHR){
            ud->tickleTimer = 0;
            ud->_muncher_hasDroppedDog = false;
            ud->dogOnHeadTickleAction = _specialAngryFaceAction;
        }
    }
    ud->restartTime = ud->stopTime + ud->stopTimeDelta;

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
    _personBody = _world->CreateBody(&personBodyDef);

    //fixture for head hitbox
    b2PolygonShape personShape;
    personShape.SetAsBox(person->hitboxWidth/PTM_RATIO, person->hitboxHeight/PTM_RATIO, b2Vec2(person->hitboxCenterX, person->hitboxCenterY), 0);
    b2FixtureDef personShapeDef;
    personShapeDef.shape = &personShape;
    personShapeDef.density = 0;
    personShapeDef.friction = person->friction*level->frictionMul;
    personShapeDef.restitution = person->restitution;
    personShapeDef.userData = fUd1;
    personShapeDef.filter.categoryBits = _curPersonMaskBits;
    personShapeDef.filter.maskBits = WIENER;
    _personFixture = _personBody->CreateFixture(&personShapeDef);
    
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
    _personFixture = _personBody->CreateFixture(&personBodyShapeDef);

    //sensor above heads for point gathering
    b2PolygonShape personHeadSensorShape;
    personHeadSensorShape.SetAsBox(person->sensorWidth,person->sensorHeight,b2Vec2(person->hitboxCenterX, person->hitboxCenterY+(person->sensorHeight/2)), 0);
    b2FixtureDef personHeadSensorShapeDef;
    personHeadSensorShapeDef.shape = &personHeadSensorShape;
    personHeadSensorShapeDef.userData = fUd3;
    personHeadSensorShapeDef.isSensor = true;
    personHeadSensorShapeDef.filter.categoryBits = SENSOR;
    personHeadSensorShapeDef.filter.maskBits = WIENER;
    _personFixture = _personBody->CreateFixture(&personHeadSensorShapeDef);

    if(person->tag == S_POLICE){
        //create the cop's arm body if we need to
        for(int i = 1; i <= 2; i++){
            [armShootAnimFrames addObject:
                [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                [NSString stringWithFormat:@"Cop_Arm_Shoot_%d.png", i]]];
        }

        armShootAnim = [CCAnimation animationWithFrames:armShootAnimFrames delay:.08f];
        _armShootAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:armShootAnim restoreOriginalFrame:YES] times:1] retain];

        bodyUserData *ud = new bodyUserData();
        ud->sprite1 = _policeArm;
        ud->altAction = _armShootAction;

        b2BodyDef armBodyDef;
        armBodyDef.type = b2_dynamicBody;
        armBodyDef.position.Set(((_personBody->GetPosition().x*PTM_RATIO)+(_policeArm.contentSize.width/2)+armBodyXOffset)/PTM_RATIO,
                                ((_personBody->GetPosition().y*PTM_RATIO)+(armBodyYOffset))/PTM_RATIO);
        armBodyDef.userData = ud;
        _policeArmBody = _world->CreateBody(&armBodyDef);

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
    
    if(_dogsOnscreen <= _maxDogsOnScreen && !_gameOver){
        if(thisType.intValue == S_SPCDOG){
            id screenLightenAction = [CCCallFuncND actionWithTarget:self selector:@selector(screenFlash:data:) data:[[NSNumber numberWithInt:1] retain]];
            id darkenFGAction = [CCCallFuncND actionWithTarget:self selector:@selector(colorFG:data:) data:[[NSNumber numberWithInt:1] retain]];
            id lightenFGAction = [CCCallFuncND actionWithTarget:self selector:@selector(colorFG:data:) data:[[NSNumber numberWithInt:0] retain]];
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
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        self.isTouchEnabled = YES;
        
        [standardUserDefaults setInteger:1 forKey:@"introDone"];
        
        NSMutableArray *levelStructs = [LevelSelectLayer buildLevels:[NSNumber numberWithInt:1]];
        for(int i = 0; i < [levelStructs count]; i++){
            level = (levelProps *)[[levelStructs objectAtIndex:i] pointerValue];
            if(level->slug == levelSlug){
                break;
            }
        }
        
        b2Vec2 gravity = b2Vec2(0.0f, level->gravity);
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
            else if(bgc->label){
                gravityLabel = bgc->label;
                [self addChild:gravityLabel z:0];
            }
        }
        [self addChild:spriteSheetCharacter];
        [self addChild:spriteSheetCommon];

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

        _overallTime = [standardUserDefaults integerForKey:@"overallTime"];

        //basic game/box2d/cocos2d initialization
        time = 0;
        _pause = false;
        _dogHasHitGround = false;
        _lastTouchTime = 0;
        _numWorldTouches = 0;
        _curPersonMaskBits = 0x1000;
        _wienerSpawnDelayTime = WIENER_SPAWN_START;
        _points = 0;
        _peopleGrumped = 0;
        _id_counter = 0;
        _dogsOnscreen = 0;
        _dogsSaved = 0;
        _gameOver = false;
        _maxDogsOnScreen = 3;
        _shootLock = NO;
        _droppedSpacing = 200;
        _droppedCount = 0;
        _currentRayAngle = 0;

        //contact listener init
        personDogContactListener = new PersonDogContactListener();
        _world->SetContactListener(personDogContactListener);
        
        // color definitions
        _color_pink = ccc3(255, 62, 166);
            
        [standardUserDefaults synchronize];
        
        allTouchHashes = [[NSMutableArray alloc] init];

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
        scoreText = [[NSString alloc] initWithFormat:@"%06d", _points];
        scoreLabel = [CCLabelTTF labelWithString:scoreText fontName:@"LostPet.TTF" fontSize:34];
        [[scoreLabel texture] setAliasTexParameters];
        scoreLabel.color = _color_pink;
        scoreLabel.position = ccp(winSize.width-80, DOG_COUNTER_HT-3);
        [self addChild: scoreLabel z:72];

        NSInteger highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", level->slug]];
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
        movementParameters = [[NSMutableArray alloc] initWithCapacity:2];
        
        // allocate array to hold mouse joints for mutliple touches
        mouseJoints = [[NSMutableArray alloc] init];
        
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
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR2;
        groundBox.Set(b2Vec2(-30,FLOOR2_HT), b2Vec2((winSize.width+60)/PTM_RATIO, FLOOR2_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR3;
        groundBox.Set(b2Vec2(-30,FLOOR3_HT), b2Vec2((winSize.width+60)/PTM_RATIO, FLOOR3_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

        _groundBody = _world->CreateBody(&groundBodyDef);
        groundBoxDef.filter.categoryBits = FLOOR4;
        groundBox.Set(b2Vec2(-30,FLOOR4_HT), b2Vec2((winSize.width+60)/PTM_RATIO, FLOOR4_HT));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);

        fixtureUserData *fUd2 = new fixtureUserData();
        fUd2->tag = F_WALLS;

        //set up the walls
        b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
        b2Vec2 lowerRightCorner = b2Vec2(winSize.width/PTM_RATIO, 0);
        b2Vec2 upperLeftCorner = b2Vec2(0, winSize.height/PTM_RATIO);
        b2Vec2 upperRightCorner = b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO);
        b2BodyDef wallsBodyDef;
        wallsBodyDef.position.Set(0,0);
        _wallsBody = _world->CreateBody(&wallsBodyDef);
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
    
    if(!_policeOnScreen)
        _shootLock = 0;

    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    if(_points > 19000 && _wienerSpawnDelayTime != .6){
        _wienerSpawnDelayTime = .6;
    } else if(_points > 14000 && _wienerSpawnDelayTime != .7){
        _maxDogsOnScreen = 6;
        _wienerSpawnDelayTime = .7;
    } else if(_points > 12000 && _wienerSpawnDelayTime != .9) {
        _wienerSpawnDelayTime = .9;
        _maxDogsOnScreen = 5;
    } else if(_points > 7000 && _wienerSpawnDelayTime != 1) {
        _wienerSpawnDelayTime = 1;
        _maxDogsOnScreen = 4;
    } else if(_points > 5000 && _wienerSpawnDelayTime != 2) {
        _wienerSpawnDelayTime = 2;
    } else if(_points > 2000 && _wienerSpawnDelayTime != 3) {
        _wienerSpawnDelayTime = 3;
    } else if(_points > 1000 && _wienerSpawnDelayTime != 4) {
        _wienerSpawnDelayTime = 4;
    }
    
    if(_droppedCount <= DROPPED_MAX && _droppedCount >= 0){
        for(NSValue *v in dogIcons){
            CCSprite *icon = (CCSprite *)[v pointerValue];
            if([dogIcons indexOfObject:v] < _droppedCount && [icon numberOfRunningActions] == 0){
                [icon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"DogHud_X_6.png"]]];
            } else if([icon numberOfRunningActions] == 0){
                [icon setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"DogHud_Dog.png"]]];
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
    
    // level-specific repetitive actions
    if(level->slug == @"philly"){
        
    } else if(level->slug == @"nyc"){
        for(NSValue *v in bgSprites){
            CCSprite *sprite = (CCSprite *)[v pointerValue];
            [sprite setOpacity:255.00 * cosf(.01 * time)];
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
        b2Body *pBody;
        b2Body *dogBody;
        pdContact = *pos;

        if(pdContact.fixtureA->GetBody() != NULL){
            dogBody = pdContact.fixtureA->GetBody();
        }

        if(dogBody){
            bodyUserData *ud = (bodyUserData *)dogBody->GetUserData();
            fixtureUserData *fBUd = (fixtureUserData *)pdContact.fixtureB->GetUserData();
            if(fBUd->tag >= F_BUSHED && fBUd->tag <= F_TOPHED){
#ifdef DEBUG
#else
                [[SimpleAudioEngine sharedEngine] playEffect:@"hot dog on head.mp3" pitch:1 pan:0 gain:.3];
#endif
                // a dog is definitely on a head when it collides with that head
                ud->_dog_isOnHead = true;
                pBody = pdContact.fixtureB->GetBody();
                CCLOG(@"Dog/Person Collision - Y Vel: %0.2f", dogBody->GetLinearVelocity().x);
                bodyUserData *pUd = (bodyUserData *)pBody->GetUserData();
                b2Filter dogFilter;
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
                int particle = (arc4random() % 3) + 1;
                CGPoint position = ud->sprite1.position;
                CCParticleSystem* heartParticles = [CCParticleFire node];
                ccColor4F startColor = {1, 1, 1, 1};
                ccColor4F endColor = {1, 1, 1, 0};
                heartParticles.startColor = startColor;
                heartParticles.endColor = endColor;
                heartParticles.texture = [[CCTextureCache sharedTextureCache] textureForKey:[NSString stringWithFormat:@"Heart_Particle_%d.png", particle]];
                heartParticles.blendFunc = (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
                heartParticles.autoRemoveOnFinish = YES;
                heartParticles.startSize = 1.0f;
                heartParticles.speed = 90.0f;
                heartParticles.anchorPoint = ccp(0.5f,0.5f);
                heartParticles.position = position;
                heartParticles.duration = 0.1f;
                [self addChild:heartParticles z:60];
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
                    [self runAction:[CCCallFuncND actionWithTarget:self selector:@selector(plusPoints:data:) data:plusPointsParams]];
                }
                ud->hasTouchedHead = true;
                if(!pUd->_person_hasTouchedDog){
                    pUd->_person_hasTouchedDog = true;
                    _peopleGrumped++;
                }
            }
            else if (fBUd->tag == F_GROUND){
                // dog is definitely not on a head if it's touching the floor
                ud->_dog_isOnHead = false;
                ud->hasTouchedHead = false;
                if(ud->shotSeq)
                    [ud->sprite1 stopAction:ud->shotSeq];
                if(!ud->deathSeqLock){
                    ud->deathSeqLock = true;
                    id delay = [CCDelayTime actionWithDuration:ud->deathDelay];
                    id lockAction = [CCCallFuncND actionWithTarget:self selector:@selector(lockWiener:data:) data:[[NSValue valueWithPointer:ud] retain]];
                    id incAction = [CCCallFuncND actionWithTarget:self selector:@selector(incrementDroppedCount:data:) data:[[NSValue valueWithPointer:dogBody] retain]];
                    wienerParameters = [[NSMutableArray alloc] initWithCapacity:2];
                    [wienerParameters addObject:[NSValue valueWithPointer:dogBody]];
                    [wienerParameters addObject:[NSNumber numberWithInt:0]];
                    id sleepAction = [CCCallFuncND actionWithTarget:self selector:@selector(setAwake:data:) data:wienerParameters];
                    id angleAction = [CCCallFuncND actionWithTarget:self selector:@selector(setRotation:data:) data:wienerParameters];
                    id destroyAction = [CCCallFuncND actionWithTarget:self selector:@selector(destroyWiener:data:) data:[[NSValue valueWithPointer:dogBody] retain]];
                    ud->deathSeq = [CCSequence actions: delay, sleepAction, angleAction, ud->altAction3, lockAction, incAction, ud->altAction, destroyAction, nil];
                    [ud->sprite1 runAction:ud->deathSeq];
                    CCLOG(@"Run death action");
                } else if(ud->deathSeq){
                    //[ud->sprite1 stopAction:ud->deathSeq];
                }
                ud->aimedAt = false;
            }
            else if (fBUd->tag == F_WALLS){
                CCLOG(@"Dog/wall collision - _dog_isOnHead: %d - dog is awake: %d", ud->_dog_isOnHead, dogBody->IsAwake());
            }
        }
    }
    personDogContactListener->contacts.clear();

    b2RayCastInput input;
    float closestFraction = 1; //start with end of line as policeRayPoint2
    b2Vec2 intersectionNormal(0,0);
    float rayLength = COP_RANGE;
    b2Vec2 intersectionPoint(0,0);
    
    for(int i = 0; i < [mouseJoints count]; i++){
        b2MouseJoint *j = (b2MouseJoint *)[(NSValue *)[mouseJoints objectAtIndex:i] pointerValue];
        if((j->GetTarget().x == 0 && j->GetTarget().y == 0) || [mouseJoints count] > 2 || _gameOver){
            bodyUserData *ud = (bodyUserData *)((b2Body *)j->GetBodyB())->GetUserData();
            ud->grabbed = false;
            _world->DestroyJoint(j);
            [mouseJoints removeObject:[mouseJoints objectAtIndex:i]];
        }   
    }

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
                    [self runAction:[CCCallFuncND actionWithTarget:self selector:@selector(plusOneHundred:data:) data:plus100Params]];
                }
            }
            
            //destroy any sprite/body pair that's offscreen
            if(ud->sprite1.position.x > winSize.width + 130 || ud->sprite1.position.x < -130 ||
               ud->sprite1.position.y > winSize.height + 4000 || ud->sprite1.position.y < -40){
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
                _world->DestroyBody(b);
                ud = NULL;
                continue;
            }
            
            if(ud->overlaySprite != NULL){
                if(ud->sprite1.tag == S_POLICE){
                    if(!ud->aiming){
                        [ud->overlaySprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"Target_NoDog.png"]]];
                        ud->overlaySprite.position = CGPointMake(policeRayPoint2.x*PTM_RATIO, policeRayPoint2.y*PTM_RATIO);
                        ud->overlaySprite.rotation = 3 * (time % 360);
                    }
                }
                else {
                    ud->overlaySprite.position = CGPointMake(((b->GetPosition().x)*PTM_RATIO),
                                                            ((b->GetPosition().y)*PTM_RATIO));
                }
            }
            if(ud->sprite2 != NULL){
                ud->sprite2.position = CGPointMake((b->GetPosition().x)*PTM_RATIO,
                                                   (b->GetPosition().y+ud->heightOffset2)*PTM_RATIO);
                ud->sprite2.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            if(ud->angryFace != NULL){
                ud->angryFace.position = CGPointMake((b->GetPosition().x)*PTM_RATIO,
                                                   (b->GetPosition().y+ud->heightOffset2)*PTM_RATIO);
                ud->angryFace.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            if(ud->sprite1 != NULL){
                if(ud->sprite1.tag == S_MUNCHR){
                    _muncherOnScreen = YES;
                    if(ud->hasLeftScreen)
                        _muncherOnScreen = NO;
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
                        } else{
                            if(ud->timeWalking == ud->stopTime + (ud->stopTimeDelta - ([ud->postStopAction duration]*60.0))){
                                ud->_muncher_hasDroppedDog = true;
                                ud->lowerYOffset = 9;
                                if(ud->sprite1.flipX)
                                    ud->lowerXOffset = -12;
                                else
                                    ud->lowerXOffset = 11;
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
                if(ud->sprite1.tag == S_COPARM){
                    //things for cop's arm and raycasting
                    policeRayPoint1 = b->GetPosition();
                    policeRayPoint2 = policeRayPoint1 + rayLength * b2Vec2(cosf(b->GetAngle()), sinf(b->GetAngle()));
                    input.p1 = policeRayPoint1;
                    input.p2 = policeRayPoint2;
                    input.maxFraction = 1;
                } else if(ud->sprite1.tag >= S_BUSMAN && ud->sprite1.tag <= S_TOPPSN){
                    ud->dogsOnHead = 0;
                    ud->spcDogsOnHead = 0;
                    ud->timeWalking++;
                    // move person across screen at the appropriate speed
                    if((ud->timeWalking <= ud->stopTime || ud->timeWalking >= ud->stopTime + ud->stopTimeDelta)){
                        if(b->GetLinearVelocity().x != ud->moveDelta){ b->SetLinearVelocity(b2Vec2(ud->moveDelta, 0)); }
                        if(ud->timeWalking == ud->stopTime){
                            if(ud->sprite1.tag != S_POLICE && ud->sprite1.tag != S_MUNCHR){
                                [ud->sprite2 stopAllActions];
                                [ud->sprite1 stopAllActions];
                                [ud->angryFace stopAllActions];
                                [ud->sprite1 runAction:ud->idleAction];
                            }
                        }
                        else if((ud->stopTime && ud->timeWalking == ud->stopTime + ud->stopTimeDelta) || ud->timeWalking == ud->restartTime){
                            if(ud->sprite1.tag != S_MUNCHR){
                                [ud->sprite1 runAction:ud->defaultAction];
                                [ud->sprite2 runAction:ud->altAction];
                                if(ud->sprite1.tag != S_POLICE){
                                    if([ud->sprite2 numberOfRunningActions] == 0)
                                        [ud->sprite2 runAction:ud->altAction];
                                }
                            } else {
                                if(ud->timeWalking == ud->stopTime + ud->stopTimeDelta){
                                    [ud->sprite2 runAction:ud->altWalkFace];
                                    [ud->angryFace runAction:ud->angryFaceWalkAction];
                                    if(_droppedCount > 0 && !_gameOver){
                                        [self counterExplode:self data:[NSNumber numberWithInt:0]];
                                        _droppedCount--;
                                        NSLog(@"Dropped count: %d", _droppedCount);
                                    }
                                } else if(!ud->_muncher_hasDroppedDog){
                                    [ud->sprite1 stopAction:ud->altAction2];
                                    [ud->sprite2 stopAction:ud->altAction3];
                                    [ud->angryFace stopAction:ud->dogOnHeadTickleAction];
                                    CCLOG(@"muncher has not dropped dog");
                                    if(!ud->animLock){
                                        ud->animLock = true;
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
                            if(ud->dogsOnHead == 0){
                                [ud->angryFace setVisible:NO];
                                [ud->sprite2 setVisible:YES];
                            } else {
                                [ud->angryFace setVisible:YES];
                                [ud->sprite2 setVisible:NO];
                            }
                        }
                    }
                    if(!(time % 45) && ud->dogsOnHead && !_gameOver){
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
                        [self runAction:[CCCallFuncND actionWithTarget:self selector:@selector(plusTwentyFive:data:) data:plus25Params]];
                    }
                    if(ud->sprite1.tag == S_POLICE){
                        _policeOnScreen = YES;
                        if(ud->hasLeftScreen)
                            _policeOnScreen = NO;
                        //cop arm rotation
                        if(!ud->aiming){
                            b2JointEdge *j = b->GetJointList();
                            if(j && j->joint->GetType() == e_revoluteJoint){
                                b2RevoluteJoint *r = (b2RevoluteJoint *)j->joint;
                                r->SetMotorSpeed(ud->armSpeed);
                            }
                            ud->armSpeed = 8 * cosf(.07 * time);
                        } else {
                            b2JointEdge *j;
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
                                        CCLOG(@"Angle to dog: %0.2f - Upper angle: %d - lower angle: %d", a, upperArmAngle, lowerArmAngle);
                                        ud->targetAngle = a;
                                        [ud->overlaySprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"Target_Dog.png"]]];
                                        ud->overlaySprite.position = CGPointMake(aimedDog->GetPosition().x*PTM_RATIO, aimedDog->GetPosition().y*PTM_RATIO);
                                        ud->overlaySprite.rotation = 6 * (time % 360);
                                        break;
                                    }
                                }
                            }
                            
                            j = b->GetJointList();
                            if(j){
                                if(j->joint->GetType() == e_revoluteJoint && ud->targetAngle != -1){
                                    b2RevoluteJoint *r = (b2RevoluteJoint *)j->joint;
                                    if(r->GetJointAngle() < ud->targetAngle)
                                        r->SetMotorSpeed(.5);
                                    else if(r->GetJointAngle() > ud->targetAngle)
                                        r->SetMotorSpeed(-.5);
                                }
                            }
                        }
                    }
                }
                else if(ud->sprite1.tag == S_HOTDOG || ud->sprite1.tag == S_SPCDOG){
                    if(ud->sprite1.position.x > 0 && ud->sprite1.position.x < winSize.width)
                        _dogsOnscreen++;
                    if(_numWorldTouches <= 0){
                        if(ud->grabbed) // don't mark any dog as held if there are no touches
                            ud->grabbed = false;
                        for(int i = 0; i < [mouseJoints count]; i++){
                            b2MouseJoint *mj = (b2MouseJoint *)[(NSValue *)[mouseJoints objectAtIndex:i] pointerValue];
                            [mouseJoints removeObject:[mouseJoints objectAtIndex:i]];
                            _world->DestroyJoint(mj);
                        }
                    }
                    //things for hot dogs
                    if(b->IsAwake()){
                        if(!ud->grabbed){
                            if(!ud->aimedAt){
                                if(b->GetLinearVelocity().y > 1.5){
                                    [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ud->_dog_riseSprite]];
                                } else if (b->GetLinearVelocity().y < -1.5){
                                    [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ud->_dog_fallSprite]];
                                } else {
                                    [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ud->_dog_mainSprite]];
                                }
                            }
                        } else { // this is breaking because aimedAt never gets turned false
                            [ud->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ud->_dog_grabSprite]];
                        }
                        // a hacky way to ensure that dogs are registered as not on a head
                        // this works because it measures when a dog is below the level of the lowest head
                        // and then flips the _dog_isOnHead bit
                        if(b->GetPosition().y - 1 < FLOOR4_HT && ud->_dog_isOnHead){
                            ud->_dog_isOnHead = false;
                        }
                        if(!ud->_dog_isOnHead){
                            for(b2Fixture* fixture = b->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                                fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                                if(fUd->tag == F_DOGCLD){
                                    // this is the case in which a dog is not on a person's head.
                                    // we set the filters to their original value (all people, floor, and walls)
                                    b2Filter dogFilter = fixture->GetFilterData();
                                    dogFilter.maskBits = fUd->ogCollideFilters;
                                    if(b->GetPosition().y > winSize.height/PTM_RATIO)
                                        dogFilter.maskBits = 0xfffff000;
                                    else if(b->GetPosition().y < winSize.height/PTM_RATIO)
                                        dogFilter.maskBits = dogFilter.maskBits | WALLS;
                                    fixture->SetFilterData(dogFilter);
                                    ud->collideFilter = dogFilter.maskBits;
                                    break;
                                }
                            }
                        } else if(ud->_dog_isOnHead){
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
                        for(b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext()) {
                            fixtureUserData *fUd = (fixtureUserData *)f->GetUserData();
                            b2RayCastOutput output;
                            if(fUd->tag == F_DOGCLD){
                                if(!f->RayCast(&output, input, 0)){
                                    _rayTouchingDog = false;
                                    continue;
                                }
                                bodyUserData *dogUd = (bodyUserData *)b->GetUserData();
                                b2Body *dogBody = b;
                                if(output.fraction < closestFraction && output.fraction > .1){
                                    if(!_shootLock && !dogUd->grabbed && dogBody->GetPosition().x < winSize.width/PTM_RATIO && dogBody->GetPosition().x > 0){
                                        CCLOG(@"Ray touched dog fixture with fraction %0.2f", output.fraction);

                                        _shootLock = YES;

                                        closestFraction = output.fraction;
                                        _rayTouchingDog = true;
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

                                        if(copBody && copBody->GetUserData() && copArmBody && copArmBody->GetUserData()){
                                            copUd = (bodyUserData *)copBody->GetUserData();
                                            NSValue *dBody = [[NSValue valueWithPointer:dogBody] retain];

                                            CCDelayTime *delay = [CCDelayTime actionWithDuration:((float)copUd->stopTimeDelta-10)/60];
                                            copUd->stopTime = copUd->timeWalking + 1;
                                            copUd->aiming = true;
                                            
                                            //////////////////////////  COP BODY SHOOTING  /////////////////////////

                                            [copUd->sprite1 stopAllActions];
                                            [copUd->sprite1 setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithString:@"Cop_Idle.png"]]];
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
                                            id destroyAction = [CCCallFuncND actionWithTarget:self selector:@selector(destroyWiener:data:) data:dBody];
                                            id incAction = [CCCallFuncND actionWithTarget:self selector:@selector(incrementDroppedCount:data:) data:dBody];
                                            id lockAction = [CCCallFuncND actionWithTarget:self selector:@selector(lockWiener:data:) data:[[NSValue valueWithPointer:ud] retain]];
                                            
                                            CCFiniteTimeAction *wienerExplodeAction = (CCFiniteTimeAction *)ud->altAction2;
                                            ud->shotSeq = [[CCSequence actions:delay, lockAction, incAction, wienerExplodeAction, destroyAction, nil] retain];
                                            if([ud->sprite1 numberOfRunningActions] == 0) 
                                                [ud->sprite1 runAction:ud->shotSeq];

                                            
                                            id lockSeq = [CCSequence actions:delay,
                                                          [CCCallFunc actionWithTarget:self selector:@selector(flipShootLock)],
                                                          [CCCallFuncND actionWithTarget:self selector:@selector(copFlipAim:data:) data:[[NSValue valueWithPointer:copBody] retain]],
                                                          nil];
                                            [self runAction:lockSeq];
                                            
                                            break;
                                        }
                                    }
                                }
                            }
                        }
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
    b2Vec2 *locations = new b2Vec2[count];
    
    UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint touchLocation1 = [touch locationInView: [touch view]];
    touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
    locationWorld1 = b2Vec2(touchLocation1.x/PTM_RATIO, touchLocation1.y/PTM_RATIO);
    locations[0] = locationWorld1;
    
    if(count > 1){
        touch = [[allTouches allObjects] objectAtIndex:1];
        CGPoint touchLocation2 = [touch locationInView: [touch view]];
        touchLocation2 = [[CCDirector sharedDirector] convertToGL: touchLocation2];
        locationWorld2 = b2Vec2(touchLocation2.x/PTM_RATIO, touchLocation2.y/PTM_RATIO);
        locations[1] = locationWorld2;
    }
    
    _numWorldTouches = count;
    _touchedDog = NO;
    int dogsTouched = 0;
    BOOL touched1 = false, touched2 = false;
    
    if (count <= 2){
        CCLOG(@"%d touches", count);
        if(CGRectContainsPoint(_pauseButtonRect, touchLocation1)){
            if(!_pause){
                [self pauseButton];
#ifdef DEBUG
#else
                [[SimpleAudioEngine sharedEngine] playEffect:@"pause 3.mp3"];
#endif
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
                                    ud->stopTimeDelta = 250;
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
                                }
                            }
                        }
                    }
                    else if((ud->sprite1.tag == S_HOTDOG || ud->sprite1.tag == S_SPCDOG) && !ud->touchLock){ // loop over all hot dogs
                        for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                            // if the dog is not already grabbed and one of the touches is on it, make the joint
                            if (!ud->grabbed && ((fixture->TestPoint(locationWorld1) && !touched1) || (fixture->TestPoint(locationWorld2) && !touched2))){
                                dogsTouched++;
                                [ud->sprite1 stopAllActions];
                                _lastTouchTime = time;
                                ud->deathSeqLock = false;
                                ud->grabbed = true;
                                ud->aimedAt = false;
                                ud->hasTouchedHead = false;
                                body->SetAwake(false);
                                body->SetTransform(body->GetPosition(), CC_DEGREES_TO_RADIANS(0));
                                body->SetFixedRotation(true);
                                body->SetAwake(true);
                                
                                mouseJointUserData *jUd = new mouseJointUserData();
                                jUd->touch = ud->unique_id;
                                
                                b2MouseJointDef md;
                                md.bodyA = _groundBody;
                                md.bodyB = body;
                                if(fixture->TestPoint(locationWorld1)){
                                    md.target = locationWorld1;
                                    jUd->prevX = locationWorld1.x;
                                    jUd->prevY = locationWorld1.y;
                                    touched1 = true;
                                }
                                else if(fixture->TestPoint(locationWorld2)){
                                    md.target = locationWorld2;
                                    jUd->prevX = locationWorld2.x;
                                    jUd->prevY = locationWorld2.y;
                                    touched2 = true;
                                }
                                md.collideConnected = true;
                                md.userData = jUd;
                                md.maxForce = 10000.0f * body->GetMass();
                                
                                b2MouseJoint *_mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
                                [mouseJoints addObject:[NSValue valueWithPointer:_mouseJoint]];

                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_gameOver) return;
    
    NSSet *allTouches = [event allTouches];
    int count = [allTouches count];
    b2Vec2 *locations = new b2Vec2[count];
    b2Vec2 locationWorld2;
    
    UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint touchLocation1 = [touch locationInView: [touch view]];
    touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
    b2Vec2 locationWorld1 = b2Vec2(touchLocation1.x/PTM_RATIO, touchLocation1.y/PTM_RATIO);
    locations[0] = locationWorld1;
    
    if(count > 1){
        touch = [[allTouches allObjects] objectAtIndex:1];
        CGPoint touchLocation2 = [touch locationInView: [touch view]];
        touchLocation2 = [[CCDirector sharedDirector] convertToGL: touchLocation2];
        locationWorld2 = b2Vec2(touchLocation2.x/PTM_RATIO, touchLocation2.y/PTM_RATIO);
        locations[1] = locationWorld2;
    }
    
#ifdef DEBUG
    for(int i = 0; i < count; i++){
        //CCLOG(@"locations[%d] %0.2f x %0.2f", i, locations[i].x, locations[i].y);
    }
#endif
    
    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
            bodyUserData *ud = (bodyUserData *)body->GetUserData();
            CCSprite *sprite = ud->sprite1;
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
            } else if((ud->sprite1.tag == S_HOTDOG || ud->sprite1.tag == S_SPCDOG) && ud->grabbed){
                for(int i = 0; i < [mouseJoints count]; i++){
                    b2MouseJoint *mj = (b2MouseJoint *)[(NSValue *)[mouseJoints objectAtIndex:i] pointerValue];
                    mouseJointUserData *jUd = (mouseJointUserData *)mj->GetUserData();
                    if(mj->GetBodyB() == body){
                        [sprite stopAllActions];
                        ud->deathSeqLock = false;
                        for(int i = 0; i < 2; i++){
                            if((abs(locations[i].x - jUd->prevX) < 1.6 && abs(locations[i].y - jUd->prevY) < 1.6)){
                                if(locations[i].x < 1.6 && locations[i].y < 1.6){
                                    locations[i] = b2Vec2(1, 1);
                                }
                                mj->SetTarget(locations[i]);
                                jUd->prevX = locations[i].x;
                                jUd->prevY = locations[i].y;
                            }
                        }
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
                }
            }
        }
    }        
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_gameOver) return;
    
    b2Filter filter;
    
    //CGSize winSize = [[CCDirector sharedDirector] winSize];
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _numWorldTouches -= [touches count];
    
    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL && body->GetUserData() != (void*)100) {
            bodyUserData *ud = (bodyUserData *)body->GetUserData();
            if(ud->sprite1.tag == S_MUNCHR && ud->touched && !ud->_muncher_hasDroppedDog){
                ud->restartTime = ud->timeWalking + 1;
                ud->stopTimeDelta = 0;
                ud->touched = false;
            }
            else if((ud->sprite1.tag == S_HOTDOG || ud->sprite1.tag == S_SPCDOG) && ud->grabbed){
                // if there is not a finger on the dog
                b2JointEdge *j = body->GetJointList();
                b2Vec2 target;
                if(j && j->joint->GetType() == e_mouseJoint){
                    b2MouseJoint *mj = (b2MouseJoint *)j->joint;
                    target = mj->GetTarget();
                }
                if((abs(locationWorld.x - target.x) < 1.5 && abs(locationWorld.y - target.y) < 1.5) || [[event allTouches] count] == 1){
                    // drop the dog
                    // find the corresponding mouse joint
                    for(int i = 0; i < [mouseJoints count]; i++){
                        b2MouseJoint *mj = (b2MouseJoint *)[(NSValue *)[mouseJoints objectAtIndex:i] pointerValue];
                        if(mj->GetBodyB() == body){
                            [mouseJoints removeObject:[mouseJoints objectAtIndex:i]];
                            _world->DestroyJoint(mj);
                        }
                    }
                    
                    ud->grabbed = false;
                    body->SetLinearVelocity(b2Vec2(0, 0));
                    body->SetFixedRotation(false);
                    
                    if(body->GetPosition().y < .8 && body->GetPosition().x < .5)
                        body->SetTransform(b2Vec2(body->GetPosition().x, 1.8), 0);
                    if(body->GetPosition().x < 1)
                        body->SetTransform(b2Vec2(1.5, body->GetPosition().y), 0);
                    
                    for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
                        fixtureUserData *fUd = (fixtureUserData *)fixture->GetUserData();
                        if(fUd->tag == F_DOGCLD){
                            // here, we restore the fixture's original collision filter from that saved in
                            // its ogCollideFilter field
                            filter = fixture->GetFilterData();
                            fUd->ogCollideFilters = fUd->ogCollideFilters | 0xfffff000;
                            filter.maskBits = fUd->ogCollideFilters;
                            filter.maskBits = filter.maskBits | FLOOR1;
                            fixture->SetFilterData(filter);
                            ud->collideFilter = filter.maskBits;
                        }
                    }
                    break;
                }
            }
        }
    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self ccTouchesEnded:touches withEvent:event];
}

- (void) dealloc {
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_common.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_characters.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:[NSString stringWithFormat:@"%@.plist", level->spritesheet]];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];

    self.personLower = nil;
    self.personUpper = nil;
    _walkFaceAction = nil;
    self.wiener = nil;
    self.target = nil;

    [scoreText release];
    [droppedText release];
    [floorBits release];
    [xPositions release];
    [wienerParameters release];
    [personParameters release];
    [movementPatterns release];
    [movementParameters release];
    [headParams release];
    [_shotAction release];

    delete personDogContactListener;

    delete _world;
    _world = NULL;

    [super dealloc];
}
@end
