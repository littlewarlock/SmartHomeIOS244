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
    
    IBOutlet UIActivityIndicatorView *activityView;
}

@end

@implementation CloudLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor]};
    [self.navigationItem setTitle:@"co-cloud账户"];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    self.emailText.text = self.email;
    [self.prompt setHidden:YES];
    int a = [self.emailflg intValue];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"重新注册"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [self.toRegister setAttributedTitle:str forState:UIControlStateNormal];
    [self.toRegister setHidden:YES];
    self.information.text = [NSString stringWithFormat:@"密码已经发送到邮箱:%@.请查收并登录。或重新注册",@"xxx@yy.com"];
    
    activityView.frame = CGRectMake((self.view.frame.size.width/2)-100, (self.view.frame.size.height/2)-100, (self.view.frame.size.width/2)-100, (self.view.frame.size.height/2)-100);
    [activityView setHidesWhenStopped:YES];
    if(a==0){
        [self.information setHidden:NO];
        [self.toRegister setHidden:NO];
    }else{
        [self.information setHidden:YES];
        [self.toRegister setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)Login:(id)sender {
    if([self.passwordText.text isEqualToString:@""]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return ;
    }else if([@"1" isEqualToString:self.logFlag]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，您已注销，不能登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        self.passwordText.text=nil;
    }else{
        //        NSLog(self.passwordText.text);
        [activityView setHidden:NO];
        [activityView startAnimating];
        [self loginCheck];
        //        CloudLoginSuccessViewController* clc = [[CloudLoginSuccessViewController alloc]initWithNibName:@"CloudLoginSuccessViewController" bundle:nil];
        //        clc.email = self.email;
        //        clc.cocloudid = self.cid;
        //        clc.mac = self.mac;
        //        [self.navigationController pushViewController:clc animated:YES];
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
        NSLog(@"op.responseJSON==%@",completedOperation.responseJSON);
        int results = [result intValue];
        [activityView setHidden:YES];
        [activityView stopAnimating];
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
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，中转服务器未找到指定的数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==7){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，中转服务器更新DB失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==8){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，设备登录状态更新失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==1){
            CloudLoginSuccessViewController* clog = [[CloudLoginSuccessViewController alloc]initWithNibName:@"CloudLoginSuccessViewController" bundle:nil];
            clog.cocloudid = self.cid;
            clog.email = self.email;
            clog.mac = self.mac;
            [self.navigationController pushViewController:clog animated:YES];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"未知错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }
    }errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [activityView setHidden:YES];
        [activityView stopAnimating];
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (void)UpdatePassword{
    [activityView setHidden:NO];
    [activityView startAnimating];
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
        NSLog(@"%@",completedOperation.responseJSON);
        NSString *result = completedOperation.responseJSON[@"result"];
        int results = [result intValue];
        [activityView setHidden:YES];
        [activityView stopAnimating];
        if(results==0){
            [self.prompt setHidden:NO];
        }else if(results==102){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"未找到指定数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==201){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"重设密码失败，请联系管理员。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==301){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"非法设备" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==501){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"更新DB出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else if(results==601){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"发送邮件失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"未知错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            self.passwordText.text=nil;
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [activityView setHidden:YES];
        [activityView stopAnimating];
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
    crs.mac = self.mac;
    [self.navigationController pushViewController:crs animated:YES];
}

@end
