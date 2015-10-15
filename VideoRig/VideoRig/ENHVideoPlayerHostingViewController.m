//
//  DetailViewController.m
//  VideoRig
//
//  Created by Dillan Laughlin on 6/11/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "ENHVideoPlayerHostingViewController.h"

#import "ENHAVPlayerViewController.h"

@import AVKit;
@import AVFoundation;

NSString * const kTracksKey             = @"tracks";
NSString * const kPlayableKey           = @"playable";
NSString * const kDurationKey           = @"duration";
NSString * const kProtectedContentKey   = @"hasProtectedContent";
NSString * const kCommonMetadata        = @"commonMetadata";

@interface ENHVideoPlayerHostingViewController ()

@property (nonatomic, weak) IBOutlet UIView *playerHostingView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) UIViewController *playerViewController;
@property (nonatomic, strong, readwrite) AVQueuePlayer *player;

@end

@implementation ENHVideoPlayerHostingViewController

#pragma mark - View Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self setEdgesForExtendedLayout:(UIRectEdgeNone)];
    
    [self configurePlayerUI];
    
    // Setup Audio Session to allow AirPlay & PiP to continue while app is backgrounded.
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    if (![audioSession setCategory:AVAudioSessionCategoryPlayback
                             error:&setCategoryError])
    {
        NSLog(@"Audio Session Category Error: %@", setCategoryError);
    }
    
    NSError *activationError = nil;
    if (![audioSession setActive:YES error:&activationError])
    {
        NSLog(@"Audio Session Activation Error: %@", activationError);
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([self isMovingFromParentViewController] || [self isBeingDismissed])
    {
        [self.player setRate:0.0];
    }
}

-(void)configurePlayerUI
{
    [self.player setRate:0.0];
    
    UIViewController *playerViewController = nil;
    if ([self.segmentedControl selectedSegmentIndex] == 0)
    {
        playerViewController = [[AVPlayerViewController alloc] init];
    }
    else
    {
        playerViewController = [[ENHAVPlayerViewController alloc] initWithNibName:NSStringFromClass(ENHAVPlayerViewController.class) bundle:nil];
    }
    NSParameterAssert(playerViewController);
    
    [self setPlayerViewController:playerViewController];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Data

-(void)appendContentWithURL:(NSURL *)contentURL
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:contentURL];
    [self asynchronouslyLoadURLAsset:asset];
}

+(NSArray *)assetKeysRequiredToPlay
{
    return @[kPlayableKey, kProtectedContentKey];
}

+(NSArray *)assetKeysToLoad
{
    NSMutableArray *assetKeysToLoad = [NSMutableArray arrayWithArray:[self assetKeysRequiredToPlay]];
    [assetKeysToLoad addObjectsFromArray:@[kTracksKey, kDurationKey]];
    
    return [NSArray arrayWithArray:assetKeysToLoad];
}

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)asset
{
    __weak __typeof(self)weakSelf = self;
    [asset loadValuesAsynchronouslyForKeys:self.class.assetKeysToLoad completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSString *key in weakSelf.class.assetKeysRequiredToPlay)
            {
                NSError *error = nil;
                if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed)
                {
                    NSString *stringFormat = NSLocalizedString(@"error.asset_%@_key_%@_failed.description", @"Can't use this AVAsset because one of it's keys failed to load");
                    
                    NSString *message = [NSString localizedStringWithFormat:stringFormat, asset.URL, key];
                    
                    [weakSelf handleErrorWithMessage:message error:error];
                    
                    return;
                }
            }
            
            // We can't play this asset.
            if (!asset.playable || asset.hasProtectedContent) {
                NSString *stringFormat = NSLocalizedString(@"error.asset_%@_not_playable.description", @"Can't use this AVAsset because it isn't playable or has protected content");
                
                NSString *message = [NSString localizedStringWithFormat:stringFormat, asset.URL];
                
                [weakSelf handleErrorWithMessage:message error:nil];
                
                return;
            }
            
            [weakSelf enqueueAsset:asset];
        });
    }];
}

-(void)enqueueAsset:(AVURLAsset *)asset
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(playerItems))];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    if (!self.player)
    {
        self.player = [AVQueuePlayer queuePlayerWithItems:@[item]];
        [[self class] setPlayer:self.player onPlayerViewController:self.playerViewController];
    }
    else
    {
        NSArray *playerItems = [self playerItems];
        AVPlayerItem *lastItem = [playerItems lastObject];
        
        if ([self.player canInsertItem:item afterItem:lastItem])
        {
            [self.player insertItem:item afterItem:lastItem];
        }
    }
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(playerItems))];
}

- (void)handleErrorWithMessage:(NSString *)message error:(NSError *)error {
    NSLog(@"Error occured with message: %@, error: %@.", message, error);
    
    NSString *alertTitle = NSLocalizedString(@"alert.error.title", @"Alert title for errors");
    NSString *defaultAlertMessage = NSLocalizedString(@"error.default.description", @"Default error message when no NSError provided");
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:alertTitle message:message ?: defaultAlertMessage  preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *alertActionTitle = NSLocalizedString(@"alert.error.actions.OK", @"OK on error alert");
    UIAlertAction *action = [UIAlertAction actionWithTitle:alertActionTitle style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    
    [self presentViewController:controller animated:YES completion:nil];
}

+(void)setPlayer:(AVQueuePlayer *)player onPlayerViewController:(UIViewController *)viewController
{
    [player setRate:0.0];
    if ([viewController isKindOfClass:[AVPlayerViewController class]])
    {
        AVPlayerViewController *playerVC = (AVPlayerViewController *)viewController;
        [playerVC setPlayer:player];
    }
    else if ([viewController isKindOfClass:[ENHAVPlayerViewController class]])
    {
        ENHAVPlayerViewController *playerVC = (ENHAVPlayerViewController *)viewController;
        [playerVC setPlayer:player];
    }
}

-(void)skipPlayerToItem:(AVPlayerItem *)playerItem
{
    NSArray *playerItems = [self playerItems];
    NSInteger index = [playerItems indexOfObject:playerItem];
    if (index != NSNotFound && index > 0)
    {
        NSArray *itemsToRemove = [playerItems subarrayWithRange:NSMakeRange(0, index)];
        [itemsToRemove enumerateObjectsWithOptions:NSEnumerationReverse
                                        usingBlock:^(AVPlayerItem * _Nonnull playerItem, NSUInteger idx, BOOL * __nonnull stop) {
                                            [self.player removeItem:playerItem];
                                        }];
    }
}

#pragma mark - Actions

-(IBAction)segmentedControlValueChanged:(id)sender
{
    [self configurePlayerUI];
}

#pragma mark - Accessors

-(void)setPlayerViewController:(UIViewController *)playerViewController
{
    if (_playerViewController != playerViewController)
    {
        if (_playerViewController)
        {
            [_playerViewController willMoveToParentViewController:nil];
            [_playerViewController.view removeFromSuperview];
            [_playerViewController removeFromParentViewController];
            [self.class setPlayer:nil onPlayerViewController:_playerViewController];
        }
        
        _playerViewController = playerViewController;
        
        if (_playerViewController)
        {
            [self addChildViewController:_playerViewController];
            
            UIView *playerView = [_playerViewController view];
            playerView.frame = [self.view bounds];
            [self.view addSubview:playerView];
            [self.view sendSubviewToBack:playerView];
            
            [_playerViewController didMoveToParentViewController:self];
            
            [[self class] setPlayer:self.player onPlayerViewController:_playerViewController];
        }
    }
}

-(NSArray *)playerItems
{
    return [self.player items];
}

@end
