//
//  ENHAVContentModel.m
//  VideoRig
//
//  Created by Dillan Laughlin on 10/6/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "ENHAVContentModel.h"

@implementation ENHAVContentModel

-(instancetype)initWithContentURL:(NSURL *)contentURL title:(NSString *)title contentDescription:(NSString *)contentDescription
{
    NSParameterAssert(contentURL);
    NSParameterAssert(title);
    
    self = [super init];
    if (self)
    {
        _contentURL = contentURL;
        _title = [title copy];
        _contentDescription = [contentDescription copy];
    }
    
    return self;
}

+(instancetype)contentModelWithContentURL:(NSURL *)contentURL title:(NSString *)title contentDescription:(NSString *)contentDescription
{
    return [[self.class alloc] initWithContentURL:contentURL
                                            title:title
                               contentDescription:contentDescription];
}

@end
