//
//  Clouds.mm
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "Clouds.h"
#import "GameplayLayer.h"


@implementation Clouds

-(Clouds *)initWithLayer:(NSValue *)s{
    CGSize size = [CCDirector sharedDirector].winSize;
    CCLayer *parent = (CCLayer *)[s pointerValue];
    self->spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_menus.png"];
    [parent addChild:self->spritesheet];
    
    self->cloud1 = [CCSprite spriteWithSpriteFrameName:@"Cloud_1.png"];
    self->cloud1.position = ccp(size.width, size.height/2-50);
    [self->spritesheet addChild:self->cloud1];
    
    self->cloud2 = [CCSprite spriteWithSpriteFrameName:@"Cloud_2.png"];
    self->cloud2.position = ccp(0, size.height);
    [self->spritesheet addChild:self->cloud2];
    
    self->cloud3 = [CCSprite spriteWithSpriteFrameName:@"Cloud_3.png"];
    self->cloud3.position = ccp(0, 50);
    [self->spritesheet addChild:self->cloud3];
    
    [self->cloud1 runAction:[CCMoveTo actionWithDuration:90 position:CGPointMake(0, self->cloud1.position.y)]];
    [self->cloud2 runAction:[CCMoveTo actionWithDuration:80 position:CGPointMake(size.width, self->cloud2.position.y)]];
    [self->cloud3 runAction:[CCMoveTo actionWithDuration:100 position:CGPointMake(size.width, self->cloud3.position.y)]];
    
    return self;
}

@end