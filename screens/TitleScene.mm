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
#import "UIDefs.h"

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
        winSize = [[CCDirector sharedDirector] winSize];
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
        dlabel.position = ccp(winSize.width-(dlabel.contentSize.width/2)-6, winSize.height-(dlabel.contentSize.height/2)-5);
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
        label.position = ccp((label.contentSize.width/2)+6, winSize.height-(label.contentSize.height/2)-5);
        [self addChild:label];

        CCSprite *button1 = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        button1.position = ccp(winSize.width/4, button1.contentSize.height);
        [self addChild:button1 z:10];
        label = [CCLabelTTF labelWithString:@"Start" fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(button1.position.x, button1.position.y-1);
        [self addChild:label z:11];
        _startRect = CGRectMake((button1.position.x-(button1.contentSize.width*button1.scaleX)/2), (button1.position.y-(button1.contentSize.height*button1.scaleY)/2), (button1.contentSize.width*button1.scaleX+70), (button1.contentSize.height*button1.scaleY+70));
        
        CCSprite *button2 = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        button2.position = ccp(3*(winSize.width/4), button1.contentSize.height);
        [self addChild:button2 z:10];
        CCLabelTTF *otherLabel = [CCLabelTTF labelWithString:@"Options" fontName:@"LostPet.TTF" fontSize:22.0];
        [[otherLabel texture] setAliasTexParameters];
        otherLabel.color = _color_pink;
        otherLabel.position = ccp(button2.position.x, button2.position.y-1);
        [self addChild:otherLabel z:11];
        _optionsRect = CGRectMake((button2.position.x-(button2.contentSize.width*button2.scaleX)/2), (button2.position.y-(button2.contentSize.height*button2.scaleY)/2), (button2.contentSize.width*button2.scaleX+70), (button2.contentSize.height*button2.scaleY+70));
        
        // TODO - stub for eventual placement of ASG more games button
        _moreGamesRect = CGRectMake(0, 0, 0, 0);
        
        background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        background.anchorPoint = CGPointZero;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            background.scaleX = IPAD_SCALE_FACTOR_X;
            background.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [self addChild:background z:-10];
        
        dogLogo = [CCSprite spriteWithSpriteFrameName:@"HotDogs.png"];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            dogLogo.scale = 2;
        }
        dogLogo.position = ccp(winSize.width/2, winSize.height+100);
        [spriteSheet addChild:dogLogo];
        dogLogoAnchor = CGPointMake(dogLogo.position.x, 4*(winSize.height/10));
        
        swooshLogo = [CCSprite spriteWithSpriteFrameName:@"HeadsUp.png"];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            swooshLogo.scale = 2;
        }
        swooshLogo.position = ccp(-1*(swooshLogo.contentSize.width), 15*(winSize.height/20));
        [spriteSheet addChild:swooshLogo];
        
        [swooshLogo runAction:[CCMoveTo actionWithDuration:.4 position:CGPointMake(winSize.width/2, swooshLogo.position.y)]];
        [dogLogo runAction:[CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:.6 position:dogLogoAnchor] rate:.5]];
        
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

-(void)showASGMoreGamesView{
    myController = [[UIViewController alloc] init];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                            target:self
                                                                            action:@selector(dismissASGMoreGamesView:)];
    [[myController navigationItem] setRightBarButtonItem:button];
    
    [button release];
    
    CGRect frame = CGRectMake(0, 0, winSize.width, winSize.height);
    
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:frame];
    frame.size = [navBar sizeThatFits:frame.size];
	[navBar setFrame:frame];
	[navBar setItems:[NSArray arrayWithObject:myController.navigationItem]];
    
	[myController.view addSubview:navBar];
    
    CGRect webFrame = CGRectMake(0, frame.size.height, winSize.width, winSize.height-40);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webFrame];
    webView.backgroundColor = [UIColor whiteColor];
    [webView setOpaque:NO];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://games.adultswim.com/mobile/index.html?cid=iphone_heads_up_hot_dogs_moregames&app=true"]]];
    [myController.view addSubview:webView];
    
    [[[CCDirector sharedDirector] openGLView] addSubview:myController.view];
}

-(void)dismissASGMoreGamesView:(id)sender{
    [myController.view removeFromSuperview];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if(CGRectContainsPoint(_startRect, location)){
        [self switchSceneStart];
    } else if(CGRectContainsPoint(_optionsRect, location)){
        [self switchSceneOptions];
    } else if(CGRectContainsPoint(_moreGamesRect, location)){
        [self showASGMoreGamesView];
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
    [myController release];
    [super dealloc];
}

@end