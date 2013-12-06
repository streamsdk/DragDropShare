//
//  dragdropshareAppDelegate.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-13.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "dragdropshareAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FirstTestViewController.h"
#import "MainController.h"
#import "UploadDB.h"
#import "FileCache.h"
#import <arcstreamsdk/STreamFile.h>
#import "FakeViewController.h"

@implementation dragdropshareAppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
                        NSLog(@"In fallback handler");
                    }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // If you have not added the -ObjC linker flag, you may need to uncomment the following line because
    // Nib files require the type to have been loaded before they can do the wireup successfully.
    // http://stackoverflow.com/questions/1725881/unknown-class-myclass-in-interface-builder-file-error-at-runtime
    // [FBProfilePictureView class];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UploadDB *db = [[UploadDB alloc]init];
    [db initDB];
    [db readInitDB];
    
    FileCache *cache = [FileCache sharedObject];
    [cache loadDownloadedFiles];
    
    FirstTestViewController *first = [[FirstTestViewController alloc] init];
  //  FakeViewController *first = [[FakeViewController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:first];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        self.window.rootViewController = [[MainController alloc]init];
         self.window.rootViewController = nav;
    } else {
        self.window.rootViewController = nav;
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    OBDragDropManager *manager = [OBDragDropManager sharedManager];
    [manager prepareOverlayWindowUsingMainWindow:self.window];
    
    
    //added testing comments
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application	{
    // FBSample logic
    // Call the 'activateApp' method to log an app event for use in analytics and advertising reporting.
    [FBAppEvents activateApp];
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
}

@end
