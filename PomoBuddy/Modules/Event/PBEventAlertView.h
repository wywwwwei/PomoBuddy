//
//  PBEventAlertView.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/18.
//

#import <UIKit/UIKit.h>
#import "PBEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBEventAlertView : UIView

@property (nonatomic, copy) void(^confirmBlock)(PBEvent *event);
@property (nonatomic, copy) void(^cancelBlock)(void);

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
