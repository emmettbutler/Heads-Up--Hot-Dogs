//
//  LoseScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "LoseScene.h"
#import "GameplayLayer.h"
#import "LevelSelectLayer.h"
#import "TestFlight.h"
#import "Clouds.h"
#import "UIDefs.h"
#import "AppDelegate.h"
#import "HotDogManager.h"

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
            
        }
    }];
}

-(void)showGameCenterLeaderboard{
    leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil){
        leaderboardController.category = level->slug;
        AppDelegate *ad = [[UIApplication sharedApplication] delegate];
        UIViewController *rootViewController = (UIViewController *)ad.getRootViewController;
        leaderboardController.leaderboardDelegate = self;
        [rootViewController presentModalViewController:leaderboardController animated:YES];
    } else {
        NSLog(@"Game center view not found");
    }
}

-(void)showGameCenterAchievements{
    achievementController = [[GKAchievementViewController alloc] init];
    if (achievementController != nil){
        AppDelegate *ad = [[UIApplication sharedApplication] delegate];
        UIViewController *rootViewController = (UIViewController *)ad.getRootViewController;
        achievementController.achievementDelegate = self;
        [rootViewController presentModalViewController:achievementController animated:YES];
    } else {
        NSLog(@"Game center view not found");
    }
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
    [leaderboardController dismissModalViewControllerAnimated:YES];
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
    [achievementController dismissModalViewControllerAnimated:YES];
}

- (IBAction)tweetButtonPressed:(id)sender{
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];

    [tweetSheet setInitialText:[tweets objectAtIndex:arc4random() % [tweets count]]];
    //[tweetSheet addImage:[UIImage imageNamed:@"Icon_Head_big.png"]];
    [tweetSheet addURL:[NSURL URLWithString:@"http://asw.im/7cz09a"]];
    
    UIViewController* myController = [[UIViewController alloc] init];
    [[[CCDirector sharedDirector] openGLView] addSubview:myController.view];
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){[myController dismissModalViewControllerAnimated:YES];};
    [myController presentModalViewController:tweetSheet animated:YES];
    
    [reporter reportAchievementIdentifier:@"tweet" percentComplete:100];
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
    NSInteger *dogsShotByCop = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:6] pointerValue];
    NSInteger *dogsMissedByCop = (NSInteger *)[(NSValue *)[(NSMutableArray *) data objectAtIndex:7] pointerValue];
    
    layer->_score = (int)score;
    layer->_timePlayed = (int)timePlayed;
    layer->_peopleGrumped = (int)peopleGrumped;
    layer->_dogsSaved = (int)dogsSaved;
    layer->slug = slug;
    layer->level = l;
    layer->_shotByCop = (int)dogsShotByCop;
    layer->_missedByCop = (int)dogsMissedByCop;
    CCLOG(@"In sceneWithData: score = %d, time = %d, peopleGrumped = %d, dogsSaved = %d", layer->_score, layer->_timePlayed, layer->_peopleGrumped, layer->_dogsSaved);
    
	[scene addChild:layer];
	return scene;
}

-(face *)buildFace:(NSString *)characterName withGrade:(NSNumber *)grade{
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
    f->speechBubble = [self makeComment:characterName withGrade:grade];
    return f;
}

-(NSString *)makeComment:(NSString *)characterName withGrade:(NSNumber *)grade{
    NSString *comment;
    characterSpeech *s = new characterSpeech();
    
    if(characterName == @"Business"){
        s->bad = @"You should probably think about restructuring your workflow.";
        s->ok = @"You\'re on your way to the top. Nice work.";
        s->good = @"I\'ve been impressed with your efficiency lately. Best regards.";
        s->other1 = @"Would you please stop? I\'ve got an important business meeting today.";
        s->other2 = @"Shouldn\'t you be at work!?";
    } else if (characterName == @"Cop"){
        s->bad = @"Nice try, punk! You\'re coming with me!";
        s->ok = @"We can\'t let this delinquent keep causing mayhem!";
        s->good = @"There are too many of them! I need backup!";
        s->other1 = [NSString stringWithFormat:@"I missed %d dogs? No way!", _missedByCop];
        s->other2 = [NSString stringWithFormat:@"Ha! I shot %d dogs, and I\'ll get more next time!", _shotByCop];
    } else if (characterName == @"CrustPunk"){
        s->bad = @"Haha, that score chunks it.";
        s->ok = @"Not too bad, dude. Nice.";
        s->good = @"Cool score! Share the wealth?";
        s->other1 = @"I\'m thinking about getting a face-tat. Pentagram maybe?";
        s->other2 = @"Hanging out with you is pretty cool. Wanna get our eyeballs pierced?";
    } else if (characterName == @"Jogger"){
        s->bad = @"Did you pull something? Keep training!";
        s->ok = @"Haha woah. It\'s hard to work out with you tossing those hot dogs around.";
        s->good = @"Wow, you\'re in amazing shape! What motivation.";
        s->other1 = @"Exercising works out both the body and mind!!!";
        s->other2 = @"I\'m trying to keep in shape but those franks look so tasty!";
    } else if (characterName == @"Nudie"){
        s->bad = @"Uhm... not so good...";
        s->ok = @"Urk! Not bad...";
        s->good = @"Great job! But excuse me...";
        s->other1 = @"Please stop looking at me!";
        s->other2 = @"Why not save a screencap? It\'ll last longer.";
    } else if (characterName == @"Shiba"){
        s->bad = @"Barf barf barf!";
        s->ok = @"Bark!";
        s->good = @"Bark bark bark bark bark bark bark bark bark bark!";
        s->other1 = @"C\'\'an y ou teacher me use wo rds";
        s->other2 = @"C\'\'an y ou teacher me use wo rds";
    } else if (characterName == @"YoungProfesh"){
        s->bad = @"Keep trying! I believe in you.";
        s->ok = @"You\'re getting there! Nice work!";
        s->good = @"Oh wow! Amazing! You\'re so good at this.";
        s->other1 = @"You look like you\'re having a lot of fun. I wish I didn\'t have work today.";
        s->other2 = @"I\'m on my way into the office, let\'s talk later!";
    } else if (characterName == @"Rubber"){
        s->bad = @"You\'ve gotta put in some work, dude!";
        s->ok = @"That score\'s pretty good... I\'m supes hungry...";
        s->good = @"Are you kidding me?? How\'d you get so good!?";
        s->other1 = @"...How could you do this to me?";
        s->other2 = @"PLEASE LEAVE ME ALONE PLEASE";
    } else if (characterName == @"Professor"){
        s->bad = @"Such a low grade. Study harder.";
        s->ok = @"Interesting score, but there are a few points you could use to elaborate.";
        s->good = @"Such a model of excellence. The ideal pupil!";
        s->other1 = [NSString stringWithFormat:@"Are you going anywhere for summer vacation? I hear %@ is nice.", level->prev->name];
        s->other2 = @"The history of the hot dog is unclear, but fascinating nonetheless.";
    }  else if (characterName == @"Astronaut"){
        s->bad = @"Something's wrong with the frank diffuser!";
        s->ok = @"You're becoming more like your father.";
        s->good = @"We're in the pipe, five by five.";
        s->other1 = @"I wonder what spring is like on mars and stuff, tra la...";
        s->other2 = @"I wonder what spring is like on mars and stuff, tra la...";
    }
    
    if(arc4random() % 4 == 1){
        comment = s->other2;
        if(arc4random() % 2 == 1)
            comment = s->other1;
    } else {
        if(grade.floatValue > .7){
            comment = s->good;
        } else if(grade.floatValue > 0){
            comment = s->ok;
        } else {
            comment = s->bad;
        }
    }
    return comment;
}

-(NSMutableArray *)buildFaces:(NSNumber *)grade{
    NSMutableArray *faces = [[NSMutableArray alloc] init];
    
    NSMutableArray *charSlugs = [[NSMutableArray alloc] init];
    for(int i = 0; i < [level->characters count]; i++){
        personStruct *p = (personStruct *)[[level->characters objectAtIndex:i] pointerValue];
        [charSlugs addObject:p->slug];
    }
    
    if([charSlugs containsObject:@"busman"])
        [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Business" withGrade:grade]]];
    if([charSlugs containsObject:@"police"])
        [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Cop" withGrade:grade]]];
    if([charSlugs containsObject:@"crpunk"])
        [faces addObject:[NSValue valueWithPointer:[self buildFace:@"CrustPunk" withGrade:grade]]];
    if([charSlugs containsObject:@"jogger"])
        [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Jogger" withGrade:grade]]];
    if([charSlugs containsObject:@"nudie"])
        [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Nudie" withGrade:grade]]];
    if([charSlugs containsObject:@"muncher"])
        [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Rubber" withGrade:grade]]];
    if(level->hasShiba)
        [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Shiba" withGrade:grade]]];
    if([charSlugs containsObject:@"youngpro"])
        [faces addObject:[NSValue valueWithPointer:[self buildFace:@"YoungProfesh" withGrade:grade]]];
    if([charSlugs containsObject:@"astronaut"])
        [faces addObject:[NSValue valueWithPointer:[self buildFace:@"Astronaut" withGrade:grade]]];
    //if([charSlugs containsObject:@"professor"])
        //[faces addObject:[NSValue valueWithPointer:[self buildFace:@"Professor" withGrade:grade]]];
    
    return faces;
}

-(endResult *)buildResult{
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
    
    if(grade.floatValue > 1.6){
        res->trophy = @"Trophy_Gold.png";
        res->trophyLevel = 1;
        res->dogName = @"GOLD DOG";
    } else if(grade.floatValue > .6){
        res->trophy = @"Trophy_Silver.png";
        res->trophyLevel = 2;
        res->dogName = @"SILVER DOG";
    } else if(grade.floatValue > 0){
        res->trophy = @"Trophy_Bronze.png";
        res->trophyLevel = 3;
        res->dogName = @"BRONZE DOG";
    } else if(grade.floatValue > -.4){
        res->trophy = @"Trophy_Wood.png";
        res->trophyLevel = 4;
        res->dogName = @"WOODEN DOG";
    } else {
        res->trophy = @"Trophy_Cardboard.png";
        res->trophyLevel = 5;
        res->dogName = @"CARDBOARD DOG";
    }
    
    NSMutableArray *faces = [self buildFaces:grade];
    res->head = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Business_1.png"];
    res->f = (face *)[[faces objectAtIndex:arc4random() % [faces count]] pointerValue];
    
    return res;
}

-(id) init{
    if ((self = [super init])){
        touchLock = false;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.isTouchEnabled = YES;
        [[HotDogManager sharedManager] setPause:[NSNumber numberWithBool:false]];
        [[HotDogManager sharedManager] setInGame:[NSNumber numberWithBool:false]];
        
        reporter = [[AchievementReporter alloc] init];
        [reporter loadAchievements];
        
        // color definitions
        _color_pink = ccc3(255, 62, 166);
        _color_blue = ccc3(6, 110, 163);
        _color_darkblue = ccc3(14, 168, 248);
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spriteSheet];
        [[Clouds alloc] initWithLayer:[NSValue valueWithPointer:self] andSpritesheet:[NSValue valueWithPointer:spriteSheet]];
        
        float headerFontSize = IPHONE_HEADER_TEXT_SIZE;
        float scale = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scale = IPAD_SCALE_FACTOR_X;
        }
        float fontSize = scale*22.0;
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        background.anchorPoint = CGPointZero;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            background.scaleX = IPAD_SCALE_FACTOR_X;
            background.scaleY = IPAD_SCALE_FACTOR_Y;
            headerFontSize = IPAD_HEADER_TEXT_SiZE;
        } else {
            background.scaleX = winSize.width / background.contentSize.width;
        }
        [self addChild:background z:-1];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Overlayer.png"];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            sprite.scaleX = IPAD_SCALE_FACTOR_X;
            sprite.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        sprite.position = CGPointMake(winSize.width/2, winSize.height/2+19);
        [spriteSheet addChild:sprite];
    
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"GAME END!" fontName:@"LostPet.TTF" fontSize:headerFontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(winSize.width/2, sprite.position.y+((sprite.contentSize.height*sprite.scaleY)/2)-label.contentSize.height/2);
        [self addChild:label];
        
        elmtScale = 1.0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            elmtScale = 2.0;
        }
        
        bubble = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Bubble.png"];
        bubble.scale = elmtScale;
        bubble.position = ccp(sprite.position.x-((sprite.contentSize.width*sprite.scaleX)*.11), sprite.position.y-((sprite.contentSize.height*sprite.scaleY)/4)-(bubble.contentSize.height*bubble.scaleY/5));
        [self addChild:bubble];
        
        charFace = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Cop_1.png"];
        charFace.scale = elmtScale;
        charFace.position = ccp(sprite.position.x+((sprite.contentSize.width*sprite.scaleX)*.36), sprite.position.y-((sprite.contentSize.height*sprite.scaleY)/4));
        charFace.visible = false;
        [self addChild:charFace];
        
        trophy = [CCSprite spriteWithSpriteFrameName:@"Trophy_Cardboard.png"];
        trophy.scale = elmtScale*1.15;
        trophy.position = ccp(sprite.position.x-((sprite.contentSize.width*sprite.scaleX)/4), sprite.position.y+((sprite.contentSize.height*sprite.scaleY)/7));
        trophy.visible = false;
        [self addChild:trophy];
        
        summary = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(170*elmtScale, 100*elmtScale) alignment:UITextAlignmentCenter fontName:@"LostPet.TTF" fontSize:20.0*elmtScale];
        [summary setPosition:ccp(sprite.position.x+((sprite.contentSize.width*sprite.scaleX)/5), sprite.position.y+((sprite.contentSize.height*sprite.scaleY)/7))];
        summary.color = _color_pink;
        [self addChild:summary];
        
        CCSprite *button1 = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        button1.scale = scale;
        button1.position = ccp(winSize.width/4, (float)button1.contentSize.height*button1.scaleY/1.5);
        [self addChild:button1 z:10];
        label = [CCLabelTTF labelWithString:@"Try Again" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(button1.position.x, button1.position.y-1);
        [self addChild:label z:11];
        _replayRect = CGRectMake((button1.position.x-(button1.contentSize.width*button1.scaleX)/2), (button1.position.y-(button1.contentSize.height*button1.scaleY)/2), (button1.contentSize.width*button1.scaleX+70), (button1.contentSize.height*button1.scaleY+70));
        
        CCSprite *button2 = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        button2.scale = scale;
        button2.position = ccp(3*(winSize.width/4), (float)button1.contentSize.height*button1.scaleY/1.5);
        [self addChild:button2 z:10];
        CCLabelTTF *otherLabel = [CCLabelTTF labelWithString:@"Levels" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[otherLabel texture] setAliasTexParameters];
        otherLabel.color = _color_pink;
        otherLabel.position = ccp(button2.position.x, button2.position.y-1);
        [self addChild:otherLabel z:11];
        _quitRect = CGRectMake((button2.position.x-(button2.contentSize.width*button2.scaleX)/2), (button2.position.y-(button2.contentSize.height*button2.scaleY)/2), (button2.contentSize.width*button2.scaleX+70), (button2.contentSize.height*button2.scaleY+70));
        
        CCSprite *box = [CCSprite spriteWithSpriteFrameName:@"GameEnd_Social_Overlay.png"];
        box.scale = scale;
        box.position = CGPointMake(winSize.width-box.scaleX*box.contentSize.width/2-5, winSize.height-box.scaleY*box.contentSize.height/2-3);
        [self addChild:box];
        
        CCSprite *twitterButton = [CCSprite spriteWithSpriteFrameName:@"twitter.png"];
        twitterButton.scale = scale;
        twitterButton.position = ccp(winSize.width-(twitterButton.scaleX*twitterButton.contentSize.width*.75), winSize.height-(twitterButton.scaleY*twitterButton.contentSize.height*.75));
        [[twitterButton texture] setAliasTexParameters];
        [self addChild:twitterButton z:10];
        _twitterRect = CGRectMake((twitterButton.position.x-(twitterButton.scaleX*twitterButton.contentSize.width)/2), (twitterButton.position.y-(twitterButton.scaleY*twitterButton.contentSize.height)/2), (twitterButton.scaleX*twitterButton.contentSize.width+10), (twitterButton.scaleY*twitterButton.contentSize.height+10));
        
        CCSprite *gcButton = [CCSprite spriteWithSpriteFrameName:@"game-center-logo-tiny.png"];
        gcButton.scale = scale;
        gcButton.position = ccp(winSize.width-(gcButton.scaleX*gcButton.contentSize.width), winSize.height-(gcButton.scaleY*gcButton.contentSize.height)/2-twitterButton.scaleY*twitterButton.contentSize.height-gcButton.scaleY*gcButton.contentSize.height/2);
        [[gcButton texture] setAliasTexParameters];
        [self addChild:gcButton z:10];
        _gcRect = CGRectMake((gcButton.position.x-(gcButton.scaleX*gcButton.contentSize.width)/2), (gcButton.position.y-(gcButton.scaleY*gcButton.contentSize.height)/2), (gcButton.scaleX*gcButton.contentSize.width+10), (gcButton.scaleY*gcButton.contentSize.height+10));
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    time++;
    
    if(time == 5){
        [charFace setVisible:true];
    }
    
    if(!_lock){
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", level->slug]];
        NSInteger bestTime = [standardUserDefaults integerForKey:@"bestTime"];
        NSInteger overallTime = [standardUserDefaults integerForKey:@"overallTime"];
        NSInteger totalGames = [standardUserDefaults integerForKey:@"totalGames"];
        _numberOfTotalGamesPlayed = totalGames;
        _lock = 1;
        
        endResult *res = [self buildResult];
        
        NSLog(@"Trophy: %@", res->trophy);
        [trophy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:res->trophy]];
        [trophy setVisible:true];
        
        CCLabelTTF *speech = [CCLabelTTF labelWithString:res->f->speechBubble dimensions:CGSizeMake(((bubble.contentSize.width*bubble.scaleX)*.75), (([res->f->speechBubble length]/25 > 1) ? [res->f->speechBubble length]/25 : 1)*34.0*elmtScale) alignment:UITextAlignmentCenter fontName:@"LostPet.TTF" fontSize:17.0*elmtScale];
        speech.color = _color_pink;
        speech.position = CGPointMake(bubble.position.x-3, bubble.position.y);
        speech.anchorPoint = ccp(0.5, 0.5);
        [[speech texture] setAliasTexParameters];
        [self addChild:speech];
        
        [charFace runAction:res->f->faceAction];
        
        int seconds = _timePlayed/60;
        int minutes = seconds/60;
        [summary setString:[NSString stringWithFormat:@"You lasted %02d:%02d and scored %d points.\nYou earned %@", minutes, seconds%60, _score, res->dogName]];
        [[summary texture] setAliasTexParameters];
        
        if(res->dogName == @"GOLD DOG"){
            [reporter reportAchievementIdentifier:[NSString stringWithFormat:@"gold_%@", level->slug] percentComplete:100];
        }
        
        NSLog(@"Should report scores: %d", [[HotDogManager sharedManager] shouldReportScores]);
        if([[HotDogManager sharedManager] shouldReportScores]){
            if(_score > highScore){
                _setNewHighScore = true;
                [standardUserDefaults setInteger:_score forKey:[NSString stringWithFormat:@"highScore%@", level->slug]];
                highScore = _score;
                // max 6 digits
                if(highScore > 999999)
                    highScore = 999999;
                [self reportScore:highScore forCategory:level->slug];
            }
        }
        [[HotDogManager sharedManager] setDontReportScores:[NSNumber numberWithBool:false]];
        if(_timePlayed > bestTime)
            [standardUserDefaults setInteger:_timePlayed forKey:@"bestTime"];
        
        if(res->trophyLevel < level->highestTrophy){
            level->highestTrophy = res->trophyLevel;
            [standardUserDefaults setInteger:level->highestTrophy forKey:[NSString stringWithFormat:@"trophy_%@", level->slug]];
        }
        if(res->trophyLevel > 3){
            [[HotDogManager sharedManager] customEvent:@"game_end_failure" st1:@"gameplays" st2:@"game_end" level:level->number value:_score data:@{@"dog_awarded": res->trophy}];
        } else {
            [[HotDogManager sharedManager] customEvent:@"game_end_success" st1:@"gameplays" st2:@"game_end" level:level->number value:_score data:@{@"dog_awarded": res->trophy}];
        }
        if(res->trophyLevel <= 2 && !level->next->unlocked){
            NSInteger unlocked = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"unlocked%@", level->next->slug]];
            [standardUserDefaults setInteger:1 forKey:[NSString stringWithFormat:@"unlocked%@", level->next->slug]];
            [standardUserDefaults setInteger:level->next->number forKey:@"highestLevelUnlocked"];
            [[HotDogManager sharedManager] customEvent:[NSString stringWithFormat:@"level_up_%@", level->next->slug] st1:@"level_up" st2:NULL level:NULL value:_timePlayed/60 data:@{@"game_number": [NSNumber numberWithInt:_numberOfTotalGamesPlayed]}];
            [[HotDogManager sharedManager] customEvent:@"user_level_positions" st1:@"useractions" st2:NULL level:level->number value:-1 data:NULL];
            [[HotDogManager sharedManager] customEvent:@"user_level_positions" st1:@"useractions" st2:NULL level:level->next->number value:1 data:NULL];
            if(level->next->slug != level->slug && (!unlocked || unlocked == 0)){
                float scale = 1, fontSize = 20.0;
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    scale = IPAD_SCALE_FACTOR_X;
                    fontSize *= IPAD_SCALE_FACTOR_X;
                }
                
                levelBox = [CCSprite spriteWithSpriteFrameName:@"Lvl_TextBox.png"];
                levelBox.position = ccp(winSize.width/2, (winSize.height/2));
                levelBox.scale = scale;
                [self addChild:levelBox];
                
                [reporter reportAchievementIdentifier:[NSString stringWithFormat:@"unlock_%@", level->next->slug] percentComplete:100];
        
                levelLabel2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"New level unlocked\n%@", level->next->name] dimensions:CGSizeMake(levelBox.contentSize.width*levelBox.scaleX*.9,levelBox.contentSize.height*levelBox.scaleY*.8) alignment:UITextAlignmentCenter fontName:@"LostPet.TTF" fontSize:fontSize];
                [[levelLabel2 texture] setAliasTexParameters];
                levelLabel2.color = _color_pink;
                levelLabel2.position = levelBox.position;
                [self addChild:levelLabel2];
            }
        }
        
        tweets = [[NSMutableArray alloc] init];
        [tweets addObject:[NSString stringWithFormat:@"I just scored %d points in %@! #HeadsUpHotDogs", _score, level->name]];
        [tweets addObject:[NSString stringWithFormat:@"I just saved %d inches of sweet sweet frankmeat! #HeadsUpHotDogs", _dogsSaved * (10 + (arc4random() % 3))]];
        [tweets addObject:[NSString stringWithFormat:@"I just earned a %@ trophy in %@! #HeadsUpHotDogs", res->dogName, level->name]];
            
        CCLOG(@"OverallTime + _timePlayed/60 --> %d + %d = %d", overallTime, _timePlayed/60, overallTime+(_timePlayed/60));
        int newOverallTime = overallTime+(_timePlayed/60);
        [standardUserDefaults setInteger:newOverallTime forKey:@"overallTime"];
        [standardUserDefaults synchronize];
        
        [reporter reportAchievementIdentifier:@"totaltime_1" percentComplete:newOverallTime/432000]; // two hours
    }
}

- (void)switchSceneRestart{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.3 scene:[GameplayLayer sceneWithSlug:slug andVomitCheat:[NSNumber numberWithBool:false] andBigHeadCheat:[NSNumber numberWithBool:false]]]];
}

- (void)switchSceneLevel{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInB transitionWithDuration:.3 scene:[LevelSelectLayer scene]]];
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
        [[HotDogManager sharedManager] customEvent:@"twitter_score_posted" st1:@"player_interaction" st2:NULL level:level->number value:_score data:@{@"game_number": [NSNumber numberWithInt:_numberOfTotalGamesPlayed]}];
        [self tweetButtonPressed:self];
    } else if(CGRectContainsPoint(_gcRect, location)){
        //[self showGameCenterAchievements];
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