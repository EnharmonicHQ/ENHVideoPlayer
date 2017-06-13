//
//  ENHAVPlayerViewController.h
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic inc. All rights reserved.
//
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


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
