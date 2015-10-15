//
//  ENHDataStore.h
//  VideoRig
//
//  Created by Dillan Laughlin on 6/12/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ENHAVContentModel.h"

@interface ENHDataStore : NSObject

@property (nonatomic, strong, readonly, nonnull) NSArray <ENHAVContentModel *> *localContent;
@property (nonatomic, strong, readonly, nonnull) NSArray <ENHAVContentModel *> *remoteContent;

+(nonnull instancetype)sharedDataStore;

-(nullable ENHAVContentModel *)contentModelWithURL:(nonnull NSURL *)contentURL;
-(void)reloadData;

@end
