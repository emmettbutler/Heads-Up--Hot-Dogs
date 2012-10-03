//
//  LoseScene.h
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "cocos2d.h"
#import <CocosDenshion/SimpleAudioEngine.h>
#import "LevelSelectLayer.h"
#import <Twitter/Twitter.h>
#import "AchievementReporter.h"

@interface LoseLayer : CCLayer <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
    struct face{
        NSString *speechBubble;
        CCAction *faceAction;
    };
    
    struct endResult{
        NSString *trophy;
        NSString *dogName;
        CCSprite *head;
        int grade, trophyLevel;
        face *f;
    };
    
    struct characterSpeech{
        NSString *good, *ok, *bad, *other1, *other2;
    };
    
    int _score, _timePlayed, _peopleGrumped, _dogsSaved, _lock, _shotByCop, _missedByCop, time;
    CCLabelTTF *scoreLine, *timeLine, *dogsLine, *peopleLine, *highScoreLine;
    CCLabelTTF *scoreNotify, *timeNotify, *summary;
    CCSpriteBatchNode *spriteSheet;
    CCSprite *levelBox, *bubble, *charFace, *trophy;
    CCLabelTTF *levelLabel1, *levelLabel2;
    NSInteger highScore;
    ALuint sting;
    float elmtScale;
    int _numberOfTotalGamesPlayed;
    AchievementReporter *reporter;
    GKLeaderboardViewController *leaderboardController;
    GKAchievementViewController *achievementController;
    BOOL touchLock, _setNewHighScore;
    CGRect _twitterRect, _replayRect, _quitRect, _gcRect;
    NSString *slug;
    NSMutableArray *tweets;
    ccColor3B _color_pink, _color_blue, _color_darkblue;
    levelProps *level;
}

+(CCScene *)sceneWithData:(void *)data;

@end