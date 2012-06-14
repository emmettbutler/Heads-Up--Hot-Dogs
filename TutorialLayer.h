//
//  TutorialLayer.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "cocos2d.h"

@interface TutorialLayer : CCLayer
{
    CCSpriteBatchNode *spriteSheet;
    CCLayer *_introLayer;
    CCLabelTTF *tutorialLabel;
    NSMutableArray *tutCaptions, *tutPages, *animFrames;
    CCAnimation *anim;
    CCAction *action;
    CCSprite *s;
    int count;
}

+(CCScene *)scene;

struct tutorialSprite {
    CCAction *animation;
    CGPoint location;
};

struct tutorialPage {
    NSMutableArray *sprites;
    NSString *caption;
};

@end