//
//  PBSettingManager.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import <Foundation/Foundation.h>
#import "PBSettingGroup.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSNotificationName PBSettingItemChange;
OBJC_EXTERN NSString *const PBSettingItemTypeKey;
OBJC_EXTERN NSString *const PBSettingItemStatusKey;

@interface PBSettingManager : NSObject

+ (NSArray<PBSettingGroup *> *)loadSettings;

+ (NSString *)titleOfSwitchType:(PBSettingSwitchType)type;
+ (NSString *)storeIdenfierOfSwitchType:(PBSettingSwitchType)type;
+ (BOOL)isOnOfSwitchType:(PBSettingSwitchType)type;
+ (void)updateSwitchType:(PBSettingSwitchType)type isOn:(BOOL)isOn;

+ (BOOL)enableWhiteNoise;
+ (BOOL)enableMusicFusion;
+ (BOOL)disbaleLockScreen;

@end

NS_ASSUME_NONNULL_END
