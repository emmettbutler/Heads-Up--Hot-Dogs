//
//  Level.h
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <SimpleAudioEngine.h>

static NSMutableArray *levelStructs = nil;

@interface Level : NSObject {
    CCSprite *background;
    NSString *bgm;
    float gravity;
    int highScore;
    
    struct levelProps{
        NSString *bg;
        NSString *bgm;
        float gravity;
        NSString *name;
        NSString *slug;
    };
}

-(id) initWithBackground:(NSString *)theBG AndBGM:(NSString *)theBGM AndGravity:(NSNumber *)theGravity;
-(id) initWithBackground:(NSString *)theBG AndBGM:(NSString *)theBGM;
-(void) playBGM;

@end
