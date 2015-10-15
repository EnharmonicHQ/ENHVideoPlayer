//
//  ENHAVPlayerView.h
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@interface ENHAVPlayerView : UIView

@property (nonatomic, weak) AVPlayer *player;
@property (readonly) AVPlayerLayer *playerLayer;

@end
