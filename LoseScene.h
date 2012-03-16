//
//  LoseScene.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "cocos2d.h"

@interface LoseLayer : CCLayer
{
    int score;
}

+(CCScene *) sceneWithData:(void*)data;


@end