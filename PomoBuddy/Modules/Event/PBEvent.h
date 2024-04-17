//
//  PBEvent.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBEvent : NSObject

// 事件名
@property (nonatomic, strong) NSString *title;

// 每次的时间
@property (nonatomic, assign) NSInteger spendTime;

// 总共做了多少时间
@property (nonatomic, assign) NSInteger totalTime;

+ (instancetype)eventWithTitle:(NSString *)title
                     spendTime:(NSInteger)spendTime
                     totalTime:(NSInteger)totalTime;
@end

NS_ASSUME_NONNULL_END
