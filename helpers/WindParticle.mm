#import "WindParticle.h"

@implementation WindParticle

-(id)init
{
	if ((self = [super init])) {
		velocityX = 2.0f;
	}
	return self;
}
-(void)startMovement
{	
	[self setImage];
	[self createVerticalMotion];
}

-(void) createVerticalMotion
{
	float multiplierX = 150.0f;
	float multiplierY = 30.0f;
	
	float variantY = 3.0f;
	
	float dura1 = ((CCRANDOM_0_1() + 0.01) * 3)+1;
	float dura2 = ((CCRANDOM_0_1() + 0.01) * 3)+1;
	
	
	float xPos1 = position_.x + ((CCRANDOM_0_1() + 0.01) * velocityX * multiplierX);
	float xPos2 = xPos1 + ((CCRANDOM_0_1() + 0.01) * velocityX * multiplierX);
	
	float yPos1 = position_.y + ((CCRANDOM_0_1() + 0.01) * variantY * multiplierY);
	float yPos2 = position_.y + ((CCRANDOM_0_1() + 0.01) * -variantY * multiplierY);
	
	id actionVariateUp = [CCMoveTo 
						  actionWithDuration: dura1
						  position:ccp(xPos1,yPos1)
						  ];
	id actionVariateDown = [CCMoveTo 
							actionWithDuration:dura2
							position:ccp(xPos2,yPos2)
							];	
	id callFunction = [CCCallFunc 
					   actionWithTarget:self 
					   selector:@selector(createVerticalMotion)
					   ];
	id sequence = [CCSequence 
				   actions: actionVariateUp, 
							actionVariateDown, 
							callFunction, 
							nil
				   ];
		
	
	[self runAction:[CCRepeat 
						 actionWithAction:sequence 
						 times:1]
	];	
	[self runAction:[CCRepeat 
					 actionWithAction:[CCRotateBy 
									   actionWithDuration:((CCRANDOM_0_1() + 0.01) * 3)+1 
									   angle:((CCRANDOM_0_1() + 0.01) * 360)+1
									   ] 
					 times:2]
	 ];
}
-(void) setImage
{
    int choice = (arc4random() % 2) + 1;
	CCSprite* img = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Wind_Particle_%d.png", choice]];
	img.scale = 0.5+ (CCRANDOM_0_1() + 0.01) * 0.3;
	[self addChild:img z:0 tag:1];
}
-(void)setSpeed:(float) speed
{
	velocityX = speed;
}

-(void)removeLeaf
{
	if (parent_){
		[parent_ removeChild:self cleanup:YES];
	}
}
- (void) dealloc
{	
	[super dealloc];
}

@end
