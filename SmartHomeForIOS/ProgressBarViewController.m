//
//  ProgressBarViewController1.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#define  PROGRESSHEIGHT  80
#define  MARGINTOP 20
#import "ProgressBarViewController.h"


@interface ProgressBarViewController ()
{
    UIButton* rightBtn;
    UIBarButtonItem *leftBtn;
}
@end

@implementation ProgressBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"                                              style:UIBarButtonItemStyleBordered target:self action:@selector(returnAction:)];
    [leftBtn setTintColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1]];
    self.navigationItem.leftBarButtonItem = leftBtn;
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame =CGRectMake(200, 0, 32, 32);
    [rightBtn setTitleColor:[UIColor colorWithRed:48.0/255 green:131.0/255 blue:251.0/255 alpha:1] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"清除" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(clearProgressBarAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=item;
    //  [self loadData];
}


+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ProgressBarViewController *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ProgressBarViewController alloc] initWithNibName:@"ProgressBarViewController" bundle:nil];
        instance.taskDic = [[NSMutableDictionary alloc] init];
        instance.progressBarDic =[[NSMutableDictionary alloc] init];
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        instance.scrollView = [[UIScrollView alloc]init];
        instance.scrollView.frame = CGRectMake(5, 20, size.width-10, size.height-20);
        instance.scrollView.bounces = NO;
        instance.scrollView.alwaysBounceVertical = NO;
        instance.scrollView.showsVerticalScrollIndicator = NO;
        [instance.scrollView setContentSize:CGSizeMake(instance.scrollView.frame.size.width , instance.scrollView.frame.size.height-20)];
        [instance.view addSubview:instance.scrollView];
    });
    return instance;
}

-(void) loadData
{
    self.viewY = MARGINTOP;
    if (self.taskDic .count>0) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        CGFloat viewWidth = size.width;
        int rowIndex =0;
        for (NSString *taskId in [self.taskDic allKeys]){
            if (rowIndex) {
                self.viewY = self.viewY + PROGRESSHEIGHT+MARGINTOP;
            }
            TaskInfo* taskInfo = [self.taskDic objectForKey:taskId];
            ProgressView* progressView =(ProgressView*)[[[NSBundle mainBundle] loadNibNamed:@"ProgressView" owner:self options:nil] lastObject];
            progressView.progressBar.progress = 0.0f;
            progressView.progressBar.layer.masksToBounds = YES;
            progressView.progressBar.layer.cornerRadius = 4;
            //设置进度条的高度
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 7.0f);
            progressView.progressBar.transform = transform;
            progressView.taskNameLabel.text = [taskInfo.taskName lastPathComponent];
            progressView.taskDetailLabel.text = taskInfo.taskType;
            progressView.frame = CGRectMake(0, self.viewY, viewWidth-10, PROGRESSHEIGHT);
            progressView.percentLabel.text =@"0%";
            [self.progressBarDic setObject:progressView forKey:taskInfo.taskId];
            [self.scrollView addSubview:progressView];
        }
    }
}

-(void)addProgressBarRow:(TaskInfo *)taskInfo
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat viewWidth = size.width;
    if (self.taskDic.count==1) {
        self.viewY = MARGINTOP;
    }else{
        self.viewY = self.viewY+PROGRESSHEIGHT+MARGINTOP;
    }
    ProgressView* progressView =(ProgressView*)[[[NSBundle mainBundle] loadNibNamed:@"ProgressView" owner:self options:nil] lastObject];
    progressView.taskInfo = taskInfo;
    progressView.frame = CGRectMake(0, self.viewY, viewWidth-10, PROGRESSHEIGHT);
    progressView.progressBar.progress = 0.0f;
    progressView.progressBar.layer.masksToBounds = YES;
    progressView.progressBar.layer.cornerRadius = 4;
    //设置进度条的高度
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 7.0f);
    progressView.progressBar.transform = transform;
    progressView.taskNameLabel.text = [taskInfo.taskName lastPathComponent];
    progressView.taskDetailLabel.text = taskInfo.taskType;
    if ([taskInfo.taskType isEqualToString:@"上传"] || [taskInfo.taskType isEqualToString:@"备份"]) {
        progressView.pauseBtn.hidden = YES;
    }
    progressView.percentLabel.text =@"0%";
    progressView.taskInfo = taskInfo;
    [self.progressBarDic setObject:progressView forKey:taskInfo.taskId];
    [self.scrollView addSubview:progressView];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width ,([self.progressBarDic count]*(PROGRESSHEIGHT+MARGINTOP)))];
    if (self.scrollView.frame.size.height<self.scrollView.contentSize.height) {
        self.scrollView.showsVerticalScrollIndicator = YES;
    }
}

#pragma mark updateProgress 刷新进度条进度的方法
-(void)updateProgress:(NSMutableDictionary*) currentProgressDic
{
    if ([[currentProgressDic allKeys]containsObject:@"taskId"]) {
        NSString * taskId = [currentProgressDic objectForKey:@"taskId"];
        ProgressView* progressView =[self.progressBarDic objectForKey:taskId];
        if ([[currentProgressDic allKeys]containsObject:@"progress"]) {
            NSNumber * progress = [currentProgressDic objectForKey:@"progress"];
            [progressView.progressBar setProgress:[progress floatValue] animated:NO];
            float currentProgress =[progress floatValue]*100;
            progressView.percentLabel.text =[NSString stringWithFormat:@"%d%%",(int)currentProgress];
        }else{//当备份时，更新进度
            if([[currentProgressDic allKeys]containsObject:@"sendBytes"]){
                NSNumber * sendBytes = [currentProgressDic objectForKey:@"sendBytes"];
                long long  totalBytes = progressView.taskInfo.totalBytes;
                progressView.taskInfo.transferedBytes+= [sendBytes longLongValue];
                float currentProgress =(float)progressView.taskInfo.transferedBytes/(float)totalBytes*100;
                NSLog(@"currentProgress===========================%f,transferedBytes===%lld",currentProgress,progressView.taskInfo.transferedBytes);
                [progressView.progressBar setProgress:currentProgress/100 animated:NO];
                progressView.percentLabel.text =[NSString stringWithFormat:@"%d%%",(int)currentProgress];
            }
            if ([[currentProgressDic allKeys]containsObject:@"fileName"]){
                NSString *fileName = [currentProgressDic objectForKey:@"fileName"];
                progressView.taskNameLabel.text =fileName;
            }
            
        }
    }
}
#pragma mark setPauseBtnState 设置进度条暂停按钮的状态
-(void)setPauseBtnState:(NSMutableDictionary*) btnStateDic{
    if ([[btnStateDic allKeys]containsObject:@"taskId"]) {
        NSString * taskId = [btnStateDic objectForKey:@"taskId"];
        ProgressView* progressView =[self.progressBarDic objectForKey:taskId];
        if ([[btnStateDic allKeys]containsObject:@"btnState"]) {
            NSString * btnState = [btnStateDic objectForKey:@"btnState"];
            if([btnState isEqualToString:@"enable"]){
                [progressView setPauseBtnState:YES];
            }else{
                [progressView setPauseBtnState:NO];       }
        }
    }
}
#pragma mark setTaskStatusInfo 设置当前任务的状态信息
- (void)setTaskStatusInfo:(NSMutableDictionary *)taskStatusDic{
    if ([[taskStatusDic allKeys]containsObject:@"taskId"]) {
        NSString * taskId = [taskStatusDic objectForKey:@"taskId"];
        ProgressView* progressView =[self.progressBarDic objectForKey:taskId];
        if ([[taskStatusDic allKeys]containsObject:@"taskStatus"]) {
            NSString * taskStatus = [taskStatusDic objectForKey:@"taskStatus"];
            [progressView setTaskStatusInfo:taskStatus];
        }
    }
}

#pragma mark setPauseBtnStateCaptionAndTaskStatus 设置暂停按钮的状态、标题以及任务的当前状态
- (void)setPauseBtnStateCaptionAndTaskStatus:(NSMutableDictionary *)taskStatusDic{
    if ([[taskStatusDic allKeys]containsObject:@"taskId"]) {
        NSString * taskId = [taskStatusDic objectForKey:@"taskId"];
        ProgressView* progressView =[self.progressBarDic objectForKey:taskId];
        NSString * taskStatusInfo;
        NSString * caption;
        BOOL enabled;
        if ([[taskStatusDic allKeys]containsObject:@"taskStatus"]) {
            taskStatusInfo= [taskStatusDic objectForKey:@"taskStatus"];
        }
        if ([[taskStatusDic allKeys]containsObject:@"btnState"]) {
            NSString * btnState = [taskStatusDic objectForKey:@"btnState"];
            if ([btnState isEqualToString:@"enable"]) {
                enabled = YES;
            }else{
                enabled = NO;
            }
            
        }
        if ([[taskStatusDic allKeys]containsObject:@"caption"]) {
            caption = [taskStatusDic objectForKey:@"caption"];
            
        }
        [progressView setPauseBtnStateCaptionAndTaskStatus:enabled caption:caption taskStatus:taskStatusInfo];
    }
}

#pragma mark returnAction 返回父页面的方法
- (void)returnAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark clearProgressBarAction 清除所有进度条方法
- (void)clearProgressBarAction:(UIBarButtonItem *)sender {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.progressBarDic removeAllObjects];
    [self.taskDic removeAllObjects];
}

#pragma mark 设置progressView的TaskInfo对象
- (void)setProgressViewTaskInfo:(TaskInfo *)taskInfo{
    ProgressView* progressView =[self.progressBarDic objectForKey:taskInfo.taskId];
    progressView.taskInfo = taskInfo;
}


@end
