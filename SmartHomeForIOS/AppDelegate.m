//
//  AppDelegate.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/8/21.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "AppInfo.h"
#import "UserEditViewController.h"
#import "RequestConstant.h"
#import "FileTools.h"
#import <AVOSCloud/AVOSCloud.h>
#import "AlarmMessagePopUpViewController.h"
#import "AlarmMessageListViewController.h"
#import "DeviceNetworkInterface.h"

#import "TaskInfo.h"
#import "ProgressBarViewController.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "NSUUIDTool.h"
#import "FileHandler.h"

#import "FunctionManageTools.h"
#import "NSOperationDownloadQueue.h"
#import <CoreLocation/CoreLocation.h>
@interface AppDelegate ()

@property (strong,nonatomic)UIView *popUpView;
@property (assign,nonatomic)BOOL flag;
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;

@property (strong, nonatomic) dispatch_block_t expirationHandler;
@property (assign, nonatomic) BOOL jobExpired;
@property (assign, nonatomic) BOOL background;
@end

@implementation AppDelegate
CLLocationManager * locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginView.isShowLocalFileBtn = YES;
    loginView.isPushHomeView = YES;
    [self.window setRootViewController:loginView]; //显示登陆
    [self.window makeKeyAndVisible];
    
    [self loadData];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:kDocument_Folder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:kDocument_Folder withIntermediateDirectories:YES attributes:nil error:nil];
            _selectedAppArray = [NSMutableArray arrayWithCapacity:10];
            [_selectedAppArray addObject:_appArray[0]]; //默认为用户添加前三个 app
            [_selectedAppArray addObject :_appArray[1]];
            [_selectedAppArray addObject :_appArray[2]];
            [_selectedAppArray addObject :_appArray[5]];
            [FunctionManageTools saveSelectedApp];
        }
    }else{
        NSLog(@"不是第一次启动");
        _selectedAppArray = [NSMutableArray arrayWithCapacity:10];
        _selectedAppArray =[FunctionManageTools readSavedApp];
    }
    
    NSString *documentsDirectory = [FileTools getUserDataFilePath];
    NSString *userListPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:userListPath];
    NSMutableArray *savedUserInfoArray = [dictionary objectForKey:@"UserInfo"];
    
    if(savedUserInfoArray.count !=0){
        loginView.checkBox.selected=YES;
        [loginView loginAction:nil];
    }
    
    //2015 11 16 hgc add
    //如果使用美国站点，请加上这行代码 [AVOSCloud useAVCloudUS];
    [AVOSCloud setApplicationId:@"r8Vno4kQ9DFIfmhmgbUx7hah"
                      clientKey:@"iXYzLJnCYWAIHnwOoHeIbMmJ"];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                UIUserNotificationTypeAlert|
                                                UIUserNotificationTypeBadge|
                                                UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        NSLog(@"ios888");
        
    } else{ // ios7
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
        NSLog(@"ios777");
    }
     //2015 11 16 hgc end
    
    return YES;
}
// 2015 11 16 RemoteNotice start
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    //20160106 start
    [currentInstallation setChannels:[NSArray arrayWithObjects:@"123",nil]];
    //20160106 end
    NSLog(@"---Token--%@", deviceToken);
    
    //发送消息到刚才订阅的"Giants"频道
    //    AVPush *push = [[AVPush alloc] init];
    //    [push setChannel:@"Giants"];
    //    [push setMessage:@"The Giants just scored!"];
    //    [push sendPushInBackground];
    //
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive) {
        //
        NSLog(@"active");
        
        //2015 12 03 start
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 8.0) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
        
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setBadge:0];
        [currentInstallation saveEventually];
        application.applicationIconBadgeNumber = 0;
        
        NSLog(@"application.applicationIconBadgeNumber==%ld",(long)application.applicationIconBadgeNumber);
        //2015 12 03 end
        
        [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        // 此处可以写上应用激活状态下接收到通知的处理代码，如无需处理可忽略
        
        //2015 11 26 hgc
        //推送给本地通知
        [self pushLocalNotificationWithUserInfo:userInfo];
        
        NSLog(@"UIApplicationStateActive");
        
    } else if(application.applicationState == UIApplicationStateInactive){
        //
        NSLog(@"inactive");
        //
        [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        
        NSLog(@"userInfo not active== %@",userInfo);
        //
        
        //2015 12 03 start
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 8.0) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
        
        application.applicationIconBadgeNumber++;
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setBadge:application.applicationIconBadgeNumber];
        [currentInstallation saveEventually];
        NSLog(@"application.applicationIconBadgeNumber==%ld",(long)application.applicationIconBadgeNumber);
        //2015 12 03 end
        //给homeViewcontroller推送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PUSHTOALARMDETAIL" object:userInfo];
    }
    
    //    NSString *message = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    //
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //
    //    [alert show];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"Regist fail%@",error);
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //
    NSLog(@"Application did receive local notifications");
    //
    NSLog(@"notification===%@",notification);
    NSLog(@"notification.userinfo===%@",notification.userInfo);
    //
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"PUSHCONTENT" object:@"ddd"];
    //popUpView
    if (self.popUpView != NULL) {
        NSLog(@"start");
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
            //
            [self.popUpView setAlpha:0.0];
            self.popUpView.frame = CGRectMake(0.0f, -120.0f, self.window.frame.size.width, 120.0f);
        } completion:^(BOOL finished) {
            //            [self.popUpView removeFromSuperview];
        }];
        self.popUpView = NULL;
    }
    //new popUpView
    self.popUpView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, -120.0f, self.window.frame.size.width, 120.0f)];
    self.popUpView.alpha = 0.3f;
    self.popUpView.backgroundColor = [UIColor redColor];
    [self.window addSubview:self.popUpView];
    
    //AlarmMessagePopUpViewController
    AlarmMessagePopUpViewController *alarmMessagePopUpViewController = [[AlarmMessagePopUpViewController alloc]initWithNibName:@"AlarmMessagePopUpViewController" bundle:nil];
    alarmMessagePopUpViewController.view.frame = CGRectMake(0.0f, 0.0f, self.popUpView.frame.size.width, self.popUpView.frame.size.height);
    [self.popUpView setUserInteractionEnabled:YES];
    [alarmMessagePopUpViewController.view setUserInteractionEnabled:YES];
    [self.popUpView addSubview:alarmMessagePopUpViewController.view];
    [self.window.rootViewController addChildViewController:alarmMessagePopUpViewController];
    
    //imageView
    if (![DeviceNetworkInterface isObjectNULLwith:notification.userInfo[@"snapshot"]]) {
        alarmMessagePopUpViewController.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:notification.userInfo[@"snapshot"]]]];
    }else{
        alarmMessagePopUpViewController.imageView.image = [UIImage imageNamed:@"camera"];
    }
    //labelTitle
    if (![DeviceNetworkInterface isObjectNULLwith:notification.userInfo[@"type"]]) {
        alarmMessagePopUpViewController.labelTitle.text = notification.userInfo[@"type"];
    }
    //labelFrom
    //    alarmMessagePopUpViewController.labelFrom.text = @"for Test";
    if (![DeviceNetworkInterface isObjectNULLwith:notification.userInfo[@"devname"]]) {
        alarmMessagePopUpViewController.labelFrom.text = [NSString stringWithFormat:@"来自%@",notification.userInfo[@"devname"]];
    }
    
    //labelTime
    if (![DeviceNetworkInterface isObjectNULLwith:notification.userInfo[@"datetime"]]) {
        alarmMessagePopUpViewController.labelDate.text = notification.userInfo[@"datetime"];
    }
    
    //buttonGoto
    if (![DeviceNetworkInterface isObjectNULLwith:notification.userInfo[@"unreadnum"]]) {
        [alarmMessagePopUpViewController.buttonGoto setTitle:notification.userInfo[@"unreadnum"] forState:UIControlStateNormal];
    }
    
    //action
    [alarmMessagePopUpViewController.buttonGoto addTarget:self action:@selector(gotoAlarmList) forControlEvents:UIControlEventTouchUpInside];
    [alarmMessagePopUpViewController.buttonGoto2 addTarget:self action:@selector(gotoAlarmList) forControlEvents:UIControlEventTouchUpInside];
    //buttonClose
    [alarmMessagePopUpViewController.buttonClose addTarget:self action:@selector(localNotiClose) forControlEvents:UIControlEventTouchUpInside];
    //topview bottomview
    UITapGestureRecognizer *topViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoAlarmList)];
    [alarmMessagePopUpViewController.viewTopSide addGestureRecognizer:topViewGesture];
    
    //subView
    [self.window addSubview:self.popUpView];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        self.popUpView.frame = CGRectMake(0.0f, 20.0f, self.window.frame.size.width, 120.0f);
        self.popUpView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"pop Up");
            if (self.popUpView != NULL ) {
                NSLog(@"not null");
                [self performSelector:@selector(removePopView) withObject:nil afterDelay:3.0f];
            }
        }
    }];
    //
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"welcome" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert setBackgroundColor:[UIColor clearColor]];
    //    [alert show];
    
}
- (void)localNotiClose{
    NSLog(@"localNotiClose");
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:15.0f options:UIViewAnimationOptionAllowUserInteraction&&UIViewAnimationCurveEaseInOut animations:^{
        self.popUpView.frame = CGRectMake(0.0f, -120.0f, self.window.frame.size.width, 120.0f);
        self.popUpView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            for (UIView *view in self.popUpView.subviews) {
                [view removeFromSuperview];
            }
            [self.popUpView removeFromSuperview];
            NSLog(@"closeByUser");
            self.popUpView = NULL;
            NSLog(@"self.popUpView==%@",self.popUpView);
        }
    }];
}
-(void)gotoAlarmList{
    NSLog(@"gotoAlarmList");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PUSHTOALARMDETAIL" object:nil];
    [self localNotiClose];
}

- (void)removePopView{
    NSLog(@"hello");
    if (self.popUpView != NULL ) {
        [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:15.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            //        self.popUpView.frame = CGRectMake(0.0f, -120.0f, self.window.frame.size.width, 120.0f);
            self.popUpView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.popUpView setHidden:YES];
            NSLog(@"popDown");
            self.popUpView = NULL;
        }];
    }
}
- (void)pushLocalNotificationWithUserInfo:(NSDictionary *)userInfo{
    NSLog(@"pushLocalNotification");
    
    //
    // 初始化本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        // 设置通知的提醒时间
        NSDate *currentDate   = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        //        notification.fireDate = [currentDate dateByAddingTimeInterval:3.0];
        notification.fireDate = [currentDate dateByAddingTimeInterval:0.0];
        
        // 设置重复间隔
        //        notification.repeatInterval = kCFCalendarUnitDay;
        notification.repeatInterval = 0;
        
        // 通知提示音 使用默认的
        notification.soundName= UILocalNotificationDefaultSoundName;
        
        // 设置应用程序右上角的提醒个数
        //        notification.applicationIconBadgeNumber++;
        
        // 设定通知的userInfo，用来标识该通知
        if (userInfo) {
            NSLog(@"userInfotest == %@",userInfo);
            notification.userInfo = userInfo;
        }else{
            NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
            aUserInfo[@"kLocalNotificationID"] = @"LocalNotificationID";
            notification.userInfo = aUserInfo;
        }
        
        // 将通知添加到系统中
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}



// 2015 11 16 RemoteNotice end

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSOperationDownloadQueue *downloadQueue = [NSOperationDownloadQueue sharedInstance];
    [downloadQueue freezeOperations];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSInteger num = application.applicationIconBadgeNumber;
    if(num!=0){
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setBadge:0];
        [currentInstallation saveEventually];
        application.applicationIconBadgeNumber = 0;
    }
    [application cancelAllLocalNotifications];
    //...
    NSLog(@"App is active");
    //切换到前台时恢复操作
    NSOperationDownloadQueue *downloadQueue = [NSOperationDownloadQueue sharedInstance];
    [downloadQueue checkAndRestoreFrozenOperations];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark -
#pragma mark LoadData
- (void)loadData
{
    static NSString * const AppNameKey = @"appName";
    static NSString * const AppIconNameKey = @"appIconName";
    static NSString * const AppKey = @"appKey";
    static NSString * const AppInfoKey = @"appInfo";
    static NSString * const AppVersionKey = @"appVersion";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppInfo" ofType:@"plist"];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSArray *array = dictionary[@"AppInfo"];
    
    if (!array)
    {
        NSLog(@"文件加载失败");
    }
    _appArray = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        AppInfo *appInfo = [[AppInfo alloc] init];
        appInfo.appName = dict[AppNameKey];
        appInfo.appIconName = dict[AppIconNameKey];
        appInfo.appKey = (int)[dict[AppKey] integerValue];
        appInfo.appInfo = dict[AppInfoKey];
        appInfo.appVersion = dict[AppVersionKey];
        [_appArray addObject:appInfo];
    }];
}


@end
