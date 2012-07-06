//
//  LevelSelectLayer.m
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "GameplayLayer.h"

@implementation LevelSelectLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	LevelSelectLayer *layer = [LevelSelectLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        CGSize size = [[CCDirector sharedDirector] winSize];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
        self.isTouchEnabled = true;
        
        _color_pink = ccc3(255, 62, 166);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"end_sprites_default.plist"];
        spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"end_sprites_default.png"];
        [self addChild:spritesheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"GameEnd_BG"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Philly" fontName:@"LostPet.TTF" fontSize:25.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *buttonPhilly = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchScreenPhila)];
        
        label = [CCLabelTTF labelWithString:@"Big Apple" fontName:@"LostPet.TTF" fontSize:25.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        CCMenuItem *buttonNYC = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchScreenNYC)];
        
        CCMenu *menu = [CCMenu menuWithItems:buttonPhilly, buttonNYC, nil];
        [menu setPosition:ccp(110, 200)];
        [menu alignItemsVertically];
        [self addChild:menu z:11];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    //CGSize size = [[CCDirector sharedDirector] winSize];
    time++;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
}

-(void)switchScreenPhila{
    [self switchScreenStartWithSlug:[NSString stringWithString:@"philly"]];
}

-(void)switchScreenNYC{
    [self switchScreenStartWithSlug:[NSString stringWithString:@"nyc"]];
}

-(void)switchScreenStartWithSlug:(NSString *)slug{
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:1];
    [params addObject:slug];
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer sceneWithData:params]];
}

-(void) dealloc{
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    //[[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [super dealloc];
}

@end
