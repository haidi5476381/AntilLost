//
//  AppDelegate.m
//  AntilLost
//
//  Created by vpclub on 15/1/19.
//  Copyright (c) 2015年 vpclub. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SearcherViewController.h"
#import "SetViewController.h"
#import "Global.h"
@interface AppDelegate ()
{

}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
//    ViewController *rootVC = [[ViewController alloc]init];

//    SetViewController *rootVC = [[SetViewController alloc]init];
//    [Global getInstance].language = 1;
    
    
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    
    SystemSoundID soundId;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"wusheng" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
    AudioServicesPlaySystemSound(soundId);

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryErr];

//    [[AVAudioSession sharedInstance]
//     setCategory: AVAudioSessionCategoryPlayback
//     error: &setCategoryErr];
    [[AVAudioSession sharedInstance]
     setActive: YES
     error: &activationErr];
    [[NSUUID UUID] UUIDString];
    //取消本地通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    [self uuid];
    NSLog(@"----------->>>>>%@",[[[UIDevice currentDevice]identifierForVendor]UUIDString]);

    SearcherViewController *rootVC = [[SearcherViewController alloc]init];
    UINavigationController *rootNav = [[UINavigationController alloc]initWithRootViewController:rootVC];
    self.window.rootViewController = rootNav;
    [self.window makeKeyAndVisible];
    
    
    //运行计时器
    NSTimer *tip = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(tik)
                                                      userInfo:nil
                                                       repeats:1.0];
    [[NSRunLoop currentRunLoop] addTimer:tip forMode:NSDefaultRunLoopMode];

    
//    if([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone)
//    {
////        [self addLocalNotification];
//    }
//    else
//    {
//        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
//    }
    
    return YES;
}


-(NSString*) uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}


#pragma mark - 私有方法
#pragma mark 添加本地通知
-(void)addLocalNotification
{
    
//    if([Global getInstance].isDuanKai)
//    {
//        //定义本地通知对象
//        UILocalNotification *notification=[[UILocalNotification alloc]init];
//        //设置调用时间
//        notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:1.0];//通知触发的时间，10s以后
//        notification.repeatInterval=2;//通知重复次数
//        //notification.repeatCalendar=[NSCalendar currentCalendar];//当前日历，使用前最好设置时区等信息以便能够自动同步时间
//        
//        //设置通知属性
//        notification.alertBody=@"晚来风雨雪，"; //通知主体
//        notification.applicationIconBadgeNumber=1;//应用程序图标右上角显示的消息数
//        notification.alertAction=@"打开应用"; //待机界面的滑动动作提示
//        notification.alertLaunchImage=@"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
//        //notification.soundName=UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
//        notification.soundName=@"msg.caf";//通知声音（需要真机才能听到声音）
//        
//        //设置用户信息
//        notification.userInfo=@{@"id":@1,@"user":@"Kenshin Cui"};//绑定到通知上的其他附加信息
//        
//        //调用通知
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
// 
//    }
}


#pragma mark 调用过用户注册通知方法之后执行（也就是调用完registerUserNotificationSettings:方法之后执行）
//-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
//{
////    if (notificationSettings.types!=UIUserNotificationTypeNone)
////    {
//////        [self addLocalNotification];
////    }
//}



#pragma mark 移除本地通知，在不需要此通知时记得移除
//-(void)removeNotification{
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents]; // 让后台可以处理多媒体的事件
    NSLog(@"%s",__FUNCTION__);
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil]; //后台播放

    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



//本地通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"接收到本地提醒 in app"
//                                                    message:notification.alertBody
//                                                   delegate:nil
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil];
//    [alert show];
//    //这里，你就可以通过notification的useinfo，干一些你想做的事情了
//    application.applicationIconBadgeNumber -= 1;

}


//蓝牙后台的操作
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [Global getInstance].isBackgroud = YES;
    
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)])
    {
        backgroundSupported = device.multitaskingSupported;
//        NSLog(@"%@",[application backgroundTimeRemaining]);

    }
    
//    
//    BOOL backgroundAccepted = [[UIApplication sharedApplication]setKeepAliveTimeout:MAXFLOAT handler:^{
//        [self backgroundHandler];
//    }];
//    
//    if (backgroundAccepted)
//    {
//        NSLog(@"backgroud  Accepted");
//    }
//    [self backgroundHandler];
    
    
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
    
//    
//    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
//        // Clean up any unfinished task business by marking where you
//        // stopped or ending the task outright.
//        
//        NSLog(@"-------------%d",11111);
//        
//        [application endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    }];
//    
//    
//    
//    [application setKeepAliveTimeout:  610 handler:^{
//        self.timer_smart = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                            target:self
//                                                          selector:@selector(smartConnect)
//                                                          userInfo:nil
//                                                           repeats:1.0];
//        [[NSRunLoop currentRunLoop] addTimer:self.timer_smart forMode:NSDefaultRunLoopMode];
//
//    }];
//
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        // Do the work associated with the task, preferably in chunks.
//        NSLog(@"-------------%d",11111);
//
//    self.timer_smart = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                        target:self
//                                                      selector:@selector(smartConnect)
//                                                      userInfo:nil
//                                                       repeats:1.0];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer_smart forMode:NSDefaultRunLoopMode];
//
//        
//        [application endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    });

    
    
    
    
//    self.timer_smart = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                        target:self
//                                                      selector:@selector(smartConnect)
//                                                      userInfo:nil
//                                                       repeats:1.0];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer_smart forMode:NSDefaultRunLoopMode];

}



- (void)tik
{
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0) {
//        [[CKAudioTool sharedInstance] playSound];
        
        
        SystemSoundID soundId;
        NSString *path = [[NSBundle mainBundle]pathForResource:@"wusheng" ofType:@"mp3"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
        AudioServicesPlaySystemSound(soundId);

        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    }
}


- (void)backgroundHandler
{
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1)
        {
            
            
            sleep(1);
        }
        

    });

}



- (void)smartConnect
{
    NSLog(@"-------------%d",11111);
    
    
    

    [[Global getInstance].manager scanForPeripheralsWithServices:[Global getInstance].peripheral.services options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
}




- (void)hhhh
{
    NSLog(@"iiiiiiiiiiiii");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
     [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    
    [Global getInstance].isBackgroud = NO;

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
//    [self.timer_smart invalidate];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}
@end
