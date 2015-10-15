//
//  ENHAVContentModel.h
//  VideoRig
//
//  Created by Dillan Laughlin on 10/6/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENHAVContentModel : NSObject

@property (nonatomic, strong) NSURL *contentURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *contentDescription;

-(instancetype)initWithContentURL:(NSURL *)contentURL title:(NSString *)title contentDescription:(NSString *)contentDescription;
+(instancetype)contentModelWithContentURL:(NSURL *)contentURL title:(NSString *)title contentDescription:(NSString *)contentDescription;

@end
