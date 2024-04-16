//
//  PBHomePageMenuView.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBHomePageMenuItem : NSObject

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) void(^handler)(void);

@end

@interface PBHomePageMenuView : UIView

@property (nonatomic, copy) void(^dismissBlock)(BOOL animated);

- (instancetype)initWithMenuItems:(NSArray<PBHomePageMenuItem *> *)menuItems;

@end

NS_ASSUME_NONNULL_END
