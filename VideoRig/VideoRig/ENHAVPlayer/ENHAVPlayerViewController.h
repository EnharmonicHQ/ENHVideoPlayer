//
//  ENHAVPlayerViewController.h
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@import AVFoundation;

@class ENHAVPlayerControlsView;

@protocol ENHAVPlayerViewControllerControlVisibilityDelegate;
@protocol ENHAVPlayerViewControllerControlFullScreenDelegate;

@interface ENHAVPlayerViewController : UIViewController

@property (nonatomic, weak, readonly) IBOutlet ENHAVPlayerControlsView *playerControlsView;

@property (weak) id <ENHAVPlayerViewControllerControlVisibilityDelegate> controlVisibilityDelegate;
@property (weak) id <ENHAVPlayerViewControllerControlFullScreenDelegate> fullScreenDelegate;
@property (nonatomic, weak, nullable) AVPlayer *player;
@property (readonly) BOOL isShowingPlayerControls;
@property (nonatomic, weak, readonly) IBOutlet UIView *contentOverlayView;
@property (readonly, nullable) NSURL *currentPlayerItemURL;
@property (nonatomic, copy, nullable) void (^singleTapHandler)(UITapGestureRecognizer *tap);
@property (nonatomic, assign, readonly) BOOL fullScreenActive;
@property (nonatomic, assign) BOOL lockFullScreenToLandscapeOrientation;

-(void)play;
-(void)hidePlayerControlsView;
-(void)showPlayerControlsView;

-(void)showFullscreenView:(BOOL)goFullScreen
             withDuration:(NSTimeInterval)duration
                  options:(UIViewAnimationOptions)options;

@property (nonatomic, copy, nullable) void (^playerItemStatusHandler)(AVPlayerItemStatus status);

@end

@protocol ENHAVPlayerViewControllerControlVisibilityDelegate <NSObject>

@optional
-(void)playerViewController:(ENHAVPlayerViewController *)playerViewController
       willShowControlsView:(ENHAVPlayerControlsView *)controlsView
                   duration:(NSTimeInterval)duration
                    options:(UIViewAnimationOptions)options;

-(void)playerViewController:(ENHAVPlayerViewController *)playerViewController
        didShowControlsView:(ENHAVPlayerControlsView *)controlsView;

-(void)playerViewController:(ENHAVPlayerViewController *)playerViewController
       willHideControlsView:(ENHAVPlayerControlsView *)controlsView
                   duration:(NSTimeInterval)duration
                    options:(UIViewAnimationOptions)options;

-(void)playerViewController:(ENHAVPlayerViewController *)playerViewController
        didHideControlsView:(ENHAVPlayerControlsView *)controlsView;

@end

@protocol ENHAVPlayerViewControllerControlFullScreenDelegate <NSObject>

@optional
-(void)playerViewController:(ENHAVPlayerViewController *)playerViewController
willRequestFullScreenModeChangeForOrientation:(UIDeviceOrientation)orientation;
-(BOOL)playerViewController:(ENHAVPlayerViewController *)playerViewController
shouldChangeFullScreenModeForChangeInOrientation:(UIDeviceOrientation)orientation;
-(void)playerViewControllerFullScreenModeWillBecomeActive:(ENHAVPlayerViewController *)playerViewController;
-(void)playerViewControllerFullScreenModeDidBecomeActive:(ENHAVPlayerViewController *)playerViewController;
-(void)playerViewControllerFullScreenModeWillBecomeInactive:(ENHAVPlayerViewController *)playerViewController;
-(void)playerViewControllerFullScreenModeDidBecomeInactive:(ENHAVPlayerViewController *)playerViewController;

@end



NS_ASSUME_NONNULL_END
