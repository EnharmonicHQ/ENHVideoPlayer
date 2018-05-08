//
//  ENHAVPlayerViewController.m
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


#import "ENHAVPlayerViewController.h"

// UI
#import "ENHAVPlayerView.h"
#import "ENHAVPlayerControlsView.h"
#import "ENHAVIdlePlaybackView.h"

// Utilities
#import "NSObject+FBKVOController.h"
#import "NSString+ENHTimeInterval.h"
#import "UIImageView+ENHAVThumbnail.h"

static const NSTimeInterval kENHInteractionTimeoutInterval = 3.0;

@interface ENHAVPlayerViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet ENHAVPlayerView *playerView;
@property (nonatomic, weak, readwrite) IBOutlet UIView *contentOverlayView;
@property (nonatomic, weak, readwrite) IBOutlet ENHAVPlayerControlsView *playerControlsView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *playerControlsBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *playerControlsHeightConstraint;
@property (nonatomic, strong) IBOutlet ENHAVIdlePlaybackView *idlePlaybackView;

@property (nonatomic, assign) id periodicTimeObserver;
@property (nonatomic, assign) BOOL seekToZeroBeforePlay;
@property (nonatomic, assign) float preSeekRate;
@property (nonatomic, assign, getter=isSeekInProgress) BOOL seekInProgress;
@property (nonatomic, assign, getter=isPlayerControlsViewAnimationInFlight) BOOL playerControlsViewAnimationInFlight;

@property (nonatomic, strong) UIView *hostingView;
@property (nonatomic, assign, readwrite) BOOL fullScreenActive;
@property (nonatomic, assign) BOOL fullScreenTransitionInProgress;

@property (nonatomic, strong, readwrite) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *doubleTapGestureRecognizer;

@end

@implementation ENHAVPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupGestureRecognizers];
    [self.playerControlsView.playbackPositionSlider setMinimumValue:0.0];
    [self.playerControlsView.playbackPositionSlider setMaximumValue:1.0];
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self.view setClipsToBounds:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUIDeviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

-(void)setupGestureRecognizers
{
    UIGestureRecognizer *interactionRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(handleInteractionGestureRecognizer:)];
    [interactionRecognizer setEnabled:YES];
    [interactionRecognizer setCancelsTouchesInView:NO];
    [interactionRecognizer setDelaysTouchesBegan:NO];
    [interactionRecognizer setDelaysTouchesEnded:NO];
    [interactionRecognizer setDelegate:self];
    [self.view addGestureRecognizer:interactionRecognizer];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTap];
    [self setSingleTapGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGestureRecognizer:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    [self setDoubleTapGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

-(void)viewWillLayoutSubviews
{
    if ([self fullScreenActive] && ![self fullScreenTransitionInProgress])
    {
        UIWindow *window = [self.view window];
        [self.view setFrame:window.bounds];
    }
    [super viewWillLayoutSubviews];
}

#pragma mark - UI

-(void)showPlayerControlsView:(BOOL)show
                 withDuration:(NSTimeInterval)duration
                      options:(UIViewAnimationOptions)options
{
    [self setPlayerControlsViewAnimationInFlight:YES];
    
    if (show)
    {
        [self syncTimeUIForced:YES];
        if ([self.controlVisibilityDelegate respondsToSelector:@selector(playerViewController:willShowControlsView:duration:options:)])
        {
            [self.controlVisibilityDelegate playerViewController:self
                                            willShowControlsView:self.playerControlsView
                                                        duration:duration
                                                         options:options];
        }
    }
    else
    {
        if ([self.controlVisibilityDelegate respondsToSelector:@selector(playerViewController:willHideControlsView:duration:options:)])
        {
            [self.controlVisibilityDelegate playerViewController:self
                                            willHideControlsView:self.playerControlsView
                                                        duration:duration
                                                         options:options];
        }
    }
    
    CGFloat alpha = show ? 1.0 : 0.0;
    
    [self.playerControlsView updateUIVisibilityAnimated:NO];
    [self.view layoutIfNeeded]; // Ensures that all pending layout operations have been completed
    [UIView animateWithDuration:duration
                          delay:duration
                        options:options
                     animations:^{
                         
                         [self updatePlayerControlsViewConstraintsShowing:show];
                         [self.playerControlsView setAlpha:alpha];
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         if (show)
                         {
                             if ([self.controlVisibilityDelegate respondsToSelector:@selector(playerViewController:didShowControlsView:)])
                             {
                                 [self.controlVisibilityDelegate playerViewController:self didShowControlsView:self.playerControlsView];
                             }
                             
                             [self deferredHidePlayerControlsView];
                         }
                         else
                         {
                             if ([self.controlVisibilityDelegate respondsToSelector:@selector(playerViewController:didHideControlsView:)])
                             {
                                 [self.controlVisibilityDelegate playerViewController:self didHideControlsView:self.playerControlsView];
                             }
                         }
                         [self setPlayerControlsViewAnimationInFlight:NO];
                     }];
}

-(void)updatePlayerControlsViewConstraintsShowing:(BOOL)show
{
    self.playerControlsBottomConstraint.constant = show ? 0.0 : (-1.0 * self.playerControlsHeightConstraint.constant);
}

-(BOOL)isShowingPlayerControls
{
    return (self.playerControlsBottomConstraint.constant == 0.0);
}

-(void)syncPlayPauseButtons
{
    ENHPlaybackButtonState status = ENHPlaybackButtonStateUnknown;
    
    AVPlayerItem *playerItem = [self.player currentItem];
    
    if ([playerItem isPlaybackLikelyToKeepUp] ||
        [playerItem isPlaybackBufferFull] ||
        CMTIME_COMPARE_INLINE(playerItem.currentTime, >=, playerItem.duration))
    {
        [self.playerControlsView.playPauseButton setEnabled:YES];
        BOOL isPlaying = self.player.rate != 0.0;
        status = (isPlaying ? ENHPlaybackButtonStatePlaybackPlaying : ENHPlaybackButtonStatePlaybackReady);
    }
    else
    {
        [self.playerControlsView.playPauseButton setEnabled:NO];
        status = ENHPlaybackButtonStateLoading;
    }
    
    [self.playerControlsView.playPauseButton setStatus:status];
}

-(void)syncTimeUI
{
    [self syncTimeUIForced:NO];
}

-(void)syncTimeUIForced:(BOOL)forced
{
    if (![self isSeekInProgress] && ((self.playerControlsView.hidden == NO && [self isShowingPlayerControls]) || forced))
    {
        NSString *playheadTimeString = NSLocalizedString(@"--:--", @"Undetermined media playback time label placeholder");
        NSString *durationString = NSLocalizedString(@"--:--", @"Undetermined media duration label placeholder");
        
        CMTime duration = [self.player.currentItem duration];
        if (CMTIME_IS_INDEFINITE(duration))
        {
            playheadTimeString =  NSLocalizedString(@"Live", @"Live video duration label. Live video has an indeterminate duration, so we display \"Live\" indicator text instead.");
            [self.playerControlsView.playbackPositionSlider setEnabled:NO];
        }
        else
        {
            [self.playerControlsView.playbackPositionSlider setEnabled:YES];
            [self.playerControlsView.playbackPositionSlider setHidden:NO];
            if ((self.player.status == AVPlayerStatusReadyToPlay))
            {
                UISlider *playbackPositionSlider = [self.playerControlsView playbackPositionSlider];
                
                if (CMTIME_IS_INVALID(duration))
                {
                    [playbackPositionSlider setMinimumValue:0.0];
                    return;
                }
                
                durationString = [NSString enh_HHMMSSStringWithTime:self.player.currentItem.duration];
                Float64 durationSeconds = CMTimeGetSeconds(duration);
                
                CMTime currentTime = self.player.currentItem.currentTime;
                if (CMTIME_IS_VALID(currentTime))
                {
                    playheadTimeString = [NSString enh_HHMMSSStringWithTime:self.player.currentItem.currentTime];
                    Float64 currentTimeSeconds = CMTimeGetSeconds(currentTime);
                    [self.playerControlsView.playbackPositionSlider setValue:currentTimeSeconds animated:YES];
                    
                    float minValue = [playbackPositionSlider minimumValue];
                    float maxValue = [playbackPositionSlider maximumValue];
                    float value = (maxValue - minValue) * currentTimeSeconds / durationSeconds + minValue;
                    [playbackPositionSlider setValue:value animated:YES];
                }
            }
        }
        
        [self.playerControlsView.playheadTimeLabel setText:playheadTimeString];
        [self.playerControlsView.durationLabel setText:durationString];
    }
}

-(void)cancelDeferredHidePlayerControlsView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePlayerControlsView) object:nil];
}

-(void)deferredHidePlayerControlsView
{
    [self cancelDeferredHidePlayerControlsView];
    if ([self shouldHidePlayerControlsView])
    {
        [self performSelector:@selector(hidePlayerControlsView)
                   withObject:nil
                   afterDelay:kENHInteractionTimeoutInterval];
    }
}

-(BOOL)shouldHidePlayerControlsView
{
    BOOL shouldHidePlayerControls = YES;
    
    if ([self.player isExternalPlaybackActive]) // Do not hide while airplay is active.
    {
        shouldHidePlayerControls = NO;
    }
    else if ([self.player rate] == 0.0) // Do not hide while paused.
    {
        shouldHidePlayerControls = NO;
    }
    else if (CGSizeEqualToSize([self.player.currentItem presentationSize], CGSizeZero)) // Do not hide when playing audio only content.
    {
        shouldHidePlayerControls = NO;
    }
    
    return shouldHidePlayerControls;
}

-(void)hidePlayerControlsView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    
    if ([self shouldHidePlayerControlsView])
    {
        [self showPlayerControlsView:NO
                        withDuration:0.2
                             options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)];
    }
}

-(void)showPlayerControlsView
{
    [self cancelDeferredHidePlayerControlsView];
    
    if (!self.isPlayerControlsViewAnimationInFlight)
    {
        [self showPlayerControlsView:YES
                        withDuration:0.2
                             options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)];
    }
}

-(void)toggleVideoGravity
{
    NSString *currentVideoGravity = [self.playerView.playerLayer videoGravity];
    NSString *nextVideoGravity = [currentVideoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill] ? AVLayerVideoGravityResizeAspect : AVLayerVideoGravityResizeAspectFill;
    [self.playerView.playerLayer setVideoGravity:nextVideoGravity];
}

-(void)showIdlePlaybackView:(BOOL)show
                    message:(NSString *)message
               withDuration:(NSTimeInterval)duration
                    options:(UIViewAnimationOptions)options
{
//    NSLog(@"-[%@ %@] show: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), (show ? @"YES" : @"NO"));
  
    CGFloat initialAlpha = show ? 0.0 : 1.0;
    CGFloat finalAlpha = show ? 1.0 : 0.0;
    
    UIView *hostingView = [self contentOverlayView];
    
    ENHAVIdlePlaybackView *idlePlaybackView = [self idlePlaybackView];
    
    [idlePlaybackView setAlpha:initialAlpha];
    [idlePlaybackView.textLabel setText:message];
    
    if (show && ![idlePlaybackView superview])
    {
        [hostingView addSubview:idlePlaybackView];
        [hostingView sendSubviewToBack:idlePlaybackView];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(idlePlaybackView);
        NSArray *constraintStrings = @[ @"H:|-0-[idlePlaybackView]-0-|",
                                        @"V:|-0-[idlePlaybackView]-0-|" ];
        for (NSString *constraintString in constraintStrings)
        {
            NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                           options:0
                                                                           metrics:nil views:viewsDictionary];
            [idlePlaybackView.superview addConstraints:constraints];
        }
    }
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:duration
                          delay:duration
                        options:options
                     animations:^{
                         [idlePlaybackView setAlpha:finalAlpha];
                     } completion:^(BOOL finished) {
                         if (!show && finished)
                         {
                             if ([idlePlaybackView superview])
                             {
                                 [idlePlaybackView removeFromSuperview];
                             }
                         }
                     }];
}

-(void)updateIdlePosterFrameImage
{
    AVPlayerItem *currentItem = [self.player currentItem];
    
    BOOL itemReady = [currentItem status] == AVPlayerItemStatusReadyToPlay;
    BOOL hasValidDuration = CMTIME_IS_VALID(currentItem.duration);
    if (itemReady && hasValidDuration)
    {
        CMTime posterTime = CMTimeMultiplyByFloat64(currentItem.duration, 0.1);
        
        if ([currentItem.asset isKindOfClass:[AVURLAsset class]])
        {
            AVURLAsset *asset = (AVURLAsset *)[currentItem asset];
            [self.idlePlaybackView.imageView enh_setImageWithAVURLAsset:asset
                                                                   time:posterTime
                                                       placeholderImage:nil
                                                               duration:0.2
                                                                options:UIViewAnimationOptionCurveEaseIn
                                                                success:nil
                                                                failure:^(NSError *error) {
                                                                    if (error)
                                                                    {
//                                                                        NSLog(@"Image Error: %@", error);
                                                                    }
                                                                }];
        }
    }
    else
    {
//        NSLog(@"-[%@ %@] not ready.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    }
}

-(void)showFullscreenView:(BOOL)goFullScreen
             withDuration:(NSTimeInterval)duration
                  options:(UIViewAnimationOptions)options
{
    [self.playerControlsView.fullscreenModeButton setSelected:goFullScreen];
  
    CGRect endRect = CGRectZero;
    
    if (goFullScreen)
    {
        CGRect startingRect = [self.view convertRect:self.view.frame toView:nil];
        
        if (self.view.superview)
        {
            [self setHostingView:self.view.superview];
        }
        
        UIWindow *window = [self.view window];
        [window addSubview:self.view];
        endRect = [window bounds];
        
        [self.view setFrame:startingRect];
    }
    else
    {
        endRect = [self.hostingView convertRect:self.hostingView.frame toView:nil];
    }
    
    [self.view layoutIfNeeded];
    [self setFullScreenTransitionInProgress:YES];
  
    if (goFullScreen)
    {
        if ([self.fullScreenDelegate respondsToSelector:@selector(playerViewControllerFullScreenModeWillBecomeActive:)])
        {
            [self.fullScreenDelegate playerViewControllerFullScreenModeWillBecomeActive:self];
        }
    }
    else
    {
        if ([self.fullScreenDelegate respondsToSelector:@selector(playerViewControllerFullScreenModeWillBecomeInactive:)])
        {
            [self.fullScreenDelegate playerViewControllerFullScreenModeWillBecomeInactive:self];
        }
    }
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:goFullScreen withAnimation:UIStatusBarAnimationFade];
#pragma clang diagnostic pop
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    CGAffineTransform transform = (self.lockFullScreenToLandscapeOrientation && goFullScreen) ? [self transformForOrientation:deviceOrientation] : CGAffineTransformIdentity;
  
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:duration
                          delay:duration
                        options:options
                     animations:^{
                         [weakSelf.view setTransform:transform];
                         [weakSelf.view setFrame:endRect];
                         [weakSelf.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         if (finished)
                         {
                             if (!goFullScreen)
                             {
                                 [weakSelf.view setFrame:weakSelf.hostingView.bounds];
                                 [weakSelf.hostingView addSubview:weakSelf.view];
                             }
                             
                             [weakSelf setFullScreenActive:goFullScreen];
                         }
                         [weakSelf setFullScreenTransitionInProgress:NO];
                         
                         if (weakSelf.fullScreenActive)
                         {
                             if ([weakSelf.fullScreenDelegate respondsToSelector:@selector(playerViewControllerFullScreenModeDidBecomeActive:)])
                             {
                                 [weakSelf.fullScreenDelegate playerViewControllerFullScreenModeDidBecomeActive:weakSelf];
                             }
                         }
                         else
                         {
                             if ([weakSelf.fullScreenDelegate respondsToSelector:@selector(playerViewControllerFullScreenModeDidBecomeInactive:)])
                             {
                                 [weakSelf.fullScreenDelegate playerViewControllerFullScreenModeDidBecomeInactive:weakSelf];
                             }
                         }
                     }];
}

-(void)handleUIDeviceOrientationDidChangeNotification:(NSNotification *)note
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    BOOL shouldAttemptFullscreen = ![self fullScreenActive] && UIDeviceOrientationIsLandscape(orientation) && self.player.rate > 0;
    if (shouldAttemptFullscreen)
    {
        if ([self.fullScreenDelegate respondsToSelector:@selector(playerViewController:willRequestFullScreenModeChangeForOrientation:)])
        {
            [self.fullScreenDelegate playerViewController:self willRequestFullScreenModeChangeForOrientation:orientation];
        }
        
        __weak __typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([weakSelf.fullScreenDelegate respondsToSelector:@selector(playerViewController:shouldChangeFullScreenModeForChangeInOrientation:)]) {
                if ([weakSelf.fullScreenDelegate playerViewController:weakSelf shouldChangeFullScreenModeForChangeInOrientation:orientation])
                {
                    BOOL shouldGoFullscreen = ![weakSelf fullScreenActive];
                    [weakSelf showFullscreenView:shouldGoFullscreen
                                    withDuration:0.2
                                         options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)];
                }
            }
        });
    }
    else if (self.fullScreenActive || self.fullScreenTransitionInProgress)
    {
        if (UIDeviceOrientationIsLandscape(orientation))
        {
            CGAffineTransform transform = [self transformForOrientation:orientation];
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.view setTransform:transform];
            }];
        }
        else if (orientation == UIDeviceOrientationPortrait)
        {
            [self showFullscreenView:NO
                        withDuration:0.2
                             options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)];
        }
    }
}

-(CGAffineTransform)transformForOrientation:(UIDeviceOrientation)orientation
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (self.lockFullScreenToLandscapeOrientation)
    {
        if (orientation == UIDeviceOrientationLandscapeLeft)
        {
            transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        else
        {
            transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
    }
    
    return transform;
}

#pragma mark - Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 **  4) the item stalled for an extended duration.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self.player setRate:0.0f];
    
    NSLog(@"assetFailedToPrepareForPlayback %@", error);
    
    NSString *message = [NSString stringWithFormat:@"Error playing content. %@", error.localizedDescription];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Playback Error"
                                                                   message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

-(IBAction)playPauseButtonTapped:(ENHPlaybackButton *)sender
{
    if ([sender status] == ENHPlaybackButtonStatePlaybackReady)
    {
        [self play];
    }
    else if ([sender status] == ENHPlaybackButtonStatePlaybackPlaying)
    {
        [self.player pause];
    }
}

-(void)play
{
    if (self.seekToZeroBeforePlay)
    {
        [self setSeekToZeroBeforePlay:NO];
        [self setSeekInProgress:YES];
        
        __weak __typeof(self)weakSelf = self;
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setSeekInProgress:NO];
                [weakSelf.player play];
            });
        }];
    }
    else
    {
        [self.player play];
    }
}

-(IBAction)playbackSliderBegin:(id)sender
{
    [self setSeekToZeroBeforePlay:NO];
    [self setPreSeekRate:self.player.rate];
    [self.player setRate:0.f];
    [self removePeriodicTimeObserver];
}

-(IBAction)playbackSliderValueChanged:(UISlider *)sender
{
    if (![self isSeekInProgress])
    {
        CMTime playerDuration = [self.player.currentItem duration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            float minValue = [sender minimumValue];
            float maxValue = [sender maximumValue];
            float value = [sender value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            __weak __typeof(self)weakSelf = self;
            [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)
                  completionHandler:^(BOOL finished) {
                      if (finished)
                      {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [weakSelf setSeekInProgress:NO];
                              [weakSelf syncTimeUI];
                          });
                      }
                  }];
        }
    }
}

-(IBAction)playbackSliderEnd:(id)sender
{
    if (!self.periodicTimeObserver)
    {
        [self addPeriodicTimeObserver];
    }
    
    if (self.preSeekRate)
    {
        [self.player setRate:self.preSeekRate];
        [self setPreSeekRate:0.0];
    }
}

-(IBAction)fullScreenModeButtonTapped:(id)sender
{
    BOOL shouldGoFullscreen = ![self.playerControlsView.fullscreenModeButton isSelected];
    [self showFullscreenView:shouldGoFullscreen
                withDuration:0.2
                     options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)];
}

#pragma mark - Gesture Handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)handleInteractionGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    [self deferredHidePlayerControlsView];
}

-(void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized)
    {
        if (self.singleTapHandler)
        {
            self.singleTapHandler(tap);
        }
      
        if ([self isShowingPlayerControls])
        {
            [self hidePlayerControlsView];
        }
        else
        {
            [self showPlayerControlsView];
        }
    }
}

-(void)handleDoubleTapGestureRecognizer:(UITapGestureRecognizer *)doubleTap
{
    if (doubleTap.state == UIGestureRecognizerStateRecognized)
    {
        [self toggleVideoGravity];
    }
}

#pragma mark - Time Observation

-(void)addPeriodicTimeObserver
{
    if (![self periodicTimeObserver])
    {
        CMTime duration = [self.player.currentItem duration];
        if (CMTIME_IS_VALID(duration) && !CMTIME_IS_INDEFINITE(duration) && !self.periodicTimeObserver)
        {
            CMTime interval = CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC);
            __weak __typeof(self)weakSelf = self;
            self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:interval
                                                                                  queue:NULL
                                                                             usingBlock:^(CMTime time) {
                                                                                 [weakSelf syncTimeUI];
                                                                             }];
        }
    }
}

-(void)removePeriodicTimeObserver
{
    if ([self periodicTimeObserver])
    {
        [self.player removeTimeObserver:self.periodicTimeObserver];
        [self setPeriodicTimeObserver:nil];
    }
}

#pragma mark - KVO

-(void)observePlayer
{
    // Player
    [self.KVOController observe:self.player
                        keyPath:NSStringFromSelector(@selector(rate))
                        options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         action:@selector(playerRateDidChange:)];
    
    [self.KVOController observe:self.player
                        keyPath:NSStringFromSelector(@selector(currentItem))
                        options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                         action:@selector(playerCurrentItemDidChange:)];
    
    [self.KVOController observe:self.player
                        keyPath:NSStringFromSelector(@selector(status))
                        options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         action:@selector(playerStatusDidChange:)];
    
    [self.KVOController observe:self.player
                        keyPath:@"externalPlaybackActive"
                        options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         action:@selector(playerExternalPlaybackStateDidChange:)];
    
    NSString *currentItemStatusKeypath = [NSString stringWithFormat:@"%@.%@",
                                          NSStringFromSelector(@selector(currentItem)),
                                          NSStringFromSelector(@selector(status))];
    [self.KVOController observe:self.player
                        keyPath:currentItemStatusKeypath
                        options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         action:@selector(playerItemStatusDidChange:)];
    
    NSString *currentItemPlaybackBufferEmptyKeypath = [NSString stringWithFormat:@"%@.playbackBufferEmpty",
                                                       NSStringFromSelector(@selector(currentItem))];
    [self.KVOController observe:self.player
                        keyPath:currentItemPlaybackBufferEmptyKeypath
                        options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         action:@selector(playerItemBufferEmptyStateDidChange:)];
    
    NSString *currentItemPlaybackLikelyToKeepUpKeypath = [NSString stringWithFormat:@"%@.playbackLikelyToKeepUp",
                                                          NSStringFromSelector(@selector(currentItem))];
    [self.KVOController observe:self.player
                        keyPath:currentItemPlaybackLikelyToKeepUpKeypath
                        options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         action:@selector(playerItemPlaybackLikelyToKeepUpStateDidChange:)];
}

-(void)unobservePlayer
{
    [self.KVOController unobserve:self.player];
}

-(void)playerRateDidChange:(NSDictionary *)change
{
    [self syncPlayPauseButtons];
    if ([self.player rate] == 0.0 && [self shouldHidePlayerControlsView] == NO)
    {
        [self showPlayerControlsView];
    }
    else
    {
        [self deferredHidePlayerControlsView];
    }
}

-(void)playerCurrentItemDidChange:(NSDictionary *)change
{
    [self.idlePlaybackView.imageView setImage:nil];
    AVPlayerItem *playerItem = [self.player currentItem];
    AVPlayerItem *previousPlayerItem = change[NSKeyValueChangeOldKey];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (previousPlayerItem)
    {
        [notificationCenter removeObserver:self
                                      name:AVPlayerItemDidPlayToEndTimeNotification
                                    object:previousPlayerItem];
    }
    [notificationCenter addObserver:self
                           selector:@selector(playerItemDidReachEnd:)
                               name:AVPlayerItemDidPlayToEndTimeNotification
                             object:playerItem];
    [self setSeekToZeroBeforePlay:NO];
}

-(void)playerStatusDidChange:(NSDictionary *)change
{
    AVPlayerStatus status = [self.player status];
    switch (status)
    {
            /* Indicates that the status of the player is not yet known because
             * it has not tried to load new media resources for playback */
        case AVPlayerStatusUnknown:
        {
            [self removePeriodicTimeObserver];
            [self.playerControlsView setEnabled:NO];
        }
            break;
            
        case AVPlayerStatusReadyToPlay:
        {
            /* Once the AVPlayerItem becomes ready to play, i.e.
             * [playerItem status] == AVPlayerItemStatusReadyToPlay,
             * its duration can be fetched from the item. */
            
            [self addPeriodicTimeObserver];
            [self syncTimeUI];
            [self syncPlayPauseButtons];
            [self.playerControlsView setEnabled:YES];
        }
            break;
            
        case AVPlayerStatusFailed:
        {
            [self.playerControlsView setEnabled:NO];
            NSError *error = [self.player.currentItem error];
            [self assetFailedToPrepareForPlayback:error];
        }
            break;
    }
}

-(void)playerExternalPlaybackStateDidChange:(NSDictionary *)change
{
    if ([self.player isExternalPlaybackActive])
    {
//        NSLog(@"-[%@ %@] - YES", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        [self showPlayerControlsView];
        [self showIdlePlaybackView:YES
                           message:NSLocalizedString(@"Playing on external device.", @"Playing on external device.")
                      withDuration:0.2
                           options:UIViewAnimationOptionCurveEaseIn];
    }
    else
    {
//        NSLog(@"-[%@ %@] - NO", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        [self showIdlePlaybackView:NO
                           message:nil
                      withDuration:0.2
                           options:UIViewAnimationOptionCurveEaseIn];
    }
}

-(void)playerItemStatusDidChange:(NSDictionary *)change
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf syncTimeUI];
        [weakSelf addPeriodicTimeObserver];
        [weakSelf deferredHidePlayerControlsView];
        
        if (weakSelf.playerItemStatusHandler)
        {
            AVPlayerItemStatus status = [weakSelf.player.currentItem status];
            weakSelf.playerItemStatusHandler(status);
        }
    });
}

-(void)playerItemBufferEmptyStateDidChange:(NSDictionary *)change
{
    [self syncPlayPauseButtons];
}

-(void)playerItemPlaybackLikelyToKeepUpStateDidChange:(NSDictionary *)change
{
    [self syncPlayPauseButtons];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self setSeekToZeroBeforePlay:YES];
    
    if ([self.player isKindOfClass:AVQueuePlayer.class])
    {
        AVQueuePlayer *player = (AVQueuePlayer *)self.player;
        AVPlayerItem *playerItem = [self.player currentItem];
        if (playerItem == [player.items lastObject])
        {
            [player pause];
        }
        else
        {
            [player advanceToNextItem];
        }
    }
    else
    {
        [self.player pause];
    }
}

#pragma mark - Accessors

-(void)setPlayer:(AVPlayer *)player
{
    if (_player != player)
    {
        if (_player)
        {
            [self unobservePlayer];
        }
        
        _player = player;
        [self.playerView setPlayer:_player];
        
        if (_player)
        {
            [_player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
            [self observePlayer];
        }
    }
}

-(NSURL *)currentPlayerItemURL
{
    NSURL *url = nil;
    AVAsset *asset = (AVURLAsset *)[self.player.currentItem asset];
    if ([asset isKindOfClass:AVURLAsset.class])
    {
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        url = [urlAsset URL];
    }
    
    return url;
}

@end
