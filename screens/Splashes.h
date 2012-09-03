//
//  Splashes.h
//  Heads Up
//
//  Created by Emmett Butler on 9/3/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TitleScene.h"
#import "Clouds.h"

@interface Splashes : CCLayer {
    CCSpriteBatchNode *spriteSheet;
    CCSprite *mainLogo, *logoBG, *cloud1, *cloud2, *cloud3;
    int time;
    CGPoint cloudAnchor;
    CGRect screen;
    CGSize winSize;
}

+(CCScene *) scene;

@end
