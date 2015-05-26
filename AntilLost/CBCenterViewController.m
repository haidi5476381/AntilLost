//
//  CBCenterViewController.m
//  BluetoothTest
//
//  Created by Pro on 14-4-6.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import "CBCenterViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
//#import "InstructionViewController.h"
//#import "SetViewController.h"
#import "CategoryViewController.h"
#import "config.h"


static NSString *const kCharacteristicUUID = @"CCE62C0F-1098-4CD0-ADFA-C8FC7EA2EE90";

static NSString *const kServiceUUID = @"50BD367B-6B17-4E81-B6E9-F62016F26E7B";


@interface CBCenterViewController ()
@end

@implementation CBCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"手环";
        //self.tabBarItem.image = [UIImage imageNamed:@"lock.png"];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"lock.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"lock.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //本地通知
//    UILocalNotification *notification = [[UILocalNotification alloc]init];
//    if (notification != nil)
//    {
//        NSDate *now = [NSDate new];
//        notification.fireDate = [now dateByAddingTimeInterval:10];
//        notification.timeZone = [NSTimeZone defaultTimeZone];
//        notification.alertBody = @"报警";
//        notification.soundName = @"雷达咚咚音效.mp3";
//        notification.applicationIconBadgeNumber = 1;
//        notification.alertAction = @"关闭";
//        
//        [[UIApplication sharedApplication]scheduleLocalNotification:notification];
//    
//    }
    
    
    if (IOS7) {
        self.view.bounds  = CGRectMake(0, -64, self.view.bounds.size.width, self.view.bounds.size.height);
    }
    
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    scroll.contentSize = CGSizeMake(kDeviceWidth, kDeviceHeight);
    [self.view addSubview:scroll];
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:UIBarMetricsDefault];
    
//    UIBarButtonItem *rightAction = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(selectRightAction:)];
//    self.navigationItem.rightBarButtonItem = rightAction;
    
    UIImageView *backView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back3.png"]];
    backView.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);
    [scroll addSubview:backView];
    
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _manager.delegate =self;
    
    UIButton *scan = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [scan setTitle:@"扫描" forState:UIControlStateNormal];
    scan.frame = CGRectMake(20, 210, 60, 30);
    [scan addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:scan];
    
    _connect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_connect setTitle:@"连接" forState:UIControlStateNormal];
    _connect.frame = CGRectMake(90, 210, 60, 30);
    [_connect addTarget:self action:@selector(connectClick:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:_connect];
    
    UIButton *send = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [send setTitle:@"报警" forState:UIControlStateNormal];
    send.frame = CGRectMake(160, 210, 60, 30);
    [send addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:send];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 250, 300, 200)];
    [scroll addSubview:_textView];
    
    _cbReady = false;
    _nDevices = [[NSMutableArray alloc]init];
    _nServices = [[NSMutableArray alloc]init];
    _nCharacteristics = [[NSMutableArray alloc]init];
    
    _deviceTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 190) style:UITableViewStyleGrouped];
    UIImageView *imageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back2.png"]];
    imageView.layer.cornerRadius = 10;
    imageView.layer.masksToBounds = YES;
    _deviceTable.backgroundView = imageView;
    _deviceTable.delegate = self;
    _deviceTable.dataSource = self;
    [scroll addSubview:_deviceTable];
    //刷新指示圈
//    _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    _activity.frame = CGRectMake(145, 13, 30, 30);
//    _activity.hidesWhenStopped = YES;
//    [self.view addSubview:_activity];
    
    _isRefreshing = NO;
//    _refreshGo = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0.0, 0.0 - _deviceTable.bounds.size.height, _deviceTable.bounds.size.width, _deviceTable.bounds.size.height)];
//    _refreshGo.delegate = self;
//    [_deviceTable addSubview:_refreshGo];
    
}



-(void)reloadData
{
    _isRefreshing  = YES;
    [NSThread detachNewThreadSelector:@selector(requestData) toTarget:self withObject:nil];
}

-(void)requestData
{
    [_nDevices addObject:@"我是蓝牙设备"];
    sleep(1.0);
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:self waitUntilDone:NO];
}

//-(void)refreshUI
//{
//    _isRefreshing = NO;
//    [_refreshGo egoRefreshScrollViewDataSourceDidFinishedLoading:_deviceTable];
//    [_deviceTable reloadData];
//}
//
//#pragma mark - EGORefreshTableHeaderDelegate
////出发下拉刷新动作，开始拉取数据
//-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
//{
//    [self reloadData];
//}
////返回当前刷新状态：是否在刷新
//-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
//{
//    return _isRefreshing;
//}
////返回刷新时间
//-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
//{
//    return [NSDate date];
//}
////此代理在scrollview滚动时就会调用
////在下拉一段距离到提示松开和松开后提示都应该有变化，变化可以在这里实现
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [_refreshGo egoRefreshScrollViewDidScroll:scrollView];
//}
////松开后判断表格是否在刷新，若在刷新则表格位置偏移，且状态说明文字变化为loading...
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [_refreshGo egoRefreshScrollViewDidEndDragging:scrollView];
//}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_nDevices count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identified = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identified];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identified];
    }
    CBPeripheral *p = [_nDevices objectAtIndex:indexPath.row];
    cell.textLabel.text = p.name;
    
    //cell.textLabel.text = [_nDevices objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"已扫描到的设备:";
}

//textView更新
-(void)updateLog:(NSString *)s
{
    static unsigned int count = 0;
    [_textView setText:[NSString stringWithFormat:@"[ %d ]  %@\r\n%@",count,s,_textView.text]];
    count++;
}
//实现代理方法
-(void)selectCategary:(NSString *)name
{
    //_nameLabel.text = name;
}

-(void)selectRightAction:(id)sender
{
    //self.tabBarController.selectedIndex  = 1;
    CategoryViewController *category = [[CategoryViewController alloc]init];
    category.delegate = self;
    [self.navigationController pushViewController:category animated:YES];
}

//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (scrollView.contentOffset.y < -30) {
//        [self scanClick];
//    }
//}

//扫描
-(void)scanClick
{
    [self updateLog:@"正在扫描外设..."];
    //[_activity startAnimating];
    [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    double delayInSeconds = 30.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.manager stopScan];
        [_activity stopAnimating];
        [self updateLog:@"扫描超时,停止扫描"];
    });
}

//连接

-(void)connectClick:(id)sender
{
    if (_cbReady ==false)
    {
        if (_peripheral != nil)
        {
            [self.manager connectPeripheral:_peripheral options:nil];
            _cbReady = true;
            [_connect setTitle:@"断开" forState:UIControlStateNormal];

        }
        else
        {
            AlertWithMessage(@"没有连接设备");
        }
    }
    else
    {
        [self.manager cancelPeripheralConnection:_peripheral];
        _cbReady = false;
        [_connect setTitle:@"连接" forState:UIControlStateNormal];
    }
}

//报警
-(void)sendClick:(UIButton *)bu
{
    
    //外部发声  和内部发声
    
    
    unsigned char data = 0x02;
    [_peripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self updateLog:@"蓝牙已打开,请扫描外设"];
            break;
        default:
            break;
    }
    
    
    if (central.state == CBCentralManagerStatePoweredOn) {
//        [self.centralManger scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"f3d9"]]
//                                                   options:nil];
    }
}

//查到外设后，停止扫描，连接设备  扫描成功
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self updateLog:[NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.UUID, advertisementData]];
    _peripheral = peripheral;
    NSLog(@"%@",_peripheral);
    [self.manager stopScan];
    //[_activity stopAnimating];
    BOOL replace = NO;
    // Match if we have this device from before
    for (int i=0; i < _nDevices.count; i++) {
        CBPeripheral *p = [_nDevices objectAtIndex:i];
        if ([p isEqual:peripheral]) {
            [_nDevices replaceObjectAtIndex:i withObject:peripheral];
            replace = YES;
        }
    }
    if (!replace) {
        [_nDevices addObject:peripheral];
        [_deviceTable reloadData];
    }
}

//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    [self updateLog:[NSString stringWithFormat:@"成功连接 peripheral: %@ with UUID: %@",peripheral,peripheral.UUID]];
   
    [self.peripheral setDelegate:self];
    
    self.peripheral.delegate = self;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(toReadRSSI)
                                                    userInfo:nil
                                                     repeats:1.0];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }

    [self.peripheral discoverServices:nil];
    [self updateLog:@"扫描服务"];
    
}

- (void)toReadRSSI
{
    if (_peripheral != nil)
    {
        [_peripheral readRSSI];
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
    NSLog(@"距离：%@",length);
}
//已发现服务
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    [self updateLog:@"发现服务."];
    int i=0;
    for (CBService *s in peripheral.services) {
        [self.nServices addObject:s];
    }
    for (CBService *s in peripheral.services) {
        [self updateLog:[NSString stringWithFormat:@"%d :服务 UUID: %@(%@)",i,s.UUID.data,s.UUID]];
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    [self updateLog:[NSString stringWithFormat:@"发现特征的服务:%@ (%@)",service.UUID.data ,service.UUID]];
    
    for (CBCharacteristic *c in service.characteristics) {
        [self updateLog:[NSString stringWithFormat:@"特征 UUID: %@ (%@)",c.UUID.data,c.UUID]];
        
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]]) {
            _writeCharacteristic = c;
        }
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
            [_peripheral readValueForCharacteristic:c];
        }
        
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
            [_peripheral readRSSI];
        }
        [_nCharacteristics addObject:c];
    }
}


//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // BOOL isSaveSuccess;
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        _batteryValue = [value floatValue];
        NSLog(@"电量%f",_batteryValue);
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        //_batteryValue = [value floatValue];
        NSLog(@"信号%@",value);
    }

    else
    NSLog(@"didUpdateValueForCharacteristic%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
}

//将视频保存到目录文件夹下
-(BOOL)saveToDocument:(NSData *) data withFilePath:(NSString *) filePath
{
    if ((data == nil) || (filePath == nil) || [filePath isEqualToString:@""]) {
        return NO;
    }
    @try {
        //将视频写入指定路径
        [data writeToFile:filePath atomically:YES];
        return  YES;
    }
    @catch (NSException *exception) {
        NSLog(@"保存失败");
    }
    return NO;
}

//根据当前时间将视频保存到VideoFile文件夹中
-(NSString *)imageSavedPath:(NSString *) VideoName
{
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //获取文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //指定新建文件夹路径
    NSString *videoDocPath = [documentPath stringByAppendingPathComponent:@"VideoFile"];
    //创建VideoFile文件夹
    [fileManager createDirectoryAtPath:videoDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    //返回保存图片的路径（图片保存在VideoFile文件夹下）
    NSString * VideoPath = [videoDocPath stringByAppendingPathComponent:VideoName];
    return VideoPath;
}

//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUp
{
//    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
//    customerCharacteristic = [[CBMutableCharacteristic alloc]initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
//    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
//    customerService = [[CBMutableService alloc]initWithType:serviceUUID primary:YES];
//    [customerService setCharacteristics:@[characteristicUUID]];
//    //添加后就会调用代理的- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
//    [peripheraManager addService:customerService];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
