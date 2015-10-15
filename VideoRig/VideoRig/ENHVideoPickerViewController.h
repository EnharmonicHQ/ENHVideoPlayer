//
//  MasterViewController.h
//  VideoRig
//
//  Created by Dillan Laughlin on 6/11/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

@import UIKit;

@class ENHVideoPlayerHostingViewController;

@interface ENHVideoPickerViewController : UITableViewController

@property (strong, nonatomic) ENHVideoPlayerHostingViewController *playerHostingViewController;

@end

