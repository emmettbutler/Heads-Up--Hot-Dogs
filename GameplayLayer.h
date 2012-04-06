//
//  HelloWorldLayer.h
//  sandbox
//
//  Created by Emmett Butler on 1/3/12.
//  Copyright NYU 2012. All rights reserved.
//

//character sprite tags will be in the range 3-10
//3: businessman
//4:

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "PersonDogContactListener.h"

@interface GameplayLayer : CCLayer
{
    b2World *_world;
    GLESDebugDraw *m_debugDraw;
    b2Body *_wallsBody, *_groundBody, *wienerBody, *targetBody, *_personBody, *_policeArmBody;
    b2Fixture *_bottomFixture, *_wallsFixture, *_wienerFixture, *_targetFixture, *_personFixture, *_policeArmFixture;
    CCSprite *_wiener, *_personLower, *_personUpper, *_target, *_pauseButton;
    b2MouseJoint *_mouseJoint;
    CCAction *_walkAction, *_walkFaceAction;
    CCFiniteTimeAction *_idleAction, *_appearAction, *_hitAction, *_shotAction, *_shootAction, *_armShootAction;
    CCAnimation *walkAnim, *idleAnim, *hitAnim, *dogDeathAnim, *dogAppearAnim, *walkFaceAnim, *dogShotAnim, *shootAnim, *armShootAnim;
    CCSpriteBatchNode *spriteSheet;
    CCLabelTTF *scoreLabel, *droppedLabel;
    b2Vec2 p1, p2;
    b2RevoluteJoint *policeArmJoint;
    CCLayerColor *_pauseLayer;
    CCMenu *_pauseMenu;
    NSMutableArray *floorBits, *xPositions, *characterTags, *wienerParameters, *headParams;
    NSMutableArray *personParameters, *wakeParameters, *movementPatterns, *movementParameters, *_touchLocations;
    NSString *scoreText, *droppedText;
    int _points, _droppedCount, _spawnLimiter, time, _curPersonMaskBits, _droppedSpacing;
    float _personSpawnDelayTime, _wienerSpawnDelayTime, _wienerKillDelay, _currentRayAngle;
    BOOL _moving, _touchedDog, _rayTouchingDog, _pause, _shootLock;
    NSString *currentAnimation;
    CGRect _pauseButtonRect;

    struct bodyUserData {
        CCSprite *sprite1;
        CCSprite *sprite2;
        float heightOffset2;
        float lengthOffset2;
        NSString *ogSprite2;
        NSString *altSprite2;
        NSString *altSprite3; //the 3 here has a different meaning than the 2 above - ie it's the 3rd sprite
        CCSprite *overlaySprite;
        CCAction *altAction;
        CCAction *altAction2;
        CCAnimation *defaultAnim;
        CCAnimation *altAnimation;
        float armSpeed;
        BOOL aiming;
        BOOL aimedAt;
        double targetAngle;
    };

    struct fixtureUserData {
        int tag;
        int ogCollideFilters;
    };

    enum _entityCategory {
        FLOOR1  = 0x0001,
        FLOOR2  = 0x0002,
        FLOOR3  = 0x0004,
        FLOOR4  = 0x0008,
        WALLS   = 0x0010,
        //PERSON  = 0x0020,
        WIENER  = 0x0040,
        BODYBOX = 0x0080,
        TARGET  = 0x0100,
      };

      PersonDogContactListener *personDogContactListener;
}

@property (nonatomic, retain) CCSprite *personLower;
@property (nonatomic, retain) CCSprite *personUpper;
@property (nonatomic, retain) CCSprite *policeArm;
@property (nonatomic, retain) CCSprite *wiener;
@property (nonatomic, retain) CCSprite *target;
@property (nonatomic, retain) CCAction *walkAction;
@property (nonatomic, retain) CCAction *walkFaceAction;
@property (nonatomic, retain) CCAction *idleAction;
@property (nonatomic, retain) CCFiniteTimeAction *deathAction;
@property (nonatomic, retain) CCFiniteTimeAction *idleFaceAction;
@property (nonatomic, retain) CCFiniteTimeAction *shotAction;
@property (nonatomic, retain) CCFiniteTimeAction *shootAction;
@property (nonatomic, retain) CCFiniteTimeAction *armShootAction;
@property (nonatomic, retain) CCAction *appearAction;
@property (nonatomic, retain) NSString *hitFace;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
