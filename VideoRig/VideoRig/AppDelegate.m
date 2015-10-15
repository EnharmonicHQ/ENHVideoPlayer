//
//  AppDelegate.m
//  VideoRig
//
//  Created by Dillan Laughlin on 6/11/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "AppDelegate.h"
#import "ENHVideoPickerViewController.h"
#import "ENHVideoPlayerHostingViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    
    UINavigationController *primaryNavigationController = [splitViewController.viewControllers firstObject];
    ENHVideoPickerViewController *pickerViewController = nil;
    if ([[primaryNavigationController topViewController] isKindOfClass:ENHVideoPickerViewController.class])
    {
        pickerViewController = (ENHVideoPickerViewController *)[primaryNavigationController topViewController];
    }
    
    UINavigationController *secondaryNavigationController = [splitViewController.viewControllers lastObject];
    secondaryNavigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    [splitViewController setPresentsWithGesture:NO];
    
    if ([[secondaryNavigationController topViewController] isKindOfClass:[ENHVideoPlayerHostingViewController class]])
    {
        ENHVideoPlayerHostingViewController *playerHost = (ENHVideoPlayerHostingViewController *)[secondaryNavigationController topViewController];
        [pickerViewController setPlayerHostingViewController:playerHost];
    }
    
    return YES;
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return YES;
    
    ENHVideoPlayerHostingViewController *playerHost = nil;
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] &&
        [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[ENHVideoPlayerHostingViewController class]])
    {
        playerHost = (ENHVideoPlayerHostingViewController *)[(UINavigationController *)secondaryViewController topViewController];
    }
    
    if (playerHost && ([playerHost.playerItems count] > 0))
    {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
