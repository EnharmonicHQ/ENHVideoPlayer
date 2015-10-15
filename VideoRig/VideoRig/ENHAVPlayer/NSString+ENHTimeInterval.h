//
//  NSString+ENHTimeInterval.h
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

@interface NSString (ENHTimeInterval)

+(NSString *)enh_HHMMSSStringWithTimeInterval:(NSTimeInterval)timeInterval;

+(NSString *)enh_HHMMSSStringWithTime:(CMTime)time;

@end
