//
//  Cloudregister.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/11/10.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "CloudRegisterViewController.h"
#import "CloudLoginViewController.h"
#import "CloudLoginSuccessViewController.h"
#import "RegisterSuccessViewController.h"
#import "FileTools.h"
#import "DataManager.h"
#import "QuartzCore/QuartzCore.h"

@interface CloudRegisterViewController ()

@end

@implementation CloudRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor]};
//    UITextAttributeFont : [UIFont boldSystemFontOfSize:18]
    self.navigationItem.title = @"co-cloud账户注册";
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    
    self.registerButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
    self.email.layer.borderColor = [UIColor blackColor].CGColor;
    self.password.layer.borderColor = [UIColor blackColor].CGColor;
    self.passwordtwo.layer.borderColor = [UIColor blackColor].CGColor;
    self.cocloudid.layer.borderColor = [UIColor blackColor].CGColor;
    // 创建复选框 使用UIButton模拟复选框
    UIButton *checkbox = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect checkboxRect = CGRectMake(40,170,25,20);
    [checkbox setFrame:checkboxRect];
    
    [checkbox setImage:[UIImage imageNamed:@"checkbox-down"] forState:UIControlStateNormal];
    [checkbox setImage:[UIImage imageNamed:@"checkall"] forState:UIControlStateSelected];
    
    [checkbox addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkbox];
    
    [self.password setHidden:YES];
    [self.passwordtwo setHidden:YES];
    // 加载页面的时候先吧确认按钮置为不可用
    if(!checkbox.selected){
        [self.registerButton setEnabled:NO];
    }
}

// 当点击复选框的时候复选框的选择与未选择状态切换 同时切换下面的确认按钮的状态
-(void)checkboxClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if(!self.registerButton.enabled){
        [self.registerButton setEnabled:YES];
    }else{
        [self.registerButton setEnabled:NO];
    }
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 注册验证

- (IBAction)registers:(id)sender {
    
    NSString *regexs = @"^[a-zA-Z0-9]*$";
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *predicates = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexs];
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([self.email.text isEqualToString:@""]||[self.cocloudid.text isEqualToString:@""]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请将信息填写完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return ;
    }
    if([emailTest evaluateWithObject:self.email.text] == NO){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入一个正确的邮箱地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return ;
    }
    if ([predicates evaluateWithObject:self.cocloudid.text] == NO) {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"云id应该由字母和数字组成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return ;
    }
    if([self.cocloudid.text length]<6){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"云id长度请大于6" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return ;
    }
    
    [self registerCheck];
    
}

-(void)registerCheck{
    NSDictionary *requestParam = @{@"cid":self.cocloudid.text,@"email":self.email.text};
    //    //请求php
    NSString* url = [NSString stringWithFormat:@"%@/smarty_storage/phone",[g_sDataManager requestHost]];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"proxyregister.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
//        NSLog(@"op.responseJSON==%@",op.responseJSON);
        NSString *result = op.responseJSON[@"result"];
        int results = [result intValue];
        if(results==0){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，注册失败，请重新填写" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==2){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，设备MAC地址取得失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==3){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，中转服务器co-cloud-id已存在，请修改" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==4){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"设备非法，不允许注册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==5){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"中转服务器co-cloud-id注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==6){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，设备上登录信息更新失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==1){
            RegisterSuccessViewController* ss = [[RegisterSuccessViewController alloc]initWithNibName:@"RegisterSuccessViewController" bundle:nil];
            ss.texts = self.email.text;
            [self.navigationController pushViewController:ss animated:YES];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"未知错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (IBAction)finish:(id)sender {
    [sender resignFirstResponder];
}
@end
