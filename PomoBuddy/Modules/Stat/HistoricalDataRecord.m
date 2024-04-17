//
//  HistoricalDataRecord.m
//  PomoBuddy
//
//  Created by 楚门 on 2024/4/17.
//

#import "HistoricalDataRecord.h"

@implementation HistoricalDataRecord


- (instancetype)initWithEventName:(NSString *)eventName
                          duration:(NSTimeInterval)duration
                         startTime:(NSDate *)startTime
                           endTime:(NSDate *)endTime
                    actualDuration:(NSTimeInterval)actualDuration {
    self = [super init];
    if (self) {
        _eventName = eventName;
        _duration = duration;
        _startTime = startTime;
        _endTime = endTime;
        _actualDuration = actualDuration;
    }
    return self;
}

@end

