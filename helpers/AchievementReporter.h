//
//  AchievementReporter.h
//  Heads Up
//
//  Created by Emmett Butler on 8/20/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>

@interface AchievementReporter : NSObject {
    NSMutableDictionary *achievementsDictionary;
}

-(void)loadAchievements;
-(GKAchievement*)getAchievementForIdentifier:(NSString*)identifier;
-(void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent;

@end
