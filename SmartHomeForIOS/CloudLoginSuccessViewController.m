//
//  CloudLoginSuccessViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/1.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CloudLoginSuccessViewController.h"
#import "UpdatePasswordViewController.h"
#import "CloudLoginViewController.h"
#import "DataManager.h"
#import "LoginViewController.h"

@interface CloudLoginSuccessViewController (){
    
    IBOutlet UIView *promotView;
    __weak IBOutlet UIActivityIndicatorView *move;
}

@end

@implementation CloudLoginSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"co-cloud账户"];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    self.AccountText.text = self.email;
    self.cid.text = self.cocloudid;
    [promotView setHidden:YES];
    promotView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    promotView.layer.borderWidth = 1;
}

- (void)logoutCheck{
    [move startAnimating];
    [promotView setHidden:NO];
    NSDictionary *requestParam = @{@"cid":self.cocloudid,@"mac":self.mac};
    //请求php
    NSString* url = @"123.57.223.91";
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"logout.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [move stopAnimating];
        [promotView setHidden:YES];
        //get data
        NSString *result = completedOperation.responseJSON[@"result"];
        NSString *results = [NSString stringWithFormat:@"%@",result];
        if([@"0" isEqualToString:results]){
            if ([g_sDataManager.requestHost rangeOfString:@"find"].location != NSNotFound||[g_sDataManager.requestHost rangeOfString:@"123.57.223.91"].location != NSNotFound) {
                g_sDataManager.logoutFlag=@"1";
                [g_sDataManager setUserName:@""];
                [g_sDataManager setPassword:@""];
                LoginViewController *loginView= [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                loginView.isPushHomeView =YES;
                loginView.isShowLocalFileBtn =YES;
//                self.viewDeckController.toggleLeftView;
                
                [self.viewDeckController presentViewController:loginView animated:YES completion:nil];
            }else{
                CloudLoginViewController* clc = [[CloudLoginViewController alloc] initWithNibName:@"CloudLoginViewController" bundle:nil];
                clc.cid = self.cocloudid;
                clc.email = self.email;
                clc.mac = self.mac;
            //检查是否为外网
            [self.navigationController pushViewController:clc animated:YES];
            }        }else if([@"1" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备上登录状态更新失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if([@"2" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备注销失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if([@"301" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备非法" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [move stopAnimating];
        [promotView setHidden:YES];
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备注销失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)update:(id)sender {
    //    CloudLoginViewController* up = [[CloudLoginViewController alloc]initWithNibName:@"CloudLoginViewController" bundle:nil];
    //    up.email = self.email;
    //    up.cid = self.cocloudid;
    //    up.mac = self.mac;
    //    [self.navigationController pushViewController:up animated:YES];
    UpdatePasswordViewController* up = [[UpdatePasswordViewController alloc]initWithNibName:@"UpdatePasswordViewController" bundle:nil];
    up.email = self.email;
    up.cid = self.cocloudid;
    up.mac = self.mac;
    [self.navigationController pushViewController:up animated:YES];
}

- (IBAction)cancel:(id)sender {
    NSLog(@"12312");
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"关闭远程访问将无法在外网访问设备。\n是否注销？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"是",@"否",nil ];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        [self logoutCheck];
    }
}

@end
