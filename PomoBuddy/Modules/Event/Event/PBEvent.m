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

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:@(self.spendTime) forKey:@"spendTime"];
    [coder encodeObject:@(self.totalTime) forKey:@"totalTime"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.title = [coder decodeObjectForKey:@"title"];
        self.spendTime = [[coder decodeObjectForKey:@"spendTime"] integerValue];
        self.totalTime = [[coder decodeObjectForKey:@"totalTime"] integerValue];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
