//
//  ENHStreamingPlaybackButton.m
//  VideoRig
//
//  Created by Dillan Laughlin on 9/28/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

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
                [self setTitle:@"►" forState:UIControlStateNormal];
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
                [self setTitle:@"||" forState:UIControlStateNormal];
            }
            break;
    }
    
    [self setTintColor:self.superview.tintColor];
}

@end
