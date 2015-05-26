//
//  AlarmViewController.m
//  BluetoothTest
//
//  Created by Pro on 14-4-8.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import "AlarmViewController.h"
#import "config.h"
#import <AVFoundation/AVFoundation.h>
#import "Global.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AlarmViewController ()
{
        NSInteger _select;

}

@end

@implementation AlarmViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStyleGrouped];
    _table.dataSource =self;
    _table.delegate = self;
    [self.view addSubview:_table];
    
    
    
    
    self.title = @"铃声选择";
//    UIButton *bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [bu setTitle:@"返回" forState:UIControlStateNormal];
//    bu.layer.cornerRadius = 5;
//    bu.layer.masksToBounds = YES;
//    [bu setBackgroundImage:[UIImage imageNamed:@"back2.png"] forState:UIControlStateNormal];
//    [bu addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
//    bu.frame = CGRectMake(0, 0, 60, 30);
//    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc]initWithCustomView:bu];
//    self.navigationItem.leftBarButtonItem = backBarButton;

    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([Global getInstance].language ==1)
    {
        [btn setTitle:@"Save" forState:UIControlStateNormal];
    }
    else
    {
        [btn setTitle:@"保存" forState:UIControlStateNormal];
        
    }
    [btn setTitleColor:hexStringToColor(@"ec1c8c") forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 80, 44);
    [btn addTarget:self action:@selector(selectRightAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightAction = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    
    self.navigationItem.rightBarButtonItem = rightAction;

    
    _arr = [NSMutableArray arrayWithObjects:@"电子警报音效",@"防盗器音效",@"雷达咚咚音效",@"信号灯音效", nil];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arr count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identified = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identified];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identified];
        UIButton *play = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        play.frame = CGRectMake(230, 10, 60, 30);
        [play addTarget:self action:@selector(playAction:event:) forControlEvents:UIControlEventTouchUpInside];
        [play setTitle:@"播放" forState:UIControlStateNormal];
//        [cell.contentView addSubview:play];
        cell.backgroundColor  = [UIColor clearColor];
    }
    
    cell.textLabel.text = [_arr objectAtIndex:indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _select = indexPath.row;
    
    
    
    
    //播放
    
    UITableViewCell *cell = [_table cellForRowAtIndexPath:indexPath];
    
    
    
    SystemSoundID soundId;
    NSString *path = [[NSBundle mainBundle]pathForResource:cell.textLabel.text ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
    AudioServicesPlaySystemSound(soundId);

    
    

    
    
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([Global  getInstance].language == 1)
        {
            return  @"Select ringtone:";
        }
        else
        {
            
        }
        return @"铃声选择:";
    }
    
    
    
    return nil;
}


-(void)playAction:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_table];
    NSIndexPath *indexPath = [_table indexPathForRowAtPoint:currentTouchPosition];
    UITableViewCell *cell = [_table cellForRowAtIndexPath:indexPath];
    
    SystemSoundID soundId;
    NSString *path = [[NSBundle mainBundle]pathForResource:cell.textLabel.text ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
    AudioServicesPlaySystemSound(soundId);

}

-(void)selectRightAction:(id)sender
{
    if (self.type ==1)
    {
        [Global getInstance].duankailingsheng = _select;
    }
    if (self.type ==2)
    {
        [Global getInstance].chaojulishneg = _select;

    }
    
    
    //
    if ([Global getInstance].language ==1)
    {
        AlertWithMessage(@"Information saved successfully");
    }
    else
    {
        AlertWithMessage(@"信息保存成功");
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
