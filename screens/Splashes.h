//
//  Splashes.h
//  Heads Up
//
//  Created by Emmett Butler on 9/3/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TitleScene.h"
#import "Clouds.h"

@interface Splashes : CCLayer <CDLongAudioSourceDelegate> {
    CCSpriteBatchNode *spriteSheet;
    CCSprite *mainLogo, *logoBG, *cloud1, *cloud2, *cloud3, *namesSprite, *namesBG;
    int time;
    float scaleX, scaleY;
    CGPoint cloudAnchor, logoAnchor, namesAnchor;
    CGRect screen;
    CGSize winSize;
    Clouds *clouds;
    UInt32 audioIsAlreadyPlaying;
}

+(CCScene *) scene;

@end
