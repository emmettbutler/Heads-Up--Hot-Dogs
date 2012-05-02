//
//  LoseScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "LoseScene.h"
#import "GameplayLayer.h"

@implementation LoseLayer

+(CCScene *) sceneWithData:(void*)data
{
	CCScene *scene = [CCScene node];
    CCLOG(@"in scenewithData");
	LoseLayer *layer;
    layer = [LoseLayer node];
    layer->_score = (int)data;
    CCLOG(@"In sceneWithData: %d", layer->_score);
	[scene addChild:layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_default.png"];
        [self addChild:spriteSheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"bg_philly.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Try Again?" fontName:@"Marker Felt" fontSize:32.0];
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchScene)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(size.width / 2, size.height / 2)];
        [self addChild:menu];
        
        
        scoreLine = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:22.0];
        [scoreLine setPosition:ccp((size.width/2), (size.height/2)-50)];
        [self addChild:scoreLine];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger highScore = [standardUserDefaults integerForKey:@"highScore"];
    if(_score > highScore){
        [standardUserDefaults setInteger:_score forKey:@"highScore"];
        
        scoreNotify = [CCLabelTTF labelWithString:@"New high score!" fontName:@"Marker Felt" fontSize:22.0];
        [scoreNotify setPosition:ccp((size.width/2), (size.height/2)-100)];
        [self addChild:scoreNotify];
    }
    [standardUserDefaults synchronize];
    
    [scoreLine setString:[NSString stringWithFormat:@"%d", _score]];
}

- (void)switchScene{
    CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[GameplayLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

-(void) dealloc{
    [super dealloc];
}

@end