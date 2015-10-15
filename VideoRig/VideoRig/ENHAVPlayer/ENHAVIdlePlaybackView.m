//
//  ENHAVIdlePlaybackView.m
//  VideoRig
//
//  Created by Dillan Laughlin on 9/29/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "ENHAVIdlePlaybackView.h"

@interface ENHAVIdlePlaybackView ()

@property (nonatomic, weak, readwrite) IBOutlet UIImageView *imageView;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *textLabel;

@end

@implementation ENHAVIdlePlaybackView

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
}

@end
