//
//  CloudLoginViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/1.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CloudLoginViewController.h"
#import "DataManager.h"
#import "CloudLoginSuccessViewController.h"
#import "CloudRegisterViewController.h"


@interface CloudLoginViewController ()

@end

@implementation CloudLoginViewController

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
//    self.email = @"13050006056@163.com";
    self.emailText.text = self.email;
    [self.prompt setHidden:YES];
    int a = [self.emailflg intValue];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"重新注册"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [self.toRegister setAttributedTitle:str forState:UIControlStateNormal];
    [self.toRegister setHidden:YES];
    self.information.text = [NSString stringWithFormat:@"密码已经发送到邮箱:%@.请查收并登录。或重新注册",@"xxx@yy.com"];
    if(a==1){
        [self.information setHidden:YES];
        [self.toRegister setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Login:(id)sender {
    if([self.passwordText.text isEqualToString:@""]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return ;
    }else{
        [self loginCheck];
    }
}

- (void)loginCheck{
    NSDictionary *requestParam = @{@"cid":self.cid,@"email":self.emailText.text,@"passwd":self.passwordText.text};
    //请求php
    NSString* url = [NSString stringWithFormat:@"%@/smarty_storage/phone",[g_sDataManager requestHost]];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"proxylogin.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
        NSString *result = op.responseJSON[@"result"];
        NSLog(@"op.responseJSON==%@",op.responseJSON);
        int results = [result intValue];
        if(results==0){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，中转服务器连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==2){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"设备MAC取得失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==3){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，密码校验错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==4){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，设备非法，不允许登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==5){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，中转服务器通信端口设置失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==6){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，设备登录状态更新失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==1){
            CloudLoginSuccessViewController* clog = [[CloudLoginSuccessViewController alloc]initWithNibName:@"CloudLoginSuccessViewController" bundle:nil];
            clog.cocloudid = self.cid;
            clog.email = self.email;
            [self.navigationController pushViewController:clog animated:YES];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"未知错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }
            } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (void)UpdatePassword{
    NSDictionary *requestParam = @{@"email":self.emailText.text,@"cid":self.cid};
    //请求php
    NSString* url = [NSString stringWithFormat:@"%@/smarty_storage/phone",[g_sDataManager requestHost]];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"~~~" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
        //        NSString *message = op.responseJSON[@"message"];
        NSString *result = op.responseJSON[@"result"];
        //        NSString* value = op.responseJSON[@"value"];
        int results = [result intValue];
        if(results==1){
            [self.prompt setHidden:NO];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"修改失败，未知错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (void)viewWillAppear:(BOOL)animated{
    self.passwordText.text=nil;
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (IBAction)finish:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)check:(id)sender {
    [self UpdatePassword];
}

- (IBAction)registerAgain:(id)sender {
    CloudRegisterViewController* crs = [[CloudRegisterViewController alloc]initWithNibName:@"CloudRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:crs animated:YES];
}

@end
