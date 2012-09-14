//
//  TitleScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "TitleScene.h"
#import "GameplayLayer.h"
#import "OptionsLayer.h"
#import "TestFlight.h"
#import "LevelSelectLayer.h"
#import "Clouds.h"

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
        NSInteger introDone = [[NSUserDefaults standardUserDefaults] integerForKey:@"introDone"];
        if(!introDone){
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"sfxon"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [TestFlight passCheckpoint:@"Title Screen"];
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
        
        [[Clouds alloc] initWithLayer:[NSValue valueWithPointer:self]];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spriteSheet];
        
        // color definitions
        _color_pink = ccc3(255, 62, 166);
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"GOLD CANDIDATE 1" fontName:@"LostPet.TTF" fontSize:30.0];
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
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean-hd.png"];
        } else {
            background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        }
        background.anchorPoint = CGPointZero;
        [self addChild:background z:-10];
        
        dogLogo = [CCSprite spriteWithSpriteFrameName:@"HotDogs.png"];
        dogLogo.position = ccp(size.width/2, size.height + 100);
        [spriteSheet addChild:dogLogo];
        dogLogoAnchor = CGPointMake(dogLogo.position.x, size.height/2-20);
        
        swooshLogo = [CCSprite spriteWithSpriteFrameName:@"HeadsUp.png"];
        swooshLogo.position = ccp(-1*(swooshLogo.contentSize.width), size.height/2+80);
        [spriteSheet addChild:swooshLogo];
        
        [swooshLogo runAction:[CCMoveTo actionWithDuration:.4 position:CGPointMake(size.width/2, swooshLogo.position.y)]];
        [dogLogo runAction:[CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:.6 position:dogLogoAnchor] rate:.5]];
        
        NSLog(@"width: %0.2f", [CCDirector sharedDirector].winSize.width);
        NSLog(@"height: %0.2f", [CCDirector sharedDirector].winSize.height);
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    //CGSize size = [[CCDirector sharedDirector] winSize];
    time++;
    
    if([dogLogo numberOfRunningActions] == 0)
        dogLogo.position = CGPointMake(dogLogo.position.x, dogLogoAnchor.y + (5 * sinf(time * .03)));
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
    [[CCDirector sharedDirector] replaceScene:[LevelSelectLayer scene]];
}

- (void)switchSceneOptions{
    [[CCDirector sharedDirector] replaceScene:[OptionsLayer scene]];
}

-(void) dealloc{
    [super dealloc];
}

@end