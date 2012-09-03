//
//  Overlay.mm
//  Heads Up
//
//  Created by Emmett Butler on 8/15/12.
//  Copyright 2012 NYU. All rights reserved.
//

#import "Overlay.h"
#import "GameplayLayer.h"


@implementation Overlay

-(Overlay *)initWithDogBody:(NSValue *)b andSpriteSheet:(NSValue *)s{
    self->body = (b2Body *)[b pointerValue];
    self->sprite = [CCSprite spriteWithSpriteFrameName:@"Drag_Overlay_1.png"];
    self->spritesheet = (CCSpriteBatchNode *)[s pointerValue];
    self->sprite.position = CGPointMake(self->body->GetPosition().x*PTM_RATIO, self->body->GetPosition().y*PTM_RATIO);
    [self->spritesheet addChild:self->sprite];
    
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 12; i++){
        [frames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Drag_Overlay_%d.png", i]]];
    }
    CCAnimation *anim = [CCAnimation animationWithFrames:frames delay:.12];
    self->action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
    
    return self;
}

-(Overlay *)initWithPersonBody:(NSValue *)b andSpriteSheet:(NSValue *)s{
    self->body = (b2Body *)[b pointerValue];
    self->sprite = [CCSprite spriteWithSpriteFrameName:@"Drop_Overlay_1.png"];
    self->spritesheet = (CCSpriteBatchNode *)[s pointerValue];
    self->sprite.position = CGPointMake(self->body->GetPosition().x*PTM_RATIO, self->body->GetPosition().y*PTM_RATIO);
    [self->spritesheet addChild:self->sprite];
    
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 12; i++){
        [frames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Drop_Overlay_%d.png", i]]];
    }
    CCAnimation *anim = [CCAnimation animationWithFrames:frames delay:.12];
    self->action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
    
    return self;
}

-(Overlay *)initWithMuncherBody:(NSValue *)b andSpriteSheet:(NSValue *)s{
    self->body = (b2Body *)[b pointerValue];
    self->sprite = [CCSprite spriteWithSpriteFrameName:@"Rub_Overlay_1.png"];
    self->spritesheet = (CCSpriteBatchNode *)[s pointerValue];
    self->sprite.position = CGPointMake(self->body->GetPosition().x*PTM_RATIO, self->body->GetPosition().y*PTM_RATIO);
    [self->spritesheet addChild:self->sprite];
    
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    for(int i = 1; i <= 12; i++){
        [frames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Rub_Overlay_%d.png", i]]];
    }
    CCAnimation *anim = [CCAnimation animationWithFrames:frames delay:.12];
    self->action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO]];
    
    return self;
}

-(void)updatePosition{
    self->sprite.position = CGPointMake(self->body->GetPosition().x*PTM_RATIO, self->body->GetPosition().y*PTM_RATIO);
}

@end