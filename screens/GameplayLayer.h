//
//  GameplayLayer.h
//  Heads Up! Hot Dogs
//
//  Created by Emmett Butler on 1/3/12.
//  Copyright Sugoi Papa Interactive 2012. All rights reserved.
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
#import "HotDog.h"
#import "SteamVent.h"

#define FLOOR1_Z 42
#define FLOOR2_Z 32
#define FLOOR3_Z 22
#define FLOOR4_Z 12
#define PTM_RATIO 32

@interface GameplayLayer : CCLayer <CDLongAudioSourceDelegate>
{
    b2World *_world;
    AchievementReporter *reporter;
    levelProps *level;
    GLESDraw *m_debugDraw;
    b2Body *_groundBody;
    CCSprite *_wiener, *_personLower, *_personUpper, *_personUpperOverlay, *_rippleSprite, *_target, *_pauseButton, *background;
    CCAction *_flag1RightAction, *_flag1LeftAction, *_flag2RightAction, *_flag2LeftAction, *_dustAction; // TODO - DEBT - these should belong to an object in /components
    CCFiniteTimeAction *_appearAction;
    CCSpriteBatchNode *spriteSheetCommon, *spriteSheetLevel, *spriteSheetCharacter;
    CCLabelTTF *scoreLabel, *sfxLabel;
    b2Vec2 policeRayPoint1, policeRayPoint2, windForce;
    CCLayerColor *_pauseLayer, *_flashLayer;
    SteamVent *vent1, *vent2;
    Firecracker *firecracker;
    Shiba *shiba;
    CCAction *window1CycleAction, *window2CycleAction, *window3CycleAction, *window4CycleAction, *stationNameCycleAction;
    CCMenu *_pauseMenu;
    ccColor3B _color_pink, spcDogFlashColor, satanColor;
    NSMutableArray *bgSprites, *floorBits, *xPositions, *dogTouches, *dogIcons, *floorHeights, *windParticles;
    NSString *slug;
    CGSize winSize;
    UInt32 audioIsAlreadyPlaying;
    CDLongAudioSource *introAudio;
    CGRect _pauseButtonRect, _resumeRect, _restartRect, _levelRect, _sfxRect;
    NSUserDefaults *standardUserDefaults;
    NSInteger _sfxOn, _introDone, _savedHighScore;
    int _points, _droppedCount, time, _curPersonMaskBits, _peopleGrumped, _dogsSaved, _spcDogsSaved, _dogsOnscreen, _maxDogsOnScreen, _numWorldTouches, _levelMaxDogs, _dogsShotByCop, _dogsMissedByCop, windCounter, dogNumberCounter, _windParticles, _vomitProb, _pointIncreaseInterval;
    float spriteScaleX, spriteScaleY, pointNotifyScale, _wienerSpawnDelayTime, _levelSpawnInterval, _subwayForce, FLOOR1_HT, FLOOR2_HT, FLOOR3_HT, FLOOR4_HT,hudScale, introAudioDuration;
    BOOL _shootLock, _policeOnScreen, _muncherOnScreen, _gameOver, _hasDroppedDog, _fgIsDark, _scoreNotifyLock, _player_hasTickled, pauseLock, vomitCheatActivated, bigHeadCheatActivated;

    struct bodyUserData {
        CCSprite *sprite1, *sprite2, *angryFace, *ripples, *overlaySprite, *howToPlaySprite;
        float heightOffset2, widthOffset, lowerXOffset, lowerYOffset;
        CCLabelTTF *countdownLabel, *countdownShadowLabel;
        NSString *_dog_fallSprite, *_dog_riseSprite, *_dog_grabSprite, *_dog_mainSprite, *aimFace;
        CCAction *altAction, *walkRipple, *idleRipple, *altAction2, *altAction3, *altWalk, *altWalkFace, *idleAction, *defaultAction, *angryFaceWalkAction, *dogOnHeadTickleAction, *deathSeq, *shotSeq, *countdownAction, *tintAction;
        CCFiniteTimeAction *postStopAction, *_not_dogContact, *_not_dogOnHead, *_not_leaveScreen, *_not_leaveScreenFlash, *_not_spcContact, *_not_spcOnHead, *_not_spcLeaveScreen, *_vomitAction;
        float rippleXOffset, ogRippleXOffset, rippleYOffset, ogRippleYOffset, deathDelay, moveDelta; // the linear velocity of the person
        double targetAngle;
        int stopTime, stopTimeDelta, timeWalking, restartTime, pointValue, dogsOnHead, spcDogsOnHead, tickleTimer, collideFilter, howToPlaySpriteXOffset, howToPlaySpriteYOffset, ogCollideFilters, _muncher_howToPlaySpriteXOffset, _muncher_howToPlaySpriteYOffset;
        BOOL aiming, touched, exploding, touchLock, aimedAt, grabbed, deathSeqLock, animLock, hasLeftScreen;
        BOOL hasTouchedHead, _dog_isOnHead, _person_hasTouchedDog, _muncher_hasDroppedDog, _cop_hasShot, _busman_willVomit, _busman_isVomiting, hasTouchedGround, _nudie_isStopped, _dog_hasBeenGrabbed;
    };

    struct fixtureUserData {
        int tag, ogCollideFilters;
    };

    enum _collisionFilters {
        FLOOR1  = 0x0001,
        FLOOR2  = 0x0002,
        FLOOR3  = 0x0004,
        FLOOR4  = 0x0008,
        WALLS   = 0x0010,
        WIENER  = 0x0040,
        BODYBOX = 0x0080, // character bodies
        SENSOR  = 0x0020,
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
        S_TWLMAN    =   10,
        S_ASTRO     =   11,
        S_LION      =   12,
        S_TOPPSN    =   20, // top person sprite tag, this must be TOPPSN > POLICE > BUSMAN with only person tags between
        S_COPARM    =   21,
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
+(CCScene *) sceneWithSlug:(NSString *)levelSlug andVomitCheat:(NSNumber *)vomitCheatActivated andBigHeadCheat:(NSNumber *)bigHeadsActivated;
-(id) initWithSlug:(NSString *)levelSlug;

@end
