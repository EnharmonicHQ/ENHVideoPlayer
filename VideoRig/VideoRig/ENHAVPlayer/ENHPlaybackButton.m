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
            [self setHidden:YES];
            break;
        case ENHPlaybackButtonStateLoading:
            [self setHidden:NO];
            [self.activityIndicator startAnimating];
            [self setTitle:nil forState:UIControlStateNormal];
            break;
        case ENHPlaybackButtonStatePlaybackReady:
            [self setHidden:NO];
            [self.activityIndicator stopAnimating];
            [self setTitle:@"►" forState:UIControlStateNormal];
//            [self setTintColor:self.superview.tintColor];
            break;
        case ENHPlaybackButtonStatePlaybackPlaying:
            [self setHidden:NO];
            [self.activityIndicator stopAnimating];
            [self setTitle:@"||" forState:UIControlStateNormal];
//            [self setTintColor:self.superview.tintColor];
            break;
    }
    
    [self setTintColor:self.superview.tintColor];
}

@end
