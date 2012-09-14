//
//  LoseScene.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "cocos2d.h"
#import <CocosDenshion/SimpleAudioEngine.h>
#import "LevelSelectLayer.h"
#import <Twitter/Twitter.h>
#import "AchievementReporter.h"

@interface LoseLayer : CCLayer <GKLeaderboardViewControllerDelegate>
{
    struct face{
        NSString *speechBubble;
        CCAction *faceAction;
    };
    
    struct endResult{
        NSString *trophy;
        NSString *dogName;
        CCSprite *head;
        int grade;
        face *f;
    };
    
    int _score, _timePlayed, _peopleGrumped, _dogsSaved, _lock;
    CCLabelTTF *scoreLine, *timeLine, *dogsLine, *peopleLine, *highScoreLine;
    CCLabelTTF *scoreNotify, *timeNotify, *summary;
    CCSpriteBatchNode *spriteSheet;
    CCSprite *levelBox, *bubble, *charFace, *trophy;
    CCLabelTTF *levelLabel1, *levelLabel2;
    NSInteger highScore;
    ALuint sting;
    float elmtScale;
    AchievementReporter *reporter;
    BOOL touchLock, _setNewHighScore;
    CGRect _twitterRect, _replayRect, _quitRect, _gcRect;
    NSString *slug;
    NSMutableArray *tweets;
    ccColor3B _color_pink, _color_blue, _color_darkblue;
    levelProps *level;
}

+(CCScene *)sceneWithData:(void *)data;

@end