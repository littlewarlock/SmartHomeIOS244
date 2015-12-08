//
//  CloudLoginSuccessViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/1.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CloudLoginSuccessViewController.h"
#import "UpdatePasswordViewController.h"
#import "DataManager.h"

@interface CloudLoginSuccessViewController ()

@end

@implementation CloudLoginSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor]};
    [self.navigationItem setTitle:@"co-cloud账户"];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    self.AccountText.text = self.email;
    self.cid.text = self.cocloudid;
}

- (void)loginCheck{
    NSDictionary *requestParam = @{@"email":self.AccountText.text,@"passwd":@"123"};
    //请求php
    NSString* url = @"http://123.57.223.91/logout.php";
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:nil params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
        NSString *result = op.responseJSON[@"result"];
        int results = [result intValue];
        if(results==0){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，中转服务器连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==2){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"设备MAC取得失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==3){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"用户未注册，不弹消息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==4){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"设备上登录状态更新失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==1){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"未知错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (IBAction)update:(id)sender {
    UpdatePasswordViewController* up = [[UpdatePasswordViewController alloc]initWithNibName:@"UpdatePasswordViewController" bundle:nil];
    up.email = self.email;
    up.cid = self.cocloudid;
    [self.navigationController pushViewController:up animated:YES];
}

- (IBAction)cancel:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"关闭远程访问将无法在外网访问设备。是否注销？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消",nil ];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        [self loginCheck];
    }
}

@end
