//
//  TutorialLayer.mm
//  sandbox
//
//  Created by Emmett Butler on 1/14/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "GameplayLayer.h"
#import "TitleScene.h"
#import "TutorialLayer.h"
#import "OptionsLayer.h"

@implementation TutorialLayer

+(CCScene *)sceneWithFrom:(NSString *)from{
	CCScene *scene = [CCScene node];
    CCLOG(@"in scenewithData");
	TutorialLayer *layer;
    layer = [TutorialLayer node];
    layer->_from = from;
	[scene addChild:layer];
	return scene;
}

-(void)tutorialBoxRemove{
    if(_introLayer != NULL){
        [self removeChild:_introLayer cleanup:YES];
        _introLayer = NULL;
    }
}

-(void)introTutorialTextBox:(void*)params {
    int boxY = 50;
    int boxX = 80;
    
    
    NSString *text = (NSString *)[(NSValue *)[(NSMutableArray *) params objectAtIndex:0] pointerValue];
    tutorialLabel = [CCLabelTTF labelWithString:text fontName:@"LostPet.TTF" fontSize:19.0];
    
    _introLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 255, 125) width:(tutorialLabel.contentSize.width+20) height:50];
    _introLayer.position = ccp(boxX, boxY);
    [spritesLayer addChild:_introLayer z:80];
    
    [tutorialLabel setPosition:ccp((_introLayer.contentSize.width/2), (_introLayer.contentSize.height/2))];
    [_introLayer addChild:tutorialLabel z:81];
}

-(CCAction *)frames2Action:(NSMutableArray *)frames{
    anim = [CCAnimation animationWithFrames:frames delay:.1f];
    return [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
}

-(id) init{
    if ((self = [super init])){
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        tutorialPage *page;
        tutorialSprite *tSprite;
        
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        _color_pink = ccc3(255, 62, 166);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"tutorial_sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"tutorial_sprites_default.png"];
        [self addChild:spriteSheet];
        
        tutPages = [[NSMutableArray alloc] init];
        
        animFrames = [[NSMutableArray alloc] init];
        page = new tutorialPage();
        tSprite = new tutorialSprite();
        page->sprites = [[NSMutableArray alloc] init];
        page->caption = [NSString stringWithString:@"This is a hot dog. It loves to travel."];
        for(int i = 1; i <= 10; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Dog_Appear_%d.png", i]]];
        }
        for(int i = 1; i <= 10; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"dog54x12.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(winSize.width/2,275);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        [tutPages addObject:[NSValue valueWithPointer:page]];
        
        animFrames = [[NSMutableArray alloc] init];
        page = new tutorialPage();
        tSprite = new tutorialSprite();
        page->sprites = [[NSMutableArray alloc] init];
        page->caption = [NSString stringWithString:@"It hates sitting still. Lose 5 and you're out."];
        for(int i = 1; i < 8; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Dog_Die_1.png"]]];
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Dog_Die_2.png"]]];
        }
        for(int i = 1; i <= 7; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Dog_Die_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(winSize.width/2,40);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        for(int i = 1; i <= 16; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"WienerCount_Wiener.png"]]];
        }
        for(int i = 1; i <= 5; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"WienerCount_X.png"]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake((winSize.width/2)+30,290);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        [tutPages addObject:[NSValue valueWithPointer:page]];
        
        animFrames = [[NSMutableArray alloc] init];
        page = new tutorialPage();
        tSprite = new tutorialSprite();
        page->sprites = [[NSMutableArray alloc] init];
        page->caption = [NSString stringWithString:@"This is the hot dogs' transportation."];
        for(int i = 1; i < 6; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"BusinessMan_Walk_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(300,90);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        for(int i = 1; i < 3; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"BusinessHead_NoDog_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(300,185);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        [tutPages addObject:[NSValue valueWithPointer:page]];
        
        animFrames = [[NSMutableArray alloc] init];
        page = new tutorialPage();
        tSprite = new tutorialSprite();
        page->sprites = [[NSMutableArray alloc] init];
        page->caption = [NSString stringWithString:@"Their heads can carry hot dogs."];
        for(int i = 1; i < 6; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"BusinessMan_Walk_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(200,90);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        for(int i = 1; i < 3; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"BusinessHead_Dog_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(200,185);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        for(int i = 1; i < 11; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"plusTen%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(200,258);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"dog54x12.png"]]];
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(200,228);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        [tutPages addObject:[NSValue valueWithPointer:page]];
        
        animFrames = [[NSMutableArray alloc] init];
        page = new tutorialPage();
        tSprite = new tutorialSprite();
        page->sprites = [[NSMutableArray alloc] init];
        page->caption = [NSString stringWithString:@"The dogs get carried away"];
        for(int i = 1; i < 6; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"BusinessMan_Walk_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(0,90);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        for(int i = 1; i < 3; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"BusinessHead_Dog_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(0,185);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        for(int i = 1; i < 18; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Plus_100_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(88,278);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        [animFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"dog54x12.png"]]];
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(0,228);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        [tutPages addObject:[NSValue valueWithPointer:page]];
        
        animFrames = [[NSMutableArray alloc] init];
        page = new tutorialPage();
        tSprite = new tutorialSprite();
        page->sprites = [[NSMutableArray alloc] init];
        page->caption = [NSString stringWithString:@"But watch out for the police!"];
        for(int i = 1; i < 6; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Cop_Idle.png"]]];
        }
        for(int i = 1; i < 3; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Cop_Shoot_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(300,90);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        for(int i = 1; i < 6; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"cop_arm.png"]]];
        }
        for(int i = 1; i < 3; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Cop_Arm_Shoot_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(243,130);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        for(int i = 1; i < 6; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Cop_Head_Shoot_2.png"]]];
        }
        for(int i = 1; i < 3; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Cop_Head_Shoot_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(300,185);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        tSprite = new tutorialSprite();
        animFrames = [[NSMutableArray alloc] init];
        for(int i = 1; i < 5; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"dog54x12.png"]]];
        }
        for(int i = 1; i < 4; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Dog_Shot_%d.png", i]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake(100,130);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        animFrames = [[NSMutableArray alloc] init];
        tSprite = new tutorialSprite();
        for(int i = 1; i < 6; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"WienerCount_Wiener.png"]]];
        }
        for(int i = 1; i < 3; i++){
            [animFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"WienerCount_X.png"]]];
        }
        tSprite->animFrames = animFrames;
        tSprite->location = CGPointMake((winSize.width/2)+30,290);
        [page->sprites addObject:[NSValue valueWithPointer:tSprite]];
        [tutPages addObject:[NSValue valueWithPointer:page]];
        
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"bg_philly.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"LvlArrow.png"];
        sprite.position = ccp(winSize.width-52, winSize.height/2);
        sprite.flipX = true;
        [self addChild:sprite];
        
        spritesLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0) width:winSize.width height:winSize.height];
        [self addChild:spritesLayer z:100];
        
        CCSprite *restartButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        restartButton.position = ccp(110, 27);
        [self addChild:restartButton z:10];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"     Skip     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = ccc3(255, 62, 166);
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneStart)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(110, 26)];
        [self addChild:menu z:11];
        
        CCSprite *quitButton = [CCSprite spriteWithSpriteFrameName:@"MenuItems_BG.png"];
        quitButton.position = ccp(370, 27);
        [self addChild:quitButton z:10];
        label = [CCLabelTTF labelWithString:@"     Title     " fontName:@"LostPet.TTF" fontSize:22.0];
        [[label texture] setAliasTexParameters];
        label.color = ccc3(255, 62, 166);
        button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchSceneTitleScreen)];
        menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(370, 26)];
        [self addChild:menu z:11];
        
        label = [CCLabelTTF labelWithString:@"How to play" fontName:@"LostPet.TTF" fontSize:25.0];
        [[label texture] setAliasTexParameters];
        label.color = _color_pink;
        label.position = ccp((label.contentSize.width/2)+6, winSize.height-(label.contentSize.height/2)-5);
        [self addChild:label];
        
        count = 0;
        
        self.isTouchEnabled = YES;
        
        tutorialPage *page1 = (tutorialPage *)[(NSValue *)[tutPages objectAtIndex:0] pointerValue];
        
        NSMutableArray *boxParams = [[NSMutableArray alloc] init];
        [boxParams addObject:[NSValue valueWithPointer:page1->caption]];
        [self introTutorialTextBox:boxParams];
        
        CCLOG(@"Page1 sprites count: %d", [page1->sprites count]);
        
        for(int i = 0; i < [page1->sprites count]; i++){
            s = [CCSprite spriteWithSpriteFrameName:@"dog54x12.png"]; //placeholder
            tutorialSprite *ts = (tutorialSprite *)[(NSValue *)[page1->sprites objectAtIndex:i]  pointerValue];
            s.position = ts->location;
            [spritesLayer addChild:s];
            [s runAction:[self frames2Action:ts->animFrames]];
        }
        
        [self schedule: @selector(tick:)];
    }
    return self;
}

-(void) tick: (ccTime) dt {
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [spritesLayer removeAllChildrenWithCleanup:YES];
    count++;
    CCLOG(@"Touch registered, count %d", count);
    
    if(count > 5){
        NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:1];
        [params addObject:[NSString stringWithString:@"philly"]];
        if(_from == @"options")
            [[CCDirector sharedDirector] replaceScene:[OptionsLayer scene]];
        else
            [[CCDirector sharedDirector] replaceScene:[GameplayLayer sceneWithData:params]];
        return;
    }
    
    tutorialPage *page = (tutorialPage *)[(NSValue *)[tutPages objectAtIndex:count] pointerValue];
    
    NSMutableArray *boxParams = [[NSMutableArray alloc] init];
    [boxParams addObject:[NSValue valueWithPointer:page->caption]];
    [self introTutorialTextBox:boxParams];
    
    CCLOG(@"Page sprites count: %d", [page->sprites count]);
    for(int i = 0; i < [page->sprites count]; i++){
        s = [CCSprite spriteWithSpriteFrameName:@"dog54x12.png"]; //placeholder
        tutorialSprite *ts = (tutorialSprite *)[(NSValue *)[page->sprites objectAtIndex:i] pointerValue];
        s.position = ts->location;
        [spritesLayer addChild:s];
        [s runAction:[self frames2Action:ts->animFrames]];
    }
}

- (void)switchSceneStart{
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:1];
    [params addObject:[NSString stringWithString:@"philly"]];
    [[CCDirector sharedDirector] replaceScene:[GameplayLayer sceneWithData:params]];
}

- (void)switchSceneTitleScreen{
    [[CCDirector sharedDirector] replaceScene:[TitleLayer scene]];
}

-(void) dealloc{
    // this causes a crash in gameplaylayer due to sprite frame namespace collisions
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile: @"tutorial_sprites_default.plist"];
    [super dealloc];
}

@end