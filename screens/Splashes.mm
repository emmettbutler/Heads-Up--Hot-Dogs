//
//  Splashes.m
//  Heads Up
//
//  Created by Emmett Butler on 9/3/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "Splashes.h"
#import "UIDefs.h"
#import "HotDogManager.h"


@implementation Splashes

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	Splashes *layer = [Splashes node];
	[scene addChild:layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        NSLog(@"Splash screens start");
        [[HotDogManager sharedManager] setInGame:[NSNumber numberWithBool:false]];
        [[HotDogManager sharedManager] setPause:[NSNumber numberWithBool:false]];
        
        scaleX = 1, scaleY = 1;
        winSize = [[CCDirector sharedDirector] winSize];
        float windowWidth = winSize.width, windowHeight = winSize.height;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            if(!(winSize.width > winSize.height)){
                windowWidth = winSize.height;
                windowHeight = winSize.width;
            }
        }
        NSLog(@"Winsize: %0.2f x %0.2f", windowWidth, windowHeight);
        
        clouds = [[Clouds alloc] initWithLayer:[NSValue valueWithPointer:self]];
        
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spriteSheet];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        background.anchorPoint = CGPointZero;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            background.scaleX = IPAD_SCALE_FACTOR_X;
            background.scaleY = IPAD_SCALE_FACTOR_Y;
            scaleX = IPAD_SCALE_FACTOR_X*.7;
            scaleY = IPAD_SCALE_FACTOR_Y*.7;
        } else {
            background.scaleX = windowWidth / IPHONE_4_INCH_SCALE_FACTOR_X;
        }
        [self addChild:background z:-10];
        
        logoBG = [CCSprite spriteWithSpriteFrameName:@"Logo_Cloud.png"];
        cloudAnchor = CGPointMake(windowWidth/2+4, windowHeight/2+8);
        logoBG.scale = scaleX;
        logoBG.position = ccp(cloudAnchor.x, cloudAnchor.y);
        //logoBG.visible = false;
        [spriteSheet addChild:logoBG z:20];
        
        mainLogo = [CCSprite spriteWithSpriteFrameName:@"ASg_Logo.png"];
        logoAnchor = CGPointMake(windowWidth/2+16, windowHeight/2-15);
        mainLogo.scale = scaleX;
        mainLogo.position = ccp(logoAnchor.x, logoAnchor.y);
        //mainLogo.visible = false;
        [spriteSheet addChild:mainLogo z:21];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void)tick:(ccTime)dt {
    time++;
    
    if(time == 90){
        [mainLogo runAction:[CCFadeOut actionWithDuration:1]];
        [logoBG runAction:[CCFadeOut actionWithDuration:1]];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1], nil]];
        
        namesBG = [CCSprite spriteWithSpriteFrameName:@"CreatedBy_Cloud.png"];
        namesBG.scale = scaleX;
        namesBG.opacity = 0;
        namesBG.position = ccp(cloudAnchor.x, cloudAnchor.y);
        [spriteSheet addChild:namesBG  z:20];
        [namesBG runAction:[CCFadeIn actionWithDuration:1.8]];
        
        namesSprite = [CCSprite spriteWithSpriteFrameName:@"CreatedBy_Names.png"];
        namesSprite.scale = scaleX;
        namesSprite.opacity = 0;
        namesAnchor = CGPointMake(logoAnchor.x*.95, logoAnchor.y*1.1);
        namesSprite.position = ccp(logoAnchor.x, logoAnchor.y);
        [spriteSheet addChild:namesSprite  z:21];
        [namesSprite runAction:[CCFadeIn actionWithDuration:1.8]];
    } else if(time == 280){
        [namesSprite runAction:[CCFadeOut actionWithDuration:1]];
        [namesBG runAction:[CCFadeOut actionWithDuration:1]];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1], [CCCallFunc actionWithTarget:self selector:@selector(switchSceneTitle)], nil]];
    }

    [logoBG setPosition:CGPointMake(cloudAnchor.x + (5 * sinf(time * .01)), cloudAnchor.y)];
    [mainLogo setPosition:CGPointMake(logoAnchor.x + (6 * sinf(time * .03)), logoAnchor.y + (3 * cosf(time * .02)))];
    [namesSprite setPosition:CGPointMake(namesAnchor.x + (5 * sinf(time * .01)), namesAnchor.y)];
}

-(void)switchSceneTitle{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

-(void) dealloc{
    [clouds dealloc];
    [super dealloc];
}

@end
