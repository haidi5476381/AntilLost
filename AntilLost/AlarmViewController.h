//
//  AlarmViewController.h
//  BluetoothTest
//
//  Created by Pro on 14-4-8.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol alarmNameDelegate <NSObject>

-(void)selectAlarm:(NSString *)name to:(NSIndexPath *)index;

@end

@interface AlarmViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) id<alarmNameDelegate>delegate;
@property (nonatomic,strong) NSMutableArray *arr;
@property (nonatomic,strong) UITableView *table;
@property (strong,nonatomic) AVAudioPlayer *player;
@property (strong,nonatomic) NSIndexPath *index;

@property (assign,nonatomic)  NSInteger   type;

@end
