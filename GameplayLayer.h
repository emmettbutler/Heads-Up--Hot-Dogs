//
//  HelloWorldLayer.h
//  sandbox
//
//  Created by Emmett Butler on 1/3/12.
//  Copyright NYU 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"

@interface GameplayLayer : CCLayer
{
	b2World *_world;
    GLESDebugDraw *m_debugDraw;
	b2Body *_groundBody;
	b2Fixture *_bottomFixture;
	b2Fixture *_weinerFixture;
	b2Fixture *_boxFixture;
	b2Body *_boxBody;
    b2Body *weinerBody;
    CCSprite *_box;
    CCSprite *weiner;
    b2Fixture *_personFixture;
    b2Body *_personBody;
    CCSprite *_person;
    b2MouseJoint *_mouseJoint;
    CCAction *_flyAction;
    CCAnimation *flyAnim;
    CCFiniteTimeAction *_hitAction;
    CCAnimation *hitAnim;
    CCSpriteBatchNode *spriteSheet;
    BOOL _moving;

	NSMutableArray *_touchLocations;
    NSString *currentAnimation;

	enum _entityCategory {
		BOUNDARY = 0x0001,
    	BOX =     0x0002,
    	WEINER =     0x0004,
  	};

  	MyContactListener *contactListener;
}

@property (nonatomic, retain) CCSprite *box;
@property (nonatomic, retain) CCSprite *person;
@property (nonatomic, retain) CCAction *flyAction;
@property (nonatomic, retain) CCAction *hitAction;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
