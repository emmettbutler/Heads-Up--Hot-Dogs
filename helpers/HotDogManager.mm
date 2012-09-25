#import "HotDogManager.h"

static HotDogManager *sharedInstance = nil;

@implementation HotDogManager

+(HotDogManager *)sharedManager{
    @synchronized(self){
        if(sharedInstance == nil){
            [[self alloc] init];
        }
    }
    return sharedInstance;
}

-(id)init{
    @synchronized(self) {
        [super init];
        _pause = [NSNumber numberWithBool:false];
        return self;
    }
}

-(void)setPause:(NSNumber *)pause{
    @synchronized(self) {
        if (_pause != pause) {
            [pause release];
            _pause = [pause retain];
        }
    }
}

-(BOOL)isPaused{
    @synchronized(self) {
        return [_pause boolValue];
    }
}

// singleton boilerplate

+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (sharedInstance == nil){
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

- (id)retain{
    return self;
}

- (void)release{/* do nothing */}

- (id)autorelease{
    return self;
}

- (NSUInteger)retainCount{
    return NSUIntegerMax; // This is sooo not zero
}

@end