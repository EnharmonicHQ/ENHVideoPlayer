//
//  ENHTappableSlider.m
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "ENHTappableSlider.h"

@implementation ENHTappableSlider

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    
    return self;
}

-(void)sharedInit
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(sliderTapped:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

-(void)sliderTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (![self isHighlighted]) // User is interacting with the slider thumb, let default behavior take place.
        {
            CGPoint touchPoint = [gestureRecognizer locationInView:self];
            CGFloat percentage = touchPoint.x / self.bounds.size.width;
            CGFloat delta = percentage * (self.maximumValue - self.minimumValue);
            CGFloat value = self.minimumValue + delta;
            [self setValue:value animated:YES];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

@end
