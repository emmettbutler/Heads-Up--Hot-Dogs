//
//  LevelSelectLayer.h
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LevelSelectLayer : CCLayer {
    NSUserDefaults *standardUserDefaults;
    int time;
    ccColor3B _color_pink;
    CCSpriteBatchNode *spritesheet;
}

+(CCScene *) scene;

@end
