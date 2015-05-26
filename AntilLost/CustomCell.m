//
//  CustomCell.m
//  AntilLost
//
//  Created by 王会 on 15/4/16.
//  Copyright (c) 2015年 vpclub. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self)
    {
        self.swith = [[UISwitch alloc]initWithFrame:CGRectMake(220, 8, 60, 30)];
        [self.contentView addSubview:_swith];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
