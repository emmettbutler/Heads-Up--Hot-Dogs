//
//  CharBuilder.m
//  Heads Up
//
//  Created by Emmett Butler on 7/22/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "CharBuilder.h"
#import "GameplayLayer.h"

@implementation CharBuilder

+(NSMutableArray *)buildCharacters:(NSString *)levelSlug{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_characters.plist"];
    NSMutableArray *characters = [[self performSelector:NSSelectorFromString(levelSlug)] retain];
    return characters;
}

+(NSMutableArray *)philly{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];

    [levelArray addObject:[NSValue valueWithPointer:[self businessman]]];
    [levelArray addObject:[NSValue valueWithPointer:[self youngPro]]];
    [levelArray addObject:[NSValue valueWithPointer:[self jogger]]];
    
    return levelArray;
}

+(NSMutableArray *)nyc{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;

    [levelArray addObject:[NSValue valueWithPointer:[self crustPunk]]];
    [levelArray addObject:[NSValue valueWithPointer:[self youngPro]]];
    [levelArray addObject:[NSValue valueWithPointer:[self jogger]]];
    [levelArray addObject:[NSValue valueWithPointer:[self dogMuncher]]];
    
    return levelArray;
}

+(NSMutableArray *)china{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    
    [levelArray addObject:[NSValue valueWithPointer:[self businessman]]];
    [levelArray addObject:[NSValue valueWithPointer:[self professor]]];
    [levelArray addObject:[NSValue valueWithPointer:[self lion]]];
    [levelArray addObject:[NSValue valueWithPointer:[self police]]];
    [levelArray addObject:[NSValue valueWithPointer:[self dogMuncher]]];
    
    return levelArray;
}

+(NSMutableArray *)london{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    
    [levelArray addObject:[NSValue valueWithPointer:[self crustPunk]]];
    [levelArray addObject:[NSValue valueWithPointer:[self jogger]]];
    [levelArray addObject:[NSValue valueWithPointer:[self police]]];
    [levelArray addObject:[NSValue valueWithPointer:[self dogMuncher]]];
    
    return levelArray;
}

+(NSMutableArray *)japan{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    
    [levelArray addObject:[NSValue valueWithPointer:[self businessman]]];
    [levelArray addObject:[NSValue valueWithPointer:[self nudie]]];
    [levelArray addObject:[NSValue valueWithPointer:[self jogger]]];
    [levelArray addObject:[NSValue valueWithPointer:[self youngPro]]];
    
    return levelArray;
}

+(NSMutableArray *)chicago{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    
    [levelArray addObject:[NSValue valueWithPointer:[self businessman]]];
    [levelArray addObject:[NSValue valueWithPointer:[self professor]]];
    [levelArray addObject:[NSValue valueWithPointer:[self jogger]]];
    [levelArray addObject:[NSValue valueWithPointer:[self police]]];
    [levelArray addObject:[NSValue valueWithPointer:[self dogMuncher]]];
    
    return levelArray;
}

+(NSMutableArray *)space{
    NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];;
    
    [levelArray addObject:[NSValue valueWithPointer:[self dogMuncher]]];
    [levelArray addObject:[NSValue valueWithPointer:[self youngPro]]];
    [levelArray addObject:[NSValue valueWithPointer:[self jogger]]];
    [levelArray addObject:[NSValue valueWithPointer:[self astronaut]]];
    [levelArray addObject:[NSValue valueWithPointer:[self police]]];
    
    return levelArray;
}

+(personStruct *)businessman{
    personStruct *c = new personStruct();
    
    c->slug = @"busman";
    c->lowerSprite = @"BusinessMan_Walk_1.png";
    c->upperSprite = @"BusinessHead_NoDog_1.png";
    c->upperOverlaySprite = @"BusinessHead_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_BUSMAN;
    c->hitboxWidth = 24.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 4;
    c->moveDelta = 3.6;
    c->sensorHeight = 2.5f;
    c->sensorWidth = 1.5f;
    c->restitution = .4f;
    c->framerate = .07f;
    c->friction = 0.4f;
    c->fTag = F_BUSHED;
    c->pointValue = 10;
    c->frequency = 5;
    c->heightOffset = 2.9f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleIdleAnimFrames = [[NSMutableArray alloc] init];
    c->vomitAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 6; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 2; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Idle_%d.png", i]]];
    }
    for(int i = 1; i <= 3; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessHead_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 3; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessHead_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 3; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessHead_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 2; i++){
        [c->rippleIdleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Ripple_Idle_%d.png", i]]];
    }
    for(int i = 1; i <= 6; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Ripple_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 26; i++){
        [c->vomitAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Dog_Vomit_%d.png", i]]];
    }
    for(int i = 14; i >= 1; i--){
        [c->vomitAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"BusinessMan_Dog_Vomit_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)police{
    personStruct *c = new personStruct();

    c->slug = @"police";
    c->lowerSprite = @"Cop_Run_1.png";
    c->upperSprite = @"Cop_Head_NoDog_1.png";
    c->upperOverlaySprite = @"Cop_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->armSprite = @"cop_arm.png";
    c->targetSprite = @"Target_NoDog.png";
    c->tag = S_POLICE;
    c->armTag = S_COPARM;
    c->hitboxWidth = 22.5;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 4.1;
    c->moveDelta = 5;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .3f;
    c->friction = 4.0f;
    c->fTag = F_COPHED;
    c->heightOffset = 2.9f;
    c->pointValue = 15;
    c->frequency = 2;
    c->lowerArmAngle = 0;
    c->upperArmAngle = 55;
    c->framerate = .07f;
    c->armJointXOffset = 15;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->specialAnimFrames = [[NSMutableArray alloc] init];
    c->specialFaceAnimFrames = [[NSMutableArray alloc] init];
    c->armShootAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleIdleAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Run_%d.png", i]]];
    }
    [c->idleAnimFrames addObject:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
      @"Cop_Idle.png"]];
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 2; i++){
        [c->specialAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Shoot_%d.png", i]]];
    }
    [c->specialFaceAnimFrames addObject:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
      [NSString stringWithFormat:@"Cop_Head_Shoot_1.png"]]];
    [c->specialFaceAnimFrames addObject:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
      [NSString stringWithFormat:@"Cop_Head_Shoot_2.png"]]];
    [c->rippleIdleAnimFrames addObject:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Cop_Ripple_Idle.png"]];
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Cop_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)jogger{
    personStruct *c = new personStruct();
    
    c->slug = @"jogger";
    c->lowerSprite = @"Jogger_Run_1.png";
    c->upperSprite = @"Jogger_Head_NoDog_1.png";
    c->upperOverlaySprite = @"Jogger_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_JOGGER;
    c->hitboxWidth = 24.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 3.7;
    c->moveDelta = 6.5;
    c->sensorHeight = 1.3f;
    c->sensorWidth = 1.5f;
    c->restitution = .3f;
    c->friction = 0.75f;
    c->framerate = .07f;
    c->fTag = F_JOGHED;
    c->pointValue = 25;
    c->frequency = 4;
    c->heightOffset = 2.55f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Run_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Run_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Jogger_Ripple_Run_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)youngPro{
    personStruct *c = new personStruct();
    
    c->slug = @"youngpro";
    c->lowerSprite = @"YoungProfesh_Walk_1.png";
    c->upperSprite = @"YoungProfesh_Head_NoDog_1.png";
    c->upperOverlaySprite = @"YoungProfesh_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_YNGPRO;
    c->hitboxWidth = 26.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 4.0;
    c->moveDelta = 3.7;
    c->sensorHeight = 1.3f;
    c->sensorWidth = 1.5f;
    c->restitution = .3f;
    c->friction = 0.15f;
    c->framerate = .06f;
    c->fTag = F_JOGHED;
    c->pointValue = 15;
    c->frequency = 5;
    c->heightOffset = 2.9f;
    c->rippleXOffset = .1;
    c->rippleYOffset = -1.325;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"YoungProfesh_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)crustPunk{
    personStruct *c = new personStruct();
    
    c->slug = @"crpunk";
    c->lowerSprite = @"CrustPunk_Walk_1.png";
    c->upperSprite = @"CrustPunk_Head_NoDog_1.png";
    c->upperOverlaySprite = @"YoungProfesh_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_CRPUNK;
    c->hitboxWidth = 20.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 3.2;
    c->moveDelta = 3;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .47f;
    c->friction = 0.35f;
    c->framerate = .06f;
    c->pointValue = 15;
    c->frequency = 4;
    c->fTag = F_PNKHED;
    c->heightOffset = 2.4f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)professor{
    personStruct *c = new personStruct();
    
    c->slug = @"professor";
    c->lowerSprite = @"Professor_Walk_1.png";
    c->upperSprite = @"Professor_Head_NoDog_1.png";
    c->upperOverlaySprite = @"Professor_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_PROFSR;
    c->flipSprites = true;
    c->hitboxWidth = 20.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 3.8;
    c->moveDelta = 4.7;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .36f;
    c->friction = 0.65f;
    c->framerate = .06f;
    c->pointValue = 25;
    c->frequency = 6;
    c->fTag = F_PRFHED;
    c->heightOffset = 2.9f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Professor_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Professor_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Professor_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Professor_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)dogMuncher{
    personStruct *c = new personStruct();
    
    c->slug = @"muncher";
    c->lowerSprite = @"DogEater_Walk_1.png";
    c->upperSprite = @"DogEater_Head_NoDog_1.png";
    c->upperOverlaySprite = @"DogEater_Head_NoDog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_MUNCHR;
    c->flipSprites = true;
    c->hitboxWidth = 22.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 4.0;
    c->moveDelta = 2.7;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .3f;
    c->friction = 0.35f;
    c->framerate = .06f;
    c->pointValue = 15;
    c->frequency = 2;
    c->fTag = F_PNKHED;
    c->heightOffset = 2.9f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.425;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->specialAnimFrames = [[NSMutableArray alloc] init];
    c->specialFaceAnimFrames = [[NSMutableArray alloc] init];
    c->altFaceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->altWalkAnimFrames = [[NSMutableArray alloc] init];
    c->postStopAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleIdleAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->specialAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Rub_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->specialFaceAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Head_Rub_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->altFaceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_DogGone_Head%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->altWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_DogGone_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 25; i++){
        [c->postStopAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_DogBack_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Ripple_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->rippleIdleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"DogEater_Ripple_Rub_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)nudie{
    personStruct *c = new personStruct();
    
    c->slug = @"nudie";
    c->lowerSprite = @"Nudie_Walk_1.png";
    c->upperSprite = @"Nudie_Head_NoDog_1.png";
    c->upperOverlaySprite = @"Nudie_Head_Dog_1.png";
    c->rippleSprite = @"Nudie_Ripple_Walk_1.png";
    c->tag = S_TWLMAN;
    c->hitboxWidth = 20.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 3.7;
    c->moveDelta = 3.7;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .4f;
    c->friction = 0.45f;
    c->framerate = .06f;
    c->pointValue = 25;
    c->frequency = 4;
    c->fTag = F_PNKHED;
    c->heightOffset = 2.7f;
    c->rippleXOffset = .047;
    c->rippleYOffset = -1.3;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->specialAnimFrames = [[NSMutableArray alloc] init];
    c->postStopAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleIdleAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Nudie_Walk_%d.png", i]]];
    }
    for(int i = 10; i <= 17; i++){
        [c->specialAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Nudie_towelDrop_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Nudie_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Nudie_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 9; i++){
        [c->postStopAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Nudie_towelDrop_%d.png", i]]];
    }
    // this frame should be in twice
    [c->postStopAnimFrames addObject:
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Nudie_towelDrop_9.png"]];
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Nudie_Ripple_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 17; i++){
        [c->rippleIdleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"nudie_towelDrop_ripple_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)astronaut{
    personStruct *c = new personStruct();
    
    c->slug = @"astronaut";
    c->lowerSprite = @"Astronaunt_Walk_1.png";
    c->upperSprite = @"Astronaut_Head_NoDog_1.png";
    c->upperOverlaySprite = @"Astronaut_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_ASTRO;
    c->flipSprites = false;
    c->hitboxWidth = 20.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 3.5;
    c->moveDelta = 3.0;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .36f;
    c->friction = 0.65f;
    c->framerate = .08f;
    c->pointValue = 25;
    c->frequency = 6;
    c->fTag = F_PRFHED;
    c->heightOffset = 2.7f;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Astronaunt_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Astronaunt_Walk_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Astronaut_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Astronaut_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

+(personStruct *)lion{
    personStruct *c = new personStruct();
    
    float scale = 1;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        scale = IPAD_SCALE_FACTOR_X;
    }
    
    c->slug = @"lion";
    c->lowerSprite = @"Lion_Run_1.png";
    c->upperSprite = @"Lion_Head_NoDog_1.png";
    c->upperOverlaySprite = @"Lion_Head_Dog_1.png";
    c->rippleSprite = @"BusinessMan_Ripple_Walk_1.png";
    c->tag = S_LION;
    c->flipSprites = true;
    c->hitboxWidth = 28.0;
    c->hitboxHeight = .0001;
    c->hitboxCenterX = 0;
    c->hitboxCenterY = 3.8;
    c->moveDelta = 3.1;
    c->sensorHeight = 2.0f;
    c->sensorWidth = 1.5f;
    c->restitution = .36f;
    c->friction = 0.65f;
    c->framerate = .1f;
    c->pointValue = 10;
    c->frequency = 6;
    c->fTag = F_PRFHED;
    c->heightOffset = 2.78f;
    c->widthOffset = 0.36 * scale;
    c->rippleXOffset = -.012;
    c->rippleYOffset = -1.125;
    c->walkAnimFrames = [[NSMutableArray alloc] init];
    c->idleAnimFrames = [[NSMutableArray alloc] init];
    c->faceWalkAnimFrames = [[NSMutableArray alloc] init];
    c->faceDogWalkAnimFrames = [[NSMutableArray alloc] init];
    c->rippleWalkAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 8; i++){
        [c->walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Lion_Run_%d.png", i]]];
    }
    for(int i = 1; i <= 1; i++){
        [c->idleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Lion_Run_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Lion_Head_NoDog_%d.png", i]]];
    }
    for(int i = 1; i <= 4; i++){
        [c->faceDogWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Lion_Head_Dog_%d.png", i]]];
    }
    for(int i = 1; i <= 8; i++){
        [c->rippleWalkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"CrustPunk_Ripple_Walk_%d.png", i]]];
    }
    
    return c;
}

@end
