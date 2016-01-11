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
#import "UpdatePasswordViewController.h"


@interface CloudLoginViewController (){
    IBOutlet UIView *promotView;
    IBOutlet UILabel *promotText;
    NSTimer* timer;
    IBOutlet UIButton *reset;
    IBOutlet UILabel *information2;
    IBOutlet UILabel *information3;
    __weak IBOutlet UIActivityIndicatorView *move;
}

@end

@implementation CloudLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"co-cloud账户"];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    self.emailText.text = self.email;
    [self.prompt setHidden:YES];
    [information2 setHidden:YES];
    [information3 setHidden:YES];
    [self.toRegister setHidden:YES];
    self.information.text = [NSString stringWithFormat:@"%@。",self.email];
    [promotView setHidden:YES];
    if([@"0" isEqualToString:self.emailflg]){
        [self.information setHidden:NO];
        [self.toRegister setHidden:NO];
        [information2 setHidden:NO];
        [information3 setHidden:NO];
    }else{
        [self.information setHidden:YES];
        [self.toRegister setHidden:YES];
        [information2 setHidden:YES];
        [information3 setHidden:YES];
    }
    [self.passwordText becomeFirstResponder];
    promotView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    promotView.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)Login:(id)sender {
    [self.passwordText resignFirstResponder];
    if([self.passwordText.text isEqualToString:@""]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"请输入密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self.passwordText becomeFirstResponder];
        return ;
    }else if([@"1" isEqualToString:g_sDataManager.logoutFlag]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"外网环境注销后不能再次建立连接。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        self.passwordText.text=nil;
    }else{
        [self.passwordText resignFirstResponder];
        promotText.text = @"登录中";
        [promotView setHidden:NO];
        [move startAnimating];
        [self.LoginButton setEnabled:NO];
        [self loginCheck];
    }
}

- (void)loginCheck{
    NSDictionary *requestParam = @{@"cid":self.cid,@"email":self.emailText.text,@"passwd":self.passwordText.text,@"mac":self.mac};
    //请求php
    NSString* url = [NSString stringWithFormat:@"%@/smarty_storage/phone",[g_sDataManager requestHost]];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"proxylogin.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
        NSString *result = completedOperation.responseJSON[@"result"];
        NSString *results = [NSString stringWithFormat:@"%@",result];
        [promotView setHidden:YES];
        [move stopAnimating];
        [self.LoginButton setEnabled:YES];
        if([@"0" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
        }else if([@"2" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备MAC取得失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
        }else if([@"3" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"密码校验错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
        }else if([@"4" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备非法，不允许登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if([@"5" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器通信端口设置失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
        }else if([@"6" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器未找到指定的数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
        }else if([@"7" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器更新DB失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
        }else if([@"8" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备登录状态更新失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
        }else if([@"8" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备IP取得失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
        }else if([@"1" isEqualToString:results]){
            CloudLoginSuccessViewController* clog = [[CloudLoginSuccessViewController alloc]initWithNibName:@"CloudLoginSuccessViewController" bundle:nil];
            clog.cocloudid = self.cid;
            clog.email = self.email;
            clog.mac = self.mac;
            [self.navigationController pushViewController:clog animated:YES];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
        }}errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            [self.LoginButton setEnabled:YES];
            [promotView setHidden:YES];
            [move stopAnimating];
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [self.passwordText becomeFirstResponder];
            self.passwordText.text=nil;
            NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
        }];
    [engine enqueueOperation:op];
}

- (void)resetPassword{
    promotText.text = @"重置中";
    [promotView setHidden:NO];
    NSDictionary *requestParam = @{@"email":self.emailText.text,@"cid":self.cid,@"mac":self.mac};
    //请求php
    NSString* url = @"123.57.223.91";
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"resetpasswd.php" params:requestParam httpMethod:@"POST"];
    //    NSLog(op.r)
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
        NSString *result = completedOperation.responseJSON[@"result"];
        NSString *results = [NSString stringWithFormat:@"%@",result];
        NSLog(@"%@",completedOperation.responseJSON);
        [promotView setHidden:YES];
        if([@"0" isEqualToString:results]){
            [move stopAnimating];
            [self.prompt setHidden:NO];
            [self.passwordText becomeFirstResponder];
        }else if([@"102" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器该数据已存在。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
            [self.passwordText becomeFirstResponder];
        }else if([@"203" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"重设密码失败，请联系管理员。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
            [self.passwordText becomeFirstResponder];
        }else if([@"301" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"设备非法" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
            [self.passwordText becomeFirstResponder];
        }else if([@"501" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器更新DB失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
            [self.passwordText becomeFirstResponder];
        }else if([@"601" isEqualToString:results]){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"邮件发送失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
            [self.passwordText becomeFirstResponder];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"中转服务器连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
            [self.passwordText becomeFirstResponder];
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(tickDown) userInfo:nil repeats:YES];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [move stopAnimating];
        [promotView setHidden:YES];
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"系统提示" message:@"重设密码失败，请联系管理员。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        self.passwordText.text=nil;
        [self.passwordText becomeFirstResponder];
        timer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(tickDown) userInfo:nil repeats:YES];
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

-(void)tickDown{
    [reset setEnabled:YES];
    [self.prompt setHidden:YES];
    [timer invalidate];
}

- (void)viewWillAppear:(BOOL)animated{
    self.passwordText.text=nil;
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)finish:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)check:(id)sender {
    [move startAnimating];
    [self.prompt setHidden:YES];
    [reset setEnabled:NO];
    [self resetPassword];
}

- (IBAction)registerAgain:(id)sender {
    CloudRegisterViewController* crs = [[CloudRegisterViewController alloc]initWithNibName:@"CloudRegisterViewController" bundle:nil];
    crs.mac = self.mac;
    [self.navigationController pushViewController:crs animated:YES];
}

- (IBAction)touch:(id)sender {
    [self.passwordText resignFirstResponder];
}

@end
