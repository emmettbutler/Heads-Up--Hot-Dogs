//
//  LevelSelectLayer.h
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

static NSMutableArray *levelStructs;

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
        float gravity;
        NSString *name;
        NSString *slug;
        int highScore;
        NSString *highScoreSaveKey;
        NSString *func;
        spcDogData *specialDog;
        NSString *spritesheet;
    };
    
    NSUserDefaults *standardUserDefaults;
    int time;
    ccColor3B _color_pink;
    NSMutableArray *lStructs;
    CCSpriteBatchNode *spritesheet;
    int curLevelIndex;
    levelProps *level;
    CGRect rightArrowRect;
    CGRect leftArrowRect;
    CGRect thumbnailRect;
}

+(NSMutableArray *)buildLevels;
+(CCScene *) scene;

@end
