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
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
#ifdef DEBUG
        NSLog(@"DEBUG MODE ON");
#endif
        
        // color definitions
        _color_pink = ccc3(255, 62, 166);
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
#ifdef DEBUG
#else
        [[SimpleAudioEngine sharedEngine] playEffect:@"menu intro.wav"];
        
        SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
        if (sae != nil) {
            [sae preloadBackgroundMusic:@"menu 2.wav"];
            if (sae.willPlayBackgroundMusic) {
                sae.backgroundMusicVolume = 0.5f;
            }
        }
#endif
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"title_sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"title_sprites_default.png"];
        [self addChild:spriteSheet];

        CCSprite *startButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        startButton.position = ccp(110, 27);
        [self addChild:startButton z:10];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"     Start     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneStart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 26)];
        [self addChild:menu z:11];
        
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
        
        background = [CCSprite spriteWithSpriteFrameName:@"TitleAnim_1.png"];
        background.anchorPoint = CGPointZero;
        [self addChild:background z:-10];
        
        NSMutableArray *titleAnimFrames = [[NSMutableArray alloc] initWithCapacity:13];
        for(int i = 1; i <= 13; i++){
            [titleAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"TitleAnim_%d.png", i]]];
        }
        titleAnim = [CCAnimation animationWithFrames:titleAnimFrames delay:.07f];
        self.titleAnimAction = [[CCAnimate alloc] initWithAnimation:titleAnim restoreOriginalFrame:NO];
        [titleAnimFrames release];
        
        screen = CGRectMake(0, 0, size.width, size.height);
        
        time = 0;
        
        [background runAction:_titleAnimAction];
        
        [TestFlight passCheckpoint:@"Title Screen"];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    //CGSize size = [[CCDirector sharedDirector] winSize];
    time++;
#ifdef DEBUG
#else
    if(abs((time/60)-1.6) < .01){
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu 2.wav" loop:YES];
    }
#endif
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
}

- (void)switchSceneStart{
    NSInteger introDone = [standardUserDefaults integerForKey:@"introDone"];
    CCLOG(@"introDone: %d", introDone);
    if(introDone == 1)
        [[CCDirector sharedDirector] replaceScene:[GameplayLayer scene]];
    else if(introDone == 0){
        [[CCDirector sharedDirector] replaceScene:[TutorialLayer scene]];
    }
}

- (void)switchSceneOptions{
    [[CCDirector sharedDirector] replaceScene:[OptionsLayer scene]];
}

-(void) dealloc{
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    //[[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [super dealloc];
}

@end