//
//  AppDelegate.m
//  sandbox
//
//  Created by Emmett Butler on 1/3/12.
//  Copyright NYU 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "Splashes.h"
#import "RootViewController.h"
#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Kontagent/Kontagent.h"
#import "UIDefs.h"
#import "HotDogManager.h"

#define KONTAGENT_KEY @"315132246f7a4f3ab619276a35ea6407" // qa
//#define KONTAGENT_KEY @"40a5b05ff49e43b2afa8a863eeb320c3" // prod

@implementation AppDelegate

@synthesize window;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	
		CC_ENABLE_DEFAULT_GL_STATES();
		CCDirector *director = [CCDirector sharedDirector];
		CGSize size = [director winSize];
		CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
		sprite.position = ccp(size.width/2, size.height/2);
		sprite.rotation = -90;
		[sprite visit];
		[[director openGLView] swapBuffers];
		CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    // kontagent -----------------------------------------------------------------------
#ifdef DEBUG
    [Kontagent debugEnabled];
#endif
    [Kontagent startSession:KONTAGENT_KEY mode:kKontagentSDKMode_TEST shouldSendApplicationAddedAutomatically:YES];
    
    // create and save unique ID
    NSString *savedUuid = [standardUserDefaults stringForKey:@"uuid"];
    NSString *uuid = savedUuid;
    if(!savedUuid){
        uuid = [self GetUUID];
        [standardUserDefaults setObject:uuid forKey:@"uuid"];
        //[Kontagent revenueTracking:99 optionalParams:nil];
    }
    
    KTParamMap* paramMap = [[[KTParamMap alloc] init] autorelease];
    [paramMap put:@"v_maj" value:VERSION_STRING];
    [Kontagent sendDeviceInformation:paramMap];
    //[paramMap put:@"s" value:uuid];
    //[Kontagent applicationAdded:paramMap];
    // ---------------------------------------------------------------------------------
    
    [[HotDogManager sharedManager] customEvent:@"game_load_start" st1:@"game_load" st2:NULL level:NULL value:NULL data:NULL];
    startTime = [[NSDate date] timeIntervalSince1970];
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
    [window setRootViewController:viewController];
	//[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
	// Removes the startup flicker
	[self removeStartupFlicker];
	
    [[director openGLView] setMultipleTouchEnabled:YES];

    NSLog(@"Version: %@", [[UIDevice currentDevice] systemVersion]);
    if(SYSTEM_VERSION_LESS_THAN(@"6.0")){
        // game center
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
            if (localPlayer.isAuthenticated){
                NSLog(@"Player %@ recognized", localPlayer.alias);
            } else {
                NSLog(@"Player not authenticated");
            }
        }];
    } else {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        localPlayer.authenticateHandler = ^(UIViewController *controller, NSError *error){
            if (controller != nil){
                //UIViewController* myController = [[UIViewController alloc] init];
                //[[[CCDirector sharedDirector] openGLView] addSubview:myController.view];
                //[myController presentViewController:controller animated:YES completion:nil];
            }
            else if (localPlayer.isAuthenticated){
                //[self authenticatedPlayer: localPlayer];
            }
            else{
                //[self disableGameCenter];
            }
        };
    }
 
    
#ifdef DEBUG
    [standardUserDefaults setInteger:0 forKey:@"introDone"]; //should be 0, is 1 for debugging
#else
    [[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:YES];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"menu intro.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"pause 3.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"firecracker.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"dog bark.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hot dog appear 1.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hot dog disappear.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"25pts.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"50pts.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"100pts.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"water splash loud.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hot dog on head.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"game over sting.mp3"];
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = .4;
#endif
    NSInteger timesPlayed = [standardUserDefaults integerForKey:@"timesPlayed"];
    [standardUserDefaults setInteger:++timesPlayed forKey:@"timesPlayed"];
    [standardUserDefaults synchronize];
   
    [CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
    
    // must be called before any other call to the director
    if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
        [CCDirector setDirectorType:kCCDirectorTypeMainLoop];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_menus.plist"];
    [[CCDirector sharedDirector] setDisplayFPS:NO];
    
    [[HotDogManager sharedManager] customEvent:@"game_load_complete" st1:@"game_load" st2:NULL level:NULL value:[[NSDate date] timeIntervalSince1970] - startTime data:NULL];
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene:[Splashes scene]];
}

-(NSString *)GetUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

// resignActive and becomeActive are called with home button double-taps
- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"willResignActive");
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"didBecomeActive");
    NSLog(@"paused: %d", [[HotDogManager sharedManager] isPaused]);
    if(![[HotDogManager sharedManager] isPaused]){
        [[CCDirector sharedDirector] resume];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    NSLog(@"didEnterBackground");
    [[HotDogManager sharedManager] customEvent:@"user_quit_app" st1:@"useraction" st2:NULL level:NULL value:startTime data:NULL];
    [Kontagent stopSession];
	[[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector] pause];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
    NSLog(@"willEnterForeground");
    startTime = [[NSDate date] timeIntervalSince1970];
    [Kontagent startSession:KONTAGENT_KEY mode:kKontagentSDKMode_PRODUCTION shouldSendApplicationAddedAutomatically:YES];
    [[CCDirector sharedDirector] startAnimation];
    if([[HotDogManager sharedManager] isInGame] && ![[HotDogManager sharedManager] isPaused]){
        [[HotDogManager sharedManager] setPause:[NSNumber numberWithBool:true]];
        [[CCDirector sharedDirector] resume];
    }
}

-(void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
    
    NSLog(@"Application HEADS UP HOT DOGS exiting");
    [[HotDogManager sharedManager] customEvent:@"user_quit_app" st1:@"useraction" st2:NULL level:NULL value:startTime data:NULL];
    [Kontagent stopSession];
	[[director openGLView] removeFromSuperview];
	[viewController release];
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

-(RootViewController *)getRootViewController{
    return self->viewController;
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
