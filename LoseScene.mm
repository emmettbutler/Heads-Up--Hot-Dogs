//
//  LoseScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "LoseScene.h"
#import "GameplayLayer.h"
#import "TitleScene.h"

@implementation LoseLayer

+(CCScene *) sceneWithData:(void*)data
{
	CCScene *scene = [CCScene node];
    CCLOG(@"in scenewithData");
	LoseLayer *layer;
    layer = [LoseLayer node];
    
    NSInteger *score = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:0] pointerValue];
    NSInteger *timePlayed = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:1] pointerValue]; 
    NSInteger *peopleGrumped = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:2] pointerValue]; 
    NSInteger *dogsSaved = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:3] pointerValue]; 
    layer->_score = (int)score;
    layer->_timePlayed = (int)timePlayed;
    layer->_peopleGrumped = (int)peopleGrumped;
    layer->_dogsSaved = (int)dogsSaved;
    CCLOG(@"In sceneWithData: score = %d, time = %d, peopleGrumped = %d, dogsSaved = %d", layer->_score, layer->_timePlayed, layer->_peopleGrumped, layer->_dogsSaved);
    
	[scene addChild:layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        //CGSize size = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"end_sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"end_sprites_default.png"];
        [self addChild:spriteSheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"GameEnd_BG"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        ccColor3B color = ccc3(6, 110, 163);
        
        scoreLine = [CCLabelTTF labelWithString:@"Total points: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [scoreLine setPosition:ccp(-10, -10)];
        scoreLine.color = color;
        [[scoreLine texture] setAliasTexParameters];
        [self addChild:scoreLine];
        
        timeLine = [CCLabelTTF labelWithString:@"Time lasted: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [timeLine setPosition:ccp(-10, -10)];
        timeLine.color = color;
        [[timeLine texture] setAliasTexParameters];
        [self addChild:timeLine];
        
        dogsLine = [CCLabelTTF labelWithString:@"Hot Dogs saved: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [dogsLine setPosition:ccp(-10, -10)];
        dogsLine.color = color;
        [[dogsLine texture] setAliasTexParameters];
        [self addChild:dogsLine];
        
        peopleLine = [CCLabelTTF labelWithString:@"People Grumped: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [peopleLine setPosition:ccp(-10, -10)];
        peopleLine.color = color;
        [[peopleLine texture] setAliasTexParameters];
        [self addChild:peopleLine];
        
        highScoreLine = [CCLabelTTF labelWithString:@"HIGH SCORE: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [highScoreLine setPosition:ccp(-10, -10)];
        highScoreLine.color = ccc3(14, 168, 248);;
        [[highScoreLine texture] setAliasTexParameters];
        [self addChild:highScoreLine];
        
        CCSprite *restartButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        restartButton.position = ccp(110, 27);
        [self addChild:restartButton z:10];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"     Try Again     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = ccc3(255, 62, 166);
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneRestart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 26)];
        [self addChild:menu z:11];
        
        CCSprite *quitButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        quitButton.position = ccp(370, 27);
        [self addChild:quitButton z:10];
        label = [CCLabelTTF labelWithString:@"     Quit     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = ccc3(255, 62, 166);
        button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneQuit)];
        menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(370, 26)];
        [self addChild:menu z:11];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger highScore = [standardUserDefaults integerForKey:@"highScore"];
    NSInteger bestTime = [standardUserDefaults integerForKey:@"bestTime"];
    NSInteger overallTime = [standardUserDefaults integerForKey:@"overallTime"];
    if(_score > highScore){
        [standardUserDefaults setInteger:_score forKey:@"highScore"];
        highScore = _score;
        
        scoreNotify = [CCLabelTTF labelWithString:@"New high score!" fontName:@"LostPet.TTF" fontSize:26.0];
        [scoreNotify setPosition:ccp((size.width/2), (size.height/2)-100)];
        [self addChild:scoreNotify];
    }
    if(_timePlayed > bestTime){
        [standardUserDefaults setInteger:_timePlayed forKey:@"bestTime"];
        
        timeNotify = [CCLabelTTF labelWithString:@"New best time!" fontName:@"LostPet.TTF" fontSize:26.0];
        [timeNotify setPosition:ccp((size.width/2), (size.height/2)-140)];
        [self addChild:timeNotify];
    }
    [standardUserDefaults setInteger:overallTime+_timePlayed forKey:@"overallTime"];
    [standardUserDefaults synchronize];
    
    [scoreLine setString:[NSString stringWithFormat:@"Total points: %06d", _score]];
    int seconds = _timePlayed/60;
    int minutes = seconds/60;
    [timeLine setString:[NSString stringWithFormat:@"Time lasted: %02d:%02d", minutes, seconds%60]];
    [dogsLine setString:[NSString stringWithFormat:@"Dogs saved: %d", _dogsSaved]];
    [peopleLine setString:[NSString stringWithFormat:@"People Grumped: %d", _peopleGrumped]];
    [highScoreLine setString:[NSString stringWithFormat:@"HIGH SCORE: %d", highScore]];
    
    [scoreLine setPosition:ccp(62+(scoreLine.contentSize.width/2), 225)];
    [timeLine setPosition:ccp(62+(timeLine.contentSize.width/2), 195)];
    [dogsLine setPosition:ccp(62+(dogsLine.contentSize.width/2), 165)];
    [peopleLine setPosition:ccp(62+(peopleLine.contentSize.width/2), 135)];
    [highScoreLine setPosition:ccp(389-(highScoreLine.contentSize.width/2), 70)];
}

- (void)switchSceneRestart{
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer scene]];
}

- (void)switchSceneQuit{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

-(void) dealloc{
    [super dealloc];
}

@end