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
    };
    
    struct levelProps{
        NSString *bg;
        NSString *bgm;
        NSString *prevSlug;
        float gravity;
        BOOL unlocked;
        int unlockThreshold;
        NSString *name;
        NSString *slug;
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
    CCLabelTTF *nameLabel;
}

+(NSMutableArray *)buildLevels;
+(CCScene *) scene;

@end
