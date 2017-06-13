//
//  ENHStreamingPlaybackButton.m
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


#import "ENHPlaybackButton.h"

@interface ENHPlaybackButton ()

@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@end

@implementation ENHPlaybackButton

+ (instancetype)buttonWithFrame:(CGRect)frame
{
    return [[self.class alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    
    return self;
}

-(void)sharedInit
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
    [activityIndicator setHidesWhenStopped:YES];
    [self addSubview:activityIndicator];
    [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:activityIndicator
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:activityIndicator.superview
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:activityIndicator
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:activityIndicator.superview
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0];
    [self addConstraints:@[centerX, centerY]];
    [self setActivityIndicator:activityIndicator];
    
    self.status = ENHPlaybackButtonStateUnknown;
}

- (void)setStatus:(ENHPlaybackButtonState)status
{
    _status = status;
    switch(status)
    {
        case ENHPlaybackButtonStateUnknown:
            [self.activityIndicator stopAnimating];
            break;
        case ENHPlaybackButtonStateLoading:
            [self.activityIndicator startAnimating];
            [self setTitle:nil forState:UIControlStateNormal];
            break;
        case ENHPlaybackButtonStatePlaybackReady:
            [self.activityIndicator stopAnimating];
            if (self.playImage)
            {
                [self setImage:self.playImage forState:UIControlStateNormal];
                [self setTintColor:self.superview.tintColor];
            }
            else
            {
                NSString *defaultPlayString = NSLocalizedString(@"►", @"Default play button text");
                [self setTitle:defaultPlayString forState:UIControlStateNormal];
            }
            break;
        case ENHPlaybackButtonStatePlaybackPlaying:
            [self.activityIndicator stopAnimating];
            if (self.pauseImage)
            {
                [self setImage:self.pauseImage forState:UIControlStateNormal];
                [self setTintColor:self.superview.tintColor];
            }
            else
            {
                NSString *defaultPauseString = NSLocalizedString(@"||", @"Default pause button text");
                [self setTitle:defaultPauseString forState:UIControlStateNormal];
            }
            break;
    }
    
    [self setTintColor:self.superview.tintColor];
}

@end
