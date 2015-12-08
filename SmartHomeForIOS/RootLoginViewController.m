//
//  RootLoginViewController.m
//  SmartHomeForIOS
//
//  Created by apple3 on 15/12/2.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "RootLoginViewController.h"
#import "CloudRegisterViewController.h"

@interface RootLoginViewController ()

@end

@implementation RootLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //添加viewtext
    UITextView* textView = [[UITextView alloc]initWithFrame:CGRectMake(20, 100, self.view.frame.size.width-40, 120)];
    textView.text=@"使用远程登录，可以通过co-cloud提供的免费域名，远程访问co-cloud服务器。并且在设备报警时，收到报警消息。";
    [self.view addSubview:textView];
    //添加注册按钮
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 300, 200, 50)];
    //添加注册按钮的下划线效果
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"注册co-cloud账户"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:strRange];
    [btn setAttributedTitle:str forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    //添加导航条标题 并为标题设置颜色
    [self.navigationItem setTitle:@"co-cloud账户"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor]};
    //为注册按钮添加事件
    [btn addTarget: self action: @selector(Register:) forControlEvents: UIControlEventTouchUpInside];
    //添加后退按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(0, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
}

- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)Register:(UIButton *)sender {
    CloudRegisterViewController* reg = [[CloudRegisterViewController alloc]initWithNibName:@"CloudRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:reg animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end