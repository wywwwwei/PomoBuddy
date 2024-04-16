//
//  PBSettingGroup.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import <Foundation/Foundation.h>
#import "PBSettingSwitchItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBSettingGroup : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray<PBSettingSwitchItem *> *items;

- (instancetype)initWithTitle:(NSString *)title
                 settingItems:(NSArray<PBSettingSwitchItem *> *)items;

@end

NS_ASSUME_NONNULL_END
