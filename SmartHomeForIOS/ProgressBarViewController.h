//
//  ProgressBarViewController1.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressView.h"

@interface ProgressBarViewController : UIViewController
@property (assign, nonatomic) float  viewX;
@property (assign, nonatomic) float  viewY;
@property (strong, nonatomic)  UIScrollView *scrollView;
@property (strong, nonatomic)  NSMutableDictionary *progressBarDic; //保存所有进度条的字典
@property (strong, nonatomic)  NSMutableDictionary *taskDic;//保存所有任务的字典

-(void)addProgressBarRow:(TaskInfo *)taskInfo;

-(void)updateProgress:(NSMutableDictionary*) currentProgressDic;
-(void)setPauseBtnState:(NSMutableDictionary*) btnStateDic;
- (void)setTaskStatusInfo:(NSMutableDictionary *)taskStatusDic;
- (void)setPauseBtnStateCaptionAndTaskStatus:(NSMutableDictionary *)taskStatusDic;

+ (instancetype)sharedInstance;
@end
