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
#import "TestFlight.h"
#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation LoseLayer

- (void) reportScore: (int64_t) score forCategory: (NSString*) category
{
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            NSLog(@"Error submitting high score to leaderboard");
        } else {
            [TestFlight passCheckpoint:@"Score reported to GC"];
        }
    }];
}

- (IBAction)tweetButtonPressed:(id)sender{
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    
    NSMutableArray *tweets = [[NSMutableArray alloc] init];
    [tweets addObject:[NSString stringWithFormat:@"I just scored %d points in @HeadsUpHotDogs!", _score]];
    [tweets addObject:[NSString stringWithFormat:@"I just dropped hot dogs on %d people's heads in @HeadsUpHotDogs!", _peopleGrumped]];
    [tweets addObject:[NSString stringWithFormat:@"I just saved %d hot dogs from destruction in @HeadsUpHotDogs!", _dogsSaved]];
    [tweets addObject:[NSString stringWithFormat:@"I just saved %d inches of meat from destruction in @HeadsUpHotDogs!", _dogsSaved * 12]];
    [tweets addObject:@"I am the new savior of franks in @HeadsUpHotDogs!"];
    
    NSString *highScoreString = [NSString stringWithFormat:@"I just set a new high score in @HeadsUpHotDogs: %d points!", _score];
    
    if(!_setNewHighScore)
        [tweetSheet setInitialText:[tweets objectAtIndex:arc4random() % [tweets count]]];
    else
        [tweetSheet setInitialText:highScoreString];
    //[tweetSheet addImage:[UIImage imageNamed:@"Icon_Head_big.png"]];
    [tweetSheet addURL:[NSURL URLWithString:@"http://headsuphotdogs.com"]];
    
    UIViewController* myController = [[UIViewController alloc] init];
    [[[CCDirector sharedDirector] openGLView] addSubview:myController.view];
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){[myController dismissModalViewControllerAnimated:YES];};
    [myController presentModalViewController:tweetSheet animated:YES];
}

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
    NSString *slug = (NSString *)[(NSMutableArray *) data objectAtIndex:4];
    NSValue *lV = (NSValue *)[(NSMutableArray *) data objectAtIndex:5];
    levelProps *l = (levelProps *)[lV pointerValue];
    
    layer->_score = (int)score;
    layer->_timePlayed = (int)timePlayed;
    layer->_peopleGrumped = (int)peopleGrumped;
    layer->_dogsSaved = (int)dogsSaved;
    layer->slug = slug;
    layer->level = l;
    CCLOG(@"In sceneWithData: score = %d, time = %d, peopleGrumped = %d, dogsSaved = %d", layer->_score, layer->_timePlayed, layer->_peopleGrumped, layer->_dogsSaved);
    
	[scene addChild:layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        touchLock = false;
        self.isTouchEnabled = YES;
        // color definitions
        _color_pink = ccc3(255, 62, 166);
        _color_blue = ccc3(6, 110, 163);
        _color_darkblue = ccc3(14, 168, 248);
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spriteSheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"GameEnd_BG"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        scoreLine = [CCLabelTTF labelWithString:@"Total points: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [scoreLine setPosition:ccp(-10, -10)];
        scoreLine.color = _color_blue;
        [[scoreLine texture] setAliasTexParameters];
        [self addChild:scoreLine];
        
        timeLine = [CCLabelTTF labelWithString:@"Time lasted: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [timeLine setPosition:ccp(-10, -10)];
        timeLine.color = _color_blue;
        [[timeLine texture] setAliasTexParameters];
        [self addChild:timeLine];
        
        dogsLine = [CCLabelTTF labelWithString:@"Hot Dogs saved: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [dogsLine setPosition:ccp(-10, -10)];
        dogsLine.color = _color_blue;
        [[dogsLine texture] setAliasTexParameters];
        [self addChild:dogsLine];
        
        peopleLine = [CCLabelTTF labelWithString:@"People Grumped: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [peopleLine setPosition:ccp(-10, -10)];
        peopleLine.color = _color_blue;
        [[peopleLine texture] setAliasTexParameters];
        [self addChild:peopleLine];
        
        highScoreLine = [CCLabelTTF labelWithString:@"HIGH SCORE: 0" fontName:@"LostPet.TTF" fontSize:26.0];
        [highScoreLine setPosition:ccp(-10, -10)];
        highScoreLine.color = _color_darkblue;
        [[highScoreLine texture] setAliasTexParameters];
        [self addChild:highScoreLine];
        
        CCSprite *restartButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        restartButton.position = ccp(110, 27);
        [self addChild:restartButton z:10];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"     Try Again     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneRestart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 26)];
        [self addChild:menu z:11];
        
        CCSprite *quitButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        quitButton.position = ccp(370, 27);
        [self addChild:quitButton z:10];
        label = [CCLabelTTF labelWithString:@"     Quit     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneQuit)];
        menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(370, 26)];
        [self addChild:menu z:11];
        
        CCSprite *twitterButton = [CCSprite spriteWithSpriteFrameName:@"twitter.png"];
        twitterButton.position = ccp(83, 78);
        twitterButton.scale = 1;
        [[twitterButton texture] setAliasTexParameters];
        [self addChild:twitterButton z:10];
        _twitterRect = CGRectMake((twitterButton.position.x-(twitterButton.contentSize.width)/2), (twitterButton.position.y-(twitterButton.contentSize.height)/2), (twitterButton.contentSize.width+10), (twitterButton.contentSize.height+10));
        
        _lock = 0;
        
        [TestFlight passCheckpoint:@"Game Over Screen"];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if(!_lock){
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", level->slug]];
        NSInteger bestTime = [standardUserDefaults integerForKey:@"bestTime"];
        NSInteger overallTime = [standardUserDefaults integerForKey:@"overallTime"];
        _lock = 1;

        if(_score > highScore){
            _setNewHighScore = true;
            [standardUserDefaults setInteger:_score forKey:[NSString stringWithFormat:@"highScore%@", level->slug]];
            highScore = _score;
            [self reportScore:highScore forCategory:level->slug];
        }
        if(_timePlayed > bestTime)
            [standardUserDefaults setInteger:_timePlayed forKey:@"bestTime"];
        
        if(_score > level->next->unlockThreshold && !level->next->unlocked){
            levelBox = [CCSprite spriteWithSpriteFrameName:@"Lvl_TextBox.png"];
            levelBox.position = ccp(winSize.width/2, (winSize.height/2));
            [self addChild:levelBox];
        
            // TODO - only show this the first time it's unlocked
            levelLabel1 = [CCLabelTTF labelWithString:@"New Level Unlocked" fontName:@"LostPet.TTF" fontSize:20.0];
            [[levelLabel1 texture] setAliasTexParameters];
            levelLabel1.color = _color_pink;
            levelLabel1.position = ccp(winSize.width/2, winSize.height/2+10);
            [self addChild:levelLabel1];
        
            levelLabel2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", level->next->name] fontName:@"LostPet.TTF" fontSize:20.0];
            [[levelLabel2 texture] setAliasTexParameters];
            levelLabel2.color = _color_pink;
            levelLabel2.position = ccp(winSize.width/2, winSize.height/2-10);
            [self addChild:levelLabel2];
        }
            
        CCLOG(@"OverallTime + _timePlayed/60 --> %d + %d = %d", overallTime, _timePlayed/60, overallTime+(_timePlayed/60));
        [standardUserDefaults setInteger:overallTime+(_timePlayed/60) forKey:@"overallTime"];
        [standardUserDefaults synchronize];
    
        [scoreLine setString:[NSString stringWithFormat:@"Total points: %06d", _score]];
    
        int seconds = _timePlayed/60;
        int minutes = seconds/60;
        [timeLine setString:[NSString stringWithFormat:@"Time lasted: %02d:%02d", minutes, seconds%60]];
        [dogsLine setString:[NSString stringWithFormat:@"Dogs saved: %d", _dogsSaved]];
        [peopleLine setString:[NSString stringWithFormat:@"People grumped: %d", _peopleGrumped]];
        [highScoreLine setString:[NSString stringWithFormat:@"HIGH SCORE: %d", highScore]];
    
        [scoreLine setPosition:ccp(62+(scoreLine.contentSize.width/2), 225)];
        [timeLine setPosition:ccp(62+(timeLine.contentSize.width/2), 195)];
        [dogsLine setPosition:ccp(62+(dogsLine.contentSize.width/2), 165)];
        [peopleLine setPosition:ccp(62+(peopleLine.contentSize.width/2), 135)];
        [highScoreLine setPosition:ccp(389-(highScoreLine.contentSize.width/2), 70)];
    }
}

- (void)switchSceneRestart{
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer sceneWithSlug:slug]];
}

- (void)switchSceneQuit{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    CCLOG(@"Touch: %0.2f x %0.2f", location.x, location.y);
    
    if(levelBox){
        if(!touchLock){
            touchLock = true;
            [levelLabel1 removeFromParentAndCleanup:YES];
            [levelLabel2 removeFromParentAndCleanup:YES];
            [levelBox removeFromParentAndCleanup:YES];
        }
    }
    
    if(CGRectContainsPoint(_twitterRect,location)){
        [self tweetButtonPressed:self];
    }
}

-(void) dealloc{
    [[SimpleAudioEngine sharedEngine] stopEffect:sting];
    [super dealloc];
}

@end