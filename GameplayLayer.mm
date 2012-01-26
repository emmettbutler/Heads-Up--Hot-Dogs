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
    wiener = [CCSprite spriteWithSpriteFrameName:@"dog54x12.png"];
    wiener.position = ccp(location.x, location.y);
    wiener.tag = 1;
    [self addChild:wiener z:9];
    
    // Create wiener body and shape
    b2BodyDef wienerBodyDef;
    wienerBodyDef.type = b2_dynamicBody;
    wienerBodyDef.position.Set(location.x/PTM_RATIO, location.y/PTM_RATIO);
    wienerBodyDef.userData = wiener;
    wienerBody = _world->CreateBody(&wienerBodyDef);
    
    b2PolygonShape wienerShape;
    wienerShape.SetAsBox(wiener.contentSize.width/PTM_RATIO/2, wiener.contentSize.height/PTM_RATIO/2);
    
    b2FixtureDef wienerShapeDef;
    wienerShapeDef.shape = &wienerShape;
    wienerShapeDef.density = 0.2f;
    wienerShapeDef.friction = 1.0f;
    wienerShapeDef.userData = (void *)1;
    wienerShapeDef.restitution = 0.5f;
    wienerShapeDef.filter.categoryBits = WIENER;
    wienerShapeDef.filter.maskBits = PERSON | FLOOR | WIENER;
    _wienerFixture = wienerBody->CreateFixture(&wienerShapeDef);

    b2PolygonShape wienerGrabShape;
    wienerShape.SetAsBox((wiener.contentSize.width+30)/PTM_RATIO/2, (wiener.contentSize.height+30)/PTM_RATIO/2);

    b2FixtureDef wienerGrabShapeDef;
    wienerGrabShapeDef.shape = &wienerShape;
    wienerGrabShapeDef.filter.categoryBits = WIENER;
    wienerGrabShapeDef.filter.maskBits = 0x0000;
    _wienerFixture = wienerBody->CreateFixture(&wienerGrabShapeDef);
}

-(void)walkIn:(id)sender data:(void *)params {
    int xVel, velocityMul, zIndex, fixtureUserData;
    float hitboxHeight, hitboxWidth, hitboxCenterX, hitboxCenterY, density, restitution, friction;

    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSMutableArray *incomingArray = (NSMutableArray *) params;
    NSNumber *xPos = (NSNumber *)[incomingArray objectAtIndex:0];
    NSNumber *yPos = (NSNumber *)[incomingArray objectAtIndex:1];
    NSNumber *character = (NSNumber *)[incomingArray objectAtIndex:2];
    
    switch(character.intValue){
        case 1:
            self.person = [CCSprite spriteWithSpriteFrameName:@"business82x228.png"];
            _person.tag = 3;
            hitboxWidth = 22.0;
            hitboxHeight = 1;
            hitboxCenterX = 0;
            hitboxCenterY = 3.3;
            velocityMul = 1;
            density = 10.0f;
            restitution = 0.2f;
            friction = 1.0f;
            fixtureUserData = 3;
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            break;
    }

    if( xPos.intValue == winSize.width ){
        xVel = -1*velocityMul;
    }
    else {
        _person.flipX = YES; //facing the other way
        xVel = 1*velocityMul;
    }
    
    if(yPos.intValue > 140){
        zIndex = 1;
    }
    else if(yPos.intValue > 130){
        zIndex = 2;
    }
    else if(yPos.intValue > 120){
        zIndex = 3;
    }
    else if(yPos.intValue > 110){
        zIndex = 4;
    }

    _person.position = ccp(xPos.intValue, yPos.intValue);
    CCLOG(@"Add sprite %d (%0.2f)",yPos.intValue,yPos.floatValue/PTM_RATIO);
    [spriteSheet addChild:_person z:zIndex];

    b2BodyDef personBodyDef;
    personBodyDef.type = b2_dynamicBody;
    personBodyDef.position.Set(xPos.floatValue/PTM_RATIO, yPos.floatValue/PTM_RATIO);
    personBodyDef.userData = _person;
    _personBody = _world->CreateBody(&personBodyDef);

    b2PolygonShape personShape;
    personShape.SetAsBox(hitboxWidth/PTM_RATIO, hitboxHeight/PTM_RATIO, b2Vec2(hitboxCenterX, hitboxCenterY), 0);

    b2FixtureDef personShapeDef;
    personShapeDef.shape = &personShape;
    personShapeDef.density = density;
    personShapeDef.friction = friction;
    personShapeDef.restitution = restitution;
    personShapeDef.userData = (void *)fixtureUserData;
    personShapeDef.filter.categoryBits = PERSON;
    personShapeDef.filter.maskBits = WIENER;
    _personFixture = _personBody->CreateFixture(&personShapeDef);
    
    b2PrismaticJointDef jointDef;
    b2Vec2 worldAxis(1.0f, 0.0f);
    jointDef.collideConnected = true;
    jointDef.Initialize(_personBody, _groundBody, _personBody->GetWorldCenter(), worldAxis);
    _world->CreateJoint(&jointDef);
    
    b2Vec2 force = b2Vec2(xVel,0);
    _personBody->ApplyLinearImpulse(force, personBodyDef.position);
}

//this seems to only work on one sprite at a time
-(void)runBoxLoop:(id)sender{
    //CCSprite *sprite = (CCSprite *)sender;
    //self.flyAction = [CCRepeatForever actionWithAction:
    //                  [CCAnimate actionWithAnimation:flyAnim restoreOriginalFrame:NO]];
    //[sprite runAction: _flyAction];
}

- (void)switchScene{
    CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[TitleLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

-(void)callback:(id)sender data:(void *)params {    
    NSMutableArray *incomingArray = (NSMutableArray *) params;
    NSNumber *xPos = (NSNumber *)[incomingArray objectAtIndex:0];
    NSNumber *yPos = (NSNumber *)[incomingArray objectAtIndex:1];
    NSNumber *characterTag = (NSNumber *)[incomingArray objectAtIndex:2];
    
    NSNumber* yPosition = [yPositions objectAtIndex:arc4random() % [yPositions count]];
    yPos = [NSNumber numberWithInt:yPosition.intValue];
    
    NSNumber *xPosition = [xPositions objectAtIndex:arc4random() % [xPositions count]];
    xPos = [NSNumber numberWithInt:xPosition.intValue];
    
    characterTag = [characterTags objectAtIndex:arc4random() % [characterTags count]];
    
    for (b2Body *body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL) {
			CCSprite *sprite = (CCSprite *)body->GetUserData();
            if(sprite.tag >= 3 && sprite.tag <= 10){
                CCLOG(@"Position: %0.2f x %0.2f", body->GetPosition().x, body->GetPosition().y);
                if(yPos.floatValue/PTM_RATIO - body->GetPosition().y < .5){
                    
                }
            }
        }
    }
    
    [self walkIn:self data:params];

    NSMutableArray *parameters = [[NSMutableArray alloc] initWithCapacity:3];
    [parameters addObject:xPos];
    [parameters addObject:yPos];
    [parameters addObject:characterTag];
        
    double time = 2.0f;
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
        
        //initialize global arrays for possible x,y positions and charTags
        yPositions = [[NSMutableArray alloc] initWithCapacity:4];;
        for(int i = 115; i <= 147; i += 8){
            [yPositions addObject:[NSNumber numberWithInt:i]];
        }
        xPositions = [[NSMutableArray alloc] initWithCapacity:2];
        [xPositions addObject:[NSNumber numberWithInt:winSize.width]];
        [xPositions addObject:[NSNumber numberWithInt:0]];
        characterTags = [[NSMutableArray alloc] initWithCapacity:1];
        for(int i = 1; i < 2; i++){
            [characterTags addObject:[NSNumber numberWithInt:i]];
        }
        
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
        groundBoxDef.filter.categoryBits = FLOOR;
        groundBox.SetAsEdge(b2Vec2(0,.5), b2Vec2(winSize.width/PTM_RATIO, 1));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        
        b2BodyDef wallsBodyDef;
        wallsBodyDef.position.Set(0,0);
        _wallsBody = _world->CreateBody(&wallsBodyDef);
        b2PolygonShape wallsBox;
        b2FixtureDef wallsBoxDef;
        wallsBoxDef.shape = &wallsBox;
        wallsBoxDef.filter.categoryBits = WALLS;
        wallsBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        _wallsFixture = _wallsBody->CreateFixture(&wallsBoxDef);
        wallsBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        _wallsBody->CreateFixture(&wallsBoxDef);
        wallsBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
        _wallsBody->CreateFixture(&wallsBoxDef);

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
        NSNumber *yPos = [yPositions objectAtIndex:arc4random() % [yPositions count]];
        NSNumber *xPos = [NSNumber numberWithInt:winSize.width]; 
        NSNumber *character = [NSNumber numberWithInt:1]; 
        [params addObject:xPos];
        [params addObject:yPos];
        [params addObject:character];
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
	
     b2Filter filter;
    
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
                if(myActor.tag >= 3 && myActor.tag <= 10){
                    for(b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext()){
                        
                    }
                    if(b->GetLinearVelocity().x < 1 && myActor.flipX == true){
                        b2Vec2 force = b2Vec2(1,0);
                        b->ApplyLinearImpulse(force, b->GetPosition());
                    }
                    else if(b->GetLinearVelocity().x > -1 && myActor.flipX == false){
                        b2Vec2 force = b2Vec2(-1,0);
                        b->ApplyLinearImpulse(force, b->GetPosition());
                    }
                }
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
        b2Filter filter;
        
        //for each contact

        /*if(sprite.tag == 2){
            [sprite stopAllActions];
            [sprite runAction:[CCSequence actions:_hitAction,
                               [CCCallFuncN actionWithTarget:self selector:@selector(runBoxLoop:)],nil]];
        }*/
	}
	contactListener->contacts.clear();
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint != NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _touchedDog = NO;
    
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
                    
                    _touchedDog = YES;
                    break;
                }
                else {
                    _touchedDog = NO;
                }
            }
		}
    }
    CCLOG(@"Touched Dog: %d", _touchedDog);
    if(!_touchedDog){
        if(location.y > 200){
            [self putDog:location];
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
    
    for (b2Body* body = _world->GetBodyList(); body; body = body->GetNext()){
        if (body->GetUserData() != NULL) {
            for(b2Fixture* fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext()){
    			CCSprite *sprite = (CCSprite *)body->GetUserData();
                if(sprite.tag == 1){
                    if (fixture->TestPoint(locationWorld)) {
                         body->SetLinearVelocity(b2Vec2(0, 0));
                    }
                }
            }
		}
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
    delete contactListener;
	_world = NULL;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
