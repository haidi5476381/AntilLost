//
//  SetViewController.m
//  BluetoothTest
//
//  Created by Pro on 14-4-6.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import "SetViewController.h"
#import "config.h"
#import "SetModel.h"
#import "Global.h"
#import "AlarmViewController.h"
#import "CustomCell.h"


#define COLORL @"ec1c8c"
#define Stage_one   3.5
#define Stage_two   7
#define Stage_three   10

@interface SetViewController ()
{
    int m_nPayment;
    UIImageView *imgBox_one;
    UIImageView *imgBox_two;

}

@end

@implementation SetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.tabBarItem.image = [UIImage imageNamed:@"set.png"];
//        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"set.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"set.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([Global getInstance].language ==1)
    {
        self.title = @"Settings";
    }
    else
    {
        self.title = @"设置";
        
    }

    // Do any additional setup after loading the view.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;

    }
    self.view.backgroundColor = [UIColor whiteColor];
//    UIImageView *backView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back3.png"]];
//    backView.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);
//    [self.view addSubview:backView];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:UIBarMetricsDefault];
    
//    UIBarButtonItem *rightAction = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(selectRightAction:)];
    
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
    
    self.navigationController.extendedLayoutIncludesOpaqueBars = NO;
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, self.view.frame.size.height -64) style:UITableViewStyleGrouped];
    _table.dataSource =self;
    _table.delegate = self;
    _table.backgroundColor = [UIColor clearColor];
    _table.backgroundView = nil;
    [self.view addSubview:_table];
    
    
//    UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height -108, 320, 44)];
//    bottomLabel.text = @"解除绑定";
//    bottomLabel.tag = 309;
//    bottomLabel.userInteractionEnabled = YES;
//    bottomLabel.textColor = hexStringToColor(COLORL);
//    bottomLabel.backgroundColor = [UIColor whiteColor];
//    bottomLabel.textAlignment = NSTextAlignmentCenter;
//    bottomLabel.font =[UIFont systemFontOfSize:14];
//    [self.view addSubview:bottomLabel];
    
    
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


    
}

-(void)selectRightAction:(id)sender
{
    
    if(_stage_one.selected == YES)
    {
        [Global getInstance].sliderValue = Stage_one;
    }
    else if (_stage_two.selected == YES)
    {
        [Global getInstance].sliderValue = Stage_two;

    }
    else if (_stage_three.selected == YES)
    {
        [Global getInstance].sliderValue = Stage_three;

    }
    
    
    
    SetModel * model = [[SetModel alloc]init];
    model.name = _perName.text;
    model.isContent = _fangdiu.on;
    model.style = m_nPayment;
    model.distance =  _slider.value;
    model.isShake = _zhendong.on;
    model.isRing = _linSheng.on;
    model.isBangDing = _bangding.on;
    CBPeripheral *per = [self.dataDic objectForKey:@"device"];
    //保存到全局变量
    for (NSMutableDictionary *dic in [Global getInstance].peripheralList)
    {
        CBPeripheral *p = [dic objectForKey:@"device"];
        if (per.identifier == p.identifier)
        {
            [dic setObject:model forKey:@"model"];
        }
    }
    
    //清楚信息
    if (model.isBangDing)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"bangding"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"bangdingName"];

    }
    
    [Global getInstance].isChange = YES;
//    [Global getInstance].sliderValue = _slider.value;
    [Global getInstance].isConnect = _fangdiu.on;
    [Global getInstance].jiebang = _bangding.on;

    if ([Global getInstance].language ==1)
    {
        AlertWithMessage(@"Information saved successfully");
    }
    else
    {
        AlertWithMessage(@"信息保存成功");
    }

    
    //解除绑定
    
    if ([Global getInstance].jiebang)
    {
        //提示绑定成功
        UILabel *la = (UILabel *)[self.view viewWithTag:7001];
        la.text = @"解除绑定成功";
        la.hidden = NO;
        [UIView animateWithDuration:2 animations:^{
            la.alpha = 1;
            la.alpha = 0;
        } completion:^(BOOL finished) {
            la.hidden = YES;
        }];
        
    }

    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return 1;
    }
    else if (section == 2)
    {
        return 1;
    }
    else if (section == 3)
    {
        return 4;
    }
    else if (section ==4)
    {
        return 1;
    }

    else
    {
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //----------------------0000000000
    if (indexPath.section == 0)
    {
        UITableViewCell *oneCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"oneCell"];
        for (UIView *v in oneCell.contentView.subviews)
        {
            [v removeFromSuperview];
        }
        if (_perName ==nil)
        {
            _perName = [[UITextField alloc]initWithFrame:CGRectMake(20, 0, 300, 40)];
            _perName.delegate = self;
        }
        SetModel * model = [self.dataDic objectForKey:@"model"];
        if (model != nil &&model.name.length >0)
        {
            _perName.text = model.name;
        }
        else
        {
            CBPeripheral *per = [self.dataDic objectForKey:@"device"];
            _perName.text = per.name;
            
        }
        [oneCell.contentView addSubview:_perName];
        return oneCell;
    }
    //----------------------11111111111111

    if (indexPath.section == 1)
    {
        UITableViewCell *twoCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"twoCell"];

        for (UIView *v in twoCell.contentView.subviews)
        {
            [v removeFromSuperview];
        }
        
        if (_perState == nil)
        {
            _perState = [[UITextField alloc]initWithFrame:CGRectMake(20, 0, 300, 40)];
        }
        if ([Global getInstance].language ==1)
        {
            _perState.text = @"Connecting";
            
        }
        else
        {
            _perState.text = @"正在连接";
            
        }
        _perState.userInteractionEnabled = NO;
        [twoCell.contentView addSubview:_perState];
        _fangdiu = [[UISwitch alloc]initWithFrame:CGRectMake(220, 8, 60, 30)];
        _fangdiu.on = YES;
        [_fangdiu addTarget:self action:@selector(fangdiuAction:) forControlEvents:UIControlEventValueChanged];
        _fangdiu.on = YES;
        [twoCell.contentView addSubview:_fangdiu];
        return twoCell;
    }

    
    //---------------------3
    if (indexPath.section == 2)
    {
        UITableViewCell *threeCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"threeCell"];

        for (UIView *v in threeCell.contentView.subviews)
        {
            [v removeFromSuperview];
        }
        
        
        //近
        _stage_two = [UIButton buttonWithType:UIButtonTypeCustom];
        _stage_two.frame = CGRectMake(0, 0, threeCell.frame.size.width/2, threeCell.frame.size.height-3);
        _stage_two.titleLabel.font = [UIFont systemFontOfSize:15];
        //            _stage_two.selected = YES;
        //            _stage_two.backgroundColor = hexStringToColor(COLORL);
        [_stage_two setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_stage_two setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stage_two addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        if ([Global getInstance].language == 1)
        {
            [_stage_two setTitle:@"close" forState:UIControlStateNormal];
            
        }
        else
        {
            [_stage_two setTitle:@"近" forState:UIControlStateNormal];
            
        }
        [threeCell.contentView addSubview:_stage_two];
        
        
        
        
        //远
        _stage_three = [UIButton buttonWithType:UIButtonTypeCustom];
        _stage_three.frame = CGRectMake(threeCell.frame.size.width/2, 0, threeCell.frame.size.width/2, threeCell.frame.size.height-3);
        [_stage_three setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_stage_three setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _stage_three.titleLabel.font = [UIFont systemFontOfSize:15];
        if ([Global getInstance].language == 1)
        {
            [_stage_three setTitle:@"Far" forState:UIControlStateNormal];
            
        }
        else
        {
            [_stage_three setTitle:@"远" forState:UIControlStateNormal];
            
        }
        [_stage_three addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [threeCell.contentView addSubview:_stage_three];
        
        
        if ([Global getInstance].sliderValue == Stage_one)
        {
            _stage_one.selected = YES;
            _stage_one.backgroundColor = hexStringToColor(COLORL);
        }
        else if ([Global getInstance].sliderValue == Stage_two)
        {
            _stage_two.selected = YES;
            _stage_two.backgroundColor = hexStringToColor(COLORL);
        }
        else if ([Global getInstance].sliderValue == Stage_three)
        {
            _stage_three.selected = YES;
            _stage_three.backgroundColor = hexStringToColor(COLORL);
        }
        else
        {
            _stage_two.selected = YES;
            _stage_two.backgroundColor = hexStringToColor(COLORL);
            
        }
        return threeCell;
        
    }

    
    /////------------45
    if (indexPath.section == 3)
    {
        UITableViewCell *fourCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fourCell"];

        for (UIView *v in fourCell.contentView.subviews)
        {
            [v removeFromSuperview];
        }
        
        if (indexPath.row == 0)
        {
            if ([Global getInstance].language ==1)
            {
                fourCell.textLabel.text = @"Shock";
                
            }
            else
            {
                fourCell.textLabel.text = @"震动";
                
            }
            
            _zhendong = [[UISwitch alloc]initWithFrame:CGRectMake(220, 8, 60, 30)];
            [_zhendong addTarget:self action:@selector(zhendongAction:) forControlEvents:UIControlEventValueChanged];
            SetModel * model = [self.dataDic objectForKey:@"model"];
            if (model != nil)
            {
                _zhendong.on = model.isShake;
            }
            else
            {
                _zhendong.on = YES;
            }
            
            [fourCell.contentView addSubview:_zhendong];
        }
        if (indexPath.row == 1)
        {
            if ([Global getInstance].language ==1)
            {
                fourCell.textLabel.text = @"Ring";
                
            }
            else
            {
                fourCell.textLabel.text = @"铃声";
                
            }
            
            _linSheng = [[UISwitch alloc]initWithFrame:CGRectMake(220, 8, 60, 30)];
            [_linSheng addTarget:self action:@selector(liShengAction:) forControlEvents:UIControlEventValueChanged];
            SetModel * model = [self.dataDic objectForKey:@"model"];
            if (model != nil)
            {
                _linSheng.on = model.isRing;
            }
            else
            {
                _linSheng.on = YES;
            }
            
            [fourCell.contentView addSubview:_linSheng];
        }
        
        
        if (indexPath.row == 3)
        {
            if ([Global getInstance].language ==1)
            {
                fourCell.textLabel.text = @"Disconnect ringtone";
                
            }
            else
            {
                fourCell.textLabel.text = @"设备断开铃声";
                
            }
            
        }
        
        if (indexPath.row == 2)
        {
            if ([Global getInstance].language ==1)
            {
                fourCell.textLabel.text = @"Ultra-distance ringtones";
                
            }
            else
            {
                fourCell.textLabel.text = @"超距铃声";
                
            }
            
            //                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        return fourCell;
        
    }
    
    else if (indexPath.section == 4)
    {
        UITableViewCell *fiveCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fiveCell"];

        for (UIView *v in fiveCell.contentView.subviews)
        {
            [v removeFromSuperview];
        }
        
        if (indexPath.row == 0)
        {
            if ([Global getInstance].language ==1)
            {
                fiveCell.textLabel.text = @"Shock";
                
            }
            else
            {
                fiveCell.textLabel.text = @"解除绑定";
                
            }
            
            _bangding = [[UISwitch alloc]initWithFrame:CGRectMake(220, 8, 60, 30)];
            [_bangding addTarget:self action:@selector(bangding:) forControlEvents:UIControlEventValueChanged];
            //                SetModel *model = [self.dataDic objectForKey:@"model"];
            //                if (model != nil)
            //                {
            //                    _bangding.on = model.isBangDing;
            //                }
            //                else
            //                {
            _bangding.on = NO;
            //                }
            
            [fiveCell.contentView addSubview:_bangding];
        }
        return fiveCell;
        
    }

    
    
//    
//    static NSString *identified = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identified];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identified];
//        if (indexPath.section == 0)
//        {
//            for (UIView *v in cell.contentView.subviews)
//            {
//                [v removeFromSuperview];
//            }
//            if (_perName ==nil)
//            {
//                _perName = [[UITextField alloc]initWithFrame:CGRectMake(20, 0, 300, 40)];
//                _perName.delegate = self;
//            }
//            SetModel * model = [self.dataDic objectForKey:@"model"];
//            if (model != nil &&model.name.length >0)
//            {
//                _perName.text = model.name;
//            }
//            else
//            {
//                 CBPeripheral *per = [self.dataDic objectForKey:@"device"];
//                _perName.text = per.name;
//
//            }
//            [cell.contentView addSubview:_perName];
//        }
//        if (indexPath.section == 1)
//        {
//            for (UIView *v in cell.contentView.subviews)
//            {
//                [v removeFromSuperview];
//            }
//
//            if (_perState == nil)
//            {
//                _perState = [[UITextField alloc]initWithFrame:CGRectMake(20, 0, 300, 40)];
//            }
//            if ([Global getInstance].language ==1)
//            {
//                _perState.text = @"Connecting";
//
//            }
//            else
//            {
//                _perState.text = @"正在连接";
//
//            }
//            _perState.userInteractionEnabled = NO;
//            [cell.contentView addSubview:_perState];
//            _fangdiu = [[UISwitch alloc]initWithFrame:CGRectMake(220, 8, 60, 30)];
//            _fangdiu.on = YES;
//            [_fangdiu addTarget:self action:@selector(fangdiuAction:) forControlEvents:UIControlEventValueChanged];
//            _fangdiu.on = YES;
//            [cell.contentView addSubview:_fangdiu];
//        }
//        
//        if (indexPath.section == 2)
//        {
//            for (UIView *v in cell.contentView.subviews)
//            {
//                [v removeFromSuperview];
//            }
//
//            //3个按钮
//            
////            _stage_one = [UIButton buttonWithType:UIButtonTypeCustom];
////            _stage_one.frame = CGRectMake(0, 0, cell.frame.size.width/2, cell.frame.size.height-3);
////            _stage_one.titleLabel.font = [UIFont systemFontOfSize:15];
////            [_stage_one setTitle:@"近" forState:UIControlStateNormal];
////            [_stage_one setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
////            [_stage_one setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
////            [_stage_one addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
////            [cell.contentView addSubview:_stage_one];
//            
//            
//            
//            
//            
//            //近
//            _stage_two = [UIButton buttonWithType:UIButtonTypeCustom];
//            _stage_two.frame = CGRectMake(0, 0, cell.frame.size.width/2, cell.frame.size.height-3);
//            _stage_two.titleLabel.font = [UIFont systemFontOfSize:15];
////            _stage_two.selected = YES;
////            _stage_two.backgroundColor = hexStringToColor(COLORL);
//            [_stage_two setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
//            [_stage_two setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [_stage_two addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//            if ([Global getInstance].language == 1)
//            {
//                [_stage_two setTitle:@"close" forState:UIControlStateNormal];
//
//            }
//            else
//            {
//                [_stage_two setTitle:@"近" forState:UIControlStateNormal];
// 
//            }
//            [cell.contentView addSubview:_stage_two];
//
//            
//            
//            
//            //远
//            _stage_three = [UIButton buttonWithType:UIButtonTypeCustom];
//            _stage_three.frame = CGRectMake(cell.frame.size.width/2, 0, cell.frame.size.width/2, cell.frame.size.height-3);
//            [_stage_three setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
//            [_stage_three setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            _stage_three.titleLabel.font = [UIFont systemFontOfSize:15];
//            if ([Global getInstance].language == 1)
//            {
//                [_stage_three setTitle:@"Far" forState:UIControlStateNormal];
//                
//            }
//            else
//            {
//                [_stage_three setTitle:@"远" forState:UIControlStateNormal];
//
//            }
//            [_stage_three addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.contentView addSubview:_stage_three];
//
//            
//            if ([Global getInstance].sliderValue == Stage_one)
//            {
//                _stage_one.selected = YES;
//                _stage_one.backgroundColor = hexStringToColor(COLORL);
//            }
//            else if ([Global getInstance].sliderValue == Stage_two)
//            {
//                _stage_two.selected = YES;
//                _stage_two.backgroundColor = hexStringToColor(COLORL);
//            }
//            else if ([Global getInstance].sliderValue == Stage_three)
//            {
//                _stage_three.selected = YES;
//                _stage_three.backgroundColor = hexStringToColor(COLORL);
//            }
//            else
//            {
//                _stage_two.selected = YES;
//                _stage_two.backgroundColor = hexStringToColor(COLORL);
//
//            }
//
//            
//            
////            UIImageView *phone = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"iphone.png"]];
////            phone.frame = CGRectMake(1, 8, 25, 30);
////            [cell.contentView addSubview:phone];
////            
////            UIImageView *blue = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wireless.png"]];
////            blue.frame = CGRectMake(277, 8, 25, 30);
////            [cell.contentView addSubview:blue];
////            
////            _slider = [[UISlider alloc]initWithFrame:CGRectMake(32, 15, 240, 10)];
////            _slider.continuous = NO;
////            _slider.maximumValue = 10;
////            _slider.minimumValue = 2;
////            _slider.value = 6.0;
////            [_slider addTarget:self action:@selector(distanceSlider) forControlEvents:UIControlEventTouchDragInside];
////            [cell.contentView addSubview:_slider];
////            
////            UILabel *minLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 32, 30, 30)];
////            minLabel.text = @"2";
////            minLabel.backgroundColor = [UIColor clearColor];
////            [cell.contentView addSubview:minLabel];
////            
////            UILabel *maxLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, 32, 30, 30)];
////            maxLabel.text = @"10";
////            maxLabel.backgroundColor = [UIColor clearColor];
////            [cell.contentView addSubview:maxLabel];
////            
////            UILabel *distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 10, 60, 30)];
////            //distanceLabel.text = @"距离";
////            distanceLabel.tag = 1;
////            distanceLabel.backgroundColor = [UIColor clearColor];
////            [cell.contentView addSubview:distanceLabel];
//            
//            
//            
//            
//            //        NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"5米",@"10米",@"15米",@"20米",nil];
//            //        _sege = [[UISegmentedControl alloc]initWithItems:segmentedArray];
//            //        _sege.segmentedControlStyle = UISegmentedControlStylePlain;
//            //        _sege.frame = CGRectMake(25, 8, 250, 30);
//            //        [_sege addTarget:self action:@selector(segeAction:) forControlEvents:UIControlEventValueChanged];
//            //        [cell.contentView addSubview:_sege];
//            
//        }
//        else if (indexPath.section == 3)
//        {
//            for (UIView *v in cell.contentView.subviews)
//            {
//                [v removeFromSuperview];
//            }
//
//            if (indexPath.row == 0)
//            {
//                if ([Global getInstance].language ==1)
//                {
//                    cell.textLabel.text = @"Shock";
//                    
//                }
//                else
//                {
//                    cell.textLabel.text = @"震动";
//
//                }
//                
//                _zhendong = [[UISwitch alloc]initWithFrame:CGRectMake(220, 8, 60, 30)];
//                [_zhendong addTarget:self action:@selector(zhendongAction:) forControlEvents:UIControlEventValueChanged];
//                SetModel * model = [self.dataDic objectForKey:@"model"];
//                if (model != nil)
//                {
//                   _zhendong.on = model.isShake;
//                }
//                else
//                {
//                    _zhendong.on = YES;
//                }
//
//                [cell.contentView addSubview:_zhendong];
//            }
//            if (indexPath.row == 1)
//            {
//                if ([Global getInstance].language ==1)
//                {
//                    cell.textLabel.text = @"Ring";
//                    
//                }
//                else
//                {
//                    cell.textLabel.text = @"铃声";
//                    
//                }
//                
//                _linSheng = [[UISwitch alloc]initWithFrame:CGRectMake(220, 8, 60, 30)];
//                [_linSheng addTarget:self action:@selector(liShengAction:) forControlEvents:UIControlEventValueChanged];
//                SetModel * model = [self.dataDic objectForKey:@"model"];
//                if (model != nil)
//                {
//                    _linSheng.on = model.isRing;
//                }
//                else
//                {
//                    _linSheng.on = YES;
//                }
//                
//                [cell.contentView addSubview:_linSheng];
//            }
//
//            
//            if (indexPath.row == 3)
//            {
//                if ([Global getInstance].language ==1)
//                {
//                    cell.textLabel.text = @"Disconnect ringtone";
//                    
//                }
//                else
//                {
//                    cell.textLabel.text = @"设备断开铃声";
//                    
//                }
//                
//            }
//
//            if (indexPath.row == 2)
//            {
//                if ([Global getInstance].language ==1)
//                {
//                    cell.textLabel.text = @"Ultra-distance ringtones";
//                    
//                }
//                else
//                {
//                    cell.textLabel.text = @"超距铃声";
//
//                }
//
////                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//            }
//            
//        }
//        
//        else if (indexPath.section == 4)
//        {
//            for (UIView *v in cell.contentView.subviews)
//            {
//                [v removeFromSuperview];
//            }
//
//            if (indexPath.row == 0)
//            {
//                if ([Global getInstance].language ==1)
//                {
//                    cell.textLabel.text = @"Shock";
//                    
//                }
//                else
//                {
//                    cell.textLabel.text = @"解除绑定";
//                    
//                }
//                
//                _bangding = [[UISwitch alloc]initWithFrame:CGRectMake(220, 8, 60, 30)];
//                [_bangding addTarget:self action:@selector(bangding:) forControlEvents:UIControlEventValueChanged];
////                SetModel *model = [self.dataDic objectForKey:@"model"];
////                if (model != nil)
////                {
////                    _bangding.on = model.isBangDing;
////                }
////                else
////                {
//                    _bangding.on = NO;
////                }
//                
//                [cell.contentView addSubview:_bangding];
//            }
//
//        }
////        else if (indexPath.section == 5)
////        {
////            UIProgressView *pro = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
////            pro.frame = CGRectMake(15, 20, 230, 20);
////            pro.progress = 0.5;
////            
////            UILabel *la = [[UILabel alloc]initWithFrame:CGRectMake(255, 8, 50, 30)];
////            la.backgroundColor = [UIColor clearColor];
////            la.text = [NSString stringWithFormat:@"%0.0f%%",pro.progress*100];
////            [cell.contentView addSubview:la];
////            [cell.contentView addSubview:pro];
////        }
//
//        
//
//    }
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([Global  getInstance].language == 1)
        {
          return  @"Renaming:";
        }
        else
        {
            
        }
        return @"重命名:";
    }

    if (section == 1)
    {
        if ([Global  getInstance].language == 1)
        {
            return  @"Disconnect:";
        }
        else
        {
            return @"保持连接:";

        }

    }
//    else if (section  == 2)
//    {
//        if ([Global  getInstance].language == 1)
//        {
//            return  @"Device Type:";
//        }
//        else
//        {
//            return @"设备类型:";
//
//        }
//
//    }
    else if (section == 2)
    {
        if ([Global  getInstance].language == 1)
        {
            return  @"Alarm distance:";
        }
        else
        {
            return @"报警距离:";

        }

    }
    if (section == 3)
    {
        if ([Global  getInstance].language == 1)
        {
            return  @"Phone alarm mode:";
        }
        else
        {
            return @"手机报警方式:";

        }

    }
    
    if (section == 4)
    {
        if ([Global  getInstance].language == 1)
        {
            return  @"Unbind:";
        }
        else
        {
            return @"解除绑定:";
            
        }
        
    }
    

//    if (section == 5)
//    {
//        return @"手环电量:";
//    }

    else return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 40.0;
    }else{
        return 40.0;
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    AlarmViewController *alarm = [[AlarmViewController alloc]init];
    alarm.index = indexPath;
    alarm.delegate = self;
    [self.navigationController pushViewController:alarm animated:YES];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3)
    {
        if (indexPath.row ==3)
        {
            AlarmViewController *alarm = [[AlarmViewController alloc]init];
            alarm.type = 1;
            [self.navigationController pushViewController:alarm animated:YES];
        }
        if (indexPath.row ==2)
        {
            AlarmViewController *alarm = [[AlarmViewController alloc]init];
            alarm.type = 2;
            [self.navigationController pushViewController:alarm animated:YES];
        }

    }
}

-(void)distanceSlider
{
    UILabel *la =(UILabel *)[_table viewWithTag:1];
    la.text = [NSString stringWithFormat:@"%0.0f米",_slider.value];

}

-(void)selectAlarm:(NSString *)name to:(NSIndexPath *)index
{
    UITableViewCell *cell = [_table cellForRowAtIndexPath:index];
    cell.detailTextLabel.text = name;
}



-(void)btnSelectPayment:(UIButton*)btn
{
    m_nPayment=(int)btn.tag-5000;
    
    if (m_nPayment ==0)
    {
        imgBox_one.image=[UIImage imageNamed:@"select_pay.png"];
        imgBox_two.image = [UIImage imageNamed:@"unselect_pay.png"];
    }
    else
    {
        imgBox_two.image=[UIImage imageNamed:@"select_pay.png"];
        imgBox_one.image = [UIImage imageNamed:@"unselect_pay.png"];

    }
    [_table reloadData];
}




- (void)btnAction:(UIButton *)sender
{
    if (sender == _stage_one)
    {
        _stage_one.selected = YES;
        _stage_one.backgroundColor = hexStringToColor(COLORL);
        _stage_two.backgroundColor = [UIColor whiteColor];
        _stage_three.backgroundColor = [UIColor whiteColor];

        _stage_two.selected = NO;
        _stage_three.selected = NO;
    }
    else if (sender== _stage_two)
    {
        _stage_one.selected = NO;
        _stage_two.selected = YES;
        _stage_three.selected = NO;
        
        _stage_one.backgroundColor = [UIColor whiteColor];
        _stage_two.backgroundColor = hexStringToColor(COLORL);
        _stage_three.backgroundColor = [UIColor whiteColor];


    }
    else
    {
        _stage_one.selected = NO;
        _stage_two.selected = NO;
        _stage_three.selected = YES;

        _stage_one.backgroundColor = [UIColor whiteColor];
        _stage_two.backgroundColor = [UIColor whiteColor];
        _stage_three.backgroundColor = hexStringToColor(COLORL);

    }
}


//距离设置
-(void)segeAction:(id)sender
{
    UISegmentedControl *sege = (UISegmentedControl *)sender;
    NSInteger selectedNum = sege.selectedSegmentIndex;
    switch (selectedNum) {
        case 0:
            NSLog(@"5");
            break;
        case 1:
            NSLog(@"10");
            break;
        case 2:
            NSLog(@"15");
            break;
        case 3:
            NSLog(@"20");
            break;
        default:
            break;
    }
}


//防丢开关
-(void)fangdiuAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn)
    {
        _perState.text = @"正在连接" ;
        if ([Global getInstance].language ==1)
        {
            _perState.text = @"Connecting" ;

        }
        
    }
    else
    {
        _perState.text = @"保持连接";
        if ([Global getInstance].language ==1)
        {
            _perState.text = @"Disconnect" ;
            
        }

    }
}
//震动开关
-(void)zhendongAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
//    BOOL isButtonOn = [switchButton isOn];
//    if (isButtonOn) {
//        NSLog(@"震动开") ;
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//       
//    }else {
//        NSLog(@"震动关") ;
//    }
}

- (void)liShengAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];

}


//解除绑定
- (void)bangding:(id)sender
{
    
    UISwitch *switchButton = (UISwitch*)sender;
    

    
}

- (BOOL)textView:(UITextField *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [_perName resignFirstResponder];
        return NO;
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
//    if ([textField.text isEqualToString:@"\n"])
//    {
        [_perName resignFirstResponder];
//        return NO;
//    }
    return YES;

}

- (void)linShengAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
//        NSLog(@"震动开") ;
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
    }else {
//        NSLog(@"震动关") ;
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
