//
//  PBCountdownModel.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import "PBCountdownModel.h"

@implementation PBCountdownModel

+ (instancetype)countdownModelWithTitle:(NSString *)title
                        backgroundColor:(UIColor *)backgroundColor {
    PBCountdownModel *model = [[PBCountdownModel alloc] init];
    model.title = title;
    model.backgroundColor = backgroundColor;
    return model;
}

@end
