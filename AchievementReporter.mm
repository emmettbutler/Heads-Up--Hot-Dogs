//
//  AchievementReporter.m
//  Heads Up
//
//  Created by Emmett Butler on 8/20/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "AchievementReporter.h"


@implementation AchievementReporter

-(void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent{
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if(achievement && achievement.percentComplete < 100){
        achievement.percentComplete = percent;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error){
            if(error != nil){
                NSLog(@"Error reporting achievement to game center: %@", identifier);
            } else { NSLog(@"Reported achievement to game center: %@", identifier); }
        }];
    }
}

-(void)loadAchievements{
    if(!achievementsDictionary)
        achievementsDictionary = [[NSMutableDictionary alloc] init];
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error){
        if (error != nil){
            NSLog(@"Error retrieving achievement progress");
        } else { NSLog(@"Loaded achievements successfully"); }
        if (achievements != nil){
            for (GKAchievement* achievement in achievements)
                [achievementsDictionary setObject:achievement forKey:achievement.identifier];
        }
    }];
}

-(GKAchievement*)getAchievementForIdentifier:(NSString*)identifier{
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    if (achievement == nil){
        achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
        [achievementsDictionary setObject:achievement forKey:achievement.identifier];
    }
    return [[achievement retain] autorelease];
}

@end
