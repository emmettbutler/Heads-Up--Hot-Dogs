//
//  LoseScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "LoseScene.h"
#import "GameplayLayer.h"
#import "LevelSelectLayer.h"
#import "TestFlight.h"
#import "Clouds.h"
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

-(void)showGameCenterLeaderboard{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil){
        UIViewController *myController = [[UIViewController alloc] init];
        leaderboardController.leaderboardDelegate = self;
        [myController presentModalViewController:leaderboardController animated:YES];
    } else {
        NSLog(@"Game center view not found");
    }
}

- (IBAction)tweetButtonPressed:(id)sender{
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];

    [tweetSheet setInitialText:[tweets objectAtIndex:arc4random() % [tweets count]]];
    //[tweetSheet addImage:[UIImage imageNamed:@"Icon_Head_big.png"]];
    [tweetSheet addURL:[NSURL URLWithString:@"http://headsuphotdogs.com"]];
    
    UIViewController* myController = [[UIViewController alloc] init];
    [[[CCDirector sharedDirector] openGLView] addSubview:myController.view];
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){[myController dismissModalViewControllerAnimated:YES];};
    [myController presentModalViewController:tweetSheet animated:YES];
}

+(CCScene *)sceneWithData:(void *)data
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

-(face *)buildFace:(NSString *)characterName withText:(NSString *)speech{
    NSMutableArray *frames;
    face *f;
    
    f = new face();
    frames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 2; i++){
        [frames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"GameEnd_%@_%d.png", characterName, i]]];
    }
    CCAnimation *anim = [CCAnimation animationWithFrames:frames delay:.2f];
    f->faceAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]] retain];
    f->speechBubble = speech;
    return f;
}

-(NSMutableArray *)buildFaces{
    NSMutableArray *faces = [[NSMutableArray alloc] init];
    
    [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Business" withText:@"I'm the businessman!"]]];
    [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Cop" withText:@"I'm the cop!"]]];
    [faces addObject:[NSValue valueWithPointer:[self buildFace:@"CrustPunk" withText:@"I'm the punk!"]]];
    [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Jogger" withText:@"I'm the jogger!"]]];
    [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Nudie" withText:@"I'm the towel guy!"]]];
    [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Rubber" withText:@"I'm the dog eater!"]]];
    [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Shiba" withText:@"bark bark bark bark bark bark bark"]]];
    [faces addObject:[NSValue valueWithPointer:[self buildFace:@"YoungProfesh" withText:@"I'm the young pro!"]]];
    
    return faces;
}

-(endResult *)buildResult{
    NSMutableArray *faces = [self buildFaces];
    
    endResult *res = new endResult();
    
    // value whose magnitude represents the distance from the unlock threshold
    float difference = ((float)_score - (float)level->unlockNextThreshold) / (float)level->unlockNextThreshold;
    // how many saved per grump
    int max = 4;
    if(level->maxDogs)
        max = level->maxDogs - 2;
    float savedPerGrump = ((float)_dogsSaved / (float)_peopleGrumped) / (float)max;
    if(_peopleGrumped == 0)
        savedPerGrump = 0;
    float grumpedPerTime = ((float)_peopleGrumped / (float)_timePlayed) * 100.0;
    
    NSLog(@"diff: %0.2f", difference);
    NSLog(@"saved per grump: %0.2f", savedPerGrump);
    NSLog(@"grumped per time: %0.2f", grumpedPerTime);
    
    NSNumber *grade = [NSNumber numberWithFloat:(difference + grumpedPerTime + savedPerGrump)];
    
    NSLog(@"Grade: %0.2f", grade.floatValue);
    
    if(grade.floatValue > 1.0){
        res->trophy = @"Trophy_Gold.png";
        res->dogName = @"GOLD DOG";
    } else if(grade.floatValue > .5){
        res->trophy = @"Trophy_Silver.png";
        res->dogName = @"SILVER DOG";
    } else if(grade.floatValue > 0){
        res->trophy = @"Trophy_Bronze.png";
        res->dogName = @"BRONZE DOG";
    } else if(grade.floatValue > -.5){
        res->trophy = @"Trophy_Wood.png";
        res->dogName = @"WOODEN DOG";
    } else {
        res->trophy = @"Trophy_Cardboard.png";
        res->dogName = @"CARDBOARD DOG";
    }
    
    res->head = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Business_1.png"];
    res->f = (face *)[[faces objectAtIndex:arc4random() % [faces count]] pointerValue];
    
    return res;
}

-(id) init{
    if ((self = [super init])){
        touchLock = false;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.isTouchEnabled = YES;
        
        reporter = [[AchievementReporter alloc] init];
        [reporter loadAchievements];
        
        // color definitions
        _color_pink = ccc3(255, 62, 166);
        _color_blue = ccc3(6, 110, 163);
        _color_darkblue = ccc3(14, 168, 248);
        
        [[Clouds alloc] initWithLayer:[NSValue valueWithPointer:self]];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spriteSheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Overlayer.png"];
        sprite.position = CGPointMake(winSize.width/2, winSize.height/2+19);
        [spriteSheet addChild:sprite];
    
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"GAME END!" fontName:@"LostPet.TTF" fontSize:50.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(winSize.width/2, winSize.height-(label.contentSize.height/2)-9);
        [self addChild:label];
        
        bubble = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Bubble.png"];
        bubble.position = ccp(winSize.width/2-40, winSize.height/2-70);
        [self addChild:bubble];
        
        charFace = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Cop_1.png"];
        charFace.position = ccp(winSize.width/2+125, winSize.height/2-57);
        charFace.visible = false;
        [self addChild:charFace];
        
        trophy = [CCSprite spriteWithSpriteFrameName:@"Trophy_Cardboard.png"];
        trophy.position = ccp(winSize.width/2-90, winSize.height/2+40);
        trophy.visible = false;
        [self addChild:trophy];
        
        summary = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(180, 150) alignment:UITextAlignmentCenter fontName:@"LostPet.TTF" fontSize:20.0];
        [summary setPosition:ccp(winSize.width/2+75, winSize.height/2+10)];
        summary.color = _color_pink;
        [self addChild:summary];
        
        CCSprite *restartButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        restartButton.position = ccp(110, 22);
        [self addChild:restartButton z:10];
        label = [CCLabelTTF labelWithString:@"     Try Again     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneRestart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 21)];
        [self addChild:menu z:11];
        _replayRect = CGRectMake((restartButton.position.x-(restartButton.contentSize.width)/2), (restartButton.position.y-(restartButton.contentSize.height)/2), (restartButton.contentSize.width+70), restartButton.contentSize.height+70);
        
        CCSprite *quitButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        quitButton.position = ccp(370, 22);
        [self addChild:quitButton z:10];
        label = [CCLabelTTF labelWithString:@"     Levels     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneLevel)];
        menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(370, 21)];
        [self addChild:menu z:11];
        _quitRect = CGRectMake((quitButton.position.x-(quitButton.contentSize.width)/2), (quitButton.position.y-(quitButton.contentSize.height)/2), (quitButton.contentSize.width+70), (quitButton.contentSize.height+70));
        
        CCSprite *box = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Social_Overlay.png"];
        box.position = CGPointMake(winSize.width-box.contentSize.width/2-5, winSize.height-box.contentSize.height/2-3);
        [self addChild:box];
        
        CCSprite *twitterButton = [CCSprite spriteWithSpriteFrameName:@"twitter.png"];
        twitterButton.position = ccp(winSize.width-twitterButton.contentSize.width/2-12, winSize.height-twitterButton.contentSize.height/2-13);
        twitterButton.scale = 1;
        [[twitterButton texture] setAliasTexParameters];
        [self addChild:twitterButton z:10];
        _twitterRect = CGRectMake((twitterButton.position.x-(twitterButton.contentSize.width)/2), (twitterButton.position.y-(twitterButton.contentSize.height)/2), (twitterButton.contentSize.width+10), (twitterButton.contentSize.height+10));
        
        CCSprite *gcButton = [CCSprite spriteWithSpriteFrameName:@"game-center-logo-tiny.png"];
        gcButton.position = ccp(winSize.width-gcButton.contentSize.width/2-18, winSize.height-gcButton.contentSize.height/2-twitterButton.contentSize.height-20);
        gcButton.scale = 1;
        [[gcButton texture] setAliasTexParameters];
        [self addChild:gcButton z:10];
        _gcRect = CGRectMake((gcButton.position.x-(gcButton.contentSize.width)/2), (gcButton.position.y-(gcButton.contentSize.height)/2), (gcButton.contentSize.width+10), (gcButton.contentSize.height+10));
        
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
        
        endResult *res = [self buildResult];
        
        NSLog(@"Trophy: %@", res->trophy);
        [trophy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:res->trophy]];
        [trophy setVisible:true];
        
        CCLabelTTF *speech = [CCLabelTTF labelWithString:res->f->speechBubble dimensions:CGSizeMake(bubble.contentSize.width-40, 50) alignment:UITextAlignmentCenter fontName:@"LostPet.TTF" fontSize:20.0];
        speech.color = _color_pink;
        speech.position = CGPointMake(bubble.position.x-3, bubble.position.y);
        [[speech texture] setAliasTexParameters];
        [self addChild:speech];
        [charFace runAction:res->f->faceAction];
        [charFace setVisible:true];
        
        int seconds = _timePlayed/60;
        int minutes = seconds/60;
        [summary setString:[NSString stringWithFormat:@"You lasted %02d:%02d and scored %d points. You have earned %@", minutes, seconds%60, _score, res->dogName]];
        
        if(_score > highScore){
            _setNewHighScore = true;
            [standardUserDefaults setInteger:_score forKey:[NSString stringWithFormat:@"highScore%@", level->slug]];
            highScore = _score;
            // max 6 digits
            if(highScore > 999999)
                highScore = 999999;
            [self reportScore:highScore forCategory:level->slug];
        }
        if(_timePlayed > bestTime)
            [standardUserDefaults setInteger:_timePlayed forKey:@"bestTime"];
        
        if(_score > level->unlockNextThreshold && !level->next->unlocked){
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
        
        tweets = [[NSMutableArray alloc] init];
        [tweets addObject:[NSString stringWithFormat:@"I just scored %d points in %@ in @HeadsUpHotDogs!", _score, level->name]];
        [tweets addObject:[NSString stringWithFormat:@"I just dropped hot dogs on %d people's heads in @HeadsUpHotDogs!", _peopleGrumped]];
        [tweets addObject:[NSString stringWithFormat:@"I just saved %d hot dogs from destruction in %@ in @HeadsUpHotDogs!", _dogsSaved, level->name]];
        [tweets addObject:[NSString stringWithFormat:@"I just saved %d inches of meat from destruction in @HeadsUpHotDogs!", _dogsSaved * 12]];
        [tweets addObject:@"I am the new savior of franks in @HeadsUpHotDogs!"];
        [tweets addObject:[NSString stringWithFormat:@"I just earned the %@ in %@ in @HeadsUpHotDogs!", res->dogName, level->name]];
        
        NSString *highScoreString = [NSString stringWithFormat:@"I just set a new high score in @HeadsUpHotDogs beta: %d points!", _score];
        
        if(_setNewHighScore)
            [tweets addObject:highScoreString];
        
        if(_score > level->unlockNextThreshold){
            [tweets addObject:level->next->unlockTweet];
        }
            
        CCLOG(@"OverallTime + _timePlayed/60 --> %d + %d = %d", overallTime, _timePlayed/60, overallTime+(_timePlayed/60));
        int newOverallTime = overallTime+(_timePlayed/60);
        [standardUserDefaults setInteger:newOverallTime forKey:@"overallTime"];
        [standardUserDefaults synchronize];
        
        [reporter reportAchievementIdentifier:@"totaltime_1" percentComplete:newOverallTime/432000]; // two hours
    }
}

- (void)switchSceneRestart{
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer sceneWithSlug:slug]];
}

- (void)switchSceneLevel{
    [[CCDirector sharedDirector] replaceScene:[LevelSelectLayer scene]];
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
    } else if(CGRectContainsPoint(_gcRect, location)){
        [self showGameCenterLeaderboard];
    } else if(CGRectContainsPoint(_quitRect, location)){
        [self switchSceneLevel];
    } else if(CGRectContainsPoint(_replayRect, location)){
        [self switchSceneRestart];
    }
    
}

-(void) dealloc{
    [[SimpleAudioEngine sharedEngine] stopEffect:sting];
    [super dealloc];
}

@end