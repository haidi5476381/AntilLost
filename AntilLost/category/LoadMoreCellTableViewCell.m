//
//  LoadMoreCellTableViewCell.m
//  BluetoothTest
//
//  Created by Pro on 14-4-12.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import "LoadMoreCellTableViewCell.h"

@implementation LoadMoreCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor grayColor];
        _loadLabel  = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 30)];
        _loadLabel.backgroundColor = [UIColor clearColor];
        _loadLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_loadLabel];
        
        //刷新指示圈
        _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.frame = CGRectMake(70, 5, 30, 30);
        _activity.hidesWhenStopped = YES;
        [self addSubview:_activity];

    
    }
    return self;
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
