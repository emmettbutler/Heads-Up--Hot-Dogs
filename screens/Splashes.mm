//
//  Splashes.m
//  Heads Up
//
//  Created by Emmett Butler on 9/3/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "Splashes.h"


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
        winSize = [CCDirector sharedDirector].winSize;
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spriteSheet];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        background.anchorPoint = CGPointZero;
        [spriteSheet addChild:background z:-10];
        
        [[Clouds alloc] initWithSpritesheet:[NSValue valueWithPointer:spriteSheet]];
        
        logoBG = [CCSprite spriteWithSpriteFrameName:@"Logo_Cloud.png"];
        cloudAnchor = CGPointMake(winSize.width/2-10, winSize.height/2+20);
        logoBG.position = ccp(cloudAnchor.x, cloudAnchor.y);
        [spriteSheet addChild:logoBG];
        
        mainLogo = [CCSprite spriteWithSpriteFrameName:@"ASg_Logo.png"];
        mainLogo.position = ccp(winSize.width/2, winSize.height/2);
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
    
    //NSLog(@"sine: %0.2f", sinf(time * .01));
    [logoBG setPosition:CGPointMake(cloudAnchor.x + (5 * sinf(time * .01)), cloudAnchor.y)];
    [mainLogo setPosition:CGPointMake(winSize.width/2 + (6 * sinf(time * .03)), winSize.height/2 + (3 * cosf(time * .02)))];
}

-(void)switchSceneTitle{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

-(void) dealloc{
    [super dealloc];
}

@end
