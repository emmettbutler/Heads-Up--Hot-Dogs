//
//  CharBuilder.h
//  Heads Up
//
//  Created by Emmett Butler on 7/22/12.
//  Copyright 2012 Sugoi Papa Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CharBuilder : NSObject {
    struct personStruct {
        NSString *slug;
        NSString *spritesheet;
        int tag;
        int armTag;
        NSString *upperSprite;
        NSString *lowerSprite;
        NSString *upperOverlaySprite;
        NSString *rippleSprite;
        NSString *armSprite;
        NSString *targetSprite;
        float hitboxWidth;
        float hitboxHeight;
        float hitboxCenterX;
        float hitboxCenterY;
        float moveDelta;
        float sensorHeight;
        float sensorWidth;
        float restitution;
        float framerate;
        float friction;
        float heightOffset;
        float lowerArmAngle;
        float upperArmAngle;
        float armJointXOffset;
        int fTag;
        int frequency;
        float rippleXOffset;
        float rippleYOffset;
        int pointValue;
        BOOL flipSprites;
        NSMutableArray *walkAnimFrames;
        NSMutableArray *idleAnimFrames; 
        NSMutableArray *faceWalkAnimFrames;
        NSMutableArray *faceDogWalkAnimFrames;
        NSMutableArray *rippleWalkAnimFrames;
        NSMutableArray *rippleIdleAnimFrames;
        NSMutableArray *specialAnimFrames;
        NSMutableArray *specialFaceAnimFrames;
        NSMutableArray *armShootAnimFrames;
        NSMutableArray *altWalkAnimFrames;
        NSMutableArray *altFaceWalkAnimFrames;
        NSMutableArray *postStopAnimFrames;
        NSMutableArray *vomitAnimFrames;
    };
}

+(NSMutableArray *)buildCharacters:(NSString *)levelSlug;
+(NSMutableArray *)buildCharacterNames:(NSString *)levelSlug;

@end
