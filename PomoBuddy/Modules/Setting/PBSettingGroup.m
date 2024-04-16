//
//  PBSettingGroup.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import "PBSettingGroup.h"

@interface PBSettingGroup ()

@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSArray<PBSettingSwitchItem *> *items;

@end

@implementation PBSettingGroup

- (instancetype)initWithTitle:(NSString *)title settingItems:(NSArray<PBSettingSwitchItem *> *)items {
    if (self = [super init]) {
        _title = title;
        _items = items;
    }
    return self;
}

@end
