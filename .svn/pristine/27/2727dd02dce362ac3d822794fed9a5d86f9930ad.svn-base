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

@interface UpdatePasswordViewController ()

@end

@implementation UpdatePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor:[UIColor blueColor]};
    [self.navigationItem setTitle:@"co-cloud账户"];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)updateCheck{
    NSDictionary *requestParam = @{@"email":self.email,@"cid":self.cid,@"currentpasswd":self.oldPassword,@"newpasswd":self.NewPassword};
    //请求php
    NSString* url = [NSString stringWithFormat:@"%@/smarty_storage/phone",[g_sDataManager requestHost]];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:url customHeaderFields:nil];
    [engine useCache];
    MKNetworkOperation *op = [engine operationWithPath:@"cocloudmodifypassword.php" params:requestParam httpMethod:@"POST"];
    //操作返回数据
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //get data
        //        NSString *message = op.responseJSON[@"message"];
        NSString *result = op.responseJSON[@"result"];
        NSLog(@"op.responseJSON==%@",op.responseJSON);
        //        NSString* value = op.responseJSON[@"value"];
        int results = [result intValue];
        //        [result isEqualToString:@"0"]
        if(results==0){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"十分抱歉，设备上登录信息取得失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        if(results==1){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"密码修改成功，下次登录情使用新密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            CloudLoginViewController* clog = [[CloudLoginViewController alloc]initWithNibName:@"CloudLoginViewController" bundle:nil];
            [self.navigationController pushViewController:clog animated:YES];
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
    }
    if([self.NewPassword.text isEqualToString:self.passwordTwo.text]){
        [self updateCheck];
    }else{
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查输入信息是否正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
}
@end
