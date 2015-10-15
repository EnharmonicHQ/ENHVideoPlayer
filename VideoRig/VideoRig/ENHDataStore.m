//
//  ENHDataStore.m
//  VideoRig
//
//  Created by Dillan Laughlin on 6/12/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "ENHDataStore.h"

@import MobileCoreServices;

@interface ENHDataStore ()

@property (nonatomic, strong, readwrite, nonnull) NSArray <ENHAVContentModel *> *localContent;
@property (nonatomic, strong, readwrite, nonnull) NSArray <ENHAVContentModel *> *remoteContent;

@end

@implementation ENHDataStore

+(nonnull instancetype)sharedDataStore
{
    static dispatch_once_t onceQueue;
    static ENHDataStore *sharedDataStore = nil;
    
    dispatch_once(&onceQueue, ^{
        sharedDataStore = [[self alloc] init];
    });
    
    return sharedDataStore;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self reloadData];
    }
    
    return self;
}

-(void)reloadData
{
    [self populateLocalContent];
    [self populateRemoteContent];
}

-(ENHAVContentModel *)contentModelWithURL:(NSURL *)contentURL
{
    ENHAVContentModel *contentModel = nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(ENHAVContentModel * _Nonnull contentModel, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [contentModel.contentURL isEqual:contentURL];
    }];
    NSArray *contentModels = [@[self.localContent, self.remoteContent] valueForKeyPath:@"@distinctUnionOfArrays.self"];
    NSArray *filteredContentModels = [contentModels filteredArrayUsingPredicate:predicate];
    contentModel = [filteredContentModels firstObject];
    
    return contentModel;
}

#pragma mark - Local Data

+(NSPredicate *)conformingUTIPredicate
{
    static NSPredicate *conformingUTIPredicate = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        conformingUTIPredicate = [NSPredicate predicateWithBlock:^BOOL(NSURL *itemURL, NSDictionary *bindings) {
            NSString *itemUTI = nil;
            NSError *itemUTIError = nil;
            if ([itemURL getResourceValue:&itemUTI forKey:NSURLTypeIdentifierKey error:&itemUTIError])
            {
                if (UTTypeConformsTo((__bridge CFStringRef)(itemUTI), kUTTypeMovie))
                {
                    return YES;
                }
                else if (UTTypeConformsTo((__bridge CFStringRef)(itemUTI), kUTTypeAudio))
                {
                    return YES;
                }
            }
            else if (itemUTIError)
            {
                NSLog(@"Failed to retrieve UTI of file at URL: %@; Error: %@", itemURL, [itemUTIError localizedDescription]);
            }
            
            return NO;
        }];
    });
    
    return conformingUTIPredicate;
}

-(void)populateLocalContent
{
    NSMutableArray *localContentURLs = [NSMutableArray array];
    
    NSArray *directoryURLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectoryURL = [directoryURLs lastObject];
    NSURL *sampleDataDirectoryURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"SampleData"];
    
    for (NSURL *directoryURL in @[documentsDirectoryURL, sampleDataDirectoryURL])
    {
        NSError *error = nil;
        NSArray *fileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directoryURL
                                                          includingPropertiesForKeys:@[ NSURLTypeIdentifierKey, NSURLLocalizedNameKey ]
                                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               error:&error];
        NSArray *filteredURLs = [fileURLs filteredArrayUsingPredicate:[[self class] conformingUTIPredicate]];
        [localContentURLs addObjectsFromArray:filteredURLs];
    }
    
    NSMutableArray *localContent = [NSMutableArray array];
    
    for (NSURL *fileURL in localContentURLs)
    {
        NSString *localizedName = nil;
        NSError *error = nil;
        if (![fileURL getResourceValue:&localizedName
                           forKey:NSURLLocalizedNameKey
                            error:&error])
        {
            if (error)
            {
                NSLog(@"URL resource value error: %@", error);
            }
        }
        
        ENHAVContentModel *contentModel = [ENHAVContentModel contentModelWithContentURL:fileURL
                                                                                  title:localizedName
                                                                     contentDescription:@"Local File"];
        [localContent addObject:contentModel];
    }
    
    [self setLocalContent:[NSArray arrayWithArray:localContent]];
}

#pragma mark - Remote Content

-(void)populateRemoteContent
{
    NSMutableArray *remoteContent = [NSMutableArray array];
    
    // Content URLs below are from: http://stackoverflow.com/questions/10104301/hls-streaming-video-url-need-for-testing
    ENHAVContentModel *appleBipBopVideo = [ENHAVContentModel contentModelWithContentURL:[NSURL URLWithString:@"https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"]
                                                                                    title:@"Bip Bop" contentDescription:@"Apple Test HLS Pattern"];
    [remoteContent addObject:appleBipBopVideo];
    
    ENHAVContentModel *tearsOfSteelAdaptiveVideo = [ENHAVContentModel contentModelWithContentURL:[NSURL URLWithString:@"http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8"]
                                                                                           title:@"Tears of Steel"
                                                                              contentDescription:@"Sample Adaptive Stream"];
    [remoteContent addObject:tearsOfSteelAdaptiveVideo];
    
    ENHAVContentModel *vevoLiveVideo = [ENHAVContentModel contentModelWithContentURL:[NSURL URLWithString:@"http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch1/appleman.m3u8"]
                                                                               title:@"Vevo Live" contentDescription:@"Vevo Live HLS Stream"];
    [remoteContent addObject:vevoLiveVideo];
    
    [self setRemoteContent:[NSArray arrayWithArray:remoteContent]];
}

@end
