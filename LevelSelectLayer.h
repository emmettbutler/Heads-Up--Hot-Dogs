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
        NSString *riseSprite;
        NSString *fallSprite;
        NSString *mainSprite;
        NSString *grabSprite;
        NSMutableArray *deathAnimFrames;
        NSMutableArray *shotAnimFrames;
        NSMutableArray *flashAnimFrames;
    };
    
    struct bgComponent{
        CCLabelTTF *label; // one or the other
        CCSprite *sprite;
        NSMutableArray *anim1;
        NSMutableArray *anim2;
        CGPoint position;
    };
    
    struct levelProps{
        NSString *bg;
        NSString *bgm;
        NSMutableArray *bgComponents;
        levelProps *next;
        levelProps *prev;
        int characterProbSum;
        float gravity;
        BOOL unlocked;
        int unlockThreshold;
        NSString *name;
        NSString *slug;
        BOOL enabled;
        int highScore;
        NSString *func;
        float frictionMul;
        spcDogData *specialDog;
        NSString *spritesheet;
        NSString *thumbnail;
        NSMutableArray *characters;
        float personSpeedMul;
        float restitutionMul;
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
