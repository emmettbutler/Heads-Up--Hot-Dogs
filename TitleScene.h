//
//  TitleScene.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "cocos2d.h"

@interface TitleLayer : CCLayer 
{
    CCSpriteBatchNode *spriteSheet;
}

+(CCScene *) scene;

@end