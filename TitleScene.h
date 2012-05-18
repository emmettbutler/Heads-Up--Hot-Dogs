//
//  TitleScene.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "cocos2d.h"
#import "OpenFeint/OpenFeint.h"
#import "OpenFeint/OFControllerLoaderObjC.h"

@interface TitleLayer : CCLayer 
{
    CCSpriteBatchNode *spriteSheet;
    CCAnimation *titleAnim;
    CCAction *titleAnimAction;
    CCSprite *background;
    CGRect screen;
    ccColor3B _color_pink;
}

+(CCScene *) scene;

@property (nonatomic, retain) CCFiniteTimeAction *titleAnimAction;


@end