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

@interface ENHAVPlayerViewController : UIViewController

@property (weak) id <ENHAVPlayerViewControllerControlVisibilityDelegate> controlVisibilityDelegate;
@property (nonatomic, weak, nullable) AVPlayer *player;
@property (readonly) BOOL isShowingPlayerControls;
@property (nonatomic, weak, readonly) IBOutlet UIView *contentOverlayView;
@property (readonly, nullable) NSURL *currentPlayerItemURL;

@end

@protocol ENHAVPlayerViewControllerControlVisibilityDelegate <NSObject>

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

NS_ASSUME_NONNULL_END
