//
//  PBEvent.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PBEventRepeatType) {
    PBEventRepeatTypeOnce,      // 一次性
    PBEventRepeatTypeRepeat,    // 可重复的
};

@interface PBEvent : NSObject

// 事件名
@property (nonatomic, strong) NSString *name;

// 持续时间
@property (nonatomic, assign) NSInteger duration;

// 重复类型
@property (nonatomic, assign) PBEventRepeatType repeatType;

@end

NS_ASSUME_NONNULL_END
