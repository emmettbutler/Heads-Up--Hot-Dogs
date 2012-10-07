//
//  HotDogManager.mm
//  Heads Up
//
//  Created by Emmett Butler on 9/25/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//


#import "HotDogManager.h"
#import "Kontagent/Kontagent.h"

static HotDogManager *sharedInstance = nil;

@implementation HotDogManager

+(HotDogManager *)sharedManager{
    @synchronized(self){
        if(sharedInstance == nil){
            [[self alloc] init];
        }
    }
    return sharedInstance;
}

-(id)init{
    @synchronized(self) {
        [super init];
        _pause = [NSNumber numberWithBool:false];
        _sfxOn = [NSNumber numberWithBool:false];
        _inGame = [NSNumber numberWithBool:false];
        _dontReportScores = [NSNumber numberWithBool:false];
        _startTime = [[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] retain];
        return self;
    }
}

-(void)customEvent:(NSString *)name st1:(NSString *)st1 st2:(NSString *)st2 level:(int)level value:(int)value data:(NSDictionary *)data{
    KTParamMap* paramMap = [[[KTParamMap alloc] init] autorelease];
    [paramMap put:@"st1" value:st1];
    if(st2)
        [paramMap put:@"st2" value:st2];
    if(level)
        [paramMap put:@"l" value:[NSString stringWithFormat:@"%d",level]];
    if(value)
        [paramMap put:@"v" value:[NSString stringWithFormat:@"%d",value]];
    if(data)
        [paramMap put:@"data" value:[NSString stringWithFormat:@"%@", data]];
    NSLog(@"Reported custom event %@", name);
    [Kontagent customEvent:name optionalParams:paramMap];
}

-(void)resetStartTime{
    _startTime = [[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] retain];
}

-(int)getStartTime{
    return _startTime.intValue;
}

-(int)getTotalAppOpenTime{
    return [[NSDate date] timeIntervalSince1970] - _startTime.intValue;
}

-(void)setPause:(NSNumber *)pause{
    @synchronized(self) {
        if (_pause != pause) {
            [pause release];
            _pause = [pause retain];
        }
    }
}

-(BOOL)isPaused{
    @synchronized(self) {
        return [_pause boolValue];
    }
}

-(void)setDontReportScores:(NSNumber *)set{
    @synchronized(self) {
        if (_dontReportScores != set) {
            [set release];
            _dontReportScores = [set retain];
        }
    }
}
-(BOOL)shouldReportScores{
    return ![_dontReportScores boolValue];
}

-(void)setInGame:(NSNumber *)inGame{
    @synchronized(self) {
        if (_inGame != inGame) {
            [inGame release];
            _inGame = [inGame retain];
        }
    }
}

-(BOOL)isInGame{
    @synchronized(self) {
        return [_inGame boolValue];
    }
}

-(void)setSFX:(NSNumber *)sfxOn{
    @synchronized(self) {
        if (_sfxOn != sfxOn) {
            [sfxOn release];
            _sfxOn = [sfxOn retain];
        }
    }
}

-(BOOL)sfxOn{
    @synchronized(self) {
        return [_sfxOn boolValue];
    }
}

// singleton boilerplate

+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (sharedInstance == nil){
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

- (id)retain{
    return self;
}

- (void)release{/* do nothing */}

- (id)autorelease{
    return self;
}

- (NSUInteger)retainCount{
    return NSUIntegerMax; // This is sooo not zero
}

@end