//
//  UIImageView+ENHAVThumbnail.h
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@interface UIImageView (ENHAVThumbnail)

- (void)enh_setImageWithAVAssetURL:(NSURL *)assetURL
                              time:(Float64)timeInSeconds
                  placeholderImage:(UIImage *)placeholderImage
                           success:(void (^)(UIImage *image))success
                           failure:(void (^)(NSError *error))failure;

- (void)enh_setImageWithAVURLAsset:(AVURLAsset *)asset
                              time:(CMTime)time
                  placeholderImage:(UIImage *)placeholderImage
                           success:(void (^)(UIImage *image))success
                           failure:(void (^)(NSError *error))failure;

- (void)enh_setImageWithAVURLAsset:(AVURLAsset *)asset
                              time:(CMTime)time
                  placeholderImage:(UIImage *)placeholderImage
                          duration:(NSTimeInterval)duration
                           options:(UIViewAnimationOptions)options
                           success:(void (^)(UIImage *image))success
                           failure:(void (^)(NSError *error))failure;

@end
