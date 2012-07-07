//
//  LevelSelectLayer.m
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "GameplayLayer.h"

#define NUM_LEVELS 2

@implementation LevelSelectLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	LevelSelectLayer *layer = [LevelSelectLayer node];
	[scene addChild:layer];
	return scene;
}

+(NSMutableArray *)buildLevels{
    levelStructs = [[NSMutableArray alloc] initWithCapacity:NUM_LEVELS];
    levelProps *lp;
    spcDogData *dd;
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"sprites_default.plist"];
    
    // TODO - spritesheet per level, divide into "common" and "per level" sheets
    
    /******************************************
    * PHILLY LEVEL SETTINGS
    ******************************************/
    
    lp = new levelProps();
    lp->slug = [NSString stringWithString:@"philly"];
    lp->name = [NSString stringWithString:@"Philly"];
    lp->bg = [NSString stringWithString:@"bg_philly.png"];
    lp->bgm = [NSString stringWithString:@"menu 3.wav"];
    lp->gravity = -30.0f;
    lp->highScoreSaveKey = [NSString stringWithString:@"highScorePhilly"];
    lp->func = [NSString stringWithString:@"switchScreenPhilly"];
    
    dd = new spcDogData();
    dd->riseSprite = [NSString stringWithString:@"Steak_Rise.png"];
    dd->fallSprite = [NSString stringWithString:@"Steak_Fall.png"];
    dd->mainSprite = [NSString stringWithString:@"Steak.png"];
    dd->grabSprite = [NSString stringWithString:@"Steak_Grabbed.png"];
    dd->deathAnimFrames = [[NSMutableArray alloc] init];
    dd->shotAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 0; i < 1; i++){
        [dd->deathAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Steak_Die_1.png"]]];
        [dd->deathAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Steak_Die_2.png"]]];
    }
    for(int i = 1; i <= 7; i++){
        [dd->deathAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Steak_Die_%d.png", i]]];
    }
    for(int i = 1; i <= 9; i++){
        [dd->shotAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Steak_Shot_%d.png", i]]];
    }
    lp->specialDog = dd;
    [levelStructs addObject:[NSValue valueWithPointer:lp]];
    
    
    
    /******************************************
     * NYC LEVEL SETTINGS
     ******************************************/
    
    lp = new levelProps();
    lp->slug = [NSString stringWithString:@"nyc"];
    lp->name = [NSString stringWithString:@"Big Apple"];
    lp->bg = [NSString stringWithString:@"BG_NYC.png"];
    lp->bgm = [NSString stringWithString:@"menu 3.wav"];
    lp->gravity = -30.0f;
    lp->highScoreSaveKey = [NSString stringWithString:@"highScoreNYC"];
    lp->func = [NSString stringWithString:@"switchScreenNYC"];
    
    dd = new spcDogData();
    // TODO - audio per level
    // TODO - collection audio from emails
    dd->riseSprite = [NSString stringWithString:@"Bagel_Rise.png"];
    dd->fallSprite = [NSString stringWithString:@"Bagel_Fall.png"];
    dd->mainSprite = [NSString stringWithString:@"Bagel.png"];
    dd->grabSprite = [NSString stringWithString:@"Steak_Grabbed.png"];
    dd->deathAnimFrames = [[NSMutableArray alloc] init];
    dd->shotAnimFrames = [[NSMutableArray alloc] init];
    for(int i = 0; i < 1; i++){
        [dd->deathAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Bagel_Die_1.png"]]];
        [dd->deathAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Bagel_Die_2.png"]]];
    }
    for(int i = 1; i <= 8; i++){
        [dd->deathAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Bagel_Die_%d.png", i]]];
    }
    for(int i = 1; i <= 6; i++){
        [dd->shotAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Bagel_Shot_%d.png", i]]];
    }
    
    lp->specialDog = dd;
    [levelStructs addObject:[NSValue valueWithPointer:lp]];
    
    return levelStructs;
}

-(id) init{
    if ((self = [super init])){
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        //CGSize size = [[CCDirector sharedDirector] winSize];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
        self.isTouchEnabled = true;
        
        _color_pink = ccc3(255, 62, 166);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"end_sprites_default.plist"];
        spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"end_sprites_default.png"];
        [self addChild:spritesheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"GameEnd_BG"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        NSMutableArray *lStructs = [LevelSelectLayer buildLevels];
        levelProps *level;
        CCMenuItem *button;
        CCMenu *menu;
        CCLOG(@"levelStructs count: %d", [lStructs count]);
        for(int i = 0; i < [lStructs count]; i++){
            level = (levelProps *)[[lStructs objectAtIndex:i] pointerValue];
            
            CCLabelTTF *label = [CCLabelTTF labelWithString:level->name fontName:@"LostPet.TTF" fontSize:25.0];
            [[label texture] setAliasTexParameters];
            label.color = _color_pink;
            button = [CCMenuItemLabel itemWithLabel:label target:self selector:NSSelectorFromString(level->func)];
            
            menu = [CCMenu menuWithItems:button, nil];
            //[menu alignItemsVertically];
            [menu setPosition:ccp(110, 200-(i*20))];
            [self addChild:menu z:11];
        }
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

-(void)switchScreenPhilly{
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
