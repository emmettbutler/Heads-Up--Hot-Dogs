//
//  CharBuilder.h
//  Heads Up
//
//  Created by Emmett Butler on 7/22/12.
//  Copyright 2012 NYU. All rights reserved.
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
        int pointValue;
        NSMutableArray *walkAnimFrames;
        NSMutableArray *idleAnimFrames; 
        NSMutableArray *faceWalkAnimFrames;
        NSMutableArray *faceDogWalkAnimFrames;
        NSMutableArray *shootAnimFrames;
        NSMutableArray *shootFaceAnimFrames;
        NSMutableArray *armShootAnimFrames;
    };
}

+(NSMutableArray *)buildCharacters:(NSString *)levelSlug;

@end
