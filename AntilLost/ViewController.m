//
//  ViewController.m
//  AntilLost
//
//  Created by vpclub on 15/1/19.
//  Copyright (c) 2015年 vpclub. All rights reserved.
//

#import "ViewController.h"
#import "Global.h"
#import "SearcherViewController.h"
#import "SetViewController.h"
#import "SetModel.h"

@interface ViewController ()
{
    UITableView *_homeTableView;
}

@end

@implementation ViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if ([Global getInstance].peripheralList.count > 0)
    {
        [_homeTableView reloadData];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"手环";
//    self.view .backgroundColor = [UIColor purpleColor];
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];

    if (systemVersion >= 7.0)
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //创建tableView
    _homeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _homeTableView.dataSource = self;
    _homeTableView.delegate = self;
    
    [self.view addSubview:_homeTableView];
    
    //创建footview
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 80)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(150, 20, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"HP_search.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goToSearcherViewController) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:btn];
    
    _homeTableView.tableFooterView = footView;
    
//    //创建虚拟数据
//    SetModel *model = [[SetModel alloc]init];
//    model.isRing = NO;
//    model.isShake = YES;
//    model.name = @"bobo";
//    
//    CBPeripheral *p = [[CBPeripheral alloc]init];
    
    
    
    
    
//    p.name = @"D5F188DE-F85E-FF0D-10F8-D06E36F6F591";
//
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)goToSearcherViewController
{
    
//    SetViewController *se  = [[SetViewController alloc]init];
//    [self.navigationController pushViewController:se animated:YES];
    
    SearcherViewController *seaVC = [[SearcherViewController alloc]init];
    [self.navigationController pushViewController:seaVC animated:YES];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
    int num =0;

    if (list.count > 0)
    {
        
        for (NSDictionary *dic  in list)
        {
            
            NSNumber *rssi = [dic objectForKey:@"rssi"];
            int index = rssi.intValue/7;
            
            if (index== indexPath.row)
            {
               
                CBPeripheral * p = [dic objectForKey:@"device"];
                UIImage *image  = [UIImage imageNamed:@"icon.png"];
                UIImageView * iamgeView = [[UIImageView alloc]initWithFrame:CGRectMake(20 + 40*num, 10, 40, 40)];
                iamgeView.image = image;
                [cell.contentView addSubview:iamgeView];
                
                
                
                UILabel * l = [[UILabel alloc]initWithFrame:CGRectMake(10 + 40*num, CGRectGetMaxY(iamgeView.frame) +5, 100, 40)];
                l.font = [UIFont systemFontOfSize:14];
                l.text = p.name;
                [cell.contentView addSubview:l];
                num ++;
            }
        }
        
    }
//    cell.contentView.backgroundColor = [UIColor purpleColor];
    
    if (indexPath.row == 0)
    {
        UILabel *d = [[UILabel alloc]initWithFrame:CGRectMake(290, 0, 30, 100)];
        d.text = @"7m";
        d.font = [UIFont systemFontOfSize:14];
        d.textColor = [UIColor redColor];
        [cell.contentView addSubview:d];
    }
    else if (indexPath.row == 1)
    {
        UILabel *d = [[UILabel alloc]initWithFrame:CGRectMake(290, 0, 30, 100)];
        d.text = @"14m";
        d.font = [UIFont systemFontOfSize:14];
        d.textColor = [UIColor redColor];
        [cell.contentView addSubview:d];

    }
    else if (indexPath.row == 2)
    {
        UILabel *d = [[UILabel alloc]initWithFrame:CGRectMake(290, 0, 30, 100)];
        d.text = @"21m";
        d.font = [UIFont systemFontOfSize:14];
        d.textColor = [UIColor redColor];
        [cell.contentView addSubview:d];
        
    }
    else if(indexPath.row == 3)
    {
        UILabel *d = [[UILabel alloc]initWithFrame:CGRectMake(290, 0, 30, 100)];
        d.text = @"28m";
        d.font = [UIFont systemFontOfSize:14];
        d.textColor = [UIColor redColor];
        [cell.contentView addSubview:d];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    SearcherViewController *seaVC = [[SearcherViewController alloc]init];
    
    SetViewController *setVC = [[SetViewController alloc]init];
    [self.navigationController pushViewController:setVC animated:YES];

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
