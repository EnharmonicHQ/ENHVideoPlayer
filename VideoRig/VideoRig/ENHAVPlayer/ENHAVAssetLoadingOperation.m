//
//  ENHAVAssetLoadingOperation.m
//
//  Created by Dillan Laughlin
//  Copyright © 2016 Enharmonic inc. All rights reserved.
//

#import "ENHAVAssetLoadingOperation.h"

NSString * ENHAVAssetLoadingOperationErrorDomain = @"com.enharmonichq.ENHAVAssetLoadingOperation";

NSString * const kPlayableKey           = @"playable";
NSString * const kProtectedContentKey   = @"hasProtectedContent";

typedef void (^ENHAVAssetLoadingOperationSuccessBlock)(AVURLAsset *asset);
typedef void (^ENHAVAssetLoadingOperationFailureBlock)(NSError *error);

@interface ENHAVAssetLoadingOperation () {
    BOOL _executing;
    BOOL _finished;
    BOOL _ready;
}

@property (nonatomic, strong, readwrite) NSURL *assetURL;
@property (nonatomic, strong, readwrite) NSArray <NSString *> *assetKeysToLoad;

@property (nonatomic, copy) ENHAVAssetLoadingOperationSuccessBlock success;
@property (nonatomic, copy) ENHAVAssetLoadingOperationFailureBlock failure;

@end

@implementation ENHAVAssetLoadingOperation

-(instancetype)initWithAssetURL:(NSURL *)assetURL
                assetKeysToLoad:(NSArray <NSString *> *)assetKeysToLoad
                        success:(void (^)(AVURLAsset *asset))success
                        failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(assetURL);
    NSParameterAssert(assetKeysToLoad);
    NSParameterAssert(success);
    NSParameterAssert(failure);
    
    self = [super init];
    if (self)
    {
        _assetURL = assetURL;
        _assetKeysToLoad = assetKeysToLoad;
        _success = [success copy];
        _failure = [failure copy];
        
        _executing = NO;
        _finished = NO;
        
        [self willChangeValueForKey:@"isReady"];
        _ready = YES;
        [self didChangeValueForKey:@"isReady"];
    }
    
    return self;
}

-(void)start
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (!self.cancelled)
    {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        [self loadAsset];
    }
}

-(void)cancel
{
    [super cancel];
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
//    NSLog(@"cancelled loading %@, %@", self, self.assetURL);
}

-(void)loadAsset
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.assetURL];
    
    __weak __typeof(self)weakSelf = self;
    [asset loadValuesAsynchronouslyForKeys:self.assetKeysToLoad completionHandler:^{
        if (!weakSelf.isCancelled)
        {
//            NSLog(@"loaded %@, %@", self, self.assetURL);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                
                // Check required key status
                for (NSString *key in [weakSelf.class assetKeysRequiredForPlayback])
                {
                    if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed)
                    {
                        break;
                    }
                }
                
                if (!asset.playable)
                {
                    NSString *description = [NSString stringWithFormat:@"Asset isn't playable: %@", asset.URL.absoluteString];
                    error = [NSError errorWithDomain:ENHAVAssetLoadingOperationErrorDomain
                                                code:ENHAVAssetLoadingOperationErrorUnplayableAsset
                                            userInfo:@{NSLocalizedDescriptionKey : description}];
                }
                else if (asset.hasProtectedContent)
                {
                    NSString *description = [NSString stringWithFormat:@"Asset has protected content: %@", asset.URL.absoluteString];
                    error = [NSError errorWithDomain:ENHAVAssetLoadingOperationErrorDomain
                                                code:ENHAVAssetLoadingOperationErrorProtectedContent
                                            userInfo:@{NSLocalizedDescriptionKey : description}];
                }
                
                if (error)
                {
                    if (weakSelf.failure)
                    {
                        weakSelf.failure(error);
                    }
                }
                else
                {
                    if (!weakSelf.isCancelled && weakSelf.success)
                    {
                        weakSelf.success(asset);
                    }
                }
                
                [weakSelf willChangeValueForKey:@"isExecuting"];
                [weakSelf willChangeValueForKey:@"isFinished"];
                
                _executing = NO;
                _finished = YES;
                
                [weakSelf didChangeValueForKey:@"isExecuting"];
                [weakSelf didChangeValueForKey:@"isFinished"];
            });
        }
        else
        {
            NSLog(@"Skipping cancelled operation for: %@", weakSelf.assetURL);
        }
    }];
}

-(BOOL)isExecuting
{
    return _executing;
}

-(BOOL)isFinished
{
    return _finished;
}

-(BOOL)isAsynchronous
{
    return YES;
}

-(BOOL)isReady
{
    return _ready;
}

+(NSArray <NSString *> *)assetKeysRequiredForPlayback
{
    return @[kPlayableKey, kProtectedContentKey];
}

@end
