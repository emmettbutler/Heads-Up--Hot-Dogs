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
#import "UIDefs.h"

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
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"trophy_%@", lp->slug]];
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
    sprite.scale = 1.4*scale;
    [scoresLayer addChild:sprite z:81];
    
    float fontSize = 25.0*scale;
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Clear Scores" fontName:@"LostPet.TTF" fontSize:fontSize-2];
    label.color = _color_pink;
    CCMenuItem *pauseTitle = [CCMenuItemLabel itemWithLabel:label];
    pauseTitle.position = ccp((sprite.position.x+3), winSize.height*.82);
    [scoresLayer addChild:pauseTitle z:81];
    
    label = [CCLabelTTF labelWithString:@"WARNING" fontName:@"LostPet.TTF" fontSize:fontSize+5];
    label.color = _color_pink;
    CCMenuItem *warnItem = [CCMenuItemLabel itemWithLabel:label];
    
    label = [CCLabelTTF labelWithString:@"This will clear all saved scores" fontName:@"LostPet.TTF" fontSize:fontSize];
    label.color = _color_pink;
    CCMenuItem *warnItem2 = [CCMenuItemLabel itemWithLabel:label];
    
    label = [CCLabelTTF labelWithString:@"on this device. Are you sure?" fontName:@"LostPet.TTF" fontSize:fontSize];
    label.color = _color_pink;
    CCMenuItem *warnItem3 = [CCMenuItemLabel itemWithLabel:label];
    
    label = [CCLabelTTF labelWithString:@"YES!" fontName:@"LostPet.TTF" fontSize:fontSize+8];
    label.color = _color_pink;
    CCMenuItem *confirm = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(deleteScores)];
    
    CCSprite *bSprite = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
    bSprite.position = ccp(winSize.width/2, winSize.height*.36);
    bSprite.scaleY = 1.5*scale;
    bSprite.scaleX = .7*scale;
    [[bSprite texture] setAliasTexParameters];
    [scoresLayer addChild:bSprite z:81];
    
    CCMenu *scoresMenu = [CCMenu menuWithItems: warnItem, warnItem2, warnItem3, confirm, nil];
    [scoresMenu setPosition:ccp(sprite.position.x, winSize.height/2-10)];
    [scoresMenu alignItemsVerticallyWithPadding:5*scale];
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
    sprite.scale = 1.4*scale;
    [creditsLayer addChild:sprite z:81];
    
    float fontSize = 24.0*scale;
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Credits" fontName:@"LostPet.TTF" fontSize:fontSize+3];
    label.color = _color_pink;
    CCMenuItem *pauseTitle = [CCMenuItemLabel itemWithLabel:label];
    pauseTitle.position = ccp((sprite.position.x), winSize.height*.82);
    [creditsLayer addChild:pauseTitle z:81];
    
    label = [CCLabelTTF labelWithString:@"Sugoi Papa Interactive:" fontName:@"LostPet.TTF" fontSize:fontSize+3];
    label.color = _color_pink;
    CCMenuItem *teamItem = [CCMenuItemLabel itemWithLabel:label];
    
    label = [CCLabelTTF labelWithString:@"Diego Garcia" fontName:@"LostPet.TTF" fontSize:fontSize];
    label.color = _color_pink;
    CCMenuItem *diegoItem = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(diegoSocial)];
    
    label = [CCLabelTTF labelWithString:@"design & art" fontName:@"LostPet.TTF" fontSize:fontSize-3];
    label.color = _color_pink;
    CCMenuItem *diegoItem2 = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(diegoSocial)];
    
    label = [CCLabelTTF labelWithString:@"Emmett Butler" fontName:@"LostPet.TTF" fontSize:fontSize-3];
    label.color = _color_pink;
    CCMenuItem *emmettItem = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(emmettSocial)];
    
    label = [CCLabelTTF labelWithString:@"design & program" fontName:@"LostPet.TTF" fontSize:fontSize-3];
    label.color = _color_pink;
    CCMenuItem *emmettItem2 = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(emmettSocial)];
    
    label = [CCLabelTTF labelWithString:@"Music:" fontName:@"LostPet.TTF" fontSize:fontSize+3];
    label.color = _color_pink;
    CCMenuItem *musicItem = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(emmettSocial)];
    
    label = [CCLabelTTF labelWithString:@"Luke Silas/Ben Carignan" fontName:@"LostPet.TTF" fontSize:fontSize];
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
        scale = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scale = IPAD_SCALE_FACTOR_X;
        }
        
        [[Clouds alloc] initWithLayer:[NSValue valueWithPointer:self]];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_common.plist"];
        spriteSheetCommon = [CCSpriteBatchNode batchNodeWithFile:@"sprites_common.png"];
        [self addChild:spriteSheetCommon];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        background.anchorPoint = CGPointZero;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            background.scaleX = IPAD_SCALE_FACTOR_X;
            background.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [self addChild:background z:-1];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Options_Overlay.png"];
        sprite.position = ccp(winSize.width/2, winSize.height*.57);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            sprite.scaleX = IPAD_SCALE_FACTOR_X;
            sprite.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [self addChild:sprite];
        
        float fontSize = 22.0*scale;
        
        CCSprite *siteButton = [CCSprite spriteWithSpriteFrameName:@"Options_Btn.png"];
        siteButton.position = ccp(winSize.width/2, winSize.height*.7);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            siteButton.scaleX = IPAD_SCALE_FACTOR_X;
            siteButton.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [[siteButton texture] setAliasTexParameters];
        [self addChild:siteButton z:10];
        _siteRect = CGRectMake((siteButton.position.x-(siteButton.scaleX*siteButton.contentSize.width)/2), (siteButton.position.y-(siteButton.scaleY*siteButton.contentSize.height)/2), (siteButton.scaleX*siteButton.contentSize.width+10), (siteButton.scaleY*siteButton.contentSize.height+10));
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Official Site" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(siteButton.position.x, siteButton.position.y-1);
        [self addChild:label z:11];
        
        CCSprite *creditsButton = [CCSprite spriteWithSpriteFrameName:@"Options_Btn.png"];
        creditsButton.position = ccp(winSize.width/2, winSize.height*.55);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            creditsButton.scaleX = IPAD_SCALE_FACTOR_X;
            creditsButton.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [[creditsButton texture] setAliasTexParameters];
        [self addChild:creditsButton z:10];
        _creditsRect = CGRectMake((creditsButton.position.x-(creditsButton.scaleX*creditsButton.contentSize.width)/2), (creditsButton.position.y-(creditsButton.scaleY*creditsButton.contentSize.height)/2), (creditsButton.scaleX*creditsButton.contentSize.width+10), (creditsButton.scaleY*creditsButton.contentSize.height+10));
        label = [CCLabelTTF labelWithString:@"Credits" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(creditsButton.position.x, creditsButton.position.y-1);
        [self addChild:label z:11];
        
        CCSprite *scoresButton = [CCSprite spriteWithSpriteFrameName:@"Options_Btn.png"];
        scoresButton.position = ccp(winSize.width/2, winSize.height*.40);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scoresButton.scaleX = IPAD_SCALE_FACTOR_X;
            scoresButton.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [[scoresButton texture] setAliasTexParameters];
        [self addChild:scoresButton z:10];
        _scoresRect = CGRectMake((scoresButton.position.x-(scoresButton.scaleX*scoresButton.contentSize.width)/2), (scoresButton.position.y-(scoresButton.scaleY*scoresButton.contentSize.height)/2), (scoresButton.scaleX*scoresButton.contentSize.width+10), (scoresButton.scaleY*scoresButton.contentSize.height+10));
        label = [CCLabelTTF labelWithString:@"Clear Scores" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(scoresButton.position.x, scoresButton.position.y-1);
        [self addChild:label z:11];
        
        CCSprite *sfxButton = [CCSprite spriteWithSpriteFrameName:@"Options_Btn.png"];
        sfxButton.position = ccp(winSize.width/2, winSize.height*.25);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            sfxButton.scaleX = IPAD_SCALE_FACTOR_X;
            sfxButton.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [[sfxButton texture] setAliasTexParameters];
        [self addChild:sfxButton z:10];
        _sfxRect = CGRectMake((sfxButton.position.x-(sfxButton.scaleX*sfxButton.contentSize.width)/2), (sfxButton.position.y-(sfxButton.scaleY*sfxButton.contentSize.height)/2), (sfxButton.scaleX*sfxButton.contentSize.width+10), (sfxButton.scaleY*sfxButton.contentSize.height+10));
        if(sfxOn)
            sfxLabel = [CCLabelTTF labelWithString:@"SFX on" fontName:@"LostPet.TTF" fontSize:fontSize];
        else
            sfxLabel = [CCLabelTTF labelWithString:@"SFX off" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[sfxLabel texture] setAliasTexParameters];
        sfxLabel.color = _color_pink;
        sfxLabel.position = ccp(sfxButton.position.x, sfxButton.position.y-1);
        [self addChild:sfxLabel z:11];
        
        CCSprite *button1 = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        button1.scale = scale;
        button1.position = ccp(winSize.width/4, button1.contentSize.height*button1.scaleY);
        [[button1 texture] setAliasTexParameters];
        [self addChild:button1 z:10];
        label = [CCLabelTTF labelWithString:@"Start" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(button1.position.x, button1.position.y-1);
        [self addChild:label z:11];
        _startRect = CGRectMake((button1.position.x-(button1.contentSize.width*button1.scaleX)/2), (button1.position.y-(button1.contentSize.height*button1.scaleY)/2), (button1.contentSize.width*button1.scaleX+70), (button1.contentSize.height*button1.scaleY+70));
        
        CCSprite *button2 = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        button2.scale = scale;
        button2.position = ccp(3*(winSize.width/4), button1.contentSize.height*button1.scaleY);
        [[button2 texture] setAliasTexParameters];
        [self addChild:button2 z:10];
        CCLabelTTF *otherLabel = [CCLabelTTF labelWithString:@"Title" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[otherLabel texture] setAliasTexParameters];
        otherLabel.color = _color_pink;
        otherLabel.position = ccp(button2.position.x, button2.position.y-1);
        [self addChild:otherLabel z:11];
        _titleRect = CGRectMake((button2.position.x-(button2.contentSize.width*button2.scaleX)/2), (button2.position.y-(button2.contentSize.height*button2.scaleY)/2), (button2.contentSize.width*button2.scaleX+70), (button2.contentSize.height*button2.scaleY+70));
        
        [TestFlight passCheckpoint:@"Options Screen"];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
}

- (void)switchSceneStart{
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