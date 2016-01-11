//
//  CameraAddViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/10/8.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraAddViewController.h"
#import "DeviceNetworkInterface.h"
#import "CameraAddViewCell.h"
#import "CameraAddManualViewController.h"
#import "CameraListSetSingleViewController.h"
#import "CameraAddAutomaticViewController.h"
#import "MJRefresh.h"


static NSString *CellTableIdentifier = @"CellTableIdentifier";

@interface CameraAddViewController ()
@property UIActivityIndicatorView *activityIndicatorView;

@end

@implementation CameraAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"摄像头";
    
    //2015 12 24 hgc
//    [self webViewDidStartLoad];
    //2015 12 24 hgc
    
// hgc 2015 11 04 start
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
//    CGRect rect = CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 45 - 20 - 40 -10 ,[UIScreen mainScreen].bounds.size.width,45);
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn setFrame:rect];
//    [btn setTitle:@"手动添加摄像头" forState:UIControlStateNormal];
//    btn.backgroundColor = [UIColor whiteColor];
//    [btn setImage:[UIImage imageNamed:@"add-icon"] forState:UIControlStateNormal];
//    [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
//
//    btn.contentEdgeInsets = UIEdgeInsetsMake(0,20, 0, 0);
//    [self.view addSubview:btn];
//    
//    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
// hgc 2015 11 04 end
    
// hgc 2015 11 09 start
    
    CGRect rect = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,45);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //2015 11 04
    btn.frame = rect;
    [btn setTitle:@"手动添加摄像头" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    [btn setImage:[UIImage imageNamed:@"add-icon"] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [btn setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
    [btn setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    //2015 11 04
    
    CGRect rect1=CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 45);
    UIView *view = [[UIView alloc] initWithFrame:rect1];
    [view addSubview:btn];

    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:view];
    UIBarButtonItem *left=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *right=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    [self setToolbarItems:[NSArray arrayWithObjects:left,barButton,right,nil] animated:YES];
  
// hgc 2015 11 09 end

    self.tableView.rowHeight = 112;
    UINib *nib = [UINib nibWithNibName:@"CameraAddViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellTableIdentifier];

    
//edgeinsets
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = 10;
    [self.tableView setContentInset:contentInset];
    
    //
    //下拉刷新 2016 01 11
    [self example01];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //2015 12 24 hgc

    [self.navigationController.toolbar setUserInteractionEnabled:YES];
    
    //
    //getData 2016 01 11
    [self.tableView.mj_header beginRefreshing];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{

    [self.navigationController setToolbarHidden:YES animated:YES];
}


//for 刷新数据时加载动画 add by hgc 2015 10 19 start
//开始加载动画
- (void)webViewDidStartLoad{
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -20.0f, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height)];
//                    [UIScreen mainScreen].applicationFrame];
    [view setTag:104];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view setAlpha:1];
    [self.view addSubview:view];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [self.activityIndicatorView setCenter:view.center];
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicatorView setColor:[UIColor blackColor]];
    [view addSubview:self.activityIndicatorView];
    
    [self.activityIndicatorView startAnimating];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    label.text = @"数据加载中，请等待...";
    [label setCenter:CGPointMake(view.center.x, view.center.y + 40)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:label];
}
//结束加载动画
- (void)webViewDidFinishLoad{
    [self.activityIndicatorView stopAnimating];
    UIView *view = (UIView *)[self.view viewWithTag:104];
    [view removeFromSuperview];
}
//for 刷新数据时加载动画 add by hgc 2015 10 19 end
- (void)startActivityIndicatorView{
//
    self.activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.activityIndicatorView.bounds = [UIScreen mainScreen].bounds;

    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicatorView setBackgroundColor:[UIColor whiteColor]];
    [self.activityIndicatorView setColor:[UIColor blackColor]];
    self.activityIndicatorView.alpha = 1;
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshData {
    NSLog(@"setuprefresss");
    [DeviceNetworkInterface cameraDiscovery:self withBlock:^(NSArray *deviceList, NSError *error) {
        if (!error) {
            _devices = deviceList;
            NSLog(@"self.devices(cameraDiscovery)===%@",self.devices);
            NSLog(@"self.devices.count(cameraDiscovery)===%lu",(unsigned long)_devices.count);
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        else{
             NSLog(@"cameraDiscovery error");
        }
//        [self webViewDidFinishLoad];
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CameraAddViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier
                                                              forIndexPath:indexPath];
    
    NSDictionary *rowData = self.devices[indexPath.row];
// hgc 2015 11 05 start
//    if (
//        ([DeviceNetworkInterface isObjectNULLwith:rowData[@"addition"]])
//     || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"brand"]])
//     || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"model"]])
//     || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"code"]])
//     || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"type"]])
//     || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"version"]])
//     || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"sensitivity"]])
//     || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"wifi"]])
//     || ([DeviceNetworkInterface isObjectNULLwith:rowData[@"flg"]])
//        )
//    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"系统错误" message:@"网络接口出现错误，请停止操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        if (self.navigationController) {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    }else
//    {
//        NSLog(@"check ok.");
//    }
//hgc 2015 11 05 end
    
    cell.labelCameraIP.text =rowData[@"addition"];
    cell.labelCameraName.text=rowData[@"brand"];
    cell.labelCameraType.text=rowData[@"model"];
    cell.brand = rowData[@"brand"];
    cell.model = rowData[@"model"];
    cell.buttonAdd.hidden = YES;
    cell.labelAdded.hidden = NO;
    //deviceinfo
//    cell.deviceInfo = [[DeviceInfo alloc]init];
    cell.deviceInfo.code =rowData[@"code"];
    cell.deviceInfo.type =rowData[@"type"];
    cell.deviceInfo.addition =rowData[@"addition"];
    cell.deviceInfo.brand =rowData[@"brand"];
    cell.deviceInfo.model =rowData[@"model"];
    cell.deviceInfo.version =rowData[@"version"];
    cell.deviceInfo.sensitivity =rowData[@"sensitivity"];
    cell.deviceInfo.wifi =rowData[@"wifi"];

    NSLog(@"cell.deviceInfo=====%@",cell.deviceInfo);
    
    
//honban  20151014hgc
    if ([rowData[@"flg"] isEqualToString:@"0"]) {
        cell.buttonAdd.hidden = NO;
        cell.labelAdded.hidden = YES;
    }

// cell 图片设置 2015 11 04 hgc
//    UIImage *image = [UIImage imageNamed:@"cameraaddtest.jpeg"];
//    cell.image.image = image;
    
    cell.delegate = self;
    NSLog(@"what cellForRowAtIndexPath god !!! ");
    return cell;
}

//按钮位置变化 2015 11 04 hgc start
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSLog(@"viewForFooterInSection");
//    if(section==0){
//        CGRect rect = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,50);
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//        
////        btn.backgroundColor   = [UIColor clearColor];
////        [btn setTitle:@"手动添加摄像头" forState:UIControlStateNormal];
////        [btn setImage:[UIImage imageNamed:@"status_wait_big.png"] forState:UIControlStateNormal];
////        
//        //2015 11 04
//        btn.frame = rect;
//        [btn setTitle:@"手动添加摄像头" forState:UIControlStateNormal];
//        btn.backgroundColor = [UIColor whiteColor];
//        [btn setImage:[UIImage imageNamed:@"add-icon"] forState:UIControlStateNormal];
//        [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
//        //2015 11 04
//        
//        CGRect rect1=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50);
//        UIView *view = [[UIView alloc] initWithFrame:rect1];
//        [view addSubview:btn];
//        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
//
//        NSLog(@"sections====%ld",(long)section);
//        return view;
//    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
//按钮位置变化 2015 11 04 hgc end

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// 2015 10 14 hgc 不能点击单元格，故注释
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here, for example:
//    // Create the next view controller.
//    
//    NSDictionary *rowData = self.devices[indexPath.row];
//    
//    CameraListSetSingleViewController *cameraListSetSingleVC = [[CameraListSetSingleViewController alloc]initWithNibName:@"CameraListSetSingleViewController" bundle:nil];
//    [self.navigationController pushViewController:cameraListSetSingleVC animated:YES];
//    
////    cameraListSetSingleVC.deviceID = rowData[@"devid"];
//    cameraListSetSingleVC.flg = rowData[@"flg"];
//    
//    if ([rowData[@"flg"] isEqualToString:@"0"]) {
//        //调用摄像头自动添加接口，设置flg为1；
//    }
//    NSLog(@"去往camera独立设置页");
//}


// 2015 10 14 hgc delegate
- (void)chooseAppAction:(UIButton *)sender
{
    CameraAddAutomaticViewController *cameraAddAutomaticVC = [[CameraAddAutomaticViewController alloc]initWithNibName:@"CameraAddAutomaticViewController" bundle:nil];

    UIView* pview = sender.superview.superview;
//    NSLog(@"sender.superview.superview.class=====%@",sender.superview.superview.class);
    CameraAddViewCell *pcell = pview;

    
    // hgc 2015 11 18 start
        if (
            ([DeviceNetworkInterface isObjectNULLwith:pcell.brand])
         || ([DeviceNetworkInterface isObjectNULLwith:pcell.model])
         || ([DeviceNetworkInterface isObjectNULLwith:pcell.deviceInfo.brand])
         || ([DeviceNetworkInterface isObjectNULLwith:pcell.deviceInfo.addition])
         || ([DeviceNetworkInterface isObjectNULLwith:pcell.deviceInfo.model])
         || ([DeviceNetworkInterface isObjectNULLwith:pcell.deviceInfo.version])
         || ([DeviceNetworkInterface isObjectNULLwith:pcell.deviceInfo.sensitivity])
            )
        {
            NSLog(@"系统错误happen");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"系统错误" message:@"网络接口出现错误，请停止操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }else
        {
            NSLog(@"check ok.");
        }
    //hgc 2015 11 18 end
    
    //传递设备信息
    cameraAddAutomaticVC.brand = pcell.brand;
    cameraAddAutomaticVC.model = pcell.model;
    cameraAddAutomaticVC.deviceInfo = pcell.deviceInfo;
    
    NSLog(@"去往camera自动添加页");
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController pushViewController:cameraAddAutomaticVC animated:YES];
    
    
}

- (void)buttonPressed:(id)sender
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    CameraAddManualViewController *cameraAddManualVC = [[CameraAddManualViewController alloc]initWithNibName:@"CameraAddManualViewController" bundle:nil];
    [self.navigationController pushViewController:cameraAddManualVC animated:YES];
}

#pragma mark UITableView + 下拉刷新 默认
- (void)example01
{
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshData];
        //        NSLog(@"refresh data11111");
    }];
    self.tableView.mj_header.ignoredScrollViewContentInsetTop = 10.0;
    
    // 马上进入刷新状态
//    [self.tableView.mj_header beginRefreshing];
}


@end
