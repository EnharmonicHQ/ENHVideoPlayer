//
//  NSString+ENHTimeInterval.m
//  VideoRig
//
//  Created by Dillan Laughlin on 9/4/15.
//  Copyright © 2015 Enharmonic. All rights reserved.
//

#import "NSString+ENHTimeInterval.h"

@implementation NSString (ENHTimeInterval)

+(void)enh_convertTimeInterval:(NSTimeInterval)timeInterval intoHours:(int *)hours minutes:(int *)minutes seconds:(int *)seconds
{
    *seconds = fmod(timeInterval, 60);
    *minutes = fmod ((timeInterval / 60), 60);
    *hours = timeInterval / 3600;
}

+(NSString *)enh_HHMMSSStringWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSString *outputString = @"";
    
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    [self enh_convertTimeInterval:timeInterval intoHours:&hours minutes:&minutes seconds:&seconds];
    
    if (hours > 0)
    {
        outputString = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else
    {
        outputString = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    
    return outputString;
}

+(NSString *)enh_HHMMSSStringWithTime:(CMTime)time
{
    Float64 seconds = CMTimeGetSeconds(time);
    return [self enh_HHMMSSStringWithTimeInterval:seconds];
}

@end
