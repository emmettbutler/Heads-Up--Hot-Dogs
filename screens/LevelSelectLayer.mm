//
//  LevelSelectLayer.m
//  Heads Up
//
//  Created by Emmett Butler on 7/5/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "GameplayLayer.h"
#import "Clouds.h"
#import "TitleScene.h"
#import "UIDefs.h"

@implementation LevelSelectLayer

+(CCScene *) scene{
	CCScene *scene = [CCScene node];
	LevelSelectLayer *layer = [LevelSelectLayer node];
	[scene addChild:layer];
	return scene;
}

+(NSMutableArray *)buildLevels:(NSNumber *)full{
    NSMutableArray *levelStructs = [[NSMutableArray alloc] init];
    
    if(full.boolValue) [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_common.plist"];

    // check it out - seven levels!
    [levelStructs addObject:[self philly:full]];
    [levelStructs addObject:[self nyc:full]];
    [levelStructs addObject:[self london:full]];
    [levelStructs addObject:[self china:full]];
    [levelStructs addObject:[self chicago:full]];
    [levelStructs addObject:[self space:full]];
    [levelStructs addObject:[self japan:full]];
   
    if(full.boolValue) [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_common.plist"];

    NSLog(@"Loading levels...");
    for(NSValue *v in levelStructs){
        levelProps *l = (levelProps *)[v pointerValue];
        l->highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", l->slug]];
        int nextIndex = [levelStructs indexOfObject:v] + 1;
        if(nextIndex == [levelStructs count])
            nextIndex--;
        int prevIndex = [levelStructs indexOfObject:v] - 1;
        if(prevIndex == -1)
            prevIndex++;
        l->next = (levelProps *)[(NSValue *)[levelStructs objectAtIndex:nextIndex] pointerValue];
        l->prev = (levelProps *)[(NSValue *)[levelStructs objectAtIndex:prevIndex] pointerValue];

        int unlocked = 0, prevTrophyLevel = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"trophy_%@", l->prev->slug]];
        if((prevTrophyLevel && prevTrophyLevel <= 2) || l->slug == @"philly"){
            NSLog(@"Level %@ unlocked", l->name);
            [standardUserDefaults setInteger:1 forKey:[NSString stringWithFormat:@"unlocked%@", l->slug]];
            unlocked = 1;
        }
        [standardUserDefaults synchronize];

        if(unlocked) l->unlocked = true;
    }
    NSLog(@"Done");
    return levelStructs;
}

//#ifdef TEST
-(void)unlockAllLevels{
    for(NSValue *v in lStructs){
        levelProps *lp = (levelProps *)[v pointerValue];
        lp->unlocked = true;
    }
    unlockedCount = [lStructs count] - 1;
}
//#endif

-(id) init{
    if ((self = [super init])){
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        winSize = [[CCDirector sharedDirector] winSize];
        [[CCDirector sharedDirector] setDisplayFPS:NO];
#ifdef DEBUG
#else
        if(![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu 2.mp3" loop:YES];
#endif
        
        // TODO: for testing only - don't lock the levels
        // this completely bypasses the storage of level unlock userDefaults and simply shows all levels as available
        NO_LEVEL_LOCKS = false;

        self.isTouchEnabled = true;

        curLevelIndex = 0;
        float largeFontSize = IPHONE_HEADER_TEXT_SIZE;

        _color_pink = ccc3(255, 62, 166);
        
        [[Clouds alloc] initWithLayer:[NSValue valueWithPointer:self]];

        spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
        [self addChild:spritesheet];

        background = [CCSprite spriteWithSpriteFrameName:@"Splash_BG_clean.png"];
        background.anchorPoint = CGPointZero;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            background.scaleX = IPAD_SCALE_FACTOR_X;
            background.scaleY = IPAD_SCALE_FACTOR_Y;
            largeFontSize = IPAD_HEADER_TEXT_SiZE;
        }
        [self addChild:background z:-1];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Lvl_Band.png"];
        sprite.position = ccp(winSize.width/2, winSize.height/2);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            sprite.scaleX = IPAD_SCALE_FACTOR_X;
            sprite.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [self addChild:sprite];

        CCLabelTTF *label = [CCLabelTTF labelWithString:@"SELECT LEVEL" fontName:@"LostPet.TTF" fontSize:largeFontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(winSize.width/2, winSize.height-(label.contentSize.height/2)-9);
        [self addChild:label];

        sprite = [CCSprite spriteWithSpriteFrameName:@"Lvl_TextBox.png"];
        sprite.position = ccp(winSize.width/2, (winSize.height/5));
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            sprite.scaleX = IPAD_SCALE_FACTOR_X;
            sprite.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [self addChild:sprite];
        
        float fontSize = 20.0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            fontSize = 45.0;
        }
        
        nameLabel = [CCLabelTTF labelWithString:@"philadelphia\nhigh score: ######" dimensions:CGSizeMake(sprite.contentSize.width*sprite.scaleX, sprite.contentSize.height*sprite.scaleY) alignment:UITextAlignmentCenter fontName:@"LostPet.TTF" fontSize:fontSize];
        [[nameLabel texture] setAliasTexParameters];
        nameLabel.color = _color_pink;
        nameLabel.position = ccp(sprite.position.x, sprite.position.y-4*sprite.scaleY);
        [self addChild:nameLabel];

        //left
        sprite = [CCSprite spriteWithSpriteFrameName:@"LvlArrow.png"];
        sprite.position = ccp(sprite.contentSize.width, winSize.height/2);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            sprite.scaleX = IPAD_SCALE_FACTOR_X;
            sprite.scaleY = IPAD_SCALE_FACTOR_Y;
            sprite.position = ccp(sprite.position.x + 30, sprite.position.y);
        }
        [self addChild:sprite];
        leftArrowRect = CGRectMake((sprite.position.x-(sprite.contentSize.width*sprite.scaleX)/2), (sprite.position.y-(sprite.contentSize.height*sprite.scaleY)/2), (sprite.contentSize.width*sprite.scaleX+20), (sprite.contentSize.height*sprite.scaleY+300));

        //right
        sprite = [CCSprite spriteWithSpriteFrameName:@"LvlArrow.png"];
        sprite.position = ccp(winSize.width-sprite.contentSize.width, winSize.height/2);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            sprite.scaleX = IPAD_SCALE_FACTOR_X;
            sprite.scaleY = IPAD_SCALE_FACTOR_Y;
            sprite.position = ccp(sprite.position.x - 30, sprite.position.y);
        }
        sprite.flipX = true;
        [self addChild:sprite];

        rightArrowRect = CGRectMake((sprite.position.x-(sprite.contentSize.width*sprite.scaleX)/2), (sprite.position.y-(sprite.contentSize.height*sprite.scaleY)/2), (sprite.contentSize.width*sprite.scaleX+20), (sprite.contentSize.height*sprite.scaleY+300));

        float scale = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scale = IPAD_SCALE_FACTOR_Y;
        }
        thumb = [CCSprite spriteWithSpriteFrameName:@"Philly_Thumb.png"];
        thumb.position = ccp(winSize.width/2, winSize.height/2+(20*scale));
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            thumb.scaleX = IPAD_SCALE_FACTOR_X;
            thumb.scaleY = IPAD_SCALE_FACTOR_Y;
        }
        [self addChild:thumb];

        helpLabel = [CCLabelTTF labelWithString:@"Tap to start" fontName:@"LostPet.TTF" fontSize:22.0];
        [[helpLabel texture] setAliasTexParameters];
        helpLabel.color = _color_pink;
        helpLabel.position = ccp(winSize.width/2, thumb.position.y-((thumb.contentSize.height*thumb.scaleY)/2)+6);
        [self addChild:helpLabel];
        
        CCSprite *button4 = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        button4.scale = scale;
        button4.position = ccp(button4.contentSize.width/2*button4.scaleX*1.1, button4.contentSize.height*button4.scaleY*.6);
        [self addChild:button4 z:10];
        label = [CCLabelTTF labelWithString:@"Title" fontName:@"LostPet.TTF" fontSize:fontSize];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp(button4.position.x, button4.position.y-1);
        [self addChild:label z:11];
        _backRect = CGRectMake((button4.position.x-(button4.contentSize.width*button4.scaleX)/2), (button4.position.y-(button4.contentSize.height*button4.scaleY)/2), (button4.contentSize.width*button4.scaleX+70), (button4.contentSize.height*button4.scaleY+70));
        
//#ifdef TEST
        CCLabelTTF *unlockAllLevelsLabel = [CCLabelTTF labelWithString:@"Unlock all levels" fontName:@"LostPet.TTF" fontSize:25.0];
        unlockAllLevelsLabel.color = _color_pink;
        CCMenuItem *item = [CCMenuItemLabel itemWithLabel:unlockAllLevelsLabel target:self selector:@selector(unlockAllLevels)];
        CCMenu *menu = [CCMenu menuWithItems:item, nil];
        menu.position = ccp(winSize.width-unlockAllLevelsLabel.contentSize.width/2, unlockAllLevelsLabel.contentSize.height);
        [self addChild:menu];
//#endif

        thumbnailRect = CGRectMake((thumb.position.x-((thumb.contentSize.width*thumb.scaleX))/2), (thumb.position.y-(thumb.contentSize.height*thumb.scaleY)/2), ((thumb.contentSize.width*thumb.scaleX)+10), ((thumb.contentSize.height*thumb.scaleY)+10));

        lStructs = [[LevelSelectLayer buildLevels:[NSNumber numberWithInt:0]] retain];
        
        for(NSValue *v in lStructs){
            levelProps *lp = (levelProps *)[v pointerValue];
            if(lp->unlocked && unlockedCount < [lStructs count] - 1)
                unlockedCount++;
        }

        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
    //CGSize size = [[CCDirector sharedDirector] winSize];
    time++;
    level = (levelProps *)[(NSValue *)[lStructs objectAtIndex:curLevelIndex] pointerValue];

    if(level->unlocked){
        [thumb setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:level->thumbnail]];
        [nameLabel setString:[NSString stringWithFormat:@"%@\nhigh score: %06d", level->name, level->highScore]];
        [helpLabel setVisible:true];
    } else {
        [thumb setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NoLevel.png"]];
        [nameLabel setString:[NSString stringWithFormat:@"??????\nunlock: silver on %@", level->prev->name]];
        [helpLabel setVisible:false];
    }
    [[nameLabel texture] setAliasTexParameters];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    firstTouch = location;
    
    if(CGRectContainsPoint(_backRect, location)){
        [self switchSceneTitle];
    }
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
    
    if(CGRectContainsPoint(leftArrowRect, location) || (firstTouch.x < lastTouch.x && swipeLength > 60)){
        if(curLevelIndex > 0)
            curLevelIndex--;
        else curLevelIndex = unlockedCount;
    }
    else if(CGRectContainsPoint(rightArrowRect, location) || (firstTouch.x > lastTouch.x && swipeLength > 60)){
        if(curLevelIndex < unlockedCount)
            curLevelIndex++;
        else curLevelIndex = 0;
    }
    else if(CGRectContainsPoint(thumbnailRect, location)){
        SEL levelMethod = NSSelectorFromString(level->func);
        CCSequence *seq = [CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(addLoading)], [CCDelayTime actionWithDuration:.001], [CCCallFunc actionWithTarget:self selector:levelMethod], nil];
        
        if(NO_LEVEL_LOCKS || level->unlocked)
            [self runAction:seq];
    }
}

-(void)addLoading{
    [background setColor:ccc3(160, 160, 160)];
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Lvl_TextBox.png"];
    sprite.position = ccp(winSize.width/2, (winSize.height/2));
    [self addChild:sprite];
    
    loading = [[CCLabelTTF labelWithString:@"Loading..." fontName:@"LostPet.TTF" fontSize:40.0] retain];
    loading.color = _color_pink;
    loading.position = ccp(winSize.width/2, winSize.height/2);
    [[loading texture] setAliasTexParameters];
    [self addChild:loading];
}

- (void)switchSceneTitle{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

-(void)switchScreenPhilly{
    [self switchScreenStartWithSlug:@"philly"];
}

-(void)switchScreenNYC{
    [self switchScreenStartWithSlug:@"nyc"];
}

-(void)switchScreenLondon{
    [self switchScreenStartWithSlug:@"london"];
}

-(void)switchScreenChina{
    [self switchScreenStartWithSlug:@"china"];
}

-(void)switchScreenChicago{
    [self switchScreenStartWithSlug:@"chicago"];
}

-(void)switchScreenJapan{
    [self switchScreenStartWithSlug:@"japan"];
}

-(void)switchScreenSpace{
    [self switchScreenStartWithSlug:@"space"];
}

-(void)switchScreenStartWithSlug:(NSString *)slug{
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer sceneWithSlug:slug]];
}

-(void) dealloc{
    [lStructs release];
    [super dealloc];
}

+(NSValue *)philly:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * PHILLY LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"philly";
    lp->name = @"Philly";
    lp->unlockNextThreshold = 20000;
    lp->func = @"switchScreenPhilly";
    lp->thumbnail = @"Philly_Thumb.png";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_philly.plist"];
        lp->bg = @"bg_philly.png";
        lp->bgm = @"gameplay 1.mp3";
        lp->spritesheet = @"sprites_philly";
        lp->highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", lp->slug]];
        lp->personSpeedMul = 1;
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"Steak_Rise.png";
        dd->fallSprite = @"Steak_Fall.png";
        dd->mainSprite = @"Steak.png";
        dd->grabSprite = @"Steak_Grabbed.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Steak_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
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
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_philly.plist"];
    }
    return [NSValue valueWithPointer:lp];
}

+(NSValue *)nyc:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * NYC LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"nyc";
    lp->name = @"Big Apple";
    lp->unlockNextThreshold = 16000;
    lp->func = @"switchScreenNYC";
    lp->thumbnail = @"NYC_Thumb.png";
    lp->unlockTweet = @"I traveled to the Big Apple for some mischief in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_nyc.plist"];
        lp->bg = @"BG_NYC.png";
        lp->bgm = @"gameplay 3.mp3";
        lp->gravity = -25.0f;
        lp->spritesheet = @"sprites_nyc";
        lp->personSpeedMul = .8;
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"Bagel_Rise.png";
        dd->fallSprite = @"Bagel_Fall.png";
        dd->mainSprite = @"Bagel.png";
        dd->grabSprite = @"Bagel_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Bagel_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
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
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        float scale = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scale = IPAD_SCALE_FACTOR_X;
        }
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        bgComponent *bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_One.png"];
        bgc->sprite.scale = scale;
        bgc->sprite.position = CGPointMake(winSize.width*.495, winSize.height*.81);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_Two.png"];
        bgc->sprite.scale = scale;
        bgc->sprite.position = CGPointMake(winSize.width*.733, winSize.height*.81);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_Three.png"];
        bgc->sprite.scale = scale;
        bgc->sprite.position = CGPointMake(winSize.width*.792, winSize.height*.48);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"Light_Three.png"];
        bgc->sprite.scale = scale;
        bgc->sprite.position = CGPointMake(winSize.width*.179, winSize.height*.48);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_nyc.plist"];
    }
    return [NSValue valueWithPointer:lp];
}

+(NSValue *)london:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * LONDON LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"london";
    lp->name = @"London";
    lp->unlockNextThreshold = 14000;
    lp->func = @"switchScreenLondon";
    lp->thumbnail = @"London_Thumb.png";
    lp->unlockTweet = @"I went to London to conquer some franks in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_london.plist"];
        lp->bg = @"Subway_Car.png";
        lp->bgm = @"gameplay 3.mp3";
        lp->gravity = -22.0f;
        lp->spritesheet = @"sprites_london";
        lp->personSpeedMul = 1.2;
        lp->restitutionMul = 1.2;
        lp->frictionMul = .95;
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"Pasty_Rise.png";
        dd->fallSprite = @"Pasty_Fall.png";
        dd->mainSprite = @"Pasty.png";
        dd->grabSprite = @"Pasty_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Pasty_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Pasty_Die_2.png"]]];
        }
        for(int i = 1; i <= 10; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Pasty_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 7; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Pasty_Shoot_%d.png", i]]];
        }
        lp->specialDog = dd;
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        bgComponent *bgc;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        float scaleX = 1, scaleY = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scaleX = IPAD_SCALE_FACTOR_X;
            scaleY = IPAD_SCALE_FACTOR_Y;
        }
        for(int i = 1; i <= 4; i++){
            bgc = new bgComponent();
            bgc->sprite = [[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Window_%d_Start_1.png", i]] retain];
            int xPos;
            bgc->sprite.scaleX = scaleX;
            bgc->sprite.scaleY = scaleY;
            switch(i){
                case 1: xPos = winSize.width/8; break;
                case 2: xPos = 30.5*((float)winSize.width/100); break;
                case 3: xPos = 68.5*((float)winSize.width/100); break;
                case 4: xPos = winSize.width-(bgc->sprite.scaleX*(bgc->sprite.contentSize.width/1.7)); break;
                default: break;
            }
            bgc->sprite.position = CGPointMake(xPos, 2*(winSize.height/3));
            bgc->anim1 = [[NSMutableArray alloc] init];
            for(int j = 1; j <= 13; j++){
                [bgc->anim1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                       [NSString stringWithFormat:@"Window_%d_Start_%d.png", i, j]]];
            }
            CCAnimation *anim = [CCAnimation animationWithFrames:bgc->anim1 delay:.12f];
            bgc->startingAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO] times:1] retain];
            bgc->anim2 = [[NSMutableArray alloc] init];
            for(int j = 1; j <= 7; j++){
                if(i != 4){
                    [bgc->anim2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                           [NSString stringWithFormat:@"Window_%d_Loop_%d.png", i, j]]];
                } else {
                    [bgc->anim2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                           [NSString stringWithFormat:@"Window_%d_Loop.png", i]]];
                }
            }
            anim = [CCAnimation animationWithFrames:bgc->anim2 delay:.12f];
            bgc->loopingAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO] times:10] retain];
            bgc->anim3 = [[NSMutableArray alloc] init];
            for(int j = 1; j <= 10; j++){
                [bgc->anim3 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                       [NSString stringWithFormat:@"Window_%d_Stop_%d.png", i, j]]];
            }
            anim = [CCAnimation animationWithFrames:bgc->anim3 delay:.12f];
            bgc->stoppingAction = [[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO] times:1] retain];
            [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        }
    }
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_london.plist"];
    return [NSValue valueWithPointer:lp];
}

+(NSValue *)china:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * CHINA LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"china";
    lp->name = @"Beijing";
    lp->unlockNextThreshold = 15000;
    lp->func = @"switchScreenChina";
    lp->thumbnail = @"China_Thumb.png";
    lp->unlockTweet = @"Chinese New Year is a perfect time for franks in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_china.plist"];
        lp->bg = @"China_BG.png";
        lp->bgm = @"gameplay 3.mp3";
        lp->gravity = -22.0f;
        lp->spritesheet = @"sprites_china";
        lp->personSpeedMul = 1.2;
        lp->restitutionMul = 1.2;
        lp->frictionMul = .95;
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"Baozi_Rise.png";
        dd->fallSprite = @"Baozi_Fall.png";
        dd->mainSprite = @"Baozi.png";
        dd->grabSprite = @"Baozi_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Baozi_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Baozi.png"]]];
        }
        for(int i = 1; i <= 9; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Baozi_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 6; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Baozi_Shoot_%d.png", i]]];
        }
        lp->specialDog = dd;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        float scaleX = 1, scaleY = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scaleX = IPAD_SCALE_FACTOR_X;
            scaleY = IPAD_SCALE_FACTOR_Y;
        }
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        bgComponent *bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"China_LightOverlay.png"];
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.652, winSize.height*.535);
        bgc->sprite.tag = 1;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [CCSprite spriteWithSpriteFrameName:@"China_Lanterns.png"];
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.652, winSize.height*.82);
        bgc->sprite.tag = 2;
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
    }
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_china.plist"];
    return [NSValue valueWithPointer:lp];
}

+(NSValue *)japan:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * JAPAN LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"japan";
    lp->name = @"Yamanashi";
    lp->unlockNextThreshold = 8000;
    lp->func = @"switchScreenJapan";
    lp->thumbnail = @"Japan_Thumb.png";
    lp->unlockTweet = @"I was ready to relax in a calming Japanese hot spring in @HeadsUpHotDogs";
    
    if(loadFull){
        lp->bg = @"Japan_BG.png";
        lp->bgm = @"gameplay 1.mp3";
        lp->gravity = -28.0f;
        lp->spritesheet = @"sprites_japan";
        lp->dogDeathDelay = .001;
        lp->personSpeedMul = .7;
        lp->maxDogs = 7;
        lp->gravity = -17.0;
        lp->spawnInterval = 4.0;
        
        lp->dogDeathAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 9; i++){
            [lp->dogDeathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Splash_%d.png", i]]];
        }
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"YakisobaPan_Rise.png";
        dd->fallSprite = @"YakisobaPan_Fall.png";
        dd->mainSprite = @"YakisobaPan.png";
        dd->grabSprite = @"YakisobaPan_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"YakisobaPan_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"YakisobaPan_Die_2.png"]]];
        }
        for(int i = 1; i <= 11; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"YakisobaPan_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 10; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"YakisobaPan_Shoot_%d.png", i]]];
        }
        lp->specialDog = dd;
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_japan.plist"];
    }
    return [NSValue valueWithPointer:lp];
}
    
+(NSValue *)chicago:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * CHICAGO LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = true;
    lp->slug = @"chicago";
    lp->name = @"Chicago";
    lp->unlockNextThreshold = 12000;
    lp->thumbnail = @"Chicago_Thumb.png";
    lp->func = @"switchScreenChicago";
    lp->unlockTweet = @"I traveled to the Windy City in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_chicago.plist"];
        lp->bg = @"Chicago_BG.png";
        lp->bgm = @"gameplay 1.mp3";
        lp->gravity = -27.0f;
        lp->spritesheet = @"sprites_chicago";
        lp->personSpeedMul = 1;
        lp->restitutionMul = 1.1;
        lp->frictionMul = 1.1;
        lp->maxDogs = 5;
        lp->hasShiba = true;
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"ChiDog_Rise.png";
        dd->fallSprite = @"ChiDog_Fall.png";
        dd->mainSprite = @"ChiDog.png";
        dd->grabSprite = @"ChiDog_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"ChiDog_Death_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"ChiDog_Death_2.png"]]];
        }
        for(int i = 1; i <= 8; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"ChiDog_Death_%d.png", i]]];
        }
        for(int i = 1; i <= 5; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"ChiDog_Shot_%d.png", i]]];
        }
        
        lp->specialDog = dd;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float scaleX = 1, scaleY = 1;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            scaleX = IPAD_SCALE_FACTOR_X;
            scaleY = IPAD_SCALE_FACTOR_Y;
        }
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        bgComponent *bgc = new bgComponent();
        bgc->sprite = [[CCSprite spriteWithSpriteFrameName:@"Flag_Flap_1.png"] retain];
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.96, winSize.height*.765);
        bgc->anim1 = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 4; i++){
            [bgc->anim1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Flag_Flap_%d.png", i]]];
        }
        bgc->anim2 = [[NSMutableArray alloc] init];
        for(int i = 8; i <= 11; i++){
            [bgc->anim2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Flag_Flap_%d.png", i]]];
        }
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [[CCSprite spriteWithSpriteFrameName:@"Flag_Flap_1.png"] retain];
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.039, winSize.height*.834);
        bgc->anim1 = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 4; i++){
            [bgc->anim1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Flag_Flap_%d.png", i]]];
        }
        bgc->anim2 = [[NSMutableArray alloc] init];
        for(int i = 8; i <= 11; i++){
            [bgc->anim2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Flag_Flap_%d.png", i]]];
        }
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        bgc = new bgComponent();
        bgc->sprite = [[CCSprite spriteWithSpriteFrameName:@"Dust1_1.png"] retain];
        bgc->sprite.scaleX = scaleX;
        bgc->sprite.scaleY = scaleY;
        bgc->sprite.position = CGPointMake(winSize.width*.372, winSize.height*.062);
        bgc->anim1 = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 6; i++){
            [bgc->anim1 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                   [NSString stringWithFormat:@"Dust1_%d.png", i]]];
        }
        [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_chicago.plist"];
    }
    return [NSValue valueWithPointer:lp];
}

+(NSValue *)space:(NSNumber *)full{
    BOOL loadFull = [full boolValue];
    /********************************************************************************
     * SPACE LEVEL SETTINGS
     *******************************************************************************/
    
    levelProps *lp = new levelProps();
    lp->enabled = false;
    lp->slug = @"space";
    lp->name = @"Space Station";
    lp->unlockNextThreshold = 20000;
    lp->thumbnail = @"Space_Thumb.png";
    lp->func = @"switchScreenSpace";
    lp->unlockTweet = @"We sent a frankfurter to the moon in @HeadsUpHotDogs";
    
    if(loadFull){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_space.plist"];
        lp->bg = @"SpaceBG.png";
        lp->bgm = @"gameplay 3.mp3";
        lp->gravity = -40.0f;
        lp->spritesheet = @"sprites_space";
        lp->personSpeedMul = 1.1;
        lp->restitutionMul = 1.7;
        lp->frictionMul = 100;
        lp->hasShiba = true;
        
        spcDogData *dd = new spcDogData();
        dd->riseSprite = @"Chips_Rise.png";
        dd->fallSprite = @"Chips_Fall.png";
        dd->mainSprite = @"Chips.png";
        dd->grabSprite = @"Chips_Grab.png";
        dd->deathAnimFrames = [[NSMutableArray alloc] init];
        dd->shotAnimFrames = [[NSMutableArray alloc] init];
        dd->flashAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Chips_Die_1.png"]]];
            [dd->flashAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Chips_Die_2.png"]]];
        }
        for(int i = 1; i <= 8; i++){
            [dd->deathAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Chips_Die_%d.png", i]]];
        }
        for(int i = 1; i <= 6; i++){
            [dd->shotAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Chips_Shoot%d.png", i]]];
        }
        lp->specialDog = dd;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        lp->bgComponents = [[NSMutableArray alloc] init];
        int y = 152.5*(winSize.height/320);
        bgComponent *bgc;
        for(int i = 2; i <= 10; i++){
            bgc = new bgComponent();
            bgc->sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Grav_%d.png", i]];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                bgc->sprite.scaleX = IPAD_SCALE_FACTOR_X;
                bgc->sprite.scaleY = IPAD_SCALE_FACTOR_Y;
            }
            bgc->sprite.position = CGPointMake(219.5*((float)winSize.width/320), y+((bgc->sprite.scaleY*(bgc->sprite.contentSize.height+.8*IPAD_SCALE_FACTOR_Y))*(i-1)));
            [lp->bgComponents addObject:[NSValue valueWithPointer:bgc]];
        }
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sprites_space.plist"];
    }
    return [NSValue valueWithPointer:lp];
}

@end
