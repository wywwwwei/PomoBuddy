//
//  PBSettingSwitchItem.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import "PBSettingSwitchItem.h"
#import "PBSettingManager.h"

@interface PBSettingSwitchItem ()

@property (nonatomic, assign) PBSettingSwitchType type;

@end

@implementation PBSettingSwitchItem

- (instancetype)initWithType:(PBSettingSwitchType)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (NSString *)title {
    return [PBSettingManager titleOfSwitchType:self.type];
}

- (BOOL)isOn {
    return [PBSettingManager isOnOfSwitchType:self.type];
}

- (void)setIsOn:(BOOL)isOn {
    return [PBSettingManager updateSwitchType:self.type isOn:isOn];
}

@end
