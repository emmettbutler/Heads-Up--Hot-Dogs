//
//  AchievementReporter.m
//  Heads Up
//
//  Created by Emmett Butler on 8/20/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "AchievementReporter.h"


@implementation AchievementReporter

-(void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent{
    // could pass in the achievement name here and surface to user
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if(achievement && achievement.percentComplete < 100){
        achievement.percentComplete = percent;
        achievement.showsCompletionBanner = YES;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error){
            if(error != nil){
                NSLog(@"Error reporting achievement to game center: %@", identifier);
            } else {
                NSLog(@"Reported achievement to game center: %@", identifier);
            }
            // if showsCompletionHandler doesn't end up working, use this instead (however, in prod, this should be commented)
            // this might lead to confusion, but it seems like an ok fallback?
            //if(achievement.percentComplete >= 100){
            //    [GKNotificationBanner showBannerWithTitle:@"Achievement unlocked" message:@"" completionHandler:^(void){return;}];
            //}
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
            for (GKAchievement* achievement in achievements){
                [achievementsDictionary setObject:achievement forKey:achievement.identifier];
            }
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
