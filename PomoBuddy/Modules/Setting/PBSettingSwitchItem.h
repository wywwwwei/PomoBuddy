//
//  PBSettingSwitchItem.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PBSettingSwitchType) {
    PBSettingSwitchTypeWhiteNoise,
    PBSettingSwitchTypeMusicFusion,
    PBSettingSwitchTypeDisableLockScreen,
};

@interface PBSettingSwitchItem : NSObject

@property (readonly) NSString *title;
@property (nonatomic, assign) BOOL isOn;

- (instancetype)initWithType:(PBSettingSwitchType)type;

@end

NS_ASSUME_NONNULL_END
