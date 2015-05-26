//
//  CBCenterViewController.h
//  BluetoothTest
//
//  Created by Pro on 14-4-6.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CategoryViewController.h"
//#import "EGORefreshTableHeaderView.h"

@interface CBCenterViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate,categeryNameDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property BOOL cbReady;
@property BOOL isRefreshing;
@property(nonatomic) float batteryValue;
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (strong ,nonatomic) CBCharacteristic *writeCharacteristic;

@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *nServices;
@property (strong,nonatomic) NSMutableArray *nCharacteristics;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UIButton *connect;
@property (nonatomic,strong) UITableView *deviceTable;
@property (nonatomic,strong) UIActivityIndicatorView *activity;
@property (nonatomic,retain) NSTimer *timer;
//@property (nonatomic,strong) EGORefreshTableHeaderView *refreshGo;




@end
