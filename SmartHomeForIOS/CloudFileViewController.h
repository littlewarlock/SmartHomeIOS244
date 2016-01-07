//
//  CloudFileViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/13.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSUUIDTool.h"
#import "FileDialogViewController.h"
#import "MWPhotoBrowser.h"
#import "FileHandler.h"
#import "FDTableViewCell.h"
#import "CustomIOSAlertView.h"
@interface CloudFileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,FileDialogDelegate,MWPhotoBrowserDelegate,UIGestureRecognizerDelegate,CustomIOSAlertViewDelegate>

@property(assign,nonatomic) BOOL isServerFile; //表示是否读的是服务器端的文件YES：读的是服务器端的 NO：读的是本地目录下的文件
@property (copy, nonatomic) NSString *cpath; //当前路径
@property (assign, nonatomic) BOOL isShowFile; //是否显示文件 YES：显示 NO：不显示文件 显示目录
@property (assign, nonatomic) BOOL isMultiple;//是否允许多选，YES：允许多选 NO：不允许多选
@property (copy, nonatomic) NSString *rootUrl; //存储当前用户的根目录
@property (assign, nonatomic) BOOL isInShareFolder; //是否在共享文件夹下
@property (strong, nonatomic) IBOutlet UITableView *fileListTableView;


@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;


@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIButton *footerBtn_1;
@property (strong, nonatomic) IBOutlet UILabel *footerLabel_1;
@property (strong, nonatomic) IBOutlet UIButton *footerBtn_2;
@property (strong, nonatomic) IBOutlet UILabel *footerLabel_2;
@property (strong, nonatomic) IBOutlet UIButton *footerBtn_3;

@property (strong, nonatomic) IBOutlet UILabel *footerLabel_3;
@property (strong, nonatomic) IBOutlet UIButton *footerBtn_4;
@property (strong, nonatomic) IBOutlet UILabel *footerLabel_4;
@property (weak, nonatomic) FDTableViewCell *curCel;
- (IBAction)footerButtonEventHandleAction:(id)sender;
@end
