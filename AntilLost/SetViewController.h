//
//  SetViewController.h
//  BluetoothTest
//
//  Created by Pro on 14-4-6.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface SetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,alarmNameDelegate,UITextFieldDelegate>

@property (nonatomic,strong) UITableView *table;
@property (nonatomic,strong) UISwitch *fangdiu;
@property (nonatomic,strong) UISwitch *zhendong;
@property (nonatomic,strong) UISwitch *linSheng;
@property (nonatomic,strong) UISwitch *bangding;

@property (nonatomic,strong) UITextField    * perName;
@property (nonatomic,strong) UITextField    * perState;


@property (nonatomic,strong) UISegmentedControl *sege;
@property (nonatomic,strong) UISlider           *slider;
@property (nonatomic,strong) NSDictionary       *dataDic;
@property (nonatomic,strong) UIButton   *stage_one;
@property (nonatomic,strong) UIButton   *stage_two;
@property (nonatomic,strong) UIButton   *stage_three;

@end
