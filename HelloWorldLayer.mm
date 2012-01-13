//
//  HelloWorldLayer.mm
//  sandbox
//
//  Created by Emmett Butler on 1/3/12.
//  Copyright NYU 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32
#define VELOCITY_MULT 95

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize box = _box;
@synthesize flyAction = _flyAction;
@synthesize hitAction = _hitAction;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)putBox:(CGPoint)location xVel:(float)xVel yVel:(float)yVel{
    CCLOG(@"Add sprite %0.2f x %02.f",location.x,location.y);

    self.box = [CCSprite spriteWithSpriteFrameName:@"box_1.png"];
    
    location.y += 18; 
    _box.position = ccp( location.x, location.y);
    _box.tag = 2;
    
    self.hitAction = [CCAnimate actionWithAnimation:hitAnim restoreOriginalFrame:YES];
    self.flyAction = [CCRepeatForever actionWithAction:
                      [CCAnimate actionWithAnimation:flyAnim restoreOriginalFrame:NO]];
    
    [_box runAction:_flyAction];
    [spriteSheet addChild:_box];

    b2BodyDef boxBodyDef;
    boxBodyDef.type = b2_dynamicBody;
    boxBodyDef.position.Set(location.x/PTM_RATIO, location.y/PTM_RATIO);
    boxBodyDef.userData = _box;
    _boxBody = _world->CreateBody(&boxBodyDef);
    
    b2PolygonShape boxShape;
    boxShape.SetAsBox(_box.contentSize.width/PTM_RATIO/2,
                      _box.contentSize.height/PTM_RATIO/2);
    
    b2FixtureDef boxShapeDef;
    boxShapeDef.shape = &boxShape;
    boxShapeDef.density = 10.0f;
    boxShapeDef.friction= 0.4f;
    boxShapeDef.restitution = 0.9f;
    boxShapeDef.userData = (void *)2;
    boxShapeDef.filter.categoryBits = BOX;
    boxShapeDef.filter.maskBits = BALL | BOUNDARY;
    _boxFixture = _boxBody->CreateFixture(&boxShapeDef);
    
    b2Vec2 force = b2Vec2(xVel, yVel);
    _boxBody->ApplyLinearImpulse(force, boxBodyDef.position);
}

-(void)runBoxLoop:(id)sender{
    CCSprite *sprite = (CCSprite *)sender;
    [sprite runAction: _flyAction];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
        
        self.isAccelerometerEnabled = YES;
        self.isTouchEnabled = YES;
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, -30.0f);
        
        bool doSleep = true;
        _world = new b2World(gravity, doSleep);
        _world->SetGravity( b2Vec2(0,0) );
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        _groundBody = _world->CreateBody(&groundBodyDef);
        b2PolygonShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 
                                                                        winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), 
                            b2Vec2(winSize.width/PTM_RATIO, 0));
        _groundBody->CreateFixture(&groundBoxDef);


        // Create sprite and add it to the layer
        CCSprite *ball = [CCSprite spriteWithFile:@"circlesprite.png" rect:CGRectMake(0, 0, 15, 15)];
        ball.position = ccp(100, 100);
        ball.tag = 1;
        [self addChild:ball z:9];
        
        // Create ball body and shape
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 180/PTM_RATIO);
        ballBodyDef.userData = ball;
        b2Body * ballBody = _world->CreateBody(&ballBodyDef);
        
        b2CircleShape circle;
        circle.m_radius = 7.5f/PTM_RATIO;
        
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 10.0f;
        ballShapeDef.friction = 0.f;
        ballShapeDef.userData = (void *)1;
        ballShapeDef.restitution = 0.8f;
        ballShapeDef.filter.categoryBits = BALL;
	    ballShapeDef.filter.maskBits = BOX | BOUNDARY;
        _ballFixture = ballBody->CreateFixture(&ballShapeDef);

        b2Vec2 force = b2Vec2(0.3f,0.9f);
        ballBody->ApplyLinearImpulse(force, ballBodyDef.position);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"spritesheet_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet_default.png"];
        [self addChild:spriteSheet];
        
        NSMutableArray *flyAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 3; ++i){
            [flyAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"box_%d.png", i]]];
        }
        
        NSMutableArray *hitAnimFrames = [NSMutableArray array];
        [hitAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"box_hit.png"]];
        hitAnim = [CCAnimation animationWithFrames:hitAnimFrames delay:0.1f];
        flyAnim = [CCAnimation animationWithFrames:flyAnimFrames delay:0.1f];
        
        for(float i = 0.0f; i < 2*M_PI; i += M_PI/8){
            [self putBox:CGPointMake(winSize.width/2, winSize.height/2) xVel:VELOCITY_MULT*sin(i) yVel:VELOCITY_MULT*cos(i)];
        }

        contactListener = new MyContactListener();
		_world->SetContactListener(contactListener);
		
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	_world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(dt, velocityIterations, positionIterations);

	for (b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
		if (body->GetUserData() != NULL) {
			CCSprite *sprite = (CCSprite *)body->GetUserData();
            if(sprite.tag == 2){
                b2Vec2 force = b2Vec2(0.7f,0);
		        //body->ApplyLinearImpulse(force, body->GetWorldCenter());
		    }
	    }
    }
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}

	std::set<b2Body*>::iterator pos;
	for(pos = contactListener->contacts.begin();
		pos != contactListener->contacts.end(); ++pos)
	{
		b2Body *body = *pos;

		CCNode *contactNode = (CCNode*)body->GetUserData();
        CCSprite *sprite = (CCSprite *)body->GetUserData();
		CGPoint position = contactNode.position;
        
        if(sprite.tag == 2){
            [sprite stopAllActions];
            [sprite runAction:[CCSequence actions:_hitAction,
                               [CCCallFuncN actionWithTarget:self selector:@selector(runBoxLoop:)],nil]];
        }

		CCParticleSun* explosion = [[CCParticleSun alloc] initWithTotalParticles:200];
		explosion.autoRemoveOnFinish = YES;
		explosion.startSize = 1.0f;
		explosion.speed = 70.0f;
		explosion.anchorPoint = ccp(0.5f,0.5f);
		explosion.position = position;
		explosion.duration = 0.2f;
		[self addChild:explosion z:11];
		[explosion release];
	}
	contactListener->contacts.clear();
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	UITouch *myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView:[myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
    for (b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL) {
			CCSprite *sprite = (CCSprite *)body->GetUserData();
            if(sprite.tag == 2){
                [self removeChild:sprite cleanup:YES];
		        _world->DestroyBody(body);
                [sprite removeFromParentAndCleanup:YES];
            }
		}
    }
    for(float i = 0.0f; i < 2*M_PI; i += M_PI/8){
		[self putBox:location xVel:VELOCITY_MULT*sin(i) yVel:VELOCITY_MULT*cos(i)];
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	_world->SetGravity( gravity );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures]; 
    
	self.box = nil;
	self.flyAction = nil;
    self.hitAction = nil;

    delete _world;
	_world = NULL;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
