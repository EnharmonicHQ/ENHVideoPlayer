//
//  DetailViewController.h
//  VideoRig
//
//  Created by Dillan Laughlin on 6/11/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

@import UIKit;
@import AVFoundation;

@interface ENHVideoPlayerHostingViewController : UIViewController

@property (readonly) NSArray *playerItems;
@property (nonatomic, strong, readonly) AVQueuePlayer *player;

-(void)appendContentWithURL:(NSURL *)contentURL;
-(void)skipPlayerToItem:(AVPlayerItem *)playerItem;

@end

