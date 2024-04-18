//
//  PBEventListCell.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/17.
//

#import <UIKit/UIKit.h>
#import "PBEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBEventListCell : UITableViewCell

@property (nonatomic, copy) void(^startBlock)(NSDictionary *indexDic);

@property (nonatomic, strong) PBEvent *event;

@end

NS_ASSUME_NONNULL_END
