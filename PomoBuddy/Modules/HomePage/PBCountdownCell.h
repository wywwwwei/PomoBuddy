//
//  PBCountdownCell.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import <UIKit/UIKit.h>
#import "PBCountdownModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBCountdownCell : UICollectionViewCell

@property (nonatomic, strong) PBCountdownModel *model;

// 外圈动画
- (void)startAnimation;
- (void)stopAnimation;

// 展示描述
- (void)showInformationView;
// 展示倒计时
- (void)showCountdownView;

// 更新当前时间
- (void)updateCurrentDuration:(NSInteger)duration;

@end

NS_ASSUME_NONNULL_END
