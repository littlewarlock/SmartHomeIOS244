//
//  UpdatePasswordViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/1.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "UpdatePasswordViewController.h"
#import "CloudLoginViewController.h"
#import "DataManager.h"

@interface UpdatePasswordViewController (){
    
    IBOutlet UIActivityIndicatorView *activityView;
}

@end

@implementation UpdatePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"co-cloud账户"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor]};
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    activityView.frame = CGRectMake((self.view.frame.size.width/2)-100, (self.view.frame.size.height/2)-100, (self.view.frame.size.width/2)-100, (self.view.frame.size.height/2)-100);
    [activityView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)updateCheck{
    [activityView setHidden:NO];
    [activityView startAnimating];
    NSDictionary *requestParam = @{@"email":self.email,@"cid":self.cid,@"passwd":self.oldPassword,@"new_pwd":self.NewPassword,@"mac":self.mac};
    //请求php
    NSString* url = @"123.57.223.91";
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"changepasswd.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
        NSString *result = completedOperation.responseJSON[@"result"];
        NSLog(@"op.responseJSON==%@",completedOperation.responseJSON);
        int results = [result intValue];
        [activityView setHidden:YES];
        [activityView stopAnimating];
        if(results==0){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"密码修改成功，下次登录情使用新密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            CloudLoginViewController* clog = [[CloudLoginViewController alloc]initWithNibName:@"CloudLoginViewController" bundle:nil];
            clog.email = self.email;
            clog.cid = self.cid;
            clog.mac = self.mac;
            [self.navigationController pushViewController:clog animated:YES];
        }else if(results==201){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"密码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==301){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"设备非法" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==501){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"更新DB出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else if(results==601){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"发送邮件失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"未知错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"MKNetwork request error : %@", [error localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

- (IBAction)update:(id)sender {
    if([self.NewPassword.text isEqualToString:@""]||[self.passwordTwo.text isEqualToString:@""]){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }else if([self.NewPassword.text isEqualToString:self.passwordTwo.text]){
        //        self.passwordTwo = nil;
        //        self.oldPassword = nil;
        //        self.NewPassword = nil;
        [self updateCheck];
    }else{
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查输入信息是否正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
}
@end
