//
//  SteamVent.h
//  Heads Up
//
//  Created by Emmett Butler on 8/28/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "UIDefs.h"

@interface SteamVent : NSObject {
    CCSprite *mainSprite, *grateSprite;
    CCAction *combinedAction;
    b2Body *worldBody;
    CCSpriteBatchNode *common_sheet, *level_sheet;
    NSString *fallSprite, *riseSprite;
    CGPoint position;
    int blowInterval, force;
    BOOL isOn;
    CGSize winSize;
}

-(SteamVent *)init:(NSValue *)s_common withLevelSpriteSheet:(NSValue *)s_level withPosition:(NSValue *)pos;
-(int)getInterval;
-(void)startBlowing;
-(void)blowFrank:(NSValue *)body;

@end