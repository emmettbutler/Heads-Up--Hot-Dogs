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
	b2Body *_wallsBody;
    b2Body *_groundBody;
	b2Fixture *_bottomFixture;
    b2Fixture *_wallsFixture;
	b2Fixture *_wienerFixture;
    b2Body *wienerBody;
    CCSprite *_wiener;
    b2Fixture *_targetFixture;
    b2Body *targetBody;
    CCSprite *_target;
    b2Fixture *_personFixture;
    b2Body *_personBody;
    CCSprite *_person;
    b2MouseJoint *_mouseJoint;
    CCAction *_flyAction;
    CCAnimation *flyAnim;
    CCFiniteTimeAction *_hitAction;
    CCAnimation *hitAnim;
    CCSpriteBatchNode *spriteSheet;
    CCLabelTTF *scoreLabel;
    NSMutableArray *floorBits;
    NSMutableArray *xPositions;
    NSMutableArray *characterTags;
    NSMutableArray *wienerParameters;
    NSMutableArray *personParameters;
    NSMutableArray *movementPatterns;
    NSMutableArray *movementParameters;
    NSString *scoreText;
    int _points;
    BOOL _moving;
    BOOL _touchedDog;

	NSMutableArray *_touchLocations;
    NSString *currentAnimation;

	enum _entityCategory {
		FLOOR1  = 0x0001,
        FLOOR2  = 0x0002,
        FLOOR3  = 0x0004,
        FLOOR4  = 0x0008,
        WALLS   = 0x0010,
    	PERSON  = 0x0020,
    	WIENER  = 0x0040,
        BODYBOX = 0x0080,
        TARGET  = 0x0100,
  	};

  	PersonDogContactListener *personDogContactListener;
}

@property (nonatomic, retain) CCSprite *person;
@property (nonatomic, retain) CCSprite *wiener;
@property (nonatomic, retain) CCSprite *target;
@property (nonatomic, retain) CCAction *flyAction;
@property (nonatomic, retain) CCAction *hitAction;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
