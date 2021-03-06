//
//  AlarmMessageListViewController.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "AlarmMessageListViewController.h"
#import "AlarmMessageListCell.h"
#import "AlarmMessageDetailViewController.h"
#import "DeviceNetworkInterface.h"
#import "MJRefresh.h"

static NSString *AlarmMessageCellIdentifier = @"AlarmMessageCellIdentifier";
static NSString *NumOfAlarmList = @"10";

@interface AlarmMessageListViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIToolbar *myToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *allSelectedBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *allReadedBtn;
@property Boolean isTableViewEdit;
@property Boolean isTableViewAllSelected;
@property NSArray *sections;
@property NSMutableDictionary *rowsForSection;
@property NSMutableArray *alarmList;
@end

@implementation AlarmMessageListViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"AlarmMessageListViewControllerAlarmMessageListViewController");
    // Do any additional setup after loading the view from its nib.
    self.sections = @[@"1"];
//    self.rowsForSection = [[NSMutableDictionary alloc]init];
//    self.rowsForSection = @{@"1":@[@"10",@"11",@"12",@"10",@"11",@"12",@"10",@"11",@"12"],
//                            @"2":@[@"20",@"21",@"22",@"20",@"21",@"22",@"20",@"21",@"22"],
//                            @"3":@[@"30",@"31",@"32",@"30",@"31",@"32"]
//                            };
    
    //
    self.navigationItem.title = @"消息";

    UIBarButtonItem *rightBTN = [[UIBarButtonItem alloc]
                                 initWithTitle:@"编辑"
                                 //                                initWithImage:[UIImage imageNamed:@"history-bj"]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(editTableCell)];
    self.navigationItem.rightBarButtonItem = rightBTN;
//    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];

    // 设置myToolBar上的字体颜色
    [self.allSelectedBtn setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    [self.deleteBtn setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    [self.allReadedBtn setTintColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]];
    
    //2016 01 09 start
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.0/255 green:153.0/255 blue:255.0/255 alpha:1]];
    //2016 01 09 end
    
    
    //下拉刷新
    [self example01];
    //上拉刷新
    [self example11];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    [self.myToolBar setHidden:YES];
    [self.myToolBar setAlpha:0.0f];
    //
    [self.myToolBar setFrame:CGRectMake(self.myToolBar.frame.origin.x, self.myToolBar.frame.origin.y, self.myToolBar.frame.size.width, 100)];
    //
    self.isTableViewAllSelected = NO;
    self.isTableViewEdit = NO;
    self.isTableViewEdit = NO;
    //
    self.tableView = (id)[self.view viewWithTag:3001];
    UINib *nib = [UINib nibWithNibName:@"AlarmMessageListCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:AlarmMessageCellIdentifier];
    
    //2016 01 12
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = 10;
    [self.tableView setContentInset:contentInset];
    
    //
    
    self.tableView.rowHeight = 90;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    //
    [self refreshData];
    
}

- (void)refreshData
{
    NSLog(@"refreshData");
    NSString *msgId = @"0";
    NSString *msgCnt = NumOfAlarmList;
    
    [DeviceNetworkInterface getAlarmListWithMsgId:msgId andMsgCnt:msgCnt withBlock:^(NSString *result, NSString *message, NSArray *alarms, NSError *error) {
        if (!error) {
            NSLog(@"self.rowsForSection==%@",self.rowsForSection);
            self.rowsForSection = [[NSMutableDictionary alloc]init];
            [self.rowsForSection setValue:alarms forKey:@"1"];
            self.alarmList = [[NSMutableArray alloc]init];
            [self.alarmList addObjectsFromArray:alarms];
            NSLog(@"self.rowsForSection==%@",self.rowsForSection);
            NSLog(@"self.devices(cameraDiscovery)===%@",message);
            NSLog(@"self.devices.count(cameraDiscovery)===%@",result);
//            NSLog(@"self.devices.count(cameraDiscovery)===%@",alarms);
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        else{
            NSLog(@"cameraDiscovery error");
        }
    }];
    //
    [self.tableView.mj_header endRefreshing];
}

- (void)loadMoreData
{
    NSLog(@"refreshData");
    NSString *newestMsgId =self.alarmList.lastObject[@"msgid"];
    NSLog(@"newestMsgId===%@",newestMsgId);
    
//    NSString *msgId = @"0";
    NSString *msgCnt = NumOfAlarmList;
    
    [DeviceNetworkInterface getAlarmListWithMsgId:newestMsgId andMsgCnt:msgCnt withBlock:^(NSString *result, NSString *message, NSArray *alarms, NSError *error) {
        if (!error) {
            
            NSLog(@"self.devices(cameraDiscovery)===%@",message);
            NSLog(@"self.devices.count(cameraDiscovery)===%@",result);
            NSLog(@"self.devices.count(cameraDiscovery)===%@",alarms);
            
//            self.rowsForSection = [[NSMutableDictionary alloc]init];
//            [self.rowsForSection setValue:alarms forKey:@"1"];
            [self.alarmList addObjectsFromArray:alarms];
            [self sortedByMegId:self.alarmList];
            
            [self.rowsForSection setValue:self.alarmList forKey:@"1"];
            
            NSLog(@"self.rowsForSection==1213%@",self.alarmList);
            NSLog(@"self.rowsForSection==1314%@",self.rowsForSection);
            
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        else{
            NSLog(@"cameraDiscovery error");
        }
    }];

    // 拿到当前的上拉刷新控件，结束刷新状态
    [self.tableView.mj_footer endRefreshing];
    
}

- (NSMutableArray *)sortedByMegId:(NSMutableArray *)array{
    //
    NSSortDescriptor *megIdDesc = [NSSortDescriptor sortDescriptorWithKey:@"msgid" ascending:NO];
    NSArray *descs = [NSArray arrayWithObjects:megIdDesc,nil];
    [array sortUsingDescriptors:descs];
    return array;
}

- (void)editTableCell{
    NSLog(@"editing");
    if (self.isTableViewEdit) {
        self.isTableViewEdit = NO;
        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
        //
        [self.tableView setEditing:NO animated:YES];
        //
        [UIView animateWithDuration:0.3f animations:^{
            [self.myToolBar setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.myToolBar setHidden:YES];
            self.isTableViewAllSelected = NO;
            [self.allSelectedBtn setTitle:@"全选"];
        }];
    }else{
        self.isTableViewEdit = YES;
        [self.navigationItem.rightBarButtonItem setTitle:@"取消"];
        //
        [self.tableView setEditing:YES animated:YES];
        
        //
        [UIView animateWithDuration:0.3f animations:^{
            [self.myToolBar setHidden:NO];
            [self.myToolBar setAlpha:0.8f];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    for (NSString *str in self.sections) {
//        NSLog(@"str==%@",str);
//    }
    NSString *key = self.sections[section];
    NSLog(@"key == %@",key);
    NSArray *array = [self.rowsForSection objectForKey:key];
    NSLog(@"array.count===%lu",(unsigned long)array.count);
    return array.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"self.sections.count===%lu",(unsigned long)self.sections.count);
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlarmMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:AlarmMessageCellIdentifier forIndexPath:indexPath];
//    AlarmMessageListCell *cell = [[AlarmMessageListCell alloc]init];
//    if (indexPath.row < 4) {
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//    } else {
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
    
//    NSLog(@"sdfsdf==%@",[self.rowsForSection objectForKey:self.sections[indexPath.section]][indexPath.row]);
    
    NSDictionary *rowData =[self.rowsForSection objectForKey:self.sections[indexPath.section]][indexPath.row];
    cell.labelTitle.text = rowData[@"type"];
    cell.labelSubTitle.text = rowData[@"devname"];
//    cell.labelTime.text = rowData[@"datetime"];
    
    //datetime start 2015 11 30
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *testDate = [dateFormatter dateFromString:rowData[@"datetime"]];
    //
    NSString *string = rowData[@"datetime"];
    if ([testDate isEqualToDate:[NSDate date]]) {
        string = [string stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        string = [string substringFromIndex:11];
        NSLog(@"string===%@",string);
    }else{
        string = [string stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        string = [string substringFromIndex:5];
        NSLog(@"string===%@",string);
    }
    cell.labelTime.text = string;
    //datetime end 2015 11 30
    
    [cell.imageSnapshot setImage:[self getImageFromURL:rowData[@"snapshotUrl"]]];
    //
    if ([rowData[@"readonly"] isEqualToString:@"1"]) {
        [cell.imagePoint setHidden:YES];
    }else{
        [cell.imagePoint setHidden:NO];
    }
    
    return cell;
//    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"push to AlarmMessageDetailViewController");
    if (self.isTableViewEdit) {
        
    }else{
        // 点击时设置已读
        NSMutableArray *array = [[NSMutableArray alloc]init];
        [array addObject:self.alarmList[indexPath.row][@"msgid"]];
        
        [DeviceNetworkInterface setAlarmMsgReadedWithMsgIds:array withBlock:^(NSString *result, NSString *message, NSError *error) {
            if (!error) {
                if ([result isEqualToString:@"success"]) {
                    NSLog(@"success");
                    //
                    //已读标志隐藏  2015 11 26
                    AlarmMessageListCell *cell =  [self.tableView cellForRowAtIndexPath:indexPath];
                    [cell.imagePoint setHidden:YES];
                    //
                    //跳转到详情页面 hgc 2015 11 03
                    AlarmMessageDetailViewController *alarmMessageDetailViewController =
                    [[AlarmMessageDetailViewController alloc]initWithNibName:@"AlarmMessageDetailViewController" bundle:nil];
                    
                    [self.navigationController pushViewController:alarmMessageDetailViewController animated:YES];
                    alarmMessageDetailViewController.messageID = [self.rowsForSection objectForKey:self.sections[indexPath.section]][indexPath.row][@"msgid"];
                    NSLog(@"alarmMessageDetailViewController.messageID==%@",alarmMessageDetailViewController.messageID);
                    //
                    alarmMessageDetailViewController.rowData = [self.rowsForSection objectForKey:self.sections[indexPath.section]][indexPath.row];
                }else{
                    NSLog(@"false");
                }
            }
            else{
                NSLog(@"cameraDiscovery error");
            }
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row < 4) {
//        return YES;
//    } else {
//        return NO;
//    }
    return YES;
}

//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return self.sections;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    return self.sections[section];
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (IBAction)barButtonDelPressed:(UIBarButtonItem *)sender {
    NSLog(@"del.....");
    NSIndexPath *indexPath;
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (indexPath in [self.tableView indexPathsForSelectedRows]) {
        NSLog(@"indexPath====%ld===%ld",(long)indexPath.row,(long)indexPath.section);
        NSLog(@"msgid del == %@",self.alarmList[indexPath.row][@"msgid"]);
        [array addObject:self.alarmList[indexPath.row][@"msgid"]];
    }
    NSLog(@"del array==%@",array);
    [DeviceNetworkInterface delAlarmMsgWithMsgIds:array withBlock:^(NSString *result, NSString *message, NSError *error) {
        if (!error) {
            if ([result isEqualToString:@"success"]) {
                NSLog(@"success");
                //tableview delete
                
                [self refreshData];
                
                //for data
//                for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
//
//                    [self.alarmList removeObjectAtIndex:indexPath.row];
//                }
//                [self.rowsForSection setValue:self.alarmList forKey:@"1"];
                //for UI
//                [self.tableView deleteRowsAtIndexPaths:[self.tableView indexPathsForSelectedRows] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                NSLog(@"false");
            }
        }
        else{
            NSLog(@"delAlarmMsgWithMsgIds error");
        }
    }];
}
- (IBAction)barButtonReadPressed:(id)sender {
    
    NSLog(@"read......");
    NSIndexPath *indexPath;
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (indexPath in [self.tableView indexPathsForSelectedRows]) {
//        NSLog(@"indexPath====%ld===%ld",(long)indexPath.row,(long)indexPath.section);
        NSLog(@"msgid del == %@",self.alarmList[indexPath.row][@"msgid"]);
        [array addObject:self.alarmList[indexPath.row][@"msgid"]];
    }
    
    NSLog(@"read array==%@",array);
    [DeviceNetworkInterface setAlarmMsgReadedWithMsgIds:array withBlock:^(NSString *result, NSString *message, NSError *error) {
        if (!error) {
            if ([result isEqualToString:@"success"]) {
                NSLog(@"success");
                NSIndexPath *indexPath;
                for (indexPath in [self.tableView indexPathsForSelectedRows]) {
                    //已读标志隐藏
                    AlarmMessageListCell *cell =  [self.tableView cellForRowAtIndexPath:indexPath];
                    [cell.imagePoint setHidden:YES];
                }
            }else{
                NSLog(@"false");
            }
        }
        else{
            NSLog(@"cameraDiscovery error");
        }
    }];

}

- (IBAction)barButtonAllSelectedPressed:(UIBarButtonItem *)sender {
    
    NSIndexPath *indexPath;
    if (self.isTableViewAllSelected) {
        //取消全选
        self.isTableViewAllSelected = !self.isTableViewAllSelected;
        [sender setTitle:@"全选"];
        for (int i = 0; i< self.tableView.numberOfSections; i++) {
            NSLog(@"section===%d",i);
            NSLog(@"rows==%ld",(long)[self.tableView numberOfRowsInSection:i]);
            for (int j = 0 ; j < [self.tableView numberOfRowsInSection:i]; j++) {
                NSLog(@"row==%d",j);
                indexPath = [NSIndexPath indexPathForRow:j inSection:i];
//                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }else{
        //全选
        self.isTableViewAllSelected = !self.isTableViewAllSelected;
        [sender setTitle:@"取消"];
        for (int i = 0; i< self.tableView.numberOfSections; i++) {
            NSLog(@"section===%d",i);
            NSLog(@"rows==%ld",(long)[self.tableView numberOfRowsInSection:i]);
            for (int j = 0 ; j < [self.tableView numberOfRowsInSection:i]; j++) {
                NSLog(@"row==%d",j);
                indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    NSLog(@"over");
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    NSLog(@"执行图片下载函数");
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];

    // hgc add debug
    //    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    //    NSString *documentsDirectory=[paths objectAtIndex:0];
    //    NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:@"saveFore.jpg"];
    //    NSLog(@"savedImagePath==%@",savedImagePath);
    //    [data writeToFile:savedImagePath atomically:YES];
    // hgc add
    
    result = [UIImage imageWithData:data];
    
    UIImage *placeholder = [UIImage imageNamed:@"video_icon"];
    if ([DeviceNetworkInterface isObjectNULLwith:result]) {
        result =  placeholder;
    }
    
    return result;
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
    self.tableView.mj_header.ignoredScrollViewContentInsetTop = 12.0f;
    
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}
#pragma mark UITableView + 上拉刷新 默认
- (void)example11
{
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
//        NSLog(@"more data11111");
    }];
}
@end
