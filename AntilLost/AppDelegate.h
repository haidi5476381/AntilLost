//
//  AppDelegate.h
//  AntilLost
//
//  Created by vpclub on 15/1/19.
//  Copyright (c) 2015年 vpclub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) NSTimer *timer_smart;


@end

