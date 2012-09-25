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
        CGPoint position;
        CCFiniteTimeAction *startingAction, *loopingAction, *stoppingAction;
    };
    
    struct levelProps{
        NSString *bg, *bgm, *name, *slug, *func, *spritesheet, *thumbnail, *unlockTweet;
        NSMutableArray *bgComponents, *characters, *activeComponents, *dogDeathAnimFrames;
        levelProps *next, *prev;
        int characterProbSum, maxDogs, highScore, unlockNextThreshold, highestTrophy;
        float gravity, frictionMul, personSpeedMul, restitutionMul, dogDeathDelay, spawnInterval;
        BOOL unlocked, enabled, hasShiba;
        spcDogData *specialDog;
    };

    int time, unlockedCount;
    ccColor3B _color_pink;
    NSMutableArray *lStructs;
    CGPoint firstTouch, lastTouch;
    CCSpriteBatchNode *spritesheet;
    int curLevelIndex;
    levelProps *level;
    CGRect rightArrowRect;
    BOOL NO_LEVEL_LOCKS;
    CGRect leftArrowRect, _backRect;
    CGRect thumbnailRect;
    CGSize winSize;
    CCSprite *thumb, *background;
    CCLabelTTF *scoreLabel, *loading;
    CCLabelTTF *nameLabel, *helpLabel;
}

+(NSMutableArray *)buildLevels:(NSNumber *)full;
+(CCScene *) scene;

@end
