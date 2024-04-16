//
//  PBSettingSwitchCell.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import "PBSettingSwitchCell.h"
#import <BlocksKit/UIControl+BlocksKit.h>

@interface PBSettingSwitchCell ()

@property (nonatomic, strong) UISwitch *switchView;

@end

@implementation PBSettingSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setItem:(PBSettingSwitchItem *)item {
    _item = item;
    self.textLabel.text = item.title;
    self.switchView.on = item.isOn;
    [self setNeedsLayout];
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    [self createSwitchView];
    self.accessoryView = self.switchView;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)createSwitchView {
    if (self.switchView) {
        return;
    }
    self.switchView = [[UISwitch alloc] init];
    WEAK_REF(self);
    [self.switchView bk_addEventHandler:^(UISwitch *sender) {
        STRONG_REF(self);
        self.item.isOn = sender.isOn;
    } forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.switchView];
}

@end
