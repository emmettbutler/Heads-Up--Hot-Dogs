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
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"bg_philly.png"];
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