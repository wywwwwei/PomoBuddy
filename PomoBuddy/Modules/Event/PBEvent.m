//
//  PBEvent.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#import "PBEvent.h"

@implementation PBEvent

+ (instancetype)eventWithTitle:(NSString *)title
                     spendTime:(NSInteger)spendTime
                     totalTime:(NSInteger)totalTime {
    PBEvent *event = [[PBEvent alloc] init];
    event.title = title;
    event.spendTime = spendTime;
    event.totalTime = totalTime;
    return event;
}

@end
