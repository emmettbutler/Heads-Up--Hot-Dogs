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
    
    // TODO - importing all of these defeats part of the purpose of using different sprite sheets
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_common.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_nyc.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_philly.plist"];
    
    // TODO - people per level
    
    /********************************************************************************
     * PHILLY LEVEL SETTINGS
     *******************************************************************************/
    
    lp = new levelProps();
    lp->slug = [NSString stringWithString:@"philly"];
    lp->name = [NSString stringWithString:@"Philly"];
    lp->bg = [NSString stringWithString:@"bg_philly.png"];
    lp->bgm = [NSString stringWithString:@"gameplay 1.mp3"];
    lp->gravity = -30.0f;
    lp->highScoreSaveKey = [NSString stringWithString:@"highScorePhilly"];
    lp->func = [NSString stringWithString:@"switchScreenPhilly"];
    lp->spritesheet = [NSString stringWithString:@"sprites_philly"];
    lp->thumbnail = [NSString stringWithString:@"Philly_Thumb.png"];
    lp->highScore = [standardUserDefaults integerForKey:lp->highScoreSaveKey];
    
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
    
    lp->characters = [CharBuilder buildCharacters:lp->slug];
    [levelStructs addObject:[NSValue valueWithPointer:lp]];
    
    
    
    /********************************************************************************
     * NYC LEVEL SETTINGS
     *******************************************************************************/
    
    lp = new levelProps();
    lp->slug = [NSString stringWithString:@"nyc"];
    lp->name = [NSString stringWithString:@"Big Apple"];
    lp->bg = [NSString stringWithString:@"BG_NYC.png"];
    lp->bgm = [NSString stringWithString:@"gameplay 3.mp3"];
    lp->gravity = -30.0f;
    lp->highScoreSaveKey = [NSString stringWithString:@"highScoreNYC"];
    lp->func = [NSString stringWithString:@"switchScreenNYC"];
    lp->spritesheet = [NSString stringWithString:@"sprites_nyc"];
    lp->thumbnail = [NSString stringWithString:@"NYC_Thumb.png"];
    lp->highScore = [standardUserDefaults integerForKey:lp->highScoreSaveKey];
    
    dd = new spcDogData();
    dd->riseSprite = [NSString stringWithString:@"Bagel_Rise.png"];
    dd->fallSprite = [NSString stringWithString:@"Bagel_Fall.png"];
    dd->mainSprite = [NSString stringWithString:@"Bagel.png"];
    dd->grabSprite = [NSString stringWithString:@"Bagel_Grab.png"];
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
    
    lp->characters = [CharBuilder buildCharacters:lp->slug];
    [levelStructs addObject:[NSValue valueWithPointer:lp]];
    
    /////////////////////////////////////////////////////////////////////////////
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_common.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_nyc.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_philly.plist"];
    
    return levelStructs;
}

-(id) init{
    if ((self = [super init])){
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
        
        self.isTouchEnabled = true;
        
        curLevelIndex = 0;
        
        _color_pink = ccc3(255, 62, 166);

        spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spritesheet];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"LvlBG.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"SELECT LEVEL" fontName:@"LostPet.TTF" fontSize:50.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(winSize.width/2, winSize.height-(label.contentSize.height/2)-9);
        [self addChild:label];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"Lvl_TextBox.png"];
        sprite.position = ccp(winSize.width/2, (sprite.contentSize.height/2)+40);
        [self addChild:sprite];
        
        nameLabel = [CCLabelTTF labelWithString:@"philadelphia" fontName:@"LostPet.TTF" fontSize:20.0];
        [[nameLabel texture] setAliasTexParameters];
        nameLabel.color = _color_pink;
        nameLabel.position = ccp(winSize.width/2, sprite.position.y+(label.contentSize.height/2)-17);
        [self addChild:nameLabel];
        
        scoreLabel = [CCLabelTTF labelWithString:@"high score: ######" fontName:@"LostPet.TTF" fontSize:20.0];
        [[scoreLabel texture] setAliasTexParameters];
        scoreLabel.color = _color_pink;
        scoreLabel.position = ccp(winSize.width/2, sprite.position.y+(label.contentSize.height/2)-35);
        [self addChild:scoreLabel];
        
        //left
        sprite = [CCSprite spriteWithSpriteFrameName:@"LvlArrow.png"];
        sprite.position = ccp(52, winSize.height/2);
        [self addChild:sprite];
        
        leftArrowRect = CGRectMake((sprite.position.x-(sprite.contentSize.width)/2), (sprite.position.y-(sprite.contentSize.height)/2), (sprite.contentSize.width+10), (sprite.contentSize.height+10));
        
        //right
        sprite = [CCSprite spriteWithSpriteFrameName:@"LvlArrow.png"];
        sprite.position = ccp(winSize.width-52, winSize.height/2);
        sprite.flipX = true;
        [self addChild:sprite];
        
        rightArrowRect = CGRectMake((sprite.position.x-(sprite.contentSize.width)/2), (sprite.position.y-(sprite.contentSize.height)/2), (sprite.contentSize.width+10), (sprite.contentSize.height+10));
        
        thumb = [CCSprite spriteWithSpriteFrameName:@"Philly_Thumb.png"];
        thumb.position = ccp(winSize.width/2, winSize.height/2+20);
        [self addChild:thumb];
        
        thumbnailRect = CGRectMake((thumb.position.x-(thumb.contentSize.width)/2), (thumb.position.y-(thumb.contentSize.height)/2), (thumb.contentSize.width+10), (thumb.contentSize.height+10));
        
        lStructs = [LevelSelectLayer buildLevels];
            
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    //CGSize size = [[CCDirector sharedDirector] winSize];
    time++;
    level = (levelProps *)[(NSValue *)[lStructs objectAtIndex:curLevelIndex] pointerValue];
    
    [thumb setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:level->thumbnail]];
    [nameLabel setString:[NSString stringWithFormat:@"%@", level->name]];
    [scoreLabel setString:[NSString stringWithFormat:@"high score: %06d", level->highScore]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    firstTouch = location;
    
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //Swipe Detection Part 2
    lastTouch = location;
    
    //Minimum length of the swipe
    float swipeLength = ccpDistance(firstTouch, lastTouch);
    
    if(CGRectContainsPoint(rightArrowRect, location) || (firstTouch.x < lastTouch.x && swipeLength > 60)){
        if(curLevelIndex < [lStructs count] - 1)
            curLevelIndex++;
        else curLevelIndex = 0;
    }
    else if(CGRectContainsPoint(leftArrowRect, location) || (firstTouch.x > lastTouch.x && swipeLength > 60)){
        if(curLevelIndex > 0)
            curLevelIndex--;
        else curLevelIndex = [lStructs count] - 1;
    }
    else if(CGRectContainsPoint(thumbnailRect, location)){
        SEL levelMethod = NSSelectorFromString(level->func);
        [self performSelector:levelMethod];
    }
}

-(void)switchScreenPhilly{
    [self switchScreenStartWithSlug:[NSString stringWithString:@"philly"]];
}

-(void)switchScreenNYC{
    [self switchScreenStartWithSlug:[NSString stringWithString:@"nyc"]];
}

-(void)switchScreenSpace{
    [self switchScreenStartWithSlug:[NSString stringWithString:@"space"]];
}

-(void)switchScreenStartWithSlug:(NSString *)slug{
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:1];
    [params addObject:slug];
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer sceneWithData:params]];
}

-(void) dealloc{
    free(lStructs);
    [super dealloc];
}

@end
