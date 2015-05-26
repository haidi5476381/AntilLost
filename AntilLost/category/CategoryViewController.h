//
//  CategoryViewController.h
//  BluetoothTest
//
//  Created by Pro on 14-4-6.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadMoreCellTableViewCell.h"
@protocol categeryNameDelegate <NSObject>

-(void)selectCategary:(NSString *)name;

@end


@interface CategoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) id<categeryNameDelegate>delegate;
@property (nonatomic,strong) NSMutableArray *arr;
@property (nonatomic,strong) UITableView *table;
@property (nonatomic,strong) LoadMoreCellTableViewCell *loadMoreCell;

//@property (nonatomic,strong) UIAlertView *add;
@end
