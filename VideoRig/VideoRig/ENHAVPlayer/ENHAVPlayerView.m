//
//  ENHAVPlayerView.m
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "ENHAVPlayerView.h"

@implementation ENHAVPlayerView

+(Class)layerClass
{
    return [AVPlayerLayer class];
}

-(AVPlayer *)player
{
    return [self.playerLayer player];
}

-(void)setPlayer:(AVPlayer *)player
{
    [self.playerLayer setPlayer:player];
    [self.layer setNeedsDisplayOnBoundsChange:YES];
}

-(AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)[self layer];
}

@end
