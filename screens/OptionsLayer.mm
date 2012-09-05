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
#import "Clouds.h"

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

-(void)flipSFX{
    if(!sfxOn){
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"sfxon"];
        [sfxLabel setString:@"SFX on"];
        sfxOn = 1;
#ifdef DEBUG
#else
        [[SimpleAudioEngine sharedEngine] playEffect:@"pause 3.mp3"];
#endif
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"sfxon"];
        [sfxLabel setString:@"SFX off"];
        sfxOn = 0;
    }
    [[sfxLabel texture] setAliasTexParameters];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)deleteScores{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    NSMutableArray *lStructs = [LevelSelectLayer buildLevels:[NSNumber numberWithInt:0]];
    for(NSValue *v in lStructs){
        levelProps *lp = (levelProps *)[v pointerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"highScore%@", lp->slug]];
    }
    [standardUserDefaults synchronize];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Scores cleared!" fontName:@"LostPet.TTF" fontSize:30.0];
    label.color = _color_pink;
    label.position = ccp(winSize.width/2, 70);
    [scoresLayer addChild:label z:100];
    lStructs = nil;
}

-(void)clearScoresWindow{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    scores = true;
    
    scoresLayer = [CCLayerColor layerWithColor:ccc4(190, 190, 190, 0) width:winSize.width height:winSize.height];
    scoresLayer.anchorPoint = CGPointZero;
    [self addChild:scoresLayer z:80];
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Pause_BG.png"];
    sprite.position = ccp(winSize.width/2, winSize.height/2);
    sprite.scale = 1.4;
    [scoresLayer addChild:sprite z:81];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Clear Scores" fontName:@"LostPet.TTF" fontSize:23.0];
    label.color = _color_pink;
    CCMenuItem *pauseTitle = [CCMenuItemLabel itemWithLabel:label];
    pauseTitle.position = ccp((sprite.position.x+3), (sprite.position.y+sprite.contentSize.height/2)+11);
    [scoresLayer addChild:pauseTitle z:81];
    
    label = [CCLabelTTF labelWithString:@"WARNING" fontName:@"LostPet.TTF" fontSize:30.0];
    label.color = _color_pink;
    CCMenuItem *warnItem = [CCMenuItemLabel itemWithLabel:label];
    
    label = [CCLabelTTF labelWithString:@"This will clear all saved scores" fontName:@"LostPet.TTF" fontSize:25.0];
    label.color = _color_pink;
    CCMenuItem *warnItem2 = [CCMenuItemLabel itemWithLabel:label];
    
    label = [CCLabelTTF labelWithString:@"on this device. Are you sure?" fontName:@"LostPet.TTF" fontSize:25.0];
    label.color = _color_pink;
    CCMenuItem *warnItem3 = [CCMenuItemLabel itemWithLabel:label];
    
    label = [CCLabelTTF labelWithString:@"YES!" fontName:@"LostPet.TTF" fontSize:33.0];
    label.color = _color_pink;
    CCMenuItem *confirm = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(deleteScores)];
    
    CCSprite *bSprite = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
    bSprite.position = ccp(winSize.width/2, 105);
    bSprite.scaleY = 1.5;
    bSprite.scaleX = .7;
    [[bSprite texture] setAliasTexParameters];
    [scoresLayer addChild:bSprite z:81];
    
    CCMenu *scoresMenu = [CCMenu menuWithItems: warnItem, warnItem2, warnItem3, confirm, nil];
    [scoresMenu setPosition:ccp(sprite.position.x, winSize.height/2-10)];
    [scoresMenu alignItemsVerticallyWithPadding:5];
    [scoresLayer addChild:scoresMenu z:81];
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
    pauseTitle.position = ccp((sprite.position.x+3), (sprite.position.y+sprite.contentSize.height/2)+8);
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
    
    label = [CCLabelTTF labelWithString:@"Music:" fontName:@"LostPet.TTF" fontSize:27.0];
    label.color = _color_pink;
    CCMenuItem *musicItem = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(emmettSocial)];
    
    label = [CCLabelTTF labelWithString:@"Luke Silas/Ben Carignan" fontName:@"LostPet.TTF" fontSize:24.0];
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
        sfxOn = [[NSUserDefaults standardUserDefaults] integerForKey:@"sfxon"];
        self.isTouchEnabled = true;
        
        _color_pink = ccc3(255, 62, 166);
        
        float imgScale = 1.8;
        
        [[Clouds alloc] initWithLayer:[NSValue valueWithPointer:self]];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_common.plist"];
        spriteSheetCommon = [CCSpriteBatchNode batchNodeWithFile:@"sprites_common.png"];
        [self addChild:spriteSheetCommon];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"OPTIONS" fontName:@"LostPet.TTF" fontSize:50.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(winSize.width/2, winSize.height-(label.contentSize.height/2)-5);
        [self addChild:label];
        
        CCSprite *siteButton = [CCSprite spriteWithSpriteFrameName:@"Steak.png"];
        siteButton.position = ccp(170, 230);
        siteButton.scale = imgScale;
        [[siteButton texture] setAliasTexParameters];
        [self addChild:siteButton z:10];
        _siteRect = CGRectMake((siteButton.position.x-(siteButton.contentSize.width)/2), (siteButton.position.y-(siteButton.contentSize.height)/2), (siteButton.contentSize.width+10), (siteButton.contentSize.height+10));
        label = [CCLabelTTF labelWithString:@"Official Site" fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *b = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(openHomepage)];
        CCMenu *m = [CCMenu menuWithItems:b, nil];
        [m setPosition:ccp(170, 190)];
        [self addChild:m z:11];
        
        CCSprite *creditsButton = [CCSprite spriteWithSpriteFrameName:@"Bagel.png"];
        creditsButton.position = ccp(320, 230);
        creditsButton.scale = imgScale;
        [[creditsButton texture] setAliasTexParameters];
        [self addChild:creditsButton z:10];
        _creditsRect = CGRectMake((creditsButton.position.x-(creditsButton.contentSize.width)/2), (creditsButton.position.y-(creditsButton.contentSize.height)/2), (creditsButton.contentSize.width+10), (creditsButton.contentSize.height+10));
        label = [CCLabelTTF labelWithString:@"Credits" fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        b = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(showCredits)];
        m = [CCMenu menuWithItems:b, nil];
        [m setPosition:ccp(320, 190)];
        [self addChild:m z:11];
        
        CCSprite *scoresButton = [CCSprite spriteWithSpriteFrameName:@"Taco.png"];
        scoresButton.position = ccp(170, 130);
        scoresButton.scale = imgScale;
        [[scoresButton texture] setAliasTexParameters];
        [self addChild:scoresButton z:10];
        _scoresRect = CGRectMake((scoresButton.position.x-(scoresButton.contentSize.width)/2), (scoresButton.position.y-(scoresButton.contentSize.height)/2), (scoresButton.contentSize.width+10), (scoresButton.contentSize.height+10));
        label = [CCLabelTTF labelWithString:@"Clear Scores" fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        b = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(clearScoresWindow)];
        m = [CCMenu menuWithItems:b, nil];
        [m setPosition:ccp(170, 90)];
        [self addChild:m z:11];
        
        CCSprite *sfxButton = [CCSprite spriteWithSpriteFrameName:@"ChiDog.png"];
        sfxButton.position = ccp(320, 130);
        sfxButton.scale = imgScale;
        [[sfxButton texture] setAliasTexParameters];
        [self addChild:sfxButton z:10];
        _sfxRect = CGRectMake((sfxButton.position.x-(sfxButton.contentSize.width)/2), (sfxButton.position.y-(sfxButton.contentSize.height)/2), (sfxButton.contentSize.width+10), (sfxButton.contentSize.height+10));
        if(sfxOn)
            sfxLabel = [CCLabelTTF labelWithString:@"SFX on" fontName:@"LostPet.TTF" fontSize:22.0];
        else
            sfxLabel = [CCLabelTTF labelWithString:@"SFX off" fontName:@"LostPet.TTF" fontSize:22.0];
        [[sfxLabel texture] setAliasTexParameters];
        sfxLabel.color = _color_pink;
        b = [CCMenuItemLabel itemWithLabel:sfxLabel target:self selector:@selector(flipSFX)];
        m = [CCMenu menuWithItems:b, nil];
        [m setPosition:ccp(320, 90)];
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
        _startRect = CGRectMake((restartButton.position.x-(restartButton.contentSize.width)/2), (restartButton.position.y-(restartButton.contentSize.height)/2), (restartButton.contentSize.width+20), (restartButton.contentSize.height+20));
        
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
        _titleRect = CGRectMake((quitButton.position.x-(quitButton.contentSize.width)/2), (quitButton.position.y-(quitButton.contentSize.height)/2), (quitButton.contentSize.width+20), (quitButton.contentSize.height+20));
        
        [TestFlight passCheckpoint:@"Options Screen"];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
}

- (void)switchSceneStart{
    NSInteger introDone = [[NSUserDefaults standardUserDefaults] integerForKey:@"introDone"];
    CCLOG(@"introDone: %d", introDone);
    [[CCDirector sharedDirector] replaceScene:[LevelSelectLayer scene]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation1 = [touch locationInView: [touch view]];
    touchLocation1 = [[CCDirector sharedDirector] convertToGL: touchLocation1];
    
    if(credits){
        credits = false;
        [self removeChild:creditsLayer cleanup:YES];
        return;
    } else if(scores){
        scores = false;
        [self removeChild:scoresLayer cleanup:YES];
        return;
    }
    
    if(CGRectContainsPoint(_siteRect, touchLocation1)){
        [self openHomepage];
    } else if(CGRectContainsPoint(_creditsRect, touchLocation1)){
        [self showCredits];
    } else if(CGRectContainsPoint(_scoresRect, touchLocation1)){
        [self clearScoresWindow];
    } else if(CGRectContainsPoint(_sfxRect, touchLocation1)){
        [self flipSFX];
    } else if(CGRectContainsPoint(_startRect, touchLocation1)){
        [self switchSceneStart];
    } else if(CGRectContainsPoint(_titleRect, touchLocation1)){
        [self switchSceneTitleScreen];
    }
}

- (void)switchSceneTitleScreen{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

-(void) dealloc{
    [super dealloc];
}

@end