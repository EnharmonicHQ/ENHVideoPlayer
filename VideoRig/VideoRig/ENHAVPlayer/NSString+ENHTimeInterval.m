//
//  NSString+ENHTimeInterval.m
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
