//
//  HomeViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/21.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "HomeViewController.h"
#import "AppViewController.h"
#import "AppInfo.h"
#import "AppTableViewCell.h"
#import "AppDelegate.h"
#import "KxMenu.h"
#import "UserEditViewController.h"
#import "ShareListViewController.h"
#import "LoginViewController.h"
#import "CameraListViewController.h"
#import "ProgressBarViewController.h"
#import "CloudFileViewController.h"
#import "BaiDuCloudViewController.h"
#import "DataManager.h"
#import "PasswordViewController.h"
#import "FileTools.h"
//#import "AppButton.h"
#import "FunctionManageTools.h"
#import "AlarmMessageListViewController.h"
#import "AlarmMessageDetailViewController.h"
#import "RootLoginViewController.h"
#import "CloudLoginViewController.h"
#import "CloudLoginSuccessViewController.h"
#import "H264ViewController.h"


#define kMainScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kMainScreenWidth  [[UIScreen mainScreen] bounds].size.width
@interface HomeViewController () <UIGestureRecognizerDelegate, IIViewDeckControllerDelegate>
{
    UIView *bottomView;
}
@end
@implementation HomeViewController

static NSString * CellIdentifier = @"AppCell";

AppDelegate *appDelegate ;
- (void)viewDidLoad
{
    [super viewDidLoad];
// 2015 11 25 start
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comeFromRemoteNotiHome:) name:@"PUSHTOALARMDETAIL" object:nil];
// 2015 11 25 end

    UIImage* img=[UIImage imageNamed:@"sidebar"];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 22, 22);
    [left setBackgroundImage:img forState:UIControlStateNormal];
    [left addTarget: self.viewDeckController action: @selector(toggleLeftView) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=item;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.layer.borderWidth = 0;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];//设置表尾不显示，就不显示多余的横线
    [self.tableView registerClass:[AppTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SelectedAppInfo" ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSMutableArray *oldAdressArr  =  [dictionary objectForKey:@"SelectedAppInfo"];
    //NSLog(plistPath);
    if (oldAdressArr.count !=0) {
        _appList = [FunctionManageTools readSavedApp];
    }else{
        appDelegate = [[UIApplication sharedApplication] delegate];
        _appList = appDelegate.selectedAppArray;
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;

    self.navigationItem.title = @"首页";
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0,height - 50,width/3,50)];
    
    [homeButton setTitle:@"在家" forState:UIControlStateNormal];
    [homeButton setBackgroundColor:[UIColor whiteColor]];
    [homeButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
    [homeButton setImage:[UIImage imageNamed:@"home-down"] forState:(UIControlStateNormal)];
    //[homeButton centerImageAndTitle];
    homeButton.tag=100;
    [homeButton addTarget:self action:@selector(homeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:homeButton];
    
    UIButton *egressButton = [[UIButton alloc] initWithFrame:CGRectMake(width/3,height - 50,width/3,50)];
    [egressButton setTitle:@"外出" forState:UIControlStateNormal];
    [egressButton setBackgroundColor:[UIColor whiteColor]];
    [egressButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [egressButton setImage:[UIImage imageNamed:@"egress"] forState:(UIControlStateNormal)];
    //[homeButton centerImageAndTitle];
    egressButton.tag=101;
    [egressButton addTarget:self action:@selector(egressAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:egressButton];
    

    UIButton *sleepButton = [[UIButton alloc] initWithFrame:CGRectMake(width*2/3,height - 50,width/3,50)];
    [sleepButton setTitle:@"睡眠" forState:UIControlStateNormal];
    [sleepButton setBackgroundColor:[UIColor whiteColor]];
    [sleepButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sleepButton setImage:[UIImage imageNamed:@"sleep"] forState:(UIControlStateNormal)];
    //[homeButton centerImageAndTitle];
    sleepButton.tag=102;
    [sleepButton addTarget:self action:@selector(sleepAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sleepButton];
 
    // 添加底部蓝色滑块
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight - 4, kMainScreenWidth / 3, 4)];
    [bottomView setBackgroundColor:[UIColor colorWithRed:0.0 / 255 green:160.0 / 255 blue:226.0 / 255 alpha:1]];
    [self.view addSubview:bottomView];
    
    self.viewDeckController.panningGestureDelegate = self;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    singleTap.delegate = self;
}

//2015 11 25 start hgc
-(void)comeFromRemoteNotiHome:(NSNotification*)notification{
    NSLog(@"comeFromRemoteNoti");
    NSObject *content = [notification object];
    NSLog(@"comeFromRemoteNotiHome==%@",content);
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"df" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alert show];

    //if cunzai goto
    //then xinjian
    Boolean isPush = YES;
    if ([self.navigationController.visibleViewController isKindOfClass:[AlarmMessageListViewController class]]) {
        NSLog(@"this is it");
        AlarmMessageListViewController *alarmList = self.navigationController.viewControllers[0];
        NSLog(@"[alarmList refreshData]");
//        [alarmList refreshData];
        isPush = NO;
    }else{
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[AlarmMessageListViewController class]]) {
                NSLog(@"have one");
                AlarmMessageListViewController *alarmList = vc;
                [self.navigationController popToViewController:alarmList animated:YES];
                isPush = NO;
                break;
            }
            NSLog(@"vc1=%@",self.navigationController.presentingViewController);
            NSLog(@"vc2=%@",self.navigationController.visibleViewController);
            NSLog(@"vc=%@",vc);
        }
    }
    if (isPush) {
        AlarmMessageListViewController *alarmList = [[AlarmMessageListViewController alloc]initWithNibName:@"AlarmMessageListViewController" bundle:nil];
        [self.navigationController pushViewController:alarmList animated:YES];
    }
}
//2015 11 25 end

- (void)awakeFromNib {

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _appList = appDelegate.selectedAppArray;
    [self.tableView reloadData];
    
    
    NSLog(@"初始化完成！！！！！！！！");
    
}


#pragma mark -
#pragma mark TableView DataSource And Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    if (_appList && _appList.count>0) {
        number = (_appList.count - 1) + 1;
        NSLog(@"%zi", number);
    }else{
        number =0;
        
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppTableViewCell *cell =(AppTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[AppTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSInteger index = indexPath.row;

    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    cell.cellDelegate=self;
    [cell bindApps:_appList[index]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return RCellHeight;
}

#pragma mark -
#pragma mark TapButton Action

- (void)appCell:(AppTableViewCell *)cell actionWithFlag:(NSInteger)flag
{
    NSLog(@"flag:%zi", flag);
    if([self.viewDeckController isSideOpen:IIViewDeckLeftSide])
    {
        
        [self.viewDeckController toggleLeftView];
        return;
    }
    //点击不同的按钮进行不同的处理
    switch (flag)
    {
        case 1:{
            CloudFileViewController *cloudView = [[CloudFileViewController alloc]initWithNibName:@"CloudFileViewController" bundle:nil];
            cloudView.isShowFile =YES;
            cloudView.isServerFile = YES;
            cloudView.cpath =@"/";
            [self.navigationController pushViewController:cloudView animated:YES];
            break;
        }
        case 2:{
            CameraListViewController *cameraListVC = [[CameraListViewController alloc]initWithNibName:@"CameraListViewController" bundle:nil];
            [self.navigationController pushViewController:cameraListVC animated:YES];
            break;
        }
        case 4:{
            BaiDuCloudViewController *baiduCloudVC = [[BaiDuCloudViewController alloc]
                                                      initWithNibName:@"BaiDuCloudViewController" bundle:nil];
            [self.navigationController pushViewController:baiduCloudVC animated:YES];
            break;
        }
        case 5:{
            ShareListViewController *shareList = [[ShareListViewController alloc]                                                    initWithNibName:@"ShareListViewController" bundle:nil];
            [self.navigationController pushViewController:shareList animated:YES];
            break;
        }
        case 6:{
            //test
//            H264ViewController *h264 = [[H264ViewController alloc]initWithNibName:@"H264ViewController" bundle:nil];
//            [self.navigationController pushViewController:h264 animated:YES];
            
            AlarmMessageListViewController *alarmList = [[AlarmMessageListViewController alloc]
                                                 initWithNibName:@"AlarmMessageListViewController" bundle:nil];
            [self.navigationController pushViewController:alarmList animated:YES];
            break;
        }
        case 7:{
            //            NSDictionary *requestParam = @{};
            //请求php
            NSString* url = [NSString stringWithFormat:@"%@/smarty_storage/phone",[g_sDataManager requestHost]];
            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
            [engine useCache];
            MKNetworkOperation *op = [engine operationWithPath:@"checkshowstatus.php" params:nil httpMethod:@"POST"];
            //操作返回数据
            [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
                NSString *result = op.responseJSON[@"result"];
                NSLog(@"op.responseJSON==%@",op.responseJSON);
                //        NSString* value = op.responseJSON[@"value"];
                int results = [result intValue];
                if(results==0){
                    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，设备上登录信息取得失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }else if(results==1){
                    NSString *cologinflg = op.responseJSON[@"cologinflg"];
                    int cfg = [cologinflg intValue];
                    NSString *registerflg = op.responseJSON[@"registerflg"];
                    int rfg = [registerflg intValue];
                    if(cfg==0&&rfg==0){
                        RootLoginViewController *cloudLogin = [[RootLoginViewController alloc]initWithNibName:@"RootLoginViewController" bundle:nil];
                        [self.navigationController pushViewController:cloudLogin animated:YES];
                    }else if(rfg==1&&cfg==0){
                        NSString *cids = op.responseJSON[@"cid"];
                        NSString *emails = op.responseJSON[@"email"];
                        NSString *efg = op.responseJSON[@"emailflg"];
                        NSLog(@"efg=%@",efg);
                        //                        NSString* cids=@"anni";
                        //                        NSString* emails=@"95132325@qq.com";
                        CloudLoginViewController* clg = [[CloudLoginViewController alloc]initWithNibName:@"CloudLoginViewController" bundle:nil];
                        clg.email = emails;
                        clg.cid = cids;
                        clg.emailflg = efg;
                        [self.navigationController pushViewController:clg animated:YES];
                    }else if(cfg==1&&rfg==0){
                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"你在逗我？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                    }else if(cfg==1&&rfg==1){
                        NSString *cids = op.responseJSON[@"cid"];
                        NSString *emails = op.responseJSON[@"email"];
                        CloudLoginSuccessViewController* clg = [[CloudLoginSuccessViewController alloc]initWithNibName:@"CloudLoginSuccessViewController" bundle:nil];
                        clg.email = emails;
                        clg.cocloudid = cids;
                        [self.navigationController pushViewController:clg animated:YES];
                    }else{
                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"你在逗我？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                    }
                }else{
                    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"未知错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
            }];
            [engine enqueueOperation:op];
            //            RootLoginViewController *cloudLogin = [[RootLoginViewController alloc]
            //                                                         initWithNibName:@"RootLoginViewController" bundle:nil];
            //            [self.navigationController pushViewController:cloudLogin animated:YES];
            //            break;
        }
        default:
            break;
            
            
    }
    
}
#pragma mark -
#pragma mark Arrow Action

- (void)appCellArrow:(AppTableViewCell *)cell actionWithFlag:(NSInteger)flag
{
    [self.viewDeckController openRightView];
}




- (void) homeAction:(UIButton *)sender {
    UIButton *homeButton = (UIButton *)[self.view viewWithTag:100];
    UIButton *egressButton = (UIButton *)[self.view viewWithTag:101];
    UIButton *sleepButton = (UIButton *)[self.view viewWithTag:102];
    [homeButton setImage:[UIImage imageNamed:@"home-down"] forState:(UIControlStateNormal)];
    [egressButton setImage:[UIImage imageNamed:@"egress"] forState:(UIControlStateNormal)];
    [sleepButton setImage:[UIImage imageNamed:@"sleep"] forState:(UIControlStateNormal)];
    [homeButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
    [egressButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sleepButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    // 设置底部滑动条
    CGRect frame = CGRectMake(0, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
    bottomView.frame = frame;
}

- (void) egressAction:(UIButton *)sender {
    UIButton *homeButton = (UIButton *)[self.view viewWithTag:100];
    UIButton *egressButton = (UIButton *)[self.view viewWithTag:101];
    UIButton *sleepButton = (UIButton *)[self.view viewWithTag:102];
    [homeButton setImage:[UIImage imageNamed:@"home"] forState:(UIControlStateNormal)];
    [egressButton setImage:[UIImage imageNamed:@"egress-down"] forState:(UIControlStateNormal)];
    [sleepButton setImage:[UIImage imageNamed:@"sleep"] forState:(UIControlStateNormal)];
    [homeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [egressButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
    [sleepButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    // 设置底部滑动条
    CGRect frame = CGRectMake(kMainScreenWidth / 3, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
    bottomView.frame = frame;
}

- (void) sleepAction:(UIButton *)sender {
    UIButton *homeButton = (UIButton *)[self.view viewWithTag:100];
    UIButton *egressButton = (UIButton *)[self.view viewWithTag:101];
    UIButton *sleepButton = (UIButton *)[self.view viewWithTag:102];
    [homeButton setImage:[UIImage imageNamed:@"home"] forState:(UIControlStateNormal)];
    [egressButton setImage:[UIImage imageNamed:@"egress"] forState:(UIControlStateNormal)];
    [sleepButton setImage:[UIImage imageNamed:@"sleep-down"] forState:(UIControlStateNormal)];
    [homeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [egressButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sleepButton setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
    // 设置底部滑动条
    CGRect frame = CGRectMake(kMainScreenWidth * 2 / 3, kMainScreenHeight - 4, kMainScreenWidth / 3, 4);
    bottomView.frame = frame;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.viewDeckController isSideOpen:IIViewDeckLeftSide])
    {
        
        [self.viewDeckController toggleLeftView];
        return;
    }
    AppTableViewCell *cell =(AppTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[AppTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [self appCell:cell actionWithFlag:cell.actionIndex];
}


- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self.viewDeckController action:@selector(toggleLeftView)];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self.viewDeckController action:@selector(toggleLeftView)];
    [(IIViewDeckController*)self.viewDeckController.leftController closeLeftView];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([self.viewDeckController isSideOpen:IIViewDeckLeftSide])
    {
        CGPoint point = [touch locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if (indexPath!=nil) {
            return YES;
        }
    }else{
        return NO;
    }
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    if([self.viewDeckController isSideOpen:IIViewDeckLeftSide])
    {
        
        [self.viewDeckController toggleLeftView];
    }
    
}
@end
