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
        int tag, armTag, pointValue, fTag, frequency;
        NSString *upperSprite, *slug, *spritesheet, *lowerSprite, *upperOverlaySprite, *rippleSprite, *armSprite, *targetSprite;
        float hitboxWidth, hitboxHeight, hitboxCenterX, hitboxCenterY, moveDelta, sensorHeight, sensorWidth, restitution, framerate, friction, heightOffset, widthOffset, lowerArmAngle, upperArmAngle, armJointXOffset, rippleXOffset, rippleYOffset;
        BOOL flipSprites;
        NSMutableArray *walkAnimFrames, *idleAnimFrames, *faceWalkAnimFrames, *faceDogWalkAnimFrames, *rippleWalkAnimFrames, *rippleIdleAnimFrames, *specialAnimFrames, *specialFaceAnimFrames, *armShootAnimFrames, *altWalkAnimFrames, *altFaceWalkAnimFrames, *postStopAnimFrames, *vomitAnimFrames;
    };
}

+(NSMutableArray *)buildCharacters:(NSString *)levelSlug;
+(NSMutableArray *)buildCharacterNames:(NSString *)levelSlug;

@end