//
//  OptionsLayer.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "GameplayLayer.h"
#import "TitleScene.h"
#import "OptionsLayer.h"
#import "TestFlight.h"
#import "LevelSelectLayer.h"
#import "TutorialLayer.h"

#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation OptionsLayer

+(CCScene *) scene{
	CCScene *scene = [CCScene node];
    CCLOG(@"in scenewithData");
	OptionsLayer *layer;
    layer = [OptionsLayer node];
	[scene addChild:layer];
	return scene;
}

-(void)openHomepage{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://headsuphotdogs.com"]];
}

-(void)diegoSocial{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://radstronomical.com"]];
}

-(void)emmettSocial{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://emmettbutler.com"]];
}

-(void)playTutorial{
    [[CCDirector sharedDirector] replaceScene:[TutorialLayer sceneWithFrom:@"options"]];
}

-(void)showCredits{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    credits = true;
    
    creditsLayer = [CCLayerColor layerWithColor:ccc4(190, 190, 190, 0) width:winSize.width height:winSize.height];
    creditsLayer.anchorPoint = CGPointZero;
    [self addChild:creditsLayer z:80];
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Pause_BG.png"];
    sprite.position = ccp(winSize.width/2, winSize.height/2);
    sprite.scale = 1.4;
    [creditsLayer addChild:sprite z:81];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Credits" fontName:@"LostPet.TTF" fontSize:27.0];
    label.color = _color_pink;
    CCMenuItem *pauseTitle = [CCMenuItemLabel itemWithLabel:label];
    pauseTitle.position = ccp((sprite.position.x+3), (sprite.position.y+sprite.contentSize.height/2)-4);
    [creditsLayer addChild:pauseTitle z:81];
    
    label = [CCLabelTTF labelWithString:@"Sugoi Papa Interactive:" fontName:@"LostPet.TTF" fontSize:27.0];
    label.color = _color_pink;
    CCMenuItem *teamItem = [CCMenuItemLabel itemWithLabel:label];
    
    label = [CCLabelTTF labelWithString:@"Diego Garcia" fontName:@"LostPet.TTF" fontSize:24.0];
    label.color = _color_pink;
    CCMenuItem *diegoItem = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(diegoSocial)];
    
    label = [CCLabelTTF labelWithString:@"design & art" fontName:@"LostPet.TTF" fontSize:21.0];
    label.color = _color_pink;
    CCMenuItem *diegoItem2 = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(diegoSocial)];
    
    label = [CCLabelTTF labelWithString:@"Emmett Butler" fontName:@"LostPet.TTF" fontSize:24.0];
    label.color = _color_pink;
    CCMenuItem *emmettItem = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(emmettSocial)];
    
    label = [CCLabelTTF labelWithString:@"design & program" fontName:@"LostPet.TTF" fontSize:21.0];
    label.color = _color_pink;
    CCMenuItem *emmettItem2 = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(emmettSocial)];
    
    label = [CCLabelTTF labelWithString:@"Music:" fontName:@"LostPet.TTF" fontSize:24.0];
    label.color = _color_pink;
    CCMenuItem *musicItem = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(emmettSocial)];
    
    label = [CCLabelTTF labelWithString:@"Luke Silas/Ben Carignan" fontName:@"LostPet.TTF" fontSize:21.0];
    label.color = _color_pink;
    CCMenuItem *musicItem2 = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(emmettSocial)];
    
    CCMenu *creditsMenu = [CCMenu menuWithItems: teamItem, diegoItem, diegoItem2, emmettItem, emmettItem2, musicItem, musicItem2, nil];
    [creditsMenu setPosition:ccp(sprite.position.x, winSize.height/2-10)];
    [creditsMenu alignItemsVerticallyWithPadding:5];
    [creditsLayer addChild:creditsMenu z:81];
}

-(id) init{
    if ((self = [super init])){
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled = true;
        
        _color_pink = ccc3(255, 62, 166);
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spriteSheet];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_common.plist"];
        spriteSheetCommon = [CCSpriteBatchNode batchNodeWithFile:@"sprites_common.png"];
        [self addChild:spriteSheetCommon];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"blank_bg.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"OPTIONS" fontName:@"LostPet.TTF" fontSize:50.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(winSize.width/2, winSize.height-(label.contentSize.height/2)+10);
        [self addChild:label];
        
        CCSprite *siteButton = [CCSprite spriteWithSpriteFrameName:@"Steak.png"];
        siteButton.position = ccp(90, 230);
        siteButton.scale = 1.5;
        [self addChild:siteButton z:10];
        _siteRect = CGRectMake((siteButton.position.x-(siteButton.contentSize.width)/2), (siteButton.position.y-(siteButton.contentSize.height)/2), (siteButton.contentSize.width+10), (siteButton.contentSize.height+10));
        label = [CCLabelTTF labelWithString:@"Official Site" fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *b = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(openHomepage)];
        CCMenu *m = [CCMenu menuWithItems:b, nil];
        [m setPosition:ccp(90, 200)];
        [self addChild:m z:11];
        
        CCSprite *creditsButton = [CCSprite spriteWithSpriteFrameName:@"Bagel.png"];
        creditsButton.position = ccp(190, 230);
        creditsButton.scale = 1.5;
        [self addChild:creditsButton z:10];
        _creditsRect = CGRectMake((creditsButton.position.x-(creditsButton.contentSize.width)/2), (creditsButton.position.y-(creditsButton.contentSize.height)/2), (creditsButton.contentSize.width+10), (creditsButton.contentSize.height+10));
        label = [CCLabelTTF labelWithString:@"Credits" fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        b = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(showCredits)];
        m = [CCMenu menuWithItems:b, nil];
        [m setPosition:ccp(190, 200)];
        [self addChild:m z:11];
        
        CCSprite *tutorialButton = [CCSprite spriteWithSpriteFrameName:@"YakisobaPan.png"];
        tutorialButton.position = ccp(290, 230);
        tutorialButton.scale = 1.5;
        [self addChild:tutorialButton z:10];
        _tutRect = CGRectMake((tutorialButton.position.x-(tutorialButton.contentSize.width)/2), (tutorialButton.position.y-(tutorialButton.contentSize.height)/2), (tutorialButton.contentSize.width+10), (tutorialButton.contentSize.height+10));
        label = [CCLabelTTF labelWithString:@"Tutorial" fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        b = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(playTutorial)];
        m = [CCMenu menuWithItems:b, nil];
        [m setPosition:ccp(290, 200)];
        [self addChild:m z:11];
        
        CCSprite *restartButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        restartButton.position = ccp(110, 27);
        [self addChild:restartButton z:10];
        label = [CCLabelTTF labelWithString:@"     Start     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneStart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 26)];
        [self addChild:menu z:11];
        
        CCSprite *quitButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        quitButton.position = ccp(370, 27);
        [self addChild:quitButton z:10];
        label = [CCLabelTTF labelWithString:@"     Title     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneTitleScreen)];
        menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(370, 26)];
        [self addChild:menu z:11];
        
        [TestFlight passCheckpoint:@"Options Screen"];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
}

- (void)switchSceneStart{
    NSInteger introDone = [standardUserDefaults integerForKey:@"introDone"];
    CCLOG(@"introDone: %d", introDone);
    if(introDone == 1)
        [[CCDirector sharedDirector] replaceScene:[LevelSelectLayer scene]];
    else if(introDone == 0){
        [[CCDirector sharedDirector] replaceScene:[TutorialLayer sceneWithFrom:@"title"]];
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation1 = [touch locationInView: [touch view]];
    touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
    
    if(credits){
        credits = false;
        [self removeChild:creditsLayer cleanup:YES];
        return;
    }
    
    if(CGRectContainsPoint(_siteRect, touchLocation1)){
        [self openHomepage];
    } else if(CGRectContainsPoint(_creditsRect, touchLocation1)){
        [self showCredits];
    } else if(CGRectContainsPoint(_tutRect, touchLocation1)){
        [self playTutorial];
    }
}

- (void)switchSceneTitleScreen{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

-(void) dealloc{
    [super dealloc];
}

@end