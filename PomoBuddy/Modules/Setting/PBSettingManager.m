//
//  PBSettingManager.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import "PBSettingManager.h"
#import <BlocksKit/NSArray+BlocksKit.h>

NSNotificationName PBSettingItemChange = @"__PBSettingItemChange__";
NSString *const PBSettingItemTypeKey = @"__PBSettingItemTypeKey__";
NSString *const PBSettingItemStatusKey = @"__PBSettingItemStatusKey__";

@interface PBSettingManager ()

@end

@implementation PBSettingManager

+ (NSArray<PBSettingGroup *> *)loadSettings {
    NSMutableArray<PBSettingGroup *> *settings = [NSMutableArray array];
    // Sounds Settings
    PBSettingGroup *soundsGroup = [[PBSettingGroup alloc] initWithTitle:@"Sounds Settings" settingItems:@[
        [[PBSettingSwitchItem alloc] initWithType:PBSettingSwitchTypeWhiteNoise],
        [[PBSettingSwitchItem alloc] initWithType:PBSettingSwitchTypeMusicFusion],
    ]];
    [settings addObject:soundsGroup];
    // Advanced Settings
    PBSettingGroup *advancedGroup = [[PBSettingGroup alloc] initWithTitle:@"Advanced Settings" settingItems:@[
        [[PBSettingSwitchItem alloc] initWithType:PBSettingSwitchTypeDisableLockScreen],
    ]];
    [settings addObject:advancedGroup];
    return settings;
}

+ (NSString *)titleOfSwitchType:(PBSettingSwitchType)type {
    static NSDictionary *titleMap = nil;
    if (!titleMap) {
        titleMap = @{
            @(PBSettingSwitchTypeWhiteNoise): @"White Noise",
            @(PBSettingSwitchTypeMusicFusion): @"Music Fusion",
            @(PBSettingSwitchTypeDisableLockScreen): @"Disable Lock Screen"
        };
    }
    return titleMap[@(type)];
}

+ (NSString *)storeIdenfierOfSwitchType:(PBSettingSwitchType)type {
    return [NSString stringWithFormat:@"settings_%ld", (long)type];
}

+ (BOOL)isOnOfSwitchType:(PBSettingSwitchType)type {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self storeIdenfierOfSwitchType:type]];;
}

+ (void)updateSwitchType:(PBSettingSwitchType)type isOn:(BOOL)isOn {
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:[self storeIdenfierOfSwitchType:type]];
    [[NSNotificationCenter defaultCenter] postNotificationName:PBSettingItemChange object:nil userInfo:@{
        PBSettingItemTypeKey: @(type),
        PBSettingItemStatusKey: @(isOn)
    }];
}

+ (BOOL)enableWhiteNoise {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self storeIdenfierOfSwitchType:PBSettingSwitchTypeWhiteNoise]];
}

+ (BOOL)enableMusicFusion {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self storeIdenfierOfSwitchType:PBSettingSwitchTypeMusicFusion]];
}

+ (BOOL)disbaleLockScreen {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self storeIdenfierOfSwitchType:PBSettingSwitchTypeDisableLockScreen]];
}

@end
