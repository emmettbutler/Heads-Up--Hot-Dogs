//
//  OptionsLayer.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "cocos2d.h"

@interface OptionsLayer : CCLayer
{
    CCSpriteBatchNode *spriteSheet;
    ccColor3B _color_pink;
}

+(CCScene *)scene;

@end