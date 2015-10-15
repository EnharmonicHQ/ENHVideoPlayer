//
//  ENHStreamingPlaybackButton.h
//  VideoRig
//
//  Created by Dillan Laughlin on 9/28/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The possible states for the playback button.
 */
typedef NS_ENUM(NSUInteger, ENHPlaybackButtonState){
    ENHPlaybackButtonStateUnknown, // Unknow state, hide the button.
    ENHPlaybackButtonStateLoading, // Loading or buffering content.
    ENHPlaybackButtonStatePlaybackReady, // Playback is ready and/or paused.
    ENHPlaybackButtonStatePlaybackPlaying, // Playing.
};

@interface ENHPlaybackButton : UIButton

/**
 *  The displayed state of the button.
 */
@property(nonatomic) ENHPlaybackButtonState status;

+(ENHPlaybackButton *)buttonWithFrame:(CGRect)frame;

@end
