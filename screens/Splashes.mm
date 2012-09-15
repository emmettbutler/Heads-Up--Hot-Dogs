//
//  Splashes.m
//  Heads Up
//
//  Created by Emmett Butler on 9/3/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "Splashes.h"
#import "UIDefs.h"


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
        
        float scaleX = 1, scaleY = 1;
        winSize = [CCDirector sharedDirector].winSize;
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spriteSheet];
        
        [[Clouds alloc] initWithLayer:[NSValue valueWithPointer:self]];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        background.anchorPoint = CGPointZero;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            background.scaleX = IPAD_SCALE_FACTOR_X;
            background.scaleY = IPAD_SCALE_FACTOR_Y;
            scaleX = IPAD_SCALE_FACTOR_X;
            scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [spriteSheet addChild:background z:-10];
        
        logoBG = [CCSprite spriteWithSpriteFrameName:@"Logo_Cloud.png"];
        cloudAnchor = CGPointMake(winSize.width/2+4, winSize.height/2+8);
        logoBG.scale = scaleX*.7;
        logoBG.position = ccp(cloudAnchor.x, cloudAnchor.y);
        [spriteSheet addChild:logoBG];
        
        mainLogo = [CCSprite spriteWithSpriteFrameName:@"ASg_Logo.png"];
        logoAnchor = CGPointMake(winSize.width/2+16, winSize.height/2-15);
        mainLogo.scale = scaleX*.7;
        mainLogo.position = ccp(logoAnchor.x, logoAnchor.y);
        [spriteSheet addChild:mainLogo];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void)tick:(ccTime)dt {
    time++;
    
    if(time == 150){
        [mainLogo runAction:[CCFadeOut actionWithDuration:1]];
        [logoBG runAction:[CCFadeOut actionWithDuration:1]];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1], [CCCallFunc actionWithTarget:self selector:@selector(switchSceneTitle)], nil]];
    }

    [logoBG setPosition:CGPointMake(cloudAnchor.x + (5 * sinf(time * .01)), cloudAnchor.y)];
    [mainLogo setPosition:CGPointMake(logoAnchor.x + (6 * sinf(time * .03)), logoAnchor.y + (3 * cosf(time * .02)))];
}

-(void)switchSceneTitle{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

-(void) dealloc{
    [super dealloc];
}

@end
