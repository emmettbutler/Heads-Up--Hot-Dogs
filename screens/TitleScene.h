//
//  TitleScene.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "cocos2d.h"
#import <SimpleAudioEngine.h>

@interface TitleLayer : CCLayer 
{
    CCSpriteBatchNode *spriteSheet;
    CCAnimation *titleAnim;
    CCAction *titleAnimAction;
    CCSprite *background;
    CGRect screen, _startRect, _optionsRect;
    ccColor3B _color_pink;
    NSUserDefaults *standardUserDefaults;
    float introSoundLen;
    ALuint soundId;
    CDSoundEngine *engine;
    float time;
}

+(CCScene *) scene;

@property (nonatomic, retain) CCFiniteTimeAction *titleAnimAction;


@end