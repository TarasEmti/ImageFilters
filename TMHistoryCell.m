//
//  TMHistoryCellTableViewCell.m
//  SkillApp
//
//  Created by Тарас on 14.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import "TMHistoryCell.h"

@implementation TMHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageFiltered.frame = CGRectMake(self.center.x, self.center.y, self.frame.size.height - 10, self.frame.size.height - 10);
    self.imageFiltered.center = [self center];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
