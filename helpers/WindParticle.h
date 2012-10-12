#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ccMacros.h"

@interface WindParticle : CCSprite {
    
@private
	float   velocityX, velocityY;
}

-(void) setSpeed: (float)speed;
-(void) startMovement;
-(void) createVerticalMotion;
-(void) setImage;
@end
