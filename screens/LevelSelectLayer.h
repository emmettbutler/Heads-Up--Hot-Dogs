//
//  LevelSelectLayer.h
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CharBuilder.h"

static NSUserDefaults *standardUserDefaults;

@interface LevelSelectLayer : CCLayer {
    struct spcDogData{
        NSString *riseSprite, *fallSprite, *mainSprite, *grabSprite;
        NSMutableArray *deathAnimFrames, *shotAnimFrames, *flashAnimFrames;
    };
    
    struct bgComponent{
        CCLabelTTF *label; // one or the other
        CCSprite *sprite;
        NSMutableArray *anim1, *anim2, *anim3;
        CGPoint position, anchorPoint;
        CCFiniteTimeAction *startingAction, *loopingAction, *stoppingAction, *resetAction;
    };
    
    struct levelProps{
        NSString *bg, *bgm, *name, *slug, *func, *spritesheet, *thumbnail, *unlockTweet, *introAudio;
        NSMutableArray *bgComponents, *characters, *activeComponents, *dogDeathAnimFrames;
        levelProps *next, *prev;
        int characterProbSum, maxDogs, highScore, unlockNextThreshold, highestTrophy, number;
        float gravity, frictionMul, personSpeedMul, restitutionMul, dogDeathDelay, spawnInterval, bgmVol, sfxVol;
        BOOL unlocked, enabled, hasShiba;
        spcDogData *specialDog;
    };

    int time, unlockedCount, lastTouchTime;
    ccColor3B _color_pink;
    NSMutableArray *lStructs;
    CGPoint firstTouch, lastTouch;
    NSNumber *vomitCheatActive, *bigHeadCheatActive;
    CCLayer *pixelsLayer;
    CCFiniteTimeAction *transition;
    CCSpriteBatchNode *spritesheet;
    int curLevelIndex;
    float leftArrowOGScaleX, leftArrowOGScaleY, rightArrowOGScaleX, rightArrowOGScaleY;
    levelProps *level;
    NSMutableArray *enteredSwipes;
    CGRect rightArrowRect;
    BOOL NO_LEVEL_LOCKS;
    CGRect leftArrowRect, _backRect, _headsRect;
    CGRect thumbnailRect;
    CGSize winSize;
    CCSprite *thumb, *background, *thumbOld, *rightArrow, *leftArrow, *trophy;
    CCLabelTTF *scoreLabel, *loading;
    CCLabelTTF *nameLabel, *helpLabel, *bigHeadToggleLabel;
}

+(NSMutableArray *)buildLevels:(NSNumber *)full;
+(CCScene *) scene;

@end
