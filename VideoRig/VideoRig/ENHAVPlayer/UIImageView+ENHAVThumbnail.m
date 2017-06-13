//
//  UIImageView+ENHAVThumbnail.m
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic inc. All rights reserved.
//
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


#import "UIImageView+ENHAVThumbnail.h"

#import <objc/runtime.h>

static const NSTimeInterval kENHAVThumbnailDefaultAnimationDuration = 0.2;
static const UIViewAnimationOptions kENHAVThumbnailDefaultAnimationOptions = UIViewAnimationOptionTransitionCrossDissolve;

@protocol ENHImageCache <NSObject>

-(UIImage *)cachedImageForAssetURL:(NSURL *)assetURL atTime:(Float64)time;
-(void)cacheImage:(UIImage *)image forAssetURL:(NSURL *)assetURL atTime:(Float64)time;

@end

@interface ENHImageCache : NSCache <ENHImageCache>
@end

@interface UIImageView (_ENHAVThumbnail)

@property (readwrite, nonatomic, strong, setter = enh_setImageRequestOperation:) NSOperation *enh_imageRequestOperation;

@end

@implementation UIImageView (_ENHAVThumbnail)

+(NSOperationQueue *)enh_sharedImageRequestOperationQueue
{
    static NSOperationQueue *_enh_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _enh_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _enh_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return _enh_sharedImageRequestOperationQueue;
}

-(NSOperation *)enh_imageRequestOperation
{
    return (NSOperation *)objc_getAssociatedObject(self, @selector(enh_imageRequestOperation));
}

-(void)enh_setImageRequestOperation:(NSOperation *)imageRequestOperation
{
    objc_setAssociatedObject(self, @selector(enh_imageRequestOperation), imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIImageView (ENHAVThumbnail)

+(id <ENHImageCache>)sharedImageCache
{
    static ENHImageCache *_enh_defaultImageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _enh_defaultImageCache = [[ENHImageCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * __unused notification) {
            [_enh_defaultImageCache removeAllObjects];
        }];
    });
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(sharedImageCache)) ?: _enh_defaultImageCache;
#pragma clang diagnostic pop
}

+(void)setSharedImageCache:(id <ENHImageCache>)imageCache
{
    objc_setAssociatedObject(self, @selector(sharedImageCache), imageCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)enh_setImageWithAVAssetURL:(NSURL *)assetURL
                              time:(Float64)timeInSeconds
                  placeholderImage:(UIImage *)placeholderImage
                           success:(void (^)(UIImage *image))success
                           failure:(void (^)(NSError *error))failure;
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:assetURL];
    CMTime cmTime = CMTimeMakeWithSeconds(timeInSeconds, asset.duration.timescale);
    [self enh_setImageWithAVURLAsset:asset
                                time:cmTime
                    placeholderImage:placeholderImage
                             success:success
                             failure:failure];
}

-(void)enh_setImageWithAVURLAsset:(AVURLAsset *)asset
                              time:(CMTime)time
                  placeholderImage:(UIImage *)placeholderImage
                           success:(void (^)(UIImage *image))success
                           failure:(void (^)(NSError *error))failure
{
    [self enh_setImageWithAVURLAsset:asset
                                time:time
                    placeholderImage:placeholderImage
                            duration:kENHAVThumbnailDefaultAnimationDuration
                             options:kENHAVThumbnailDefaultAnimationOptions
                             success:success
                             failure:failure];
}

-(void)enh_setImageWithAVURLAsset:(AVURLAsset *)asset
                              time:(CMTime)time
                  placeholderImage:(UIImage *)placeholderImage
                          duration:(NSTimeInterval)duration
                           options:(UIViewAnimationOptions)options
                           success:(void (^)(UIImage *image))success
                           failure:(void (^)(NSError *error))failure
{
    [self cancelImageRequestOperation];
    
    Float64 seconds = CMTimeGetSeconds(time);
    UIImage *cachedImage = [[[self class] sharedImageCache] cachedImageForAssetURL:asset.URL atTime:seconds];
    if (cachedImage)
    {
        if (success)
        {
            success(cachedImage);
        }
        else
        {
            self.image = cachedImage;
        }
        
        self.enh_imageRequestOperation = nil;
    }
    else
    {
        if (placeholderImage)
        {
            self.image = placeholderImage;
        }
        
        __weak __typeof(self)weakSelf = self;
        NSBlockOperation *operation = [[NSBlockOperation alloc] init];
        __weak NSBlockOperation *weakOperation = operation;
        [operation addExecutionBlock:^{
            if (![weakOperation isCancelled])
            {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                NSError *error = nil;
                UIImage *image = [strongSelf imageWithAsset:asset
                                                       time:time
                                                      error:&error];
                
                if (image)
                {
                    [[[strongSelf class] sharedImageCache] cacheImage:image forAssetURL:asset.URL atTime:seconds];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image)
                    {
                        if (success)
                        {
                            success(image);
                        }
                        else
                        {
                            [UIView transitionWithView:strongSelf
                                              duration:duration
                                               options:options
                                            animations:^{
                                                strongSelf.image = image;
                                            } completion:nil];
                        }
                    }
                    else
                    {
                        if (failure)
                        {
                            failure(error);
                        }
                    }
                });
                
                [strongSelf enh_setImageRequestOperation:nil];
            }
        }];
        
        [self enh_setImageRequestOperation:operation];
        [[[self class] enh_sharedImageRequestOperationQueue] addOperation:self.enh_imageRequestOperation];
    }
}

-(void)cancelImageRequestOperation
{
    [self.enh_imageRequestOperation cancel];
    self.enh_imageRequestOperation = nil;
}

-(UIImage *)imageWithAsset:(AVAsset *)asset time:(CMTime)time error:(NSError **)error
{
    UIImage *outputImage = nil;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    [generator setAppliesPreferredTrackTransform:YES];
    CMTime tolerance = CMTimeMake(1, 1);
    [generator setRequestedTimeToleranceBefore:tolerance];
    [generator setRequestedTimeToleranceAfter:tolerance];
    
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:error];

    outputImage = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return outputImage;
}

@end

#pragma mark -

static inline NSString * ENHImageCacheKeyFromURLAndTime(NSURL *assetURL, Float64 time)
{
    NSString *cacheKey = [NSString stringWithFormat:@"%@#%@", assetURL.absoluteString, @(time)];
    return cacheKey;
}

@implementation ENHImageCache

- (UIImage *)cachedImageForAssetURL:(NSURL *)assetURL atTime:(Float64)time
{
    return [self objectForKey:ENHImageCacheKeyFromURLAndTime(assetURL, time)];
}

- (void)cacheImage:(UIImage *)image
       forAssetURL:(NSURL *)assetURL
            atTime:(Float64)time
{
    if (image && assetURL)
    {
        [self setObject:image forKey:ENHImageCacheKeyFromURLAndTime(assetURL, time)];
    }
}

@end
