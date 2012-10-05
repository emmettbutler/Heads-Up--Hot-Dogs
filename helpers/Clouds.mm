//
//  Clouds.mm
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import "Clouds.h"
#import "GameplayLayer.h"


@implementation Clouds

-(Clouds *)initWithLayer:(NSValue *)s andSpritesheet:(NSValue *)sheet{
    CGSize size = [[CCDirector sharedDirector] winSize];
    //CCLayer *parent = (CCLayer *)[s pointerValue];
    self->spritesheet = (CCSpriteBatchNode *)[sheet pointerValue];
    //[parent addChild:self->spritesheet];
    
    float scale = 1, windowWidth = size.width, windowHeight = size.height;
    if(!(size.width > size.height)){
        windowHeight = size.width;
        windowWidth = size.height;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        scale = 2.13;
    }
    
    self->cloud1 = [CCSprite spriteWithSpriteFrameName:@"Cloud_1.png"];
    self->cloud1.position = ccp(windowWidth+24, windowHeight/2-71);
    self->cloud1.scale = scale;
    [[self->cloud1 texture] setAliasTexParameters];
    [self->spritesheet addChild:self->cloud1];
    
    self->cloud2 = [CCSprite spriteWithSpriteFrameName:@"Cloud_3.png"];
    self->cloud2.position = ccp(42, windowHeight);
    self->cloud2.scale = scale;
    [self->spritesheet addChild:self->cloud2];
    
    self->cloud3 = [CCSprite spriteWithSpriteFrameName:@"Cloud_2.png"];
    self->cloud3.position = ccp(-6, 17);
    self->cloud3.scale = scale;
    [self->spritesheet addChild:self->cloud3];
    
    [self->cloud1 runAction:[CCMoveTo actionWithDuration:90 position:CGPointMake(0, self->cloud1.position.y)]];
    [self->cloud2 runAction:[CCMoveTo actionWithDuration:80 position:CGPointMake(windowWidth, self->cloud2.position.y)]];
    [self->cloud3 runAction:[CCMoveTo actionWithDuration:100 position:CGPointMake(windowWidth, self->cloud3.position.y)]];
    
    return self;
}

-(void)dealloc:(id)sender{
    [self->cloud1 removeFromParentAndCleanup:YES];
    [self->cloud2 removeFromParentAndCleanup:YES];
    [self->cloud3 removeFromParentAndCleanup:YES];
    [super dealloc];
}

@end