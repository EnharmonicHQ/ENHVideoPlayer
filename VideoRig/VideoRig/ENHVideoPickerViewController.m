//
//  MasterViewController.m
//  VideoRig
//
//  Created by Dillan Laughlin on 6/11/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "ENHVideoPickerViewController.h"
#import "ENHVideoPlayerHostingViewController.h"
#import "ENHDataStore.h"

@interface ENHVideoPickerViewController ()

@property (readonly) NSArray<__kindof NSArray *> *sectionDataArrays;
@property (nonatomic, strong) NSArray<ENHAVContentModel *> *localContent;
@property (nonatomic, strong) NSArray<ENHAVContentModel *> *remoteContent;

@end

@implementation ENHVideoPickerViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                               target:self
                                                                               action:@selector(refreshButtonTapped:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [self setClearsSelectionOnViewWillAppear:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];

    [self reloadData];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Actions

- (void)refreshButtonTapped:(id)sender
{
    [self reloadData];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        ENHVideoPlayerHostingViewController *playerHostingViewController = (ENHVideoPlayerHostingViewController *)[[segue destinationViewController] topViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        id contentItem = [self contentItemAtIndexPath:indexPath];
        if ([contentItem isKindOfClass:ENHAVContentModel.class])
        {
            ENHAVContentModel *contentModel = (ENHAVContentModel *)contentItem;
            [playerHostingViewController appendContentWithURL:contentModel.contentURL];
        }
        else if ([contentItem isKindOfClass:AVPlayerItem.class])
        {
            AVPlayerItem *playerItem = (AVPlayerItem *)contentItem;
            [playerHostingViewController skipPlayerToItem:playerItem];
        }
        
        playerHostingViewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        playerHostingViewController.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionDataArrays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionData = [self sectionDataArrayForSection:section];
    return [sectionData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id contentItem = [self contentItemAtIndexPath:indexPath];
    if ([contentItem isKindOfClass:ENHAVContentModel.class])
    {
        [self configureCell:cell withContentModel:(ENHAVContentModel *)contentItem];
    }
    else if ([contentItem isKindOfClass:[AVPlayerItem class]])
    {
        [self configureCell:cell withPlayerItem:(AVPlayerItem *)contentItem atIndexPath:indexPath];
    }
}

-(void)configureCell:(UITableViewCell *)cell withPlayerItem:(AVPlayerItem *)playerItem atIndexPath:(NSIndexPath *)indexPath
{
    NSURL *assetURL = [self.class assetURLForPlayerItem:playerItem];
    ENHAVContentModel *contentModel = [[ENHDataStore sharedDataStore] contentModelWithURL:assetURL];
    if (contentModel)
    {
        [self configureCell:cell withContentModel:contentModel];
    }
    else
    {
        [cell.textLabel setText:assetURL.absoluteString];
        [cell.textLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    }
    
    if ([playerItem isEqual:self.playerHostingViewController.player.currentItem])
    {
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:(UITableViewScrollPositionNone)];
    }
}

-(void)configureCell:(UITableViewCell *)cell withContentModel:(ENHAVContentModel *)contentModel
{
    [cell.textLabel setText:contentModel.title];
    [cell.textLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [cell.detailTextLabel setText:contentModel.contentDescription];
    [cell.detailTextLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
}

-(nullable NSString *)tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    NSArray *sectionData = [self sectionDataArrayForSection:section];
    if (sectionData && sectionData == self.localContent)
    {
        title = @"Local";
    }
    else if (sectionData && sectionData == self.remoteContent)
    {
        title = @"Remote";
    }
    else if (section == 0)
    {
        title = @"Playback Queue";
    }
    
    return title;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UINavigationController *navigationController = (UINavigationController *)[self.splitViewController.viewControllers lastObject];
    UIViewController *viewController = [navigationController topViewController];
    
    if ([viewController isKindOfClass:[ENHVideoPlayerHostingViewController class]])
    {
        ENHVideoPlayerHostingViewController *playerHostingViewController = (ENHVideoPlayerHostingViewController *)viewController;
        id contentItem = [self contentItemAtIndexPath:indexPath];
        if ([contentItem isKindOfClass:ENHAVContentModel.class])
        {
            ENHAVContentModel *contentModel = (ENHAVContentModel *)contentItem;
            [playerHostingViewController appendContentWithURL:contentModel.contentURL];
        }
        else if ([contentItem isKindOfClass:[AVPlayerItem class]])
        {
            [playerHostingViewController skipPlayerToItem:(AVPlayerItem *)contentItem];
        }
        
        [self.splitViewController setPreferredDisplayMode:(UISplitViewControllerDisplayModePrimaryHidden)];
    }
    else
    {
        [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if (indexPath.section == 0)
    {
        style = UITableViewCellEditingStyleDelete;
    }
    
    return style;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        AVPlayerItem *playerItem = [self.playerHostingViewController.playerItems objectAtIndex:indexPath.row];
        if (playerItem)
        {
            [self.playerHostingViewController.player removeItem:playerItem];
            [self reloadData];
        }
    }
}

#pragma mark - Data Utilities

+(NSURL *)assetURLForPlayerItem:(AVPlayerItem *)playerItem
{
    NSURL *assetURL = nil;
    if ([playerItem.asset isKindOfClass:AVURLAsset.class])
    {
        AVURLAsset *asset = (AVURLAsset *)playerItem.asset;
        assetURL = [asset URL];
    }
    
    return assetURL;
}

-(NSArray *)sectionDataArrayForSection:(NSInteger)section
{
    NSArray *sectionData = nil;
    
    if (section >= 0 && section < [self.sectionDataArrays count])
    {
        sectionData = self.sectionDataArrays[section];
    }
    
    return sectionData;
}

-(id)contentItemAtIndexPath:(NSIndexPath *)indexPath
{
    id contentItem = nil;
    
    NSArray *sectionData = [self sectionDataArrayForSection:indexPath.section];
    NSInteger row = indexPath.row;
    if (row >= 0 && row < [sectionData count])
    {
        contentItem = sectionData[row];
    }
    
    return contentItem;
}

-(void)reloadData
{
    ENHDataStore *dataStore = [ENHDataStore sharedDataStore];
    [dataStore reloadData];
    [self setLocalContent:dataStore.localContent];
    [self setRemoteContent:dataStore.remoteContent];
    
    [self.tableView reloadData];
}

#pragma mark - Accessors

-(NSArray *)sectionDataArrays
{
    NSMutableArray *sectionDataArrays = [NSMutableArray array];
    if ([self.playerHostingViewController playerItems])
    {
        [sectionDataArrays addObject:self.playerHostingViewController.playerItems];
    }
    if ([self localContent])
    {
        [sectionDataArrays addObject:self.localContent];
    }
    if ([self remoteContent])
    {
        [sectionDataArrays addObject:self.remoteContent];
    }
    
    return [NSArray arrayWithArray:sectionDataArrays];
}

@end
