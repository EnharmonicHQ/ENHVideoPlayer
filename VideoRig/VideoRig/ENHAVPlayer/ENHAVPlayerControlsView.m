//
//  ENHAVPlayerControlsView.m
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "ENHAVPlayerControlsView.h"

@import MediaPlayer;

static const NSTimeInterval kENHAVPlayerControlsViewDefaultAnimationDuration = 0.1;

@interface ENHAVPlayerControlsView ()

@property (nonatomic, weak, readwrite) IBOutlet UIStackView *stackView;
@property (nonatomic, weak, readwrite) IBOutlet ENHPlaybackButton *playPauseButton;
@property (nonatomic, weak, readwrite) IBOutlet ENHTappableSlider *playbackPositionSlider;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *playheadTimeLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak, readwrite) IBOutlet MPVolumeView *airplayView;
@property (nonatomic, weak, readwrite) IBOutlet NSLayoutConstraint *airplayViewWidthConstraint;
@property (nonatomic, weak, readwrite) IBOutlet NSLayoutConstraint *durationToAirplayViewWidthConstraint;

@end

@implementation ENHAVPlayerControlsView

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.airplayView setShowsVolumeSlider:NO];
    [self.airplayView setShowsRouteButton:YES];
    [self.airplayView setClipsToBounds:YES];
    [self setVisibilityOptions:(ENHAVPlayerControlsViewOptionPlayPause |
                                ENHAVPlayerControlsViewOptionPlaybackPositionSlider |
                                ENHAVPlayerControlsViewOptionPlayheadTimeLabel |
                                ENHAVPlayerControlsViewOptionDurationLabel |
                                ENHAVPlayerControlsViewOptionAirplay)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMPVolumeViewWirelessRoutesAvailableDidChangeNotification:)
                                                 name:MPVolumeViewWirelessRoutesAvailableDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMPVolumeViewWirelessRouteActiveDidChangeNotification:)
                                                 name:MPVolumeViewWirelessRouteActiveDidChangeNotification
                                               object:nil];
}

-(void)updateUIVisibility
{
    __weak __typeof(self)weakSelf = self;
    [self layoutIfNeeded];
    [UIView animateWithDuration:kENHAVPlayerControlsViewDefaultAnimationDuration animations:^{
        [weakSelf.playPauseButton setHidden:!(weakSelf.visibilityOptions & ENHAVPlayerControlsViewOptionPlayPause)];
        [weakSelf.playbackPositionSlider setHidden:!(weakSelf.visibilityOptions & ENHAVPlayerControlsViewOptionPlaybackPositionSlider)];
        [weakSelf.playheadTimeLabel setHidden:!(weakSelf.visibilityOptions & ENHAVPlayerControlsViewOptionPlayheadTimeLabel)];
        [weakSelf.durationLabel setHidden:!(weakSelf.visibilityOptions & ENHAVPlayerControlsViewOptionDurationLabel)];
        
        BOOL shouldShowAirplay = (weakSelf.visibilityOptions & ENHAVPlayerControlsViewOptionAirplay);
        if (shouldShowAirplay)
        {
            shouldShowAirplay = [self.airplayView areWirelessRoutesAvailable];
        }
        [weakSelf.airplayView setHidden:!shouldShowAirplay];
        
        CGFloat airplayViewWidthConstant = shouldShowAirplay ? 44.0 : 0;
        [self.airplayViewWidthConstraint setConstant:airplayViewWidthConstant];
        CGFloat durationToAirplayViewWidthConstant = shouldShowAirplay ? 8.0 : 0;
        [self.durationToAirplayViewWidthConstraint setConstant:durationToAirplayViewWidthConstant];
        
        [self layoutIfNeeded];
    }];
}

-(void)setVisibilityOptions:(ENHAVPlayerControlsViewOptions)visibilityOptions
{
    if (_visibilityOptions != visibilityOptions)
    {
        _visibilityOptions = visibilityOptions;
        [self updateUIVisibility];
    }
}

-(void)setEnabled:(BOOL)enabled
{
    NSArray *controls = @[self.playPauseButton,
                          self.playbackPositionSlider];
    for (UIControl *control in controls)
    {
        [control setEnabled:enabled];
    }
}

#pragma mark - Notification Handling

-(void)handleMPVolumeViewWirelessRoutesAvailableDidChangeNotification:(NSNotification *)note
{
    [self updateUIVisibility];
}

-(void)handleMPVolumeViewWirelessRouteActiveDidChangeNotification:(NSNotification *)note
{
    [self updateUIVisibility];
}

@end
