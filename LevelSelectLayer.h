//
//  LevelSelectLayer.h
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CharBuilder.h"


static NSMutableArray *levelStructs;
static NSUserDefaults *standardUserDefaults;

@interface LevelSelectLayer : CCLayer {
    struct spcDogData{
        NSString *riseSprite, *fallSprite, *mainSprite, *grabSprite;
        NSMutableArray *deathAnimFrames, *shotAnimFrames, *flashAnimFrames;
    };
    
    struct bgComponent{
        CCLabelTTF *label; // one or the other
        CCSprite *sprite;
        NSMutableArray *anim1, *anim2;
        CGPoint position;
    };
    
    struct levelProps{
        NSString *bg, *bgm, *name, *slug, *func, *spritesheet, *thumbnail, *unlockTweet;
        NSMutableArray *bgComponents, *characters, *activeComponents;
        levelProps *next, *prev;
        int characterProbSum, maxDogs, highScore, unlockThreshold;
        float gravity, frictionMul, personSpeedMul, restitutionMul, dogDeathDelay;
        BOOL unlocked, enabled;
        spcDogData *specialDog;
    };

    int time;
    ccColor3B _color_pink;
    NSMutableArray *lStructs;
    CGPoint firstTouch, lastTouch;
    CCSpriteBatchNode *spritesheet;
    int curLevelIndex;
    levelProps *level;
    CGRect rightArrowRect;
    CGRect leftArrowRect;
    CGRect thumbnailRect;
    CCSprite *thumb;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *nameLabel, *helpLabel;
}

+(NSMutableArray *)buildLevels:(NSNumber *)full;
+(CCScene *) scene;

@end
