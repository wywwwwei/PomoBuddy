//
//  RecordsStatViewController.m
//  PomoBuddy
//
//  Created by 楚门 on 2024/4/17.
//

#import "RecordsStatViewController.h"
#import "HistoricalDataRecord.h" // 导入 Record 类的头文件
#import "PBHomePageController.h" // 导入设置页面控制器的头文件


@interface RecordsStatViewController ()

@property (nonatomic, strong) NSMutableArray<HistoricalDataRecord *> *records; // 用于存储随机生成的 Record 数据的数组

@end

@implementation RecordsStatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 生成随机的 Record 数据
    [self generateRandomRecords];
    // 初始化页面布局并展示生成的 Record 数据
    [self setupDataStatisticsView];
    
}


// 生成随机的 Record 数据
- (void)generateRandomRecords {
    self.records = [NSMutableArray array];
    // 生成 10 条随机记录
    for (int i = 0; i < 10; i++) {
        NSString *eventName = [NSString stringWithFormat:@"Event %d", i + 1];
        NSTimeInterval duration = arc4random_uniform(3600); // 时长随机在 0 到 3600 秒之间
        NSDate *startTime = [self randomDateBetweenDate:[NSDate dateWithTimeIntervalSinceNow:-86400 * 7] andDate:[NSDate date]]; // 随机开始时间,范围在最近1个月内
        // 随机生成结束时间，要大于开始时间，同时保证结束时间小于开始时间加上时长
        NSDate *endTime = [self randomDateBetweenDate:startTime andDate:[NSDate dateWithTimeInterval:duration sinceDate:startTime]];
        NSTimeInterval actualDuration = [endTime timeIntervalSinceDate:startTime]; // 实际持续时间为结束时间减去开始时间
        HistoricalDataRecord *record = [[HistoricalDataRecord alloc] initWithEventName:eventName
                                                                              duration:duration
                                                                             startTime:startTime
                                                                               endTime:endTime
                                                                        actualDuration:actualDuration];
        // NSLog(@"Record %d: Start Time: %@, Actual Duration: %.2f seconds", i + 1, startTime, actualDuration);
        [self.records addObject:record];
    }
}



- (void)setupDataStatisticsView {
    // 设置页面的背景样式
    self.view.backgroundColor =[UIColor colorWithRed:225/255.0 green:180/255.0 blue:135/255.0 alpha:0.9];
    
    // 添加第一个白底小方框作为第一块模块
    UIView *firstBox = [[UIView alloc] initWithFrame:CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, 200)];
    firstBox.backgroundColor = [UIColor whiteColor];
    firstBox.layer.cornerRadius = 10.0;
    firstBox.clipsToBounds = YES;
    [self.view addSubview:firstBox];
    
    // 创建 UIImageView 对象，并设置图片
    UIImage *image = [UIImage imageNamed:@"avatar"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

    // 设置 UIImageView 的位置，使其位于第一个方框的右下角
    CGFloat imageViewWidth = 100; // 图片宽度
    CGFloat imageViewHeight = 100; // 图片高度
    CGFloat margin = 10; // 图片距离右下角的边距
    imageView.frame = CGRectMake(CGRectGetWidth(firstBox.frame) - imageViewWidth - margin, CGRectGetHeight(firstBox.frame) - imageViewHeight - margin, imageViewWidth, imageViewHeight);

    // 将 UIImageView 添加到第一个方框中
    [firstBox addSubview:imageView];

    // 添加第二个白底小方框作为第二块模块
    UIView *secondBox = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(firstBox.frame) + 20, CGRectGetWidth(self.view.frame) - 40, 100)];
    secondBox.backgroundColor = [UIColor whiteColor];
    secondBox.layer.cornerRadius = 10.0;
    secondBox.clipsToBounds = YES;
    [self.view addSubview:secondBox];
    
    // 添加第三个白底小方框作为第三块模块
    UIView *thirdBox = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(secondBox.frame) + 20, CGRectGetWidth(self.view.frame) - 40, 380)];
    thirdBox.backgroundColor = [UIColor whiteColor];
    thirdBox.layer.cornerRadius = 10.0;
    thirdBox.clipsToBounds = YES;
    [self.view addSubview:thirdBox];
    
    // 在第一个方框中显示总时长和总天数
    [self displayTotalDurationAndTotalDaysInBox:firstBox];
        
    // 在第二个方框中显示今天的总时长
    [self displayTodayTotalDurationInBox:secondBox];
        
    // 在第三个方框中显示近7天的专注时长柱状图
    [self displayBarChartForLast7DaysInBox:thirdBox];
}


// 计算总专注时长和总专注天数
- (void)displayTotalDurationAndTotalDaysInBox:(UIView *)box {
    // 初始化总专注时长和总专注天数
    NSTimeInterval totalFocusTime = 0;
    NSMutableSet *uniqueDays = [NSMutableSet set];
    
    // 遍历所有记录
    for (HistoricalDataRecord *record in self.records) {
        // 累加总专注时长（小时）
        totalFocusTime += record.actualDuration / 3600.0;
        
        // 获取记录的开始时间的日期部分并加入集合
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:record.startTime];
        NSDate *day = [calendar dateFromComponents:components];
        [uniqueDays addObject:day];
    }
    
    // 计算总专注天数
    NSInteger totalFocusDays = [uniqueDays count];
    
    // 将总专注时长和总专注天数显示在页面上的对应位置
    UILabel *totalDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(box.frame) - 40, 30)];
    totalDurationLabel.text = @"Total Focus Duration:";
    totalDurationLabel.textColor = [UIColor blackColor];
    totalDurationLabel.font = [UIFont boldSystemFontOfSize:16.0]; // 深灰色加粗
    [box addSubview:totalDurationLabel];
        
    UILabel *totalDurationValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(totalDurationLabel.frame) + 5, CGRectGetWidth(box.frame) - 40, 30)];
    totalDurationValueLabel.text = [NSString stringWithFormat:@"%.2f hours", totalFocusTime];
    totalDurationValueLabel.textColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:0 alpha:1.0]; // #66CCCC
    totalDurationValueLabel.font = [UIFont boldSystemFontOfSize:30.0]; // 薄荷绿加粗
    [box addSubview:totalDurationValueLabel];
        
    UILabel *totalDaysLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(totalDurationValueLabel.frame) + 20, CGRectGetWidth(box.frame) - 40, 30)];
    totalDaysLabel.text = @"Total Focus Days:";
    totalDaysLabel.textColor = [UIColor blackColor];
    totalDaysLabel.font = [UIFont boldSystemFontOfSize:16.0]; // 深灰色加粗
    [box addSubview:totalDaysLabel];
        
    UILabel *totalDaysValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(totalDaysLabel.frame) + 5, CGRectGetWidth(box.frame) - 40, 30)];
    totalDaysValueLabel.text = [NSString stringWithFormat:@"%lu days", (unsigned long)totalFocusDays];
    totalDaysValueLabel.textColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:0 alpha:1.0]; // #66CCCC
    totalDaysValueLabel.font = [UIFont boldSystemFontOfSize:30.0]; // 薄荷绿加粗
    [box addSubview:totalDaysValueLabel];
}

// 计算今天的专注时长
- (void)displayTodayTotalDurationInBox:(UIView *)box {
    // 获取当前日期
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    NSDate *today = [calendar dateFromComponents:todayComponents];
    
    // 初始化今天的专注时长
    NSTimeInterval todayFocusTime = 0;
    
    // 遍历所有记录
    for (HistoricalDataRecord *record in self.records) {
        // 判断记录的开始时间是否为今天
        NSDateComponents *recordComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:record.startTime];
        NSDate *recordDay = [calendar dateFromComponents:recordComponents];
        if ([recordDay isEqualToDate:today]) {
            // 如果是今天的记录，则累加专注时长
            todayFocusTime += record.actualDuration /3600.0 ;
        }
    }
    
    // 创建显示今天总时长的 UILabel
    UILabel *todayTotalDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(box.frame) - 40, 30)];
    todayTotalDurationLabel.text = @"Today's Total Focus Duration:";
    todayTotalDurationLabel.textColor = [UIColor blackColor];
    todayTotalDurationLabel.font = [UIFont boldSystemFontOfSize:16.0]; // 深灰色加粗
    [box addSubview:todayTotalDurationLabel];
    
    UILabel *todayTotalDurationValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(todayTotalDurationLabel.frame) + 5, CGRectGetWidth(box.frame) - 40, 30)];
    todayTotalDurationValueLabel.text = [NSString stringWithFormat:@"%.2f hours", todayFocusTime];
    todayTotalDurationValueLabel.textColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:0 alpha:1.0]; // #66CCCC
    todayTotalDurationValueLabel.font = [UIFont boldSystemFontOfSize:30.0];
    [box addSubview:todayTotalDurationValueLabel];
    
}


- (void)displayBarChartForLast7DaysInBox:(UIView *)box {
    // 获取最近7天的日期
    NSMutableArray *last7Days = [NSMutableArray array];
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    for (int i = 0; i < 7; i++) {
        NSDate *day = [today dateByAddingTimeInterval:-i * 24 * 60 * 60];
        NSString *dayString = [dateFormatter stringFromDate:day];
        [last7Days addObject:dayString];
    }
    
    
    // 计算最近7天的专注时长
    NSMutableDictionary *durationForLast7Days = [NSMutableDictionary dictionary];
    for (NSString *dayString in last7Days) {
        durationForLast7Days[dayString] = @0;
    }
    for (HistoricalDataRecord *record in self.records) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:record.startTime];
        NSDate *day = [[NSCalendar currentCalendar] dateFromComponents:components];
        NSString *dayString = [dateFormatter stringFromDate:day];
        if ([last7Days containsObject:dayString]) {
            NSNumber *currentDuration = durationForLast7Days[dayString];
            durationForLast7Days[dayString] = @(currentDuration.doubleValue + record.actualDuration);
        }
    }
    // NSLog(@"durationForLast7Days: %@", durationForLast7Days);

    // 计算最大时长
    NSNumber *maxDuration = [durationForLast7Days.allValues valueForKeyPath:@"@max.self"]; // 获取最大时长
    CGFloat maxDurationValue = [maxDuration doubleValue] / 3600; // 将秒转换为小时

    // 创建柱状图
    CGFloat barWidth = (CGRectGetWidth(box.frame) - 80) / 7; // 计算每个柱子的宽度
    CGFloat maxHeight = CGRectGetHeight(box.frame) - 60; // 计算柱状图的最大高度
    NSUInteger index = 0; // 记录当前柱子的索引
    // 倒序遍历最近7天的日期
    for (NSInteger i = last7Days.count - 1; i >= 0; i--) {
        NSString *dayString = last7Days[i];
        NSNumber *duration = durationForLast7Days[dayString]; // 获取当天的专注时长
        CGFloat height = (duration.doubleValue / 3600) / maxDurationValue * (maxHeight - 50); //根据比例计算柱状图高度，以确保最高的柱子接近框框的最高点
        CGFloat x = 20 + index * (barWidth + 5); // 计算柱子的横坐标
        CGFloat y = maxHeight - height; // 将坐标原点放在底部，向上绘制柱状图
        CGRect barFrame = CGRectMake(x, y, barWidth, height); // 设置柱子的位置和大小
        UIView *barView = [[UIView alloc] initWithFrame:barFrame]; // 创建柱子
        barView.backgroundColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:0 alpha:1.0]; // 使用 #FFFFCC 颜色
        [box addSubview:barView]; // 将柱子添加到框框中
        
        // 添加日期标签
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(box.bounds) - 50, barWidth, 20)]; // 设置日期标签的位置和大小
        dateLabel.text = [dayString substringFromIndex:5]; // 只保留月-日，并设置日期标签的文本
        dateLabel.textColor = [UIColor blackColor]; // 设置日期标签的颜色为深灰色
        dateLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightBold]; // 设置日期标签的字体为加粗
        dateLabel.textAlignment = NSTextAlignmentCenter; // 设置日期标签的对齐方式为居中
        [box addSubview:dateLabel]; // 将日期标签添加到框框中
        
        // 添加时长标签
        UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y - 20, barWidth, 20)]; // 设置时长标签的位置和大小
        durationLabel.text = [NSString stringWithFormat:@"%.2f", duration.doubleValue / 3600]; // 将时长转换为小时，并设置时长标签的文本
        durationLabel.textColor = [UIColor colorWithRed:0.4 green:0.8 blue:0.8 alpha:1.0]; // 设置时长标签的颜色为 #66CCCC
        durationLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightBold]; // 设置时长标签的字体为加粗
        durationLabel.textAlignment = NSTextAlignmentCenter; // 设置时长标签的对齐方式为居中
        [box addSubview:durationLabel]; // 将时长标签添加到框框中
        
        index++; // 更新索引
    }

    // 在框框左上角放一个标签显示这个图的主题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, CGRectGetWidth(box.frame) - 20, 20)]; // 设置标题标签的位置和大小
    titleLabel.text = @"Focus Hours for the Past 7 Days"; // 设置标题标签的文本
    titleLabel.textColor = [UIColor blackColor]; //
    titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold]; //加粗
    titleLabel.textAlignment = NSTextAlignmentLeft; // 设置标题标签的对齐方式为左对齐
    [box addSubview:titleLabel]; // 将标题标签添加到框框中


}

// 随机生成介于两个日期之间的随机日期
- (NSDate *)randomDateBetweenDate:(NSDate *)startDate andDate:(NSDate *)endDate {
    NSTimeInterval timeInterval = [endDate timeIntervalSinceDate:startDate];
    NSTimeInterval randomInterval = arc4random_uniform(timeInterval);
    return [startDate dateByAddingTimeInterval:randomInterval];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end



