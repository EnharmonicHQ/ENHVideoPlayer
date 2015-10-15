//
//  ENHAVPlayerControlsView.h
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

@import UIKit;

#import "ENHTappableSlider.h"
#import "ENHPlaybackButton.h"

typedef NS_OPTIONS (NSInteger, ENHAVPlayerControlsViewOptions) {
    ENHAVPlayerControlsViewOptionNone                   = 0,
    ENHAVPlayerControlsViewOptionPlayPause              = 1 << 0,
    ENHAVPlayerControlsViewOptionPlaybackPositionSlider = 1 << 1,
    ENHAVPlayerControlsViewOptionPlayheadTimeLabel      = 1 << 2,
    ENHAVPlayerControlsViewOptionDurationLabel          = 1 << 3,
    ENHAVPlayerControlsViewOptionAirplay                = 1 << 4,
};

@interface ENHAVPlayerControlsView : UIView

@property (nonatomic, weak, readonly) IBOutlet ENHPlaybackButton *playPauseButton;
@property (nonatomic, weak, readonly) IBOutlet ENHTappableSlider *playbackPositionSlider;
@property (nonatomic, weak, readonly) IBOutlet UILabel *playheadTimeLabel;
@property (nonatomic, weak, readonly) IBOutlet UILabel *durationLabel;

@property (nonatomic, assign) ENHAVPlayerControlsViewOptions visibilityOptions;

-(void)setEnabled:(BOOL)enabled;

@end
