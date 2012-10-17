//
//  OptionsLayer.h
//  Heads Up! Hot Dogs
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "cocos2d.h"

@interface OptionsLayer : CCLayer
{
    CCSpriteBatchNode *spriteSheet, *spriteSheetCommon;
    ccColor3B _color_pink;
    CGRect _siteRect, _creditsRect, _tutRect, _scoresRect, _sfxRect, _titleRect, _startRect, _clearScoresRect;
    BOOL credits, scores, sfxOn;
    float scale;
    CCSprite *yesButton;
    CCLayerColor *creditsLayer, *scoresLayer;
    CCLabelTTF *sfxLabel;
}

+(CCScene *)scene;

@end