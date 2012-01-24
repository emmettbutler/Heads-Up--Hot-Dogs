//
//  HelloWorldLayer.mm
//  sandbox
//
//  Created by Emmett Butler on 1/3/12.
//  Copyright NYU 2012. All rights reserved.
//


// Import the interfaces
#import "GameplayLayer.h"
#import "TitleScene.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32
#define VELOCITY_MULT 35

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// HelloWorldLayer implementation
@implementation GameplayLayer

@synthesize box = _box;
@synthesize person = _person;
@synthesize flyAction = _flyAction;
@synthesize hitAction = _hitAction;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameplayLayer *layer = [GameplayLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)putDog:(CGPoint)location {
    // Create sprite and add it to the layer
    weiner = [CCSprite spriteWithSpriteFrameName:@"dog54x12.png"];
    weiner.position = ccp(location.x, location.y);
    weiner.tag = 1;
    [self addChild:weiner z:9];
    
    // Create weiner body and shape
    b2BodyDef weinerBodyDef;
    weinerBodyDef.type = b2_dynamicBody;
    weinerBodyDef.position.Set(location.x/PTM_RATIO, location.y/PTM_RATIO);
    weinerBodyDef.userData = weiner;
    weinerBody = _world->CreateBody(&weinerBodyDef);
    
    b2PolygonShape weinerShape;
    weinerShape.SetAsBox(weiner.contentSize.width/PTM_RATIO/2, weiner.contentSize.height/PTM_RATIO/2);
    
    b2FixtureDef weinerShapeDef;
    weinerShapeDef.shape = &weinerShape;
    weinerShapeDef.density = 1.0f;
    weinerShapeDef.friction = 1.0f;
    weinerShapeDef.userData = (void *)1;
    weinerShapeDef.restitution = 0.5f;
    weinerShapeDef.filter.categoryBits = WEINER;
    weinerShapeDef.filter.maskBits = BOX | BOUNDARY | WEINER;
    _weinerFixture = weinerBody->CreateFixture(&weinerShapeDef);

    b2PolygonShape weinerGrabShape;
    weinerShape.SetAsBox((weiner.contentSize.width+30)/PTM_RATIO/2, (weiner.contentSize.height+30)/PTM_RATIO/2);

    b2FixtureDef weinerGrabShapeDef;
    weinerGrabShapeDef.shape = &weinerShape;
    weinerGrabShapeDef.filter.categoryBits = WEINER;
    weinerGrabShapeDef.filter.maskBits = 0x0000;
    _weinerFixture = weinerBody->CreateFixture(&weinerGrabShapeDef);
}

-(void)walkIn:(id)sender data:(void *)params {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSMutableArray *incomingArray = (NSMutableArray *) params;
    NSNumber *xPos = (NSNumber *)[incomingArray objectAtIndex:0];
    NSNumber *yPos = (NSNumber *)[incomingArray objectAtIndex:1];
    
    self.person = [CCSprite spriteWithSpriteFrameName:@"business82x228.png"];
    
    int xVel;
    
    if( xPos.intValue == winSize.width ){
        xVel = -100;
    }
    else {
        self.person = [CCSprite spriteWithSpriteFrameName:@"business_facing_right.png"];
        xVel = 100;
    }
    
    _person.position = ccp(xPos.intValue, yPos.intValue);
    _person.tag = 3;

    [spriteSheet addChild:_person];

    b2BodyDef personBodyDef;
    personBodyDef.type = b2_dynamicBody;
    personBodyDef.position.Set(xPos.intValue/PTM_RATIO, yPos.intValue/PTM_RATIO);
    personBodyDef.userData = _person;
    _personBody = _world->CreateBody(&personBodyDef);

    b2PolygonShape personShape;
    personShape.SetAsBox(31.0/PTM_RATIO, 40.0/PTM_RATIO, b2Vec2(0, 2.1), 0);

    b2FixtureDef personShapeDef;
    personShapeDef.shape = &personShape;
    personShapeDef.density = 10.0f;
    personShapeDef.friction = 1.0f;
    personShapeDef.restitution = 0.2f;
    personShapeDef.userData = (void *)3;
    personShapeDef.filter.categoryBits = BOX;
    personShapeDef.filter.maskBits = WEINER;
    _personFixture = _personBody->CreateFixture(&personShapeDef);
    
    b2PrismaticJointDef jointDef;
    b2Vec2 worldAxis(1.0f, 0.0f);
    jointDef.collideConnected = true;
    jointDef.Initialize(_personBody, _groundBody, _personBody->GetWorldCenter(), worldAxis);
    _world->CreateJoint(&jointDef);

    b2Vec2 force = b2Vec2(xVel, 0);
    _personBody->ApplyLinearImpulse(force, personBodyDef.position);
}

//this seems to only work on one sprite at a time
-(void)runBoxLoop:(id)sender{
    CCSprite *sprite = (CCSprite *)sender;
    //self.flyAction = [CCRepeatForever actionWithAction:
    //                  [CCAnimate actionWithAnimation:flyAnim restoreOriginalFrame:NO]];
    //[sprite runAction: _flyAction];
}

- (void)switchScene{
    CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[TitleLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

-(void)callback:(id)sender data:(void *)params {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSMutableArray *incomingArray = (NSMutableArray *) params;
    NSNumber *xPos = (NSNumber *)[incomingArray objectAtIndex:0];
    NSNumber *yPos = (NSNumber *)[incomingArray objectAtIndex:1];
    
    NSMutableArray *positions = [[NSMutableArray alloc] initWithCapacity:3];;
    for(int i = 114; i <= 159; i += 15){
        [positions addObject:[NSNumber numberWithInt:i]];
    }
    NSNumber* position = [positions objectAtIndex:arc4random() % [positions count]];
    CCLOG(@"Add sprite %d",position.intValue);
    yPos = [NSNumber numberWithInt:position.intValue];
    
    positions = [[NSMutableArray alloc] initWithCapacity:2];;
    [positions addObject:[NSNumber numberWithInt:winSize.width]];
    [positions addObject:[NSNumber numberWithInt:0]];
    position = [positions objectAtIndex:arc4random() % [positions count]];
    xPos = [NSNumber numberWithInt:position.intValue];
        
    NSMutableArray *parameters = [[NSMutableArray alloc] initWithCapacity:2];
    [parameters addObject:xPos];
    [parameters addObject:yPos];
        
    [self walkIn:self data:params];
        
    double time = 5.0f;
    id delay = [CCDelayTime actionWithDuration:time];
    id callBackAction = [CCCallFuncND actionWithTarget: self selector: @selector(callback:data:) data:parameters];
    id sequence = [CCSequence actions: delay, callBackAction, nil];
    [self runAction:sequence];    
}

-(void)debugDraw{
    // Debug Draw functions
    if(!m_debugDraw){
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        uint32 flags = 0;
        flags += b2DebugDraw::e_shapeBit;
        flags += b2DebugDraw::e_jointBit;
        flags += b2DebugDraw::e_aabbBit;
        flags += b2DebugDraw::e_pairBit;
        flags += b2DebugDraw::e_centerOfMassBit;
        m_debugDraw->SetFlags(flags); 
    } else {
        m_debugDraw = nil;
    }
    _world->SetDebugDraw(m_debugDraw);
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		CGSize winSize = [CCDirector sharedDirector].winSize; 
        
        CCSprite *background = [CCSprite spriteWithFile:@"bg_philly.png"];
        background.anchorPoint = CGPointZero;
        [self addChild:background z:-1];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Title screen" fontName:@"Marker Felt" fontSize:18.0];
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchScene)];
        label = [CCLabelTTF labelWithString:@"Debug draw" fontName:@"Marker Felt" fontSize:18.0];
        CCMenuItem *debug = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(debugDraw)];
        CCMenu *menu = [CCMenu menuWithItems:button, debug, nil];
        [menu setPosition:ccp(40, winSize.height-30)];
        [menu alignItemsVertically];
        [self addChild:menu];
        
        self.isAccelerometerEnabled = YES;
        self.isTouchEnabled = YES;
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, -30.0f);
        
        bool doSleep = true;
        _world = new b2World(gravity, doSleep);
        
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

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"sprites_default.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_default.png"];
        [self addChild:spriteSheet];
        
        /*NSMutableArray *flyAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 3; ++i){
            [flyAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"box_%d.png", i]]];
        }
        
        NSMutableArray *hitAnimFrames = [NSMutableArray array];
        [hitAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"box_hit.png"]];
        hitAnim = [CCAnimation animationWithFrames:hitAnimFrames delay:0.1f];
        flyAnim = [CCAnimation animationWithFrames:flyAnimFrames delay:0.9f];*/

        contactListener = new MyContactListener();
		_world->SetContactListener(contactListener);
        
        NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:2];
        NSNumber *yPos = [NSNumber numberWithInt:winSize.height-20];
        NSNumber *xPos = [NSNumber numberWithInt:winSize.width]; 
        [params addObject:xPos];
        [params addObject:yPos];
        [self callback:self data:params];
		
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

    CGSize winSize = [CCDirector sharedDirector].winSize;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(dt, velocityIterations, positionIterations);
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            if(myActor.position.x > winSize.width || myActor.position.x < 0){
                _world->DestroyBody(b);
                [myActor removeFromParentAndCleanup:YES];
            }
            else {
    			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
    			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
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
        
        /*if(sprite.tag == 2){
            [sprite stopAllActions];
            [sprite runAction:[CCSequence actions:_hitAction,
                               [CCCallFuncN actionWithTarget:self selector:@selector(runBoxLoop:)],nil]];
        }*/

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

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint != NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL) {
            b2Fixture *fixture = body->GetFixtureList();
			CCSprite *sprite = (CCSprite *)body->GetUserData();
            if(sprite.tag == 1){
                if (fixture->TestPoint(locationWorld)) {
                    CCLOG(@"Touching hotdog");
                    b2MouseJointDef md;
                    md.bodyA = _groundBody;
                    md.bodyB = body;
                    md.target = locationWorld;
                    md.collideConnected = true;
                    md.maxForce = 10000.0f * body->GetMass();
                    
                    _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
                    body->SetAwake(true);
                    break;
                }
            }
		}
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_mouseJoint == NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    CCLOG(@"Mousejoint target @ %0.2f x %0.2f", location.x, location.y);
    
    _mouseJoint->SetTarget(locationWorld);
}

-(void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _touchedDog = NO;
    
    for (b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL) {
            for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
    			CCSprite *sprite = (CCSprite *)body->GetUserData();
                if(sprite.tag == 1){
                    if (fixture->TestPoint(locationWorld)) {
                         body->SetLinearVelocity(b2Vec2(0, 0));
                        _touchedDog = YES;
                    }
                    else {
                        _touchedDog = NO;
                    }
                }
            }
		}
    }
    CCLOG(@"Touched Dog: %d", _touchedDog);
    if(!_touchedDog){
        [self putDog:location];
    }
}
 
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures]; 
    
	self.box = nil;
    self.person = nil;
	//self.flyAction = nil;
    //self.hitAction = nil;

    delete _world;
	_world = NULL;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
