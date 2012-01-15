//
//  TitleScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "TitleScene.h"
#import "GameplayLayer.h"

@implementation TitleLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TitleLayer *layer = [TitleLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init{
    if ((self = [super init])){
        CGSize size = [[CCDirector sharedDirector] winSize];

        CCSprite *sprite = [CCSprite spriteWithFile:@"now_way!.jpg"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];

        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Sandbox" fontName:@"Marker Felt" fontSize:32.0];
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchScene)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(size.width / 2, size.height / 2)];
        [self addChild:menu];
        
        CCLabelTTF *byline = [CCLabelTTF labelWithString:@"by Emmett" fontName:@"Marker Felt" fontSize:22.0];
        [byline setPosition:ccp((size.width/2), (size.height/2)-50)];
        [self addChild:byline];
    }
    return self;
}

- (void)switchScene{
    CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[GameplayLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

-(void) dealloc{
    [super dealloc];
}

@end