//
//  TitleScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "TitleScene.h"
#import "GameplayLayer.h"
#import "TutorialLayer.h"
#import "OptionsLayer.h"
#import "TestFlight.h"
#import "LevelSelectLayer.h"

#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation TitleLayer

@synthesize titleAnimAction = _titleAnimAction;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	TitleLayer *layer = [TitleLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        self.isTouchEnabled = true;
        CGSize size = [[CCDirector sharedDirector] winSize];
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
#ifdef DEBUG
        NSLog(@"DEBUG MODE ON");
        CCLabelTTF *dlabel = [CCLabelTTF labelWithString:@"DEBUG" fontName:@"LostPet.TTF" fontSize:30.0];
        [[dlabel texture] setAliasTexParameters];
        dlabel.position = ccp(size.width-(dlabel.contentSize.width/2)-6, size.height-(dlabel.contentSize.height/2)-5);
        [self addChild:dlabel];
#else
        if(![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu 2.mp3" loop:YES];
#endif
        
        // color definitions
        _color_pink = ccc3(255, 62, 166);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_menus.plist"];
        
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spriteSheet];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"BETA v0.5" fontName:@"LostPet.TTF" fontSize:30.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp((label.contentSize.width/2)+6, size.height-(label.contentSize.height/2)-5);
        [self addChild:label];

        CCSprite *startButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        startButton.position = ccp(110, 27);
        [self addChild:startButton z:10];
        label = [CCLabelTTF labelWithString:@"     Start     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneStart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 26)];
        [self addChild:menu z:11];
        _startRect = CGRectMake((startButton.position.x-(startButton.contentSize.width)/2), (startButton.position.y-(startButton.contentSize.height)/2), (startButton.contentSize.width+70), (startButton.contentSize.height+70));
        
        CCSprite *otherButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        otherButton.position = ccp(370, 27);
        [self addChild:otherButton z:10];
        CCLabelTTF *otherLabel = [CCLabelTTF labelWithString:@"      Options      " fontName:@"LostPet.TTF" fontSize:22.0];
        [[otherLabel texture] setAliasTexParameters];
        otherLabel.color = _color_pink;
        CCMenuItem *otherTextButton = [CCMenuItemLabel itemWithLabel:otherLabel target:self selector:@selector(switchSceneOptions)];
        CCMenu *otherMenu = [CCMenu menuWithItems:otherTextButton, nil];
        [otherMenu setPosition:ccp(370, 26)];
        [self addChild:otherMenu z:11];
        _optionsRect = CGRectMake((otherButton.position.x-(otherButton.contentSize.width)/2), (otherButton.position.y-(otherButton.contentSize.height)/2), (otherButton.contentSize.width+70), (otherButton.contentSize.height+70));
        
        background = [CCSprite spriteWithSpriteFrameName:@"blank_bg.png"];
        background.anchorPoint = CGPointZero;
        [self addChild:background z:-10];
        
        NSMutableArray *titleAnimFrames = [[NSMutableArray alloc] initWithCapacity:13];
        [titleAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"blank_bg.png"]];
        for(int i = 2; i <= 13; i++){
            [titleAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"TitleAnim_%d.png", i]]];
        }
        titleAnim = [CCAnimation animationWithFrames:titleAnimFrames delay:.07f];
        self.titleAnimAction = [[CCAnimate alloc] initWithAnimation:titleAnim restoreOriginalFrame:NO];
        [titleAnimFrames release];
        
        screen = CGRectMake(0, 0, size.width, size.height);
        
        time = 0;
        
        NSInteger introDone = [[NSUserDefaults standardUserDefaults] integerForKey:@"introDone"];
        if(!introDone){
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"sfxon"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [background runAction:_titleAnimAction];
        
        [TestFlight passCheckpoint:@"Title Screen"];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    //CGSize size = [[CCDirector sharedDirector] winSize];
    time++;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if(CGRectContainsPoint(_startRect, location)){
        [self switchSceneStart];
    } else if(CGRectContainsPoint(_optionsRect, location)){
        [self switchSceneOptions];
    }
}

- (void)switchSceneStart{
    NSInteger introDone = [standardUserDefaults integerForKey:@"introDone"];
    NSLog(@"introDone: %d", introDone);
    if(introDone == 1)
        [[CCDirector sharedDirector] replaceScene:[LevelSelectLayer scene]];
    else if(introDone == 0){
        [[CCDirector sharedDirector] replaceScene:[TutorialLayer sceneWithFrom:@"title"]];
    }
}

- (void)switchSceneOptions{
    [[CCDirector sharedDirector] replaceScene:[OptionsLayer scene]];
}

-(void) dealloc{
    [super dealloc];
}

@end