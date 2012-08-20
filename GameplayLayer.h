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

@interface GameplayLayer : CCLayer
{
    b2World *_world;
    AchievementReporter *reporter;
    levelProps *level;
    GLESDraw *m_debugDraw;
    b2Body *_wallsBody, *_groundBody, *wienerBody, *targetBody, *_personBody, *_policeArmBody;
    b2Fixture *_bottomFixture, *_wallsFixture, *_wienerFixture, *_targetFixture, *_personFixture, *_policeArmFixture;
    CCSprite *_wiener, *_personLower, *_personUpper, *_personUpperOverlay, *_target, *_pauseButton, *background;
    CCAction *_walkAction, *_walkFaceAction, *_altFaceWalkAction, *_altWalkAction, *_flag1RightAction, *_flag1LeftAction, *_flag2RightAction, *_flag2LeftAction, *_dustAction;
    CCFiniteTimeAction *_idleAction, *_appearAction, *_hitAction, *_shotAction, *_specialAction, *_armShootAction, *_specialFaceAction, *_specialAngryFaceAction, *_postStopAction;
    CCAnimation *walkAnim, *idleAnim, *hitAnim, *dogDeathAnim, *dogAppearAnim, *walkFaceAnim, *walkDogFaceAnim;
    CCAnimation *dogShotAnim, *specialAnim, *armShootAnim, *specialFaceAnim, *specialAngryFaceAnim, *altWalkAnim, *altFaceWalkAnim, *postStopAnim;
    CCSpriteBatchNode *spriteSheetCommon, *spriteSheetLevel, *spriteSheetCharacter;
    CCLabelTTF *scoreLabel, *droppedLabel, *gravityLabel;
    b2Vec2 policeRayPoint1, policeRayPoint2;
    CCLayerColor *_pauseLayer, *_flashLayer;
    NSMutableArray *bgSprites;
    CCMenu *_pauseMenu;
    NSMutableArray *floorBits, *xPositions, *wienerParameters, *headParams, *mouseJoints, *dogTouches;
    NSMutableArray *personParameters, *wakeParameters, *movementPatterns, *movementParameters, *_touchLocations, *dogIcons, *allTouchHashes;
    NSString *scoreText, *droppedText;
    int _points, _droppedCount, _spawnLimiter, time, _curPersonMaskBits, _droppedSpacing, _lastTouchTime, _firstDeathTime, lowerArmAngle, upperArmAngle;
    int _peopleGrumped, _dogsSaved, _id_counter, _numTouches, _dogsOnscreen, _maxDogsOnScreen, _numWorldTouches, _sfxVol, _levelMaxDogs;
    float _wienerSpawnDelayTime, _currentRayAngle;
    BOOL _moving, _touchedDog, _rayTouchingDog, _pause, _shootLock, _dogHasHitGround, _dogHasDied, _policeOnScreen, _muncherOnScreen, _gameOver, _ventsOn, _hasDroppedDog;
    NSString *currentAnimation, *slug;
    CGRect _pauseButtonRect;
    NSUserDefaults *standardUserDefaults;
    NSInteger _overallTime, _sfxOn;
    CCDelayTime *winUpDelay, *winDownDelay;
    CCCallFuncN *removeWindow;
    ccColor3B _color_pink;

    struct bodyUserData {
        CCSprite *sprite1;
        CCSprite *sprite2;
        float heightOffset2;
        float lengthOffset2;
        float lowerXOffset;
        float lowerYOffset;
        NSString *_dog_fallSprite;
        NSString *_dog_riseSprite;
        NSString *_dog_grabSprite;
        NSString *_dog_mainSprite;
        NSString *ogSprite2;
        NSString *aimFace;
        CCSprite *angryFace;
        CCSprite *overlaySprite;
        CCAction *altAction;
        CCAction *altAction2;
        CCAction *altAction3;
        CCAction *altWalk;
        CCAction *altWalkFace;
        CCAction *idleAction;
        CCAction *defaultAction;
        CCAnimation *altAnimation;
        CCAction *angryFaceWalkAction;
        CCAction *dogOnHeadTickleAction;
        CCAction *deathSeq;
        CCAction *shotSeq;
        CCFiniteTimeAction *postStopAction;
        // point notifier actions
        CCFiniteTimeAction *_not_dogContact;
        CCFiniteTimeAction *_not_dogOnHead;
        CCFiniteTimeAction *_not_leaveScreen;
        CCFiniteTimeAction *_not_leaveScreenFlash;
        CCFiniteTimeAction *_not_spcContact;
        CCFiniteTimeAction *_not_spcOnHead;
        CCFiniteTimeAction *_not_spcLeaveScreen;
        CGRect boundingBox;
        // end point notifiers
        float armSpeed;
        float deathDelay; // how long a hot dog sits on the ground before dying, in seconds
        float moveDelta; // the linear velocity of the person
        int stopTime; // time into walk at which person should pause
        int stopTimeDelta; // how long the pause should last
        int timeWalking; // how long has this person been walking
        int restartTime;
        int pointValue; // how many points is a dog contact on this head worth?
        BOOL aiming;
        BOOL touched;
        BOOL touchLock;
        BOOL aimedAt;
        BOOL grabbed;
        BOOL deathSeqLock;
        BOOL animLock;
        BOOL hasLeftScreen;
        double targetAngle;
        int dogsOnHead;
        int spcDogsOnHead;
        int unique_id;
        int tickleTimer;
        int collideFilter;
        BOOL hasTouchedHead;
        BOOL _dog_isOnHead;
        BOOL _person_hasTouchedDog;
        BOOL _muncher_hasDroppedDog;
        BOOL _cop_hasShot;
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
@property (nonatomic, retain) CCSprite *policeArm;
@property (nonatomic, retain) CCSprite *wiener;
@property (nonatomic, retain) CCSprite *target;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) sceneWithSlug:(NSString *)slug;
-(id) initWithSlug:(NSString *)levelSlug;

@end
