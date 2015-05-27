//
//  SearcherViewController.m
//  AntilLost
//
//  Created by vpclub on 15/1/19.
//  Copyright (c) 2015年 vpclub. All rights reserved.
//

#import "SearcherViewController.h"
#import "Global.h"
#import "CBCenterViewController.h"
#import "SetViewController.h"
#import "SVProgressHUD.h"
#import "config.h"
#import "SetModel.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "SetModel.h"

#define COLORL @"ec1c8c"
#define kLocalNotificationID     9999
//#define IOS7_LAN if([Global getInstance].language = 1]) {self.edgesForExtendedLayout = UIRectEdgeNone;}

@interface SearcherViewController ()
{
    UITableView *_perTableView;
    UILabel *_dis_label;
    BOOL  _closeAlarm;

    BOOL  _flagToCon;
    UIActionSheet * _sheet;
    UIButton *cu;
    
    BOOL   _SmartConnect;
    
    BOOL  onceTiXing;
    
    
    BOOL  onceLianjie;
    NSArray *_arr;

    NSMutableArray *_advArr;
    
    CTCallCenter *callCenter;
    BOOL _isPhone;
    BOOL _isSearcher;
    
    BOOL isSender;
    NSOperationQueue *queue;
}

@end

@implementation SearcherViewController


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: YES];
    [SVProgressHUD dismiss];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    
    
    if ([Global getInstance].isChange)
    {
        
        if (_perTableView != nil)
        {
            if ([Global getInstance].jiebang == YES)
            {
                //发送解绑的信号
                long long data = 0x7f7f7f7f7f7f7f;
                NSData *mes = [NSData dataWithBytes:&data length:7];
                NSLog(@"%@",mes);
                [_peripheral writeValue:mes forCharacteristic:_writeCharacteristicBangDing type:CBCharacteristicWriteWithResponse];
                [_peripheral writeValue:mes forCharacteristic:_writeCharacteristicBangDing type:CBCharacteristicWriteWithResponse];
                [_peripheral writeValue:mes forCharacteristic:_writeCharacteristicBangDing type:CBCharacteristicWriteWithResponse];

                
                
                [Global getInstance].isConnect = NO;
                [self performSelector:@selector(duankailianjie) withObject:self afterDelay:1];
                
            }
            
            if ([Global getInstance].isConnect == NO  && [Global getInstance].jiebang == NO)
            {
                [self duankailianjie];
            }
        }
    }
    
    
}

- (void)duankailianjie
{
    if ([Global getInstance].isConnect == NO )
    {
        [_manager cancelPeripheralConnection:_peripheral] ;
    }
    
    [_perTableView reloadData];
    [Global getInstance].isChange = NO;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"手环";
    self.navigationController.navigationBar.tintColor = hexStringToColor(COLORL);
    // Do any additional setup after   the view.
    
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
   
    
    _arr = [NSMutableArray arrayWithObjects:@"电子警报音效",@"防盗器音效",@"雷达咚咚音效",@"信号灯音效", nil];

    
    
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (systemVersion >= 7.0)
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//    _cbReady = false;
    _nDevices = [[NSMutableArray alloc]init];
    _nServices = [[NSMutableArray alloc]init];
    _nCharacteristics = [[NSMutableArray alloc]init];
    _averArray = [[NSMutableArray alloc]initWithCapacity:5];

    //rightBar
    cu = [UIButton buttonWithType:UIButtonTypeCustom];
    cu.tag = 308;
    [cu setTitle:@"打开音效" forState:UIControlStateNormal];
    cu.titleLabel.font = [UIFont systemFontOfSize:15];
    [cu setTitleColor:hexStringToColor(COLORL) forState:UIControlStateNormal];
    [cu setTitle:@"关闭音效" forState:UIControlStateSelected];
    [cu setTitleColor:hexStringToColor(COLORL) forState:UIControlStateSelected];
    [cu addTarget:self action:@selector(closeAlarm:) forControlEvents:UIControlEventTouchUpInside];
    cu.selected = NO;
    cu.frame = CGRectMake(0, 0, 100, 44);
    UIBarButtonItem *rigthBtn = [[UIBarButtonItem alloc] initWithCustomView:cu];
    self.navigationItem.rightBarButtonItem = rigthBtn;

    
    
    //创建tableView
    _perTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 108) style:UITableViewStyleGrouped];
//    _homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _perTableView.dataSource = self;
    _perTableView.delegate = self;
    
    [self.view addSubview:_perTableView];
    
    
    
    //提示
    UILabel *vi = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3, [UIScreen mainScreen].bounds.size.height -160, [UIScreen mainScreen].bounds.size.width/3, 40)];
    vi.textColor = hexStringToColor(COLORL);
    vi.backgroundColor = [UIColor whiteColor];
    vi.textAlignment = NSTextAlignmentCenter;
    vi.layer.masksToBounds = YES;
    vi.layer.cornerRadius = 20.f;
    vi.hidden = YES;
    vi.tag = 7001;
    [self.view addSubview:vi];
    
    
    UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height -108, 320, 44)];
    bottomLabel.text = @"搜索设备";
    bottomLabel.tag = 309;
    bottomLabel.userInteractionEnabled = YES;
    bottomLabel.textColor = hexStringToColor(COLORL);
    bottomLabel.backgroundColor = [UIColor whiteColor];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.font =[UIFont systemFontOfSize:14];
    [self.view addSubview:bottomLabel];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startSearch)];
    [bottomLabel addGestureRecognizer:tap];
//    [self startSearch];
    
    
    

    callCenter = [[CTCallCenter alloc] init];
    callCenter.callEventHandler = ^(CTCall* call)
    {
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            _isPhone = NO;

            NSLog(@"Call has been disconnected");
        }
        else if ([call.callState isEqualToString:CTCallStateConnected])
        {
            NSLog(@"Call has just been connected");
        }
        else if([call.callState isEqualToString:CTCallStateIncoming])
        {
            NSLog(@"Call is incoming");
            //关闭所有的声音
    
            _isPhone = YES;
            
        }
        else if ([call.callState isEqualToString:CTCallStateDialing])
        {

            NSLog(@"call is dialing");
        }
        else
        {  
            NSLog(@"Nothing is done");
           _isPhone = NO;

        }
    };  

}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 3;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    v.backgroundColor = [UIColor whiteColor];
    v.tag = 212121 + section;
    

    
    
    UILabel * l = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 320, 44)];
    l.textColor = hexStringToColor(@"ec1c8c");
    l.font = [UIFont systemFontOfSize:14];
    l.tag = 305 +section;

    [v addSubview:l];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 5, 25)];
    line.backgroundColor = hexStringToColor(@"ec1c8c");
    [v addSubview:line];
    
    if (section ==1)
    {
        if (_dis_label == nil)
        {
            _dis_label = [[UILabel alloc]initWithFrame:CGRectMake(200, 0,100 , 44)];
            _dis_label.backgroundColor = [UIColor clearColor];
            _dis_label.font = [UIFont systemFontOfSize:14];
            _dis_label.textColor = [UIColor redColor];
//            _dis_label.text = @"距离";

           
        }
//         [l addSubview:_dis_label];
        
    }
    
    switch (section)
    {
        case 0:
            l.text = @"语言选择";
            break;
        case 1:
            l.text = @"已连接的设备";
            break;
        case 2:
            l.text = @"可用设备";
            break;
   
        default:
            break;
    }
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
// Default is 1 if not implemented


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger  numSection =0;
    switch (section)
    {
        case 0:
            numSection = 1;
            break;
        case 1:
            if ([Global getInstance].peripheralList.count>0)
            {
                for (NSMutableDictionary *sub in [Global getInstance].peripheralList)
                {
                    CBPeripheral *p = [sub objectForKey:@"device"];
                    if (p.state == CBPeripheralStateConnected)
                    {
                        numSection =1;
                    }
                    
                }
            }
            
            break;
        case 2:

            if ([Global getInstance].peripheralList.count>0)
            {
                for (NSMutableDictionary *sub in [Global getInstance].peripheralList)
                {
                    CBPeripheral *p = [sub objectForKey:@"device"];
                    if (p.state == CBPeripheralStateDisconnected)
                    {
                        numSection ++;
                    }
                    
                }
            }

            break;

            
        default:
            break;
    }
    return numSection;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    
    
    NSMutableArray *list = [Global getInstance].peripheralList;
    
    if (list.count > 0)
    {
        
        if (indexPath.section == 0)
        {
            cell.textLabel.text = @"语言选择";
            cell.textLabel.tag = 310;
//            [cell.imageView setImage:[UIImage imageNamed:@"icon.png"]];

        }
        else if (indexPath.section == 1)
        {
            
            if (indexPath.row ==0)
            {
                if (self.peripheral.state == CBPeripheralStateConnected)
                {
                    cell.textLabel.text = _peripheral.name;
                }
                
                
                for (NSMutableDictionary * dic  in list)
                {
                    CBPeripheral *p = [dic objectForKey:@"device"];
                    if (_peripheral.identifier == p.identifier)
                    {
                         SetModel * model = [dic objectForKey:@"model"];
                        if (model!= nil &&model.name.length >0)
                        {
                            cell.textLabel.text = model.name;
                            
                            
                            //选择图
                            if (model.style ==0)
                            {
                                 [cell.imageView setImage:[UIImage imageNamed:@"we_pay.png"]];
                            }
                            else if (model.style == 1)
                            {
                                
                                [cell.imageView setImage:[UIImage imageNamed:@"comm_detail_favourite.png"]];

                            }
                            
                            else
                            {
                                [cell.imageView setImage:[UIImage imageNamed:@"icon.png"]];

                            }

                        }
                        else
                        {
                            cell.textLabel.text = _peripheral.name;
                            [cell.imageView setImage:[UIImage imageNamed:@"icon.png"]];

                        }
                       
                    }
                    else
                    {
                        [cell.imageView setImage:[UIImage imageNamed:@"icon.png"]];

                    }
                }
                

            }

        }
        
        //section    2
        else
        {
            if (indexPath.row <[Global getInstance].peripheralList.count )
            {
                
//                NSDictionary *dic = [[Global getInstance].peripheralList objectAtIndex:indexPath.row];
                
                NSMutableArray * arr = [[NSMutableArray alloc]init];
                for (NSMutableDictionary * dic  in list)
                {
                    CBPeripheral *p = [dic objectForKey:@"device"];
                    if (p.state == CBPeripheralStateDisconnected)
                    {
                        
                        [arr addObject:dic];

                        
                    }

                    
                }

                NSDictionary *k = [arr objectAtIndex:indexPath.row];
                SetModel * model = [k objectForKey:@"model"];
                if (model!= nil&&model.name.length >0)
                {
                    cell.textLabel.text = model.name;
                    
                }
                else
                {
                    cell.textLabel.text = ((CBPeripheral*)[k objectForKey:@"device"]).name;

                }
                
                
                //绑定后得
                
//                NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"bangding"];
//                NSString *per =  [[NSUserDefaults standardUserDefaults] objectForKey:@"bangdingName"];
//                
//                if (identifier.length >0)
//                {
//                    cell.textLabel.text = per;
//                }
//                else
//                {
//                    [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"bangding"];
//                    //        [[NSUserDefaults standardUserDefaults] setObject:peripheral.name forKey:@"bangdingName"];
//                    
//                    [[NSUserDefaults standardUserDefaults] setObject:peripheral forKey:@"shebei"];
//
//                }

            }
            

        }
    }
    
    else
    {
        switch (indexPath.section)
        {
            case 0:
                cell.textLabel.text = @"语言选择";
                cell.textLabel.tag = 310;
//                [cell.imageView setImage:[UIImage imageNamed:@"icon.png"]];
                break;
        }
    }
    cell.textLabel.textColor = [UIColor grayColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (_sheet == nil)
        {
            _sheet = [[UIActionSheet alloc]initWithTitle:@"语言切换" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"English", @"简体中文",nil];
        }
        [_sheet showInView:self.view];

    }
    else if (indexPath.section == 1)
    {
        SetViewController*seaVC = [[SetViewController alloc]init];
        
        if (indexPath.row <[Global getInstance].peripheralList.count )
        {
            NSDictionary *dic = [[Global getInstance].peripheralList objectAtIndex:indexPath.row];
            seaVC.dataDic = dic;
        }
        [self.navigationController pushViewController:seaVC animated:YES];

    }
    else
    {
        //参数传送过
        if (indexPath.row <[Global getInstance].peripheralList.count )
        {
            NSDictionary *dic = [[Global getInstance].peripheralList objectAtIndex:indexPath.row];
            
            CBPeripheral *p = [dic objectForKey:@"device"];
            _peripheral= p;
            _nServices = [[dic objectForKey:@"adv"] objectForKey:@"rAdvDataServiceUUIDs"];
//            if (p.state == CBPeripheralStateDisconnected)
//            {
//                cell.textLabel.text = p.name;
//                [cell.imageView setImage:[UIImage imageNamed:@"icon.png"]];
//                
//            }
            
        }
//        NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"bangding"];
//        NSString *per =  [[NSUserDefaults standardUserDefaults] objectForKey:@"bangdingName"];
//
//        if (identifier.length > 0)
//        {
////            _peripheral = per;
//        }
        
        UIAlertView *alert;
        if ([Global getInstance].language == 1)
        {
            alert =  [[UIAlertView alloc]initWithTitle:@"Connections to this device" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Determine", nil];

        }
        else
        {
            alert =  [[UIAlertView alloc]initWithTitle:@"连接此设备" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];

        }
        alert.tag = 7001;
        [alert show];
    }
    
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==2)
    {
        return  UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
      if (editingStyle == UITableViewCellEditingStyleDelete)
      {
          
          NSMutableArray *list = [Global getInstance].peripheralList;
          
          NSMutableArray * arr = [[NSMutableArray alloc]init];
          for (NSMutableDictionary * dic  in list)
          {
              CBPeripheral *p = [dic objectForKey:@"device"];
              if (p.state == CBPeripheralStateDisconnected)
              {
                  
                  [arr addObject:dic];
                  
                  
              }
              
              
          }
          
          NSDictionary * dic = [arr objectAtIndex:indexPath.row];
          [list removeObject:dic];
          _peripheral=nil;
          
          [_perTableView reloadData];

      }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger index =  [Global getInstance].language;

    if (buttonIndex == 0)
    {
//        if (index ==1 )
//        {
        [Global getInstance].language = 1;
        UILabel * v0 = (UILabel *)[self.view viewWithTag:305 ];
        v0.text = @"Language Selection";
        UILabel * v1 = (UILabel *)[self.view viewWithTag:306 ];
        v1.text = @"Connected device";
        UILabel * v2 = (UILabel *)[self.view viewWithTag:307 ];
        v2.text = @"Available devices";
        UILabel * vcell = (UILabel *)[self.view viewWithTag:310 ];
        vcell.text = @"Language Selection";

        self.title = @"Anti-lost";
        
        UILabel * b = (UILabel *)[self.view viewWithTag:309];
        b.text = @"Search Equipment";
        [cu setTitle:@"Open Sound" forState:UIControlStateNormal];
        [cu setTitle:@"Close Sound" forState:UIControlStateSelected];

//        }
        
    }
    else if (buttonIndex == 1)
    {
        
//        if (index == 0)
//        {
        [Global getInstance].language = 0;
        UILabel * v0 = (UILabel *)[self.view viewWithTag:305 ];
        v0.text = @"语言选择";
        UILabel * v1 = (UILabel *)[self.view viewWithTag:306 ];
        v1.text = @"已连接设备";
        UILabel * v2 = (UILabel *)[self.view viewWithTag:307 ];
        v2.text = @"可用的设备";
        
        UILabel * vcell = (UILabel *)[self.view viewWithTag:310 ];
        vcell.text = @"语言选择";

        UILabel *b = (UILabel *)[self.view viewWithTag:309 ];
        b.text = @"搜索设备";
        [cu setTitle:@"打开音效" forState:UIControlStateNormal];
        [cu setTitle:@"关闭音效" forState:UIControlStateSelected];
        self.title = @"手环";



//        }

    }

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==7001)
    {
        if (buttonIndex == 1)
        {
            if (_peripheral != nil)
            {
             
                if (_nServices.count > 0)
                {
                    NSLog(@"%@",_peripheral.services);
                    _flagToCon = YES;
                    
                    
//                    [SVProgressHUD showWithStatus:@"正在连接..." maskType:SVProgressHUDMaskTypeNone];
//                    [_manager scanForPeripheralsWithServices:@[uuid]  options:@{CBCentralManagerScanOptionSolicitedServiceUUIDsKey: @[[CBUUID UUIDWithString:@"1803"]] }];

                    [_manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"1802"]]  options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
                    if (_manager.state == CBCentralManagerStatePoweredOff)
                    {
                        AlertWithMessage(@"打开蓝牙设置");
                    }
                    double delayInSeconds = 30.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self.manager stopScan];
                        [SVProgressHUD dismiss];
                        //                    [_perTableView reloadData];
                        //        [_activity stopAnimating];
                        //        [self updateLog:@"扫描超时,停止扫描"];
                    });

                }
                else
                {
                    [self.manager connectPeripheral:_peripheral options:nil];

                }
                
            }
            else
            {
                
//                if ([Global getInstance].peripheralList.count > 0)
//                {
//                    <#statements#>
//                }
                AlertWithMessage(@"请重新搜索外设设备");
            }
        }
    }
    
    
    if (alertView.tag == 7002)
    {
        if (buttonIndex == 1)
        {
            _SmartConnect = YES;
            //自动连接
            [self smartConnect];
            //        self.timer_smart = [NSTimer scheduledTimerWithTimeInterval:1.0
            //                                                            target:self
            //                                                          selector:@selector(smartConnect)
            //                                                          userInfo:nil
            //                                                           repeats:1.0];
            //        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];

        }
        else
        {
            NSString *name = [NSString stringWithFormat:@"%@已断开连接",_peripheral.name];
            AlertWithMessage(name);
            return;
        }

    }
}




#pragma mark -
#pragma mark   -bluetooth
//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
//    switch (central.state) {
//        case CBCentralManagerStatePoweredOn:
//            [self updateLog:@"蓝牙已打开,请扫描外设"];
//            break;
//        default:
//            break;
//    }
    
    
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        //        [self.centralManger scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"f3d9"]]
        //                                                   options:nil];
    }
    else
    {
        
    }
}



- (void)startSearch
{
    
    //    [self updateLog:@"正在扫描外设..."];
    //[_activity startAnimating];
    NSString *word ;
    if ([Global getInstance].language ==1)
    {
        word = @"Scanning peripherals...";
    }
    else
    {
        word = @"正在扫描外设...";
    }
    [SVProgressHUD showWithStatus:word maskType:SVProgressHUDMaskTypeNone];
    _isSearcher = YES;
    [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    double delayInSeconds = 30.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.manager stopScan];
        [SVProgressHUD dismiss];
//        AlertWithMessage(@"没有搜索到外设");
        //        [_activity stopAnimating];
        //        [self updateLog:@"扫描超时,停止扫描"];
    });
    
    
//    CBCenterViewController *cbVC = [[CBCenterViewController alloc]init];
//    [self.navigationController pushViewController:cbVC animated:YES];
}


//查到外设后，停止扫描，连接设备  扫描成功  发现设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [SVProgressHUD dismiss];
    
    _advArr = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    
    
    onceLianjie = NO;
    
    [Global getInstance].isConnect = YES;
//    [self updateLog:[NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.UUID, advertisementData]];
    [self.manager stopScan];
    
    if (_peripheral.identifier == peripheral.identifier)
    {
        if (_isSearcher)
        {
            _isSearcher = NO;
            return;
        }
        else
        {
            [self.manager connectPeripheral:_peripheral options:nil];
            return;

        }
        
    }
    _peripheral = peripheral;
    NSLog(@"%@",_peripheral);

    //[_activity stopAnimating];
    BOOL replace = NO;
    // Match if we have this device from before
    for (int i=0; i < [Global getInstance].peripheralList .count; i++)
    {
        CBPeripheral *p = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"device"];
        SetModel *model = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"model"];
        if ([p.identifier isEqual:peripheral.identifier])
        {
//            [_nDevices replaceObjectAtIndex:i withObject:peripheral];
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:peripheral,@"device",advertisementData,@"adv",RSSI,@"rssi",model,@"model", nil];
            [[Global getInstance].peripheralList replaceObjectAtIndex:i withObject:dic];
            replace = YES;
            [_perTableView reloadData];

        }
    }
    if (!replace)
    {
//        [_nDevices addObject:peripheral];
        
        //
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:peripheral,@"device",advertisementData,@"adv",RSSI,@"rssi", nil];
        [[Global getInstance].peripheralList addObject:dic];
        
        [_perTableView reloadData];
        
    }
    
    
}


//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    [self updateLog:[NSString stringWithFormat:@"成功连接 peripheral: %@ with UUID: %@",peripheral,peripheral.UUID]];
    
    //连接成功   才解除自动连接
    if (_SmartConnect == YES)
    {
        _SmartConnect = NO;
        [self.timer_smart invalidate];
        
    }
    if ([Global getInstance].isConnect == NO)
    {
        [Global getInstance].isConnect = YES;
    }

    
    
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"bangding"];
    
    NSString *uuid = [NSString stringWithFormat:@"%@",peripheral.identifier];
    if ([identifier isEqualToString:uuid])
    {
       
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"bangding"];
        [[NSUserDefaults standardUserDefaults] setObject:peripheral.name forKey:@"bangdingName"];
        
//        [[NSUserDefaults standardUserDefaults] setObject:peripheral forKey:@"shebei"];
//        [[NSUserDefaults standardUserDefaults] setObject:[Global getInstance].peripheralList forKey:@"bangding"];
 
        
 
    }
    
    
    
    
    
    [_perTableView  reloadData];
    self.peripheral.delegate = self;
//    [self toAlarm];

    
    [self.peripheral discoverServices:nil];
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(toReadRSSI)
                                                userInfo:nil
                                                 repeats:1.0];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];

//    [self updateLog:@"扫描服务"];
    
}


//循环读取RSSI
- (void)toReadRSSI
{
    if (_peripheral != nil)
    {
        if (_peripheral.state == CBPeripheralStateConnected)
        {
//            self.currentRssi = [NSString stringWithFormat:@"%@",_peripheral.RSSI];
//            [self toAlarm];
            
            _peripheral.delegate = self;
            [_peripheral readRSSI];

        }
        else
        {
            
            
            for (int i=0; i < [Global getInstance].peripheralList .count; i++)
            {
                CBPeripheral *p = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"device"];
                NSDictionary *advertisementData = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"adv"];
                NSDictionary *services = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"services"];
                SetModel *model = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"model"];
                NSNumber *rssi = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"rssi"];
                if ([p.identifier isEqual:_peripheral.identifier])
                {
                    //            [_nDevices replaceObjectAtIndex:i withObject:peripheral];
                    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_peripheral,@"device",advertisementData,@"adv",services,@"services",model,@"model",rssi,@"rssi", nil];
                    [[Global getInstance].peripheralList replaceObjectAtIndex:i withObject:dic];
                }
            }

            if ([Global getInstance].language ==1)
            {
//                AlertWithMessage(@"Disconnected");

            }
            else
            {
                [Global getInstance].isDuanKai = YES;
                //  ben  di  tongzhi
                
                if ([Global getInstance].isBackgroud)
                {
                    [self playMusic];
//                    //设置20秒之后
//                    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1.f];
//                    
//                    // 初始化本地通知对象
//                    UILocalNotification *noti = [[UILocalNotification alloc] init] ;
//                    if (noti)
//                    {
//                        //设置推送时间
//                        noti.fireDate = date;
//                        //设置时区
//                        noti.timeZone = [NSTimeZone defaultTimeZone];
//                        //设置重复间隔
//                        noti.repeatInterval = kCFCalendarUnitDay;
//                        //推送声音
//                        noti.soundName = UILocalNotificationDefaultSoundName;
//                        //内容
//                        
//                        if ([Global  getInstance].language == 1)
//                        {
//                            noti.alertBody = @"You have been disconnected";
//                        }
//                        else
//                        {
//                            noti.alertBody = @"您已断开连接";
//                        }
//
//                        //显示在icon上的红色圈中的数子
//                        noti.applicationIconBadgeNumber = 1;
//                        //设置userinfo 方便在之后需要撤销的时候使用
//                        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];
//                        noti.userInfo = infoDic;
//                        //添加推送到uiapplication        
//                        UIApplication *app = [UIApplication sharedApplication];
//                        [app scheduleLocalNotification:noti];
////                         [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
////                        return;
//                    }

                }
                
                
                if (!onceLianjie)
                {
                    onceLianjie = YES;
                    
                }
                
                
                //自动连接
                
//                UIAlertView *alert;
//                if ([Global getInstance].language == 1)
//                {
//                    alert =  [[UIAlertView alloc]initWithTitle:@"Whether near the device and connection" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Determine", nil];
//                    
//                }
//                else
//                {
//                    alert =  [[UIAlertView alloc]initWithTitle:@"是否靠近此设备并连接" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                    
//                }
//                alert.tag = 7002;
//                [alert show];

                


//                AlertWithMessage(@"已断开连接");

            }
            [self.timer invalidate];
            _dis_label.text = @"";
            [_perTableView reloadData];
        }
        
    }
}

//- (void)senderMessege
//{
//    uint8_t data = 0x02;
//
//    [_peripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
//
//}




//报警
- (void)toAlarm
{
//    _dis_label.text = [NSString stringWithFormat:@"距离:%@m",self.currentRssi];
//    //发送报警字节
//    uint8_t data = 0x02;
//    [_peripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
    
    
    NSInteger va;
    if ([Global getInstance].sliderValue >1)
    {
        va =[Global getInstance].sliderValue;
    }
    else
    {
        va = 8;
    }
    

    if (self.currentRssi.intValue > va  && !_closeAlarm)
//        if (1)

    {
        
        //后台运行
        if ([Global getInstance].isBackgroud)
        {
//            [self toRing];
            [self playMusic];
            
//            //设置20秒之后
//            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1.f];
//            
//            // 初始化本地通知对象
//            UILocalNotification *noti = [[UILocalNotification alloc] init] ;
//            if (noti)
//            {
//                //设置推送时间
//                noti.fireDate = date;
//                //设置时区
//                noti.timeZone = [NSTimeZone defaultTimeZone];
//                //设置重复间隔
//                noti.repeatInterval = kCFCalendarUnitDay;
//                //推送声音
//                noti.soundName = UILocalNotificationDefaultSoundName;
//                //内容
//                if ([Global  getInstance].language == 1)
//                {
//                    
//                    noti.alertBody = [NSString stringWithFormat:@"You have exceeded%lu m",va];
//                    
//                }
//                else
//                {
//                    
//                    noti.alertBody = [NSString stringWithFormat:@"您已超过%lum",va];
//
//                }
//                //显示在icon上的红色圈中的数子
//                noti.applicationIconBadgeNumber = 1;
//                //设置userinfo 方便在之后需要撤销的时候使用
//                NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];
//                noti.userInfo = infoDic;
//                //添加推送到uiapplication
//                UIApplication *app = [UIApplication sharedApplication];
//                if (!onceTiXing )
//                {
//                    [app scheduleLocalNotification:noti];
//                    onceTiXing = YES;
//                }
//                //                         [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
//                //                        return;
//            }
            
        }
        

        
        
        if (_writeCharacteristic != nil)
        {
            uint8_t data = 0x02;
            NSData *mes = [NSData dataWithBytes:&data length:1];
            NSLog(@"%@",mes);
            [_peripheral writeValue:mes forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }

        
        for (NSMutableDictionary *dic  in [Global getInstance].peripheralList)
        {
            CBPeripheral * p = [dic objectForKey:@"device"];
            if (_peripheral.identifier == p.identifier)
            {
                SetModel * model = [dic objectForKey:@"model"];
                if (model!= nil)
                {
                    if (model.isRing == NO)
                    {

                    }
                    else
                    {
                        [self toRing];
                    }
                    
                    if (model.isShake == NO)
                    {
                        
                    }
                    else
                    {
                        [self toShark];
                    }
                    
                    
                }
                else
                {
                    [self toRing];
                    [self toShark];

                }
                

            }
        }
        



    }
    else
    {
        onceTiXing = NO;
        
        if (self.timer_send != nil)
        {
            [self.timer_send invalidate];
        }
        if (_writeCharacteristic != nil)
        {
            uint8_t data = 0x00;
             [_peripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }

    }

}




- (void)toShark
{
    
    if (_isPhone)
    {
        
    }
    else
    {
        //震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
 
    }

}



//
- (void)toRing
{
    
    if (_isPhone)
    {
        
    }
    else
    {
        SystemSoundID soundId;
        NSString *path;
        if (_SmartConnect)
        {
            NSString * name = [_arr objectAtIndex:[Global getInstance].duankailingsheng];
            
            path = [[NSBundle mainBundle]pathForResource:name ofType:@"mp3"];
        }
        else
        {
            NSString * name = [_arr objectAtIndex:[Global getInstance].chaojulishneg];
            path = [[NSBundle mainBundle]pathForResource:name ofType:@"mp3"];
        }
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
        AudioServicesPlaySystemSound(soundId);

    }

}

- (void)closeAlarm:(id)sender
{
    UIButton *s = (UIButton *)sender;
    if (s.selected == NO)
    {
        s.selected = YES;
        _closeAlarm = YES;
    }
    else
    {
        s.selected = NO;
        _closeAlarm = NO;
    }
    ;
}


//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
//    _peripheral = peripheral;
    [_perTableView reloadData];
    _SmartConnect = YES;
    
    //
//    [Global getInstance].manager = _manager;
//    [Global getInstance].peripheral = peripheral;

    //自动连接
    if ([Global getInstance].isConnect == NO)
    {
        
    }
    else
    {
        self.timer_smart = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(smartConnect)
                                                          userInfo:nil
                                                           repeats:1.0];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];

    }

    
//    NSString *name = [NSString stringWithFormat:@"%@已断开连接",peripheral.name];
//    AlertWithMessage(name);
    NSLog(@">>>>>>>%@",peripheral.identifier);
}

- (void)smartConnect
{
    if (_SmartConnect == YES)
    {
        
        
        //后台运行
        if ([Global getInstance].isBackgroud)
        {
//            [self toRing];
            [self playMusic];
            
        }
        
        
        if (_writeCharacteristic != nil)
        {
            uint8_t data = 0x02;
            NSData *mes = [NSData dataWithBytes:&data length:1];
            NSLog(@"%@",mes);
            [_peripheral writeValue:mes forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
            
        }
        
//        
//        [self toRing];
//        [self toShark];


        
        if ([Global getInstance].peripheralList.count > 0)
        {
            for (NSMutableDictionary *dic  in [Global getInstance].peripheralList)
            {
                
                CBPeripheral * p = [dic objectForKey:@"device"];
                if (_peripheral.identifier == p.identifier)
                {
                    SetModel * model = [dic objectForKey:@"model"];
                    if (model!= nil)
                    {
                        if (model.isRing == NO)
                        {
                            
                        }
                        else
                        {
                            [self toRing];
                        }
                        
                        if (model.isShake == NO)
                        {
                            
                        }
                        else
                        {
                            [self toShark];
                        }
                        
                        
                    }
                    else
                    {
                        [self toRing];
                        [self toShark];
                        
                    }
                    
                    
                }
            }

        }
        else
        {
            [self toRing];
            [self toShark];

        }
        
        
        
        if ([Global getInstance].isBackgroud)
        {
            if (_advArr.count>0)
            {
                NSString *uuid = [_advArr objectAtIndex:0];
                [_manager scanForPeripheralsWithServices:@[uuid]  options:@{CBCentralManagerScanOptionSolicitedServiceUUIDsKey: @[[CBUUID UUIDWithString:@"1803"]] }];

            }

        }
        else
        {
            [_manager scanForPeripheralsWithServices:_peripheral.services  options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];

        }

//        [[Global getInstance].manager scanForPeripheralsWithServices:[Global getInstance].peripheral.services options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];

        
    }
}


//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",error);
}

-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    //NSLog(@"%s,%@",__PRETTY_FUNCTION__,peripheral);
    int rssi = abs([peripheral.RSSI intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",_peripheral,pow(10,ci)];
    
    
    
    //加一个平滑的滤波
    if (_averArray.count ==5)
    {
        
        float total = 0;
        for (NSString *value in _averArray)
        {
            total += value.floatValue;
        }
        
        self.currentRssi = [NSString stringWithFormat:@"%.1f",pow(10,ci)*3/5 +total*2/25];
        _dis_label.text = [NSString stringWithFormat:@"距离:%@m",self.currentRssi];
        [self toAlarm];
        [_averArray removeObjectAtIndex:0];
        [_averArray addObject:length];
        
        
    }
    else
    {
        [_averArray addObject:length];
        self.currentRssi = [NSString stringWithFormat:@"%.1f",pow(10,ci)];
        _dis_label.text = [NSString stringWithFormat:@"距离:%@m",self.currentRssi];
        [self toAlarm];

    }
    
    
    NSLog(@"距离：%@",length);
}


//每次都进的方法  读取rssi
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    
//    
    int rssi = abs([RSSI intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",_peripheral,pow(10,ci)];
    
    
    //第一算法
    
    //加一个平滑的滤波
    if (_averArray.count ==5)
    {
        
        float total = 0;
        for (NSString *value in _averArray)
        {
            total += value.floatValue;
        }
        
        float dst = pow(10,ci)/3 +total*2/15;
        
        self.currentRssi = [NSString stringWithFormat:@"%.1f",dst];
        _dis_label.text = [NSString stringWithFormat:@"距离:%@m",self.currentRssi];
        [self toAlarm];
        [_averArray removeObjectAtIndex:0];
        NSString *k = [NSString stringWithFormat:@"%.1f",pow(10,ci)];
        [_averArray addObject:k];
        
        
    }
    else
    {
        NSString *k = [NSString stringWithFormat:@"%.1f",pow(10,ci)];
        [_averArray addObject:k];
        self.currentRssi = [NSString stringWithFormat:@"%.1f",pow(10,ci)];
        _dis_label.text = [NSString stringWithFormat:@"距离:%@m",self.currentRssi];
        [self toAlarm];
        
    }
    
    
    NSLog(@"距离：%@",length);

    
    
    //第二种算法
    
    
    
//    //加一个平滑的滤波
//    if (_averArray.count ==5)
//    {
//        
//        float total = 0;
//        for (NSString *value in _averArray)
//        {
//            total += value.floatValue;
//        }
//        
//        float temp = pow(10, ci);
////        //判断
////        if (pow(10, ci) -total/10 >2)
////        {
////            temp = total/5 +1.5;
////        }
////        else
////        {
////            temp = pow(10, ci);
////        }
////        
////        
////        if (pow(10, ci) -total/5 < -2)
////        {
////            temp = total/5 -1.5;
////        }
////        else
////        {
////            temp = pow(10, ci);
////        }
//
//        
//        
//        float dst ;//= pow(10,ci)*2/3 +total/15;
//        
//        //平滑一种
//        NSString *a = [_averArray objectAtIndex:7];
//        NSString *b = [_averArray objectAtIndex:8];
//        NSString *c = [_averArray objectAtIndex:9];
//
//        if (c.floatValue -b.floatValue >2 && b.floatValue-a.floatValue >2)
//        {
//            dst = temp/2 + total/20;
//        }
//       else if ( a.floatValue -b.floatValue >2 && b.floatValue-c.floatValue >2)
//       {
//           dst = temp/2 + total/20;
//
//       }
//       else
//       {
//           dst = temp/3 + total*2/30;
//
//       }
//        
//        //指数平滑
////        float dst = temp*2/5 +total*3/25;
//        
//        
//        self.currentRssi = [NSString stringWithFormat:@"%.1f",dst];
//        _dis_label.text = [NSString stringWithFormat:@"距离:%@m",self.currentRssi];
//
//        NSLog(@"%@",self.currentRssi);
//        NSLog(@"%@",self.lastRssi);
//
////        //判断如果是大于1m
////        if (self.currentRssi.floatValue - self.lastRssi.floatValue >1)
////        {
////            float num = self.lastRssi.floatValue + 1;
////            _dis_label.text = [NSString stringWithFormat:@"大约距离:%.1fm",num];
////            self.lastRssi = [NSString stringWithFormat:@"%f",num];
////        }
////        else
////        {
////            _dis_label.text = [NSString stringWithFormat:@"大约距离:%@m",self.currentRssi];
////            self.lastRssi = [NSString stringWithFormat:@"%@",self.currentRssi];
////
////        }
//        
//        
//        [self toAlarm];
//        [_averArray removeObjectAtIndex:0];
//        NSString *k = [NSString stringWithFormat:@"%.1f",temp];
//        [_averArray addObject:k];
//        
////        //卡位算法
////        float kaweiTotal ;
////        BOOL   isKawei = NO;
////        for (NSString *value in _averArray)
////        {
////            kaweiTotal += value.floatValue;
////        }
////
////        for (int i =0; i<5; i++)
////        {
////            NSString * sub = [_averArray objectAtIndex:i];
////            if (sub.floatValue - kaweiTotal >2 || sub.floatValue - kaweiTotal <-2)
////            {
////                isKawei = YES;
////            }
////        }
////        
////        
////        if (isKawei)
////        {
////            _dis_label.text = [NSString stringWithFormat:@"距离:%.1fm",kaweiTotal];
////
////        }
//    }
//    else
//    {
//        NSString *k = [NSString stringWithFormat:@"%.1f",pow(10,ci)];
//        [_averArray addObject:k];
//        self.currentRssi = [NSString stringWithFormat:@"%.1f",pow(10,ci)];
//        self.lastRssi = [NSString stringWithFormat:@"%.1f",pow(10,ci)];
//        _dis_label.text = [NSString stringWithFormat:@"大约距离:%@m",self.currentRssi];
//        [self toAlarm];
//        
//    }
    
    
    NSLog(@"距离：%@",length);

//    //进入设备
//    int rssi = abs([RSSI intValue]);
//    CGFloat ci = (rssi - 49) / (10 * 4.);
//    self.currentRssi = [NSString stringWithFormat:@"%.1f",pow(10,ci)];
//    _dis_label.text = [NSString stringWithFormat:@"距离:%@m",self.currentRssi];
//    [self toAlarm];
//    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",_peripheral,pow(10,ci)];
//    NSLog(@"距离：%@",length);

}
//已发现服务
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    
//    if (!self.timer)
//    {
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                      target:self
//                                                    selector:@selector(toReadRSSI)
//                                                    userInfo:nil
//                                                     repeats:1.0];
//        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
//    }

    _peripheral = peripheral;
    
    //跟新数据
    
    for (int i=0; i < [Global getInstance].peripheralList .count; i++)
    {
        CBPeripheral *p = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"device"];
        NSDictionary *advertisementData = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"adv"];
        SetModel *model = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"model"];
        NSNumber *rssi = [[[Global getInstance].peripheralList objectAtIndex:i] objectForKey:@"rssi"];
        if ([p.identifier isEqual:_peripheral.identifier])
        {
            //            [_nDevices replaceObjectAtIndex:i withObject:peripheral];
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_peripheral,@"device",advertisementData,@"adv",peripheral.services,@"services",model,@"model",rssi,@"rssi", nil];
//            _nServices = peripheral.services;
            [[Global getInstance].peripheralList replaceObjectAtIndex:i withObject:dic];
        }
    }

//    int i = 0;
    for (CBService *s in peripheral.services)
    {
        [self.nServices addObject:s];
    }
    for (CBService *s in peripheral.services)
    {
//        [self updateLog:[NSString stringWithFormat:@"%d :服务 UUID: %@(%@)",i,s.UUID.data,s.UUID]];
//        i++;
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
//    [self updateLog:[NSString stringWithFormat:@"发现特征的服务:%@ (%@)",service.UUID.data ,service.UUID]];
    

  
    
    for (CBCharacteristic *c in service.characteristics)
    {
        NSLog(@"------,,,,,%@",c.UUID);
//        [self updateLog:[NSString stringWithFormat:@"特征 UUID: %@ (%@)",c.UUID.data,c.UUID]];
        
//        _writeCharacteristic = c;
//        [_peripheral readValueForCharacteristic:c];

        
        
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]])
        {
            _writeCharacteristic = c;
            [_peripheral readValueForCharacteristic:c];

        }
        
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF4"]])
//        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]])
        {
            _writeCharacteristicBangDing = c;
            //发送绑定成功的信号
//            __weak typeof(self)  weakSelf= self;
//            NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^(){
//                NSLog(@"执行第1次操作，线程：%@", [NSThread currentThread]);
//                __strong typeof(self)  strongSelf = weakSelf;
          
                 [self sendbanding];

            
      //      }];
//            if (!isSender) {
//                [self sendbanding];
//            }
        //    [queue addOperation:operation1];
            //[self performSelector:@selector(sendbanding) withObject:self afterDelay:0]; // 修改（0） 不一定是里面执行.里面五秒后执行
    
          
            
        }

//        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"System ID"]]) {
//            [_peripheral readValueForCharacteristic:c];
//        }
//        
//        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
//            [_peripheral readRSSI];
//        }
////        [_nCharacteristics addObject:c];
    }
    
    
//
//    
//    
//    
//        uint8_t data = 0x02;
//        NSData *mes1 = [NSData dataWithBytes:&data length:1];
//
//        [_peripheral writeValue:mes1 forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];

    

}



- (void)sendbanding
{
    
    [_peripheral readValueForCharacteristic:_writeCharacteristicBangDing];

    NSString *temp = [[[UIDevice currentDevice]identifierForVendor]UUIDString];
    NSRange range ;
    range.location = 1;
    range.length = 5;
    NSString *temp_sub = [NSString stringWithFormat:@"p%@p",[temp substringWithRange:range] ];

    
    NSData *mes = [temp_sub dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[mes bytes];
    //
    //            NSData * da = [NSData dataWithBytes:bytes length:7] *256;
    

           [_peripheral writeValue:[NSData dataWithBytes:bytes length:7] forCharacteristic:_writeCharacteristicBangDing type:CBCharacteristicWriteWithResponse];
 
    
    
    //提示绑定成功
    UILabel *la = (UILabel *)[self.view viewWithTag:7001];
    la.text = @"绑定成功";
    la.hidden = NO;
    [UIView animateWithDuration:2 animations:^{
        la.alpha = 1;
        la.alpha = 0;
    } completion:^(BOOL finished) {
        la.hidden = YES;
    }];
    
    
    
//    [_peripheral readValueForCharacteristic:_writeCharacteristic];


}

//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // BOOL isSaveSuccess;
    
    NSLog(@"%@",characteristic.value);
    
 //   _writeCharacteristic = characteristic;(注释掉 ) add by haidi 
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        _batteryValue = [value floatValue];
//        NSLog(@"电量%f",_batteryValue);
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]])
    {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        //_batteryValue = [value floatValue];
        NSLog(@"信号%@",value);
    }
  
    
    else
        NSLog(@"didUpdateValueForCharacteristic%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
}


//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    // Notification has started
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
        
    } else { // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
}

//用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
   
    if (error) {
        NSLog(@"=======%@",error.userInfo);
     
    }else{
       
  
        NSLog(@"发送数据成功");
    }
}

//- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//{
//    if (error)
//    {
//        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
//        
//
//    }
//}


- (void)playMusic
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //播放背景音乐
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"电子警报音效" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
    
    // 创建播放器
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    [player setVolume:1];
    player.numberOfLoops = 1; //设置音乐播放次数  -1为一直循环
    [player play]; //播放
    
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
