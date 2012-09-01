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
#import <SimpleAudioEngine.h>
#import "GLES-Render.h"
#import "PersonDogContactListener.h"
#import "LevelSelectLayer.h"
#import "AchievementReporter.h"
#import "Firecracker.h"
#import "Shiba.h"

#define FLOOR1_HT 0
#define FLOOR1_Z 42
#define FLOOR2_HT .4
#define FLOOR2_Z 32
#define FLOOR3_HT .8
#define FLOOR3_Z 22
#define FLOOR4_HT 1.2
#define FLOOR4_Z 12
#define PTM_RATIO 32

@interface GameplayLayer : CCLayer
{
    b2World *_world;
    AchievementReporter *reporter;
    levelProps *level;
    GLESDraw *m_debugDraw;
    b2Body *_wallsBody, *_groundBody, *targetBody, *_personBody, *_policeArmBody;
    b2Fixture *_bottomFixture, *_wallsFixture, *_wienerFixture, *_targetFixture, *_personFixture, *_policeArmFixture;
    CCSprite *_wiener, *_personLower, *_personUpper, *_personUpperOverlay, *_rippleSprite, *_target, *_pauseButton, *background;
    CCAction *_walkAction, *_walkFaceAction, *_altFaceWalkAction, *_altWalkAction, *_flag1RightAction, *_flag1LeftAction, *_flag2RightAction, *_flag2LeftAction, *_dustAction;
    CCFiniteTimeAction *_idleAction, *_appearAction, *_hitAction, *_shotAction, *_specialAction, *_armShootAction, *_specialFaceAction, *_specialAngryFaceAction, *_postStopAction;
    CCAnimation *walkAnim, *idleAnim, *hitAnim, *dogDeathAnim, *dogAppearAnim, *walkFaceAnim, *walkDogFaceAnim;
    CCAnimation *dogShotAnim, *specialAnim, *armShootAnim, *specialFaceAnim, *specialAngryFaceAnim, *altWalkAnim, *altFaceWalkAnim, *postStopAnim;
    CCSpriteBatchNode *spriteSheetCommon, *spriteSheetLevel, *spriteSheetCharacter;
    CCLabelTTF *scoreLabel, *droppedLabel, *gravityLabel;
    b2Vec2 policeRayPoint1, policeRayPoint2;
    CCLayerColor *_pauseLayer, *_flashLayer;
    steamVent *vent1, *vent2;
    NSMutableArray *bgSprites;
    CCMenu *_pauseMenu;
    NSMutableArray *floorBits, *xPositions, *wienerParameters, *headParams, *mouseJoints, *dogTouches;
    NSMutableArray *personParameters, *wakeParameters, *movementPatterns, *movementParameters, *_touchLocations, *dogIcons, *allTouchHashes;
    NSString *scoreText, *droppedText;
    int _points, _droppedCount, _spawnLimiter, time, _curPersonMaskBits, _droppedSpacing, _lastTouchTime, _firstDeathTime, lowerArmAngle, upperArmAngle;
    int _peopleGrumped, _dogsSaved, _id_counter, _numTouches, _dogsOnscreen, _maxDogsOnScreen, _numWorldTouches, _sfxVol, _levelMaxDogs;
    float _wienerSpawnDelayTime, _currentRayAngle, _levelSpawnInterval;
    BOOL _moving, _touchedDog, _rayTouchingDog, _pause, _shootLock, _dogHasHitGround, _dogHasDied, _policeOnScreen, _muncherOnScreen, _gameOver, _ventsOn, _hasDroppedDog;
    NSString *currentAnimation, *slug;
    CGSize winSize;
    CGRect _pauseButtonRect;
    NSUserDefaults *standardUserDefaults;
    NSInteger _overallTime, _sfxOn;
    Firecracker *firecracker;
    Shiba *shiba;
    CCDelayTime *winUpDelay, *winDownDelay;
    CCCallFuncN *removeWindow;
    ccColor3B _color_pink;

    struct bodyUserData {
        CCSprite *sprite1, *sprite2, *angryFace, *ripples, *overlaySprite;
        float heightOffset2, widthOffset, lengthOffset2, lowerXOffset, lowerYOffset;
        NSString *_dog_fallSprite, *_dog_riseSprite, *_dog_grabSprite, *_dog_mainSprite, *ogSprite2, *aimFace;
        CCAction *altAction, *walkRipple, *idleRipple, *altAction2, *altAction3, *altWalk, *altWalkFace, *idleAction, *defaultAction, *angryFaceWalkAction, *dogOnHeadTickleAction, *deathSeq, *shotSeq;
        CCAnimation *altAnimation;
        CCFiniteTimeAction *postStopAction, *_not_dogContact, *_not_dogOnHead, *_not_leaveScreen, *_not_leaveScreenFlash, *_not_spcContact, *_not_spcOnHead, *_not_spcLeaveScreen, *_vomitAction;
        CGRect boundingBox;
        // end point notifiers
        float armSpeed, rippleXOffset, rippleYOffset;
        float deathDelay; // how long a hot dog sits on the ground before dying, in seconds
        float moveDelta; // the linear velocity of the person
        int stopTime; // time into walk at which person should pause
        int stopTimeDelta; // how long the pause should last
        int timeWalking; // how long has this person been walking
        int restartTime, pointValue; // how many points is a dog contact on this head worth?
        BOOL aiming, touched, exploding, touchLock, aimedAt, grabbed, deathSeqLock, animLock, hasLeftScreen;
        double targetAngle;
        int dogsOnHead, spcDogsOnHead, unique_id, tickleTimer, collideFilter;
        BOOL hasTouchedHead, _dog_isOnHead, _person_hasTouchedDog, _muncher_hasDroppedDog, _cop_hasShot, _busman_willVomit, _busman_isVomiting;
    };

    struct fixtureUserData {
        int tag;
        int ogCollideFilters;
    };
    
    struct mouseJointUserData {
        int touch; // the unique identifier for this mouse joint
        double prevX;
        double prevY;
    };

    enum _collisionFilters {
        FLOOR1  = 0x0001,
        FLOOR2  = 0x0002,
        FLOOR3  = 0x0004,
        FLOOR4  = 0x0008,
        WALLS   = 0x0010,
        WIENER  = 0x0040,
        BODYBOX = 0x0080, // character bodies
        TARGET  = 0x0100,
        SENSOR  = 0x0200,
    };
    
    enum _spriteTags {
        S_HOTDOG    =   1,
        S_SPCDOG    =   2,
        S_BUSMAN    =   3,
        S_POLICE    =   4,
        S_CRPUNK    =   5,
        S_JOGGER    =   6,
        S_YNGPRO    =   7,
        S_MUNCHR    =   8,
        S_PROFSR    =   9,
        S_TOPPSN    =   10, // top person sprite tag, this must be TOPPSN > POLICE > BUSMAN with only person tags between
        S_COPARM    =   11,
        S_CRSHRS    =   20, // crosshairs
    };
    
    enum _fixtureTags {
        F_DOGGRB    =   0, // hotdog grab box
        F_DOGCLD    =   1, // hotdog collisions
        F_BUSHED    =   3, // businessman's head
        F_COPHED    =   4, // cop's head
        F_PNKHED    =   5, // crust punk's head
        F_JOGHED    =   6, // jogger's head
        F_PRFHED    =   9,
        F_TOPHED    =   10, // top head fixture tag, this must be TOPHED > COPHED > BUSHED with only head tags between
        F_COPARM    =   11, 
        F_BUSBDY    =   53, // businessman's body
        F_COPBDY    =   54, // cop's body
        F_PNKBDY    =   55, // crust punk's body
        F_JOGBDY    =   56, // jogger's body
        F_PROBDY    =   56, // young pro's body
        F_TOPBDY    =   60, // top body fixture tag, this must be TOPBDY > COPBDY > BUSBDY with only body tags between
        F_GROUND    =   100,
        F_WALLS     =   101,
        F_BUSSEN    =   103, // sensor above businessman's head
        F_COPSEN    =   104, // sensor above cop's head
        F_PNKSEN    =   105, // sensor above crust punk's head
        F_JOGSEN    =   106, // sensor above jogger's head
        F_PROSEN    =   107, // sensor above young pro's head
        F_TOPSEN    =   110, // top head sensor tag, this must be TOPSEN > COPSEN > BUSSEN with only sensor tags between
    };
    
    PersonDogContactListener *personDogContactListener;
}

@property (nonatomic, retain) CCSprite *personLower;
@property (nonatomic, retain) CCSprite *personUpper;
@property (nonatomic, retain) CCSprite *personUpperOverlay;
@property (nonatomic, retain) CCSprite *rippleSprite;
@property (nonatomic, retain) CCSprite *policeArm;
@property (nonatomic, retain) CCSprite *wiener;
@property (nonatomic, retain) CCSprite *target;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) sceneWithSlug:(NSString *)slug;
-(id) initWithSlug:(NSString *)levelSlug;

@end