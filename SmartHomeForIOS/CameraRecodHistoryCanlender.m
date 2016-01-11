//
//  CameraRecodHistoryCanlender.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/10/21.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CameraRecodHistoryCanlender.h"
#import "CameraRecordHistoryViewController.h"
#import "DeviceNetworkInterface.h"


@interface CameraRecodHistoryCanlender ()

@property (strong,nonatomic)NSArray *eventDate;

@end

@implementation CameraRecodHistoryCanlender



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"日期选择";
// 2015 11 03 hgc start
    //navigatison Left按钮
// 2015 11 04 hgc 左侧按钮使用系统自带样式 start  1
//    UIBarButtonItem *leftBTN = [[UIBarButtonItem alloc]
//                                initWithImage:[UIImage imageNamed:@"back"]
//                                style:UIBarButtonItemStylePlain
//                                target:self
//                                action:@selector(canlenderCancel)];
//    self.navigationItem.leftBarButtonItem = leftBTN;
    
// 2015 11 04 hgc 左侧按钮使用系统自带样式 use title hgc 2
//    UIBarButtonItem *leftBTN = [[UIBarButtonItem alloc]
//                                initWithTitle:@"摄像头"
//                                style:UIBarButtonItemStylePlain
//                                target:self
//                                action:@selector(canlenderCancel)];
//    self.navigationItem.leftBarButtonItem = leftBTN;

// 2015 11 04 hgc 左侧按钮使用系统自带样式  3
//    UIButton *back = [UIButton buttonWithType:101];
//    [back addTarget:self action:@selector(canlenderCancel) forControlEvents:UIControlEventTouchUpInside];
//    [back setTitle:@"摄像头" forState:UIControlStateNormal];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:back];
//
//    self.navigationItem.leftBarButtonItem = backItem;
    
// 2015 11 04 hgc 左侧按钮使用系统自带样式 end
// 2015 11 03 hgc end

    
    
    self.eventDate = [[NSArray alloc]init];
    [self getEventDate];
    
    
    self.calendar = [JTCalendar new];
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
        self.calendar.calendarAppearance.ratioContentMenu = 1.;
    }
    
    NSLog(@"_inputDate====%@",_inputDate);
    NSLog(@"_outputDate====%@",_outputDate);
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
    
    //2016 01 09
    [self.calendar.menuMonthsView setHidden:YES];
    [self.calendar.contentView setHidden:YES];
}

- (void)canlenderCancel{
    
    [self.calendarMenuView removeFromSuperview];
    [self.calendarContentView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)viewWillDisappear:(BOOL)animated{
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self.calendarMenuView removeFromSuperview];
        [self.calendarContentView removeFromSuperview];
    }
    [super viewWillDisappear:animated];
//hgc
//    [self.calendarMenuView removeFromSuperview];
//    [self.calendarContentView removeFromSuperview];
//hgc
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //2016 01 09
    [self.calendar.menuMonthsView setHidden:NO];
    [self.calendar.contentView setHidden:NO];
    
// 2015 11 03 hgc start
//    self.eventDate = [[NSArray alloc]init];
//    [self getEventDate];
//    
//    
//    self.calendar = [JTCalendar new];
//    
//    {
//        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
//        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
//        self.calendar.calendarAppearance.ratioContentMenu = 1.;
//    }
//    
//    NSLog(@"_inputDate====%@",_inputDate);
//    NSLog(@"_outputDate====%@",_outputDate);
//    
//    [self.calendar setMenuMonthsView:self.calendarMenuView];
//    [self.calendar setContentView:self.calendarContentView];
//    [self.calendar setDataSource:self];
// 2015 11 03 hgc end
    
    [self.calendar reloadData]; // Must be call in viewDidAppear

}
//取得事件日期
- (void)getEventDate{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMM"];
    NSString *strDate = [df stringFromDate:_inputDate];
    
    [DeviceNetworkInterface getCameraRecordHistoryDatesWithDeviceId:_deviceID andDay:strDate withBlock:^(NSString *result, NSString *message, NSArray *times, NSError *error) {
        if (!error) {
            NSLog(@"result===%@",result);
            NSLog(@"mseeage===%@",message);
            NSLog(@"calendar===%@",times);
            if ([result isEqualToString:@"success"]) {
                self.eventDate = times;
            }
        }
        else{
            NSLog(@"cameraControlWithDirection error");
        }
    }];
}
//取得事件日期 by date
- (void)getEventDateWithDate:(NSDate*)date {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMM"];
    NSString *strDate = [df stringFromDate:date];
    
    [DeviceNetworkInterface getCameraRecordHistoryDatesWithDeviceId:_deviceID andDay:strDate withBlock:^(NSString *result, NSString *message, NSArray *times, NSError *error) {
        if (!error) {
            NSLog(@"result===%@",result);
            NSLog(@"mseeage===%@",message);
            NSLog(@"calendar===%@",times);
            if ([result isEqualToString:@"success"]) {
                self.eventDate = times;
                [self.calendar reloadData];
                [self.calendar reloadAppearance];
            }
        }
        else{
            NSLog(@"cameraControlWithDirection error");
        }
    }];
}


#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
    [self.calendar setCurrentDate:[NSDate date]];
}

- (IBAction)didChangeModeTouch
{
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    
    [self transitionExample];
}
- (IBAction)buttonCancelPressed:(id)sender {
    _outputDate = _inputDate;
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)buttonCommitPressed:(UIButton *)sender {
    if (_outputDate == NULL) {
        _outputDate = _inputDate;
    }
    // 2015 10 23 hgc
//    [self.view removeFromSuperview];
    [self.calendarMenuView removeFromSuperview];
    [self.calendarContentView removeFromSuperview];
    // 2015 10 23 hgc
    //superVC
    NSArray *ctrlArray = self.navigationController.viewControllers;
    for (UIViewController *ctrl in ctrlArray){
        if ([ctrl isKindOfClass:[CameraRecordHistoryViewController class]])
        {
            CameraRecordHistoryViewController *superVC = ctrl;
//            superVC.deviceID = self.deviceID;
            superVC.titleDate = self.outputDate;
            [self.navigationController popToViewController:superVC animated:YES];
        }
        NSLog(@"ctrl ---- %@", ctrl);
    }
//    [self.navigationController popToViewController:superVC animated:YES];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
//    NSLog(@"calendarHaveEventdate------%@",date);
//    NSLog(@"calendarHaveEvent------%d",rand() % 10);
//    return (rand() % 10) == 1;
// for test hgc
//    NSArray *array = @[@"2015-10-09",
//                       @"2015-10-11",
//                       @"2015-10-18",
//                       @"2015-10-20"
//                       ];
    NSArray *array = self.eventDate;
    
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *date = [dateFormatter dateFromString:@"2010-08-04 16:01:03"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    for (int i = 0 ; i < array.count; i++) {
        if ([date isEqualToDate:[dateFormatter dateFromString:array[i]]]) {
            NSLog(@"calendarHaveEventdate------%@",date);
            NSLog(@"self.eventDate====%@",self.eventDate);
            return YES;
        }
    }
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    
    NSArray *array = self.eventDate;
// 2015 11 04 hgc start
    Boolean haveEvent = FALSE;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    for (int i = 0 ; i < array.count; i++) {
        if ([date isEqualToDate:[dateFormatter dateFromString:array[i]]]) {
            NSLog(@"calendarHaveEventdate------%@",date);
            NSLog(@"self.eventDate====%@",self.eventDate);
            haveEvent = TRUE;
            break;
        }
    }
    
    if (haveEvent == FALSE) {
        NSLog(@"您所选择的时间没有历史录像");
//2015 11 05 hgc start
//        UIAlertView *alert =[[UIAlertView alloc]
//         initWithTitle:@"历史录像"
//         message:@"您所选择的时间没有历史录像"
//         delegate:self
//         cancelButtonTitle:@"OK"
//         otherButtonTitles:nil];
//        
//        [alert show];
//2015 11 05 hgc end
    }else{
// 2015 11 04 hgc end
        
    NSLog(@"Date: %@", date);
    _outputDate = date;
    
    //added 2015 11 02 hgc start
    if (_outputDate == NULL) {
        _outputDate = _inputDate;
    }
    // 2015 10 23 hgc
//    [self.calendarMenuView removeFromSuperview];
//    [self.calendarContentView removeFromSuperview];
    // 2015 10 23 hgc
    
    //superVC
    /* 2015 11 03 hgc
    NSArray *ctrlArray = self.navigationController.viewControllers;
    for (UIViewController *ctrl in ctrlArray){
        if ([ctrl isKindOfClass:[CameraRecordHistoryViewController class]])
        {
            CameraRecordHistoryViewController *superVC = ctrl;
            //            superVC.deviceID = self.deviceID;
            superVC.titleDate = self.outputDate;
            [self.navigationController popToViewController:superVC animated:YES];
        }
        NSLog(@"ctrl ---- %@", ctrl);
    }
    */ //2015 11 03 hgc
    
    // hgc 2015 11 03 start
    CameraRecordHistoryViewController *cameraRecordHistoryViewController =
    [[CameraRecordHistoryViewController alloc]initWithNibName:@"CameraRecordHistoryViewController" bundle:nil];
    [self.navigationController pushViewController:cameraRecordHistoryViewController animated:YES];
    cameraRecordHistoryViewController.deviceID = _deviceID;
    cameraRecordHistoryViewController.titleDate = _outputDate;
    
    NSLog(@"去往camera history");
    // hgc 2015 11 03 end

    //    [self.navigationController popToViewController:superVC animated:YES];
    //added 2015 11 02 hgc end
        
    }
}

#pragma mark - Transition examples

- (void)transitionExample
{
    CGFloat newHeight = 300;
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 75.;
    }
    
    [UIView animateWithDuration:.5
                     animations:^{
                         self.calendarContentViewHeight.constant = newHeight;
                         [self.view layoutIfNeeded];
                     }];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         self.calendarContentView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.calendar reloadAppearance];
                         
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.calendarContentView.layer.opacity = 1;
                                          }];
                     }];
}
// delegate
- (void)canlendarDateWhenCanlendarScrolled:(JTCalendar *)canlendar date:(NSDate *)date{
    NSLog(@"date==%@",date);
    [self getEventDateWithDate:date];
    
}


@end
