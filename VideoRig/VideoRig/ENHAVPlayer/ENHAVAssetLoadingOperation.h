//
//  ENHAVAssetLoadingOperation.h
//
//  Created by Dillan Laughlin
//  Copyright © 2016 Enharmonic inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern NSString * ENHAVAssetLoadingOperationErrorDomain;

typedef NS_ENUM(NSUInteger, ENHAVAssetLoadingOperationError){
    ENHAVAssetLoadingOperationErrorUnknown = 0,
    ENHAVAssetLoadingOperationErrorUnplayableAsset,
    ENHAVAssetLoadingOperationErrorProtectedContent,
};

@interface ENHAVAssetLoadingOperation : NSOperation

@property (nonatomic, strong, readonly) NSURL *assetURL;
@property (nonatomic, strong, readonly) NSArray <NSString *> *assetKeysToLoad;

-(instancetype)initWithAssetURL:(NSURL *)assetURL
                assetKeysToLoad:(NSArray <NSString *> *)assetKeysToLoad
                        success:(void (^)(AVURLAsset *asset))success
                        failure:(void (^)(NSError *error))failure;

+(NSArray <NSString *> *)assetKeysRequiredForPlayback;

#pragma mark - Asset Loading Utilities

/**
 *  Shared serial queue for loading assets.
 *
 *  @return a shared `NSOperationQueue` instance.
 */
+ (NSOperationQueue *)sharedAssetLoadingQueue;

/**
 *  Creates an `ENHAVAssetLoadingOperation` instance to asyncronously load an asset from a URL string.
 *
 *  @param assetURL       an `NSString` pointing to the asset to load.
 *  @param operationQueue an `NSOperationQueue` to enqueue the operation on. If nil, the operation will be enqueued on the `sharedAssetLoadingQueue`.
 *  @param success        a block that will be called when the asset has been sucessfully loaded into a player item.
 *  @param failure        a block that will be called when the asset has been failed to load.
 *
 *  @return  an `ENHAVAssetLoadingOperation` instance.
 */
+(ENHAVAssetLoadingOperation *)loadAssetWithURLString:(NSString *)assetURLString
                                       operationQueue:(NSOperationQueue *)operationQueue
                                              success:(void (^)(AVPlayerItem *playerItem))success
                                              failure:(void (^)(NSError *error))failure;

/**
 *  Creates an `ENHAVAssetLoadingOperation` instance to asyncronously load an asset from a URL.
 *
 *  @param assetURL       an `NSURL` pointing to the asset to load.
 *  @param operationQueue an `NSOperationQueue` to enqueue the operation on. If nil, the operation will be enqueued on the `sharedAssetLoadingQueue`.
 *  @param success        a block that will be called when the asset has been sucessfully loaded into a player item.
 *  @param failure        a block that will be called when the asset has been failed to load.
 *
 *  @return  an `ENHAVAssetLoadingOperation` instance.
 */
+(ENHAVAssetLoadingOperation *)loadAssetWithURL:(NSURL *)assetURL
                                 operationQueue:(NSOperationQueue *)operationQueue
                                        success:(void (^)(AVPlayerItem *playerItem))success
                                        failure:(void (^)(NSError *error))failure;

@end
