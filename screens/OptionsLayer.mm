//
//  OptionsLayer.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "GameplayLayer.h"
#import "TitleScene.h"
#import "OptionsLayer.h"
#import "LevelSelectLayer.h"
#import "Clouds.h"
#import "UIDefs.h"
#import "HotDogManager.h"

#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation OptionsLayer

+(CCScene *) scene{
	CCScene *scene = [CCScene node];
	OptionsLayer *layer;
    layer = [OptionsLayer node];
	[scene addChild:layer];
	return scene;
}

-(void)openHomepage{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://headsuphotdogs.com"]];
    [[HotDogManager sharedManager] customEvent:@"official_site_clicked" st1:@"options" st2:NULL level:NULL value:NULL data:NULL];
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
        [[HotDogManager sharedManager] customEvent:@"sfx_turned_on" st1:@"options" st2:NULL level:NULL value:NULL data:NULL];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"sfxon"];
        [sfxLabel setString:@"SFX off"];
        sfxOn = 0;
        [[HotDogManager sharedManager] customEvent:@"sfx_turned_off" st1:@"options" st2:NULL level:NULL value:NULL data:NULL];
    }
    [[sfxLabel texture] setAliasTexParameters];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)deleteScores{
    NSMutableArray *lStructs = [LevelSelectLayer buildLevels:[NSNumber numberWithInt:0]];
    for(NSValue *v in lStructs){
        levelProps *lp = (levelProps *)[v pointerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"highScore%@", lp->slug]];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"unlocked%@", lp->slug]];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"trophy_%@", lp->slug]];
    }
    [standardUserDefaults synchronize];
    
    float fontSize = 30.0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        fontSize *= IPAD_SCALE_FACTOR_X;
    }
    
#ifdef DEBUG
#else
    [[SimpleAudioEngine sharedEngine] playEffect:@"pause 3.mp3"];
#endif
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Done!" fontName:@"LostPet.TTF" fontSize:fontSize];
    label.color = _color_pink;
    label.position = ccp(yesButton.position.x+yesButton.contentSize.width/2*yesButton.scaleX*1.5, yesButton.position.y);
    [[label texture] setAliasTexParameters];
    [scoresLayer addChild:label z:100];
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
    pauseTitle.position = ccp((sprite.position.x+3), winSize.height*.817);
    [scoresLayer addChild:pauseTitle z:81];
    
    label = [CCLabelTTF labelWithString:@"WARNING: This will delete all saved scores and unlocked levels on this device. Are you sure you'd like to continue?" dimensions:CGSizeMake(sprite.contentSize.width*sprite.scaleX*.9, sprite.contentSize.height*sprite.scaleY*.6) alignment:UITextAlignmentCenter fontName:@"LostPet.TTF" fontSize:fontSize];
    label.color = _color_pink;
    label.position = ccp(sprite.position.x, sprite.position.y);
    [scoresLayer addChild:label z:81];
    
    yesButton = [CCSprite spriteWithSpriteFrameName:@"Options_Btn.png"];
    yesButton.position = ccp(winSize.width/2, sprite.position.y*.65);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        yesButton.scaleX = IPAD_SCALE_FACTOR_X;
        yesButton.scaleY = IPAD_SCALE_FACTOR_Y;
    }
    [[yesButton texture] setAliasTexParameters];
    [scoresLayer addChild:yesButton z:81];
    _clearScoresRect = CGRectMake((yesButton.position.x-(yesButton.scaleX*yesButton.contentSize.width)/2), (yesButton.position.y-(yesButton.scaleY*yesButton.contentSize.height)/2), (yesButton.scaleX*yesButton.contentSize.width+10), (yesButton.scaleY*yesButton.contentSize.height+10));
    label = [CCLabelTTF labelWithString:@"YES" fontName:@"LostPet.TTF" fontSize:fontSize];
    [[label texture] setAliasTexParameters];
    label.color = _color_pink;
    label.position = ccp(yesButton.position.x, yesButton.position.y-1);
    [scoresLayer addChild:label z:82];
    
    CCSprite *noButton = [CCSprite spriteWithSpriteFrameName:@"Options_Btn.png"];
    noButton.position = ccp(winSize.width/2, sprite.position.y*.4);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        noButton.scaleX = IPAD_SCALE_FACTOR_X;
        noButton.scaleY = IPAD_SCALE_FACTOR_Y;
    }
    [[noButton texture] setAliasTexParameters];
    [scoresLayer addChild:noButton z:81];
    label = [CCLabelTTF labelWithString:@"Never mind" fontName:@"LostPet.TTF" fontSize:fontSize];
    [[label texture] setAliasTexParameters];
    label.color = _color_pink;
    label.position = ccp(noButton.position.x, noButton.position.y-1);
    [scoresLayer addChild:label z:82];
}

-(void)showCredits{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    credits = true;
    
    creditsLayer = [CCLayerColor layerWithColor:ccc4(190, 190, 190, 0) width:winSize.width height:winSize.height];
    creditsLayer.anchorPoint = CGPointZero;
    [self addChild:creditsLayer z:80];
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Pause_BG.png"];
    sprite.position = ccp(winSize.width/2, winSize.height/2);
    sprite.scale = 1.5*scale;
    [creditsLayer addChild:sprite z:81];
    
    float fontSize = 21.0*scale;
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Credits" fontName:@"LostPet.TTF" fontSize:fontSize+3];
    label.color = _color_pink;
    [[label texture] setAliasTexParameters];
    CCMenuItem *pauseTitle = [CCMenuItemLabel itemWithLabel:label];
    float height = winSize.height*.88;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        height = winSize.height*.84;
    }
    pauseTitle.position = ccp((sprite.position.x), height);
    [creditsLayer addChild:pauseTitle z:81];
    
    label = [CCLabelTTF labelWithString:@"Emmett Butler: design & program\nDiego Garcia: design & art\nMusic: Benjamin Carignan - \"Space Boyfriend\"\nLuke Silas - \"knife city\"\nTesters: Nick Johnson, Dave Mauro, Nina Freeman, Sam Bosma, Grace Yang, Mike Bartnett, Aaron Koenigsberg, Zach Cimafonte, Noah Lemen\nSpecial thanks to Muhammed Ali Khan and Anna Anthropy" dimensions:CGSizeMake(sprite.contentSize.width*sprite.scaleX*.9, sprite.contentSize.height*sprite.scaleY*.9) alignment:UITextAlignmentLeft fontName:@"LostPet.TTF" fontSize:fontSize];
    label.position = ccp(sprite.position.x, sprite.position.y*.86);
    label.color = _color_pink;
    [[label texture] setAliasTexParameters];
    [creditsLayer addChild:label z:81];
}

-(id) init{
    if ((self = [super init])){
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        [[HotDogManager sharedManager] setInGame:[NSNumber numberWithBool:false]];
        sfxOn = [[NSUserDefaults standardUserDefaults] integerForKey:@"sfxon"];
        self.isTouchEnabled = true;
        
        _color_pink = ccc3(255, 62, 166);
        
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
        } else {
            background.scaleX = winSize.width / background.contentSize.width;
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
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
}

- (void)switchSceneStart{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInT transitionWithDuration:.3 scene:[LevelSelectLayer scene]]];
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
        if(CGRectContainsPoint(_clearScoresRect, touchLocation1)){
            [self deleteScores];
            return;
        }
        scores = false;
        [self removeChild:scoresLayer cleanup:YES];
        return;
    }
    
    if(CGRectContainsPoint(_siteRect, touchLocation1)){
        [self openHomepage];
    } else if(CGRectContainsPoint(_creditsRect, touchLocation1)){
        [self showCredits];
        [[HotDogManager sharedManager] customEvent:@"credits" st1:@"options" st2:NULL level:NULL value:NULL data:NULL];
    } else if(CGRectContainsPoint(_scoresRect, touchLocation1)){
        [self clearScoresWindow];
        [[HotDogManager sharedManager] customEvent:@"clear_scores" st1:@"options" st2:NULL level:NULL value:NULL data:NULL];
    } else if(CGRectContainsPoint(_sfxRect, touchLocation1)){
        [self flipSFX];
    } else if(CGRectContainsPoint(_startRect, touchLocation1)){
        [self switchSceneStart];
    } else if(CGRectContainsPoint(_titleRect, touchLocation1)){
        [self switchSceneTitleScreen];
    }
}

- (void)switchSceneTitleScreen{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:.3 scene:[TitleLayer scene]]];
}

-(void) dealloc{
    [super dealloc];
}

@end