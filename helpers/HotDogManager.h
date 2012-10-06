//
//  HotDogManager.h
//  Heads Up
//
//  Created by Emmett Butler on 9/25/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//


@interface HotDogManager : NSObject {
    NSNumber *_pause, *_sfxOn, *_inGame, *_dontReportScores, *_startTime;
}

+(HotDogManager *)sharedManager;
-(void)setPause:(NSNumber *)pause;
-(BOOL)isPaused;
-(void)setSFX:(NSNumber *)sfxOn;
-(BOOL)sfxOn;
-(void)setInGame:(NSNumber *)inGame;
-(BOOL)isInGame;
-(void)setDontReportScores:(NSNumber *)set;
-(BOOL)shouldReportScores;
-(void)customEvent:(NSString *)name st1:(NSString *)st1 st2:(NSString *)st2 level:(int)level value:(int)value data:(NSDictionary *)data;
-(int)getStartTime;
-(int)getTotalAppOpenTime;


@end