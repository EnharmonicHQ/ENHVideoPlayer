//
//  ENHStreamingPlaybackButton.h
//  VideoRig
//
//  Created by Dillan Laughlin on 9/28/15.
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
@property (nonatomic) ENHPlaybackButtonState status;

@property (nonatomic, strong) UIImage *playImage;
@property (nonatomic, strong) UIImage *pauseImage;

+(ENHPlaybackButton *)buttonWithFrame:(CGRect)frame;

@end
