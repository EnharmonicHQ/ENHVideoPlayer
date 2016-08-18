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

@end
