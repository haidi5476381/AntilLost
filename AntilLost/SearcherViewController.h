//
//  SearcherViewController.h
//  AntilLost
//
//  Created by vpclub on 15/1/19.
//  Copyright (c) 2015年 vpclub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface SearcherViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,UIActionSheetDelegate>
{
    
}


@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (strong ,nonatomic) CBCharacteristic *writeCharacteristic;
@property (strong ,nonatomic) CBCharacteristic *writeCharacteristicBangDing;


@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *nServices;
@property (strong,nonatomic) NSMutableArray *nCharacteristics;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) NSTimer *timer_smart;
@property (nonatomic,retain) NSTimer *timer_send;


@property (nonatomic,retain)  NSString * currentRssi;
@property (nonatomic,strong) NSString *lastRssi;
@property (nonatomic,retain)  NSMutableArray *averArray;

@end
