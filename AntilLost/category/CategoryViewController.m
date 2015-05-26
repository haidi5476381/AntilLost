//
//  CategoryViewController.m
//  BluetoothTest
//
//  Created by Pro on 14-4-6.
//  Copyright (c) 2014年 Pro. All rights reserved.
//

#import "CategoryViewController.h"
#import "config.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"类型选择";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIImageView *backView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back1.jpg"]];
//    backView.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);
//    [self.view addSubview:backView];
    
    UIBarButtonItem *rightAction = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectRightAction:)];
    self.navigationItem.rightBarButtonItem = rightAction;
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight-80) style:UITableViewStyleGrouped];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    
    _arr = [NSMutableArray arrayWithObjects:@"钱包",@"公文包",@"宠物",@"小孩",@"老人",@"行李箱",@"其他", nil];
    
}

-(void)back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else{
        NSString *addString = [alertView textFieldAtIndex:0].text;
        [_arr insertObject:addString atIndex:0];
        [_table reloadData];
    }
}

-(void)selectRightAction:(id)sender
{
    UIAlertView *add = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入要加入的类型" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    add.alertViewStyle = UIAlertViewStylePlainTextInput;
    [add show];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arr count]+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identified = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identified];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identified];
    }
    if (indexPath.row == [_arr count]) {
        _loadMoreCell = [[LoadMoreCellTableViewCell alloc]init];
        _loadMoreCell.loadLabel.text = @"点击加载更多";
        return _loadMoreCell;
    }
    
    cell.textLabel.text = [_arr objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [_arr removeObjectAtIndex:indexPath.row];
        [_table reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_arr count]) {
        [_loadMoreCell.loadLabel setText:@"正在加载..."];
        [_loadMoreCell.activity startAnimating];
        [self performSelectorInBackground:@selector(loadMore) withObject:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //return;
    }else{
        NSString *name = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        [_delegate selectCategary:name];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)loadMore
{
    NSMutableArray *more = [NSMutableArray arrayWithObjects:@"钱包1",@"公文包1",@"宠物1",@"小孩1",@"老人1",@"行李箱1",@"其他1", nil];
    sleep(1.0);
    [self performSelectorOnMainThread:@selector(refreshUI:) withObject:more waitUntilDone:NO];
}
//刷新界面
-(void)refreshUI:(NSMutableArray *)data
{
    [_arr addObjectsFromArray:data];
    //[_table reloadData];

    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:10];
    for (int ind = 0; ind < [data count]; ind++) {
        NSIndexPath    *newPath =  [NSIndexPath indexPathForRow:[_arr indexOfObject:[data objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"请选择要绑定的类型:";
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
