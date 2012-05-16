//
//  TitleScene.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "TitleScene.h"
#import "GameplayLayer.h"
#import "OptionsLayer.h"

@implementation TitleLayer

@synthesize titleAnimAction = _titleAnimAction;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	TitleLayer *layer = [TitleLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        CGSize size = [[CCDirector sharedDirector] winSize];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"title_sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"title_sprites_default.png"];
        [self addChild:spriteSheet];

        CCSprite *startButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        startButton.position = ccp(110, 27);
        [self addChild:startButton z:10];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"     Start     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = ccc3(255, 62, 166);
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneStart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 26)];
        [self addChild:menu z:11];
        
        CCSprite *otherButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        otherButton.position = ccp(370, 27);
        [self addChild:otherButton z:10];
        CCLabelTTF *otherLabel = [CCLabelTTF labelWithString:@"      Options      " fontName:@"LostPet.TTF" fontSize:22.0];
        [[otherLabel texture] setAliasTexParameters];
        otherLabel.color = ccc3(255, 62, 166);
        CCMenuItem *otherTextButton = [CCMenuItemLabel itemWithLabel:otherLabel target:self selector:@selector(switchSceneOptions)];
        CCMenu *otherMenu = [CCMenu menuWithItems:otherTextButton, nil];
        [otherMenu setPosition:ccp(370, 26)];
        [self addChild:otherMenu z:11];
        
        background = [CCSprite spriteWithSpriteFrameName:@"TitleAnim_1.png"];
        background.anchorPoint = CGPointZero;
        [self addChild:background z:-10];
        
        NSMutableArray *titleAnimFrames = [[NSMutableArray alloc] initWithCapacity:13];
        for(int i = 1; i <= 13; i++){
            [titleAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"TitleAnim_%d.png", i]]];
        }
        titleAnim = [CCAnimation animationWithFrames:titleAnimFrames delay:.07f];
        self.titleAnimAction = [[CCAnimate alloc] initWithAnimation:titleAnim restoreOriginalFrame:NO];
        [titleAnimFrames release];
        
        screen = CGRectMake(0, 0, size.width, size.height);
        
        [background runAction:_titleAnimAction];
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    //CGSize size = [[CCDirector sharedDirector] winSize];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
}

- (void)switchSceneStart{
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer scene]];
}

- (void)switchSceneOptions{
    [[CCDirector sharedDirector] replaceScene:[OptionsLayer scene]];
}

-(void) dealloc{
    [super dealloc];
}

@end