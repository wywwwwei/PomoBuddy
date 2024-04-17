//
//  HistoricalDataRecord.h
//  PomoBuddy
//
//  Created by 楚门 on 2024/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistoricalDataRecord : NSObject

@property (nonatomic, strong) NSString *eventName; // 事件名称

@property (nonatomic, assign) NSTimeInterval duration; // 设定时长

@property (nonatomic, strong) NSDate *startTime; // 开始时间

@property (nonatomic, strong) NSDate *endTime; // 结束时间

@property (nonatomic, assign) NSTimeInterval actualDuration; // 实际持续时间


- (instancetype)initWithEventName:(NSString *)eventName
                          duration:(NSTimeInterval)duration
                         startTime:(NSDate *)startTime
                           endTime:(NSDate *)endTime
                    actualDuration:(NSTimeInterval)actualDuration;

@end

NS_ASSUME_NONNULL_END
