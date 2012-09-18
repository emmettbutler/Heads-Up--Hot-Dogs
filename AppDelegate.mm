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
#import "TestFlight.h" 
#import "RootViewController.h"
#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Kontagent/Kontagent.h"
#import "UIDefs.h"

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
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
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
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
	// Removes the startup flicker
	[self removeStartupFlicker];
	
    [[director openGLView] setMultipleTouchEnabled:YES];
    
    // testflight setup ---------------------------------------------------------------
    [TestFlight takeOff:@"f6bf5ec07ee6b2acb2f1e80502d54baa_NzUyODcyMDEyLTAzLTI2IDIyOjE3OjM4LjMxMjg1OQ"];
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    //---------------------------------------------------------------------------------
    
    // kontagent -----------------------------------------------------------------------
    [Kontagent enableDebug];
    // test api key
    [Kontagent startSession:@"315132246f7a4f3ab619276a35ea6407" mode:kKontagentSDKMode_TEST shouldSendApplicationAddedAutomatically:YES];
    // prod api key
    //[Kontagent startSession:@"40a5b05ff49e43b2afa8a863eeb320c3" mode:kKontagentSDKMode_TEST shouldSendApplicationAddedAutomatically:YES];
    [Kontagent setMode:kKontagentSDKMode_TEST];
    
    // create and save unique ID
    NSString *savedUuid = [standardUserDefaults stringForKey:@"uuid"];
    NSString *uuid = savedUuid;
    if(!savedUuid){
        uuid = [self GetUUID];
        [standardUserDefaults setObject:uuid forKey:@"uuid"];
        [Kontagent revenueTracking:99 optionalParams:nil];
    }
        
    KTParamMap* paramMap = [[[KTParamMap alloc] init] autorelease];
    [paramMap put:@"v_maj" value:VERSION_STRING];
    [Kontagent sendDeviceInformation:paramMap];
    //[paramMap put:@"s" value:uuid];
    //[Kontagent applicationAdded:paramMap];
    // ---------------------------------------------------------------------------------
    
    // game center
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            NSLog(@"Player %@ recognized", localPlayer.alias);
            [TestFlight passCheckpoint:[NSString stringWithFormat:@"Player %@ recognized", localPlayer.alias]];
        } else {
            NSLog(@"Player not authenticated");
        }
    }];
    
#ifdef DEBUG
    [standardUserDefaults setInteger:0 forKey:@"introDone"]; //should be 0, is 1 for debugging
    [standardUserDefaults setInteger:1 forKey:@"unlockednyc"];
    [standardUserDefaults setInteger:1 forKey:@"unlockedjapan"];
    [standardUserDefaults setInteger:1 forKey:@"unlockedlondon"];
    [standardUserDefaults setInteger:1 forKey:@"unlockedchicago"];
    [standardUserDefaults setInteger:1 forKey:@"unlockedspace"];
#else
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"menu intro.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"pause 3.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hot dog appear 1.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hot dog disappear.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"25pts.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"50pts.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"100pts.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hot dog on head.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"game over sting.mp3"];
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
    
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene:[Splashes scene]];
}

-(NSString *)GetUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
    
    NSLog(@"Application HEADS UP HOT DOGS exiting");
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
