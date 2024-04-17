//
//  PBToast.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/18.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBToast : NSObject

+ (void)showToastTitle:(NSString *)title duration:(NSTimeInterval)duration;

@end


NS_ASSUME_NONNULL_END
