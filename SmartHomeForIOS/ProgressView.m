//
//  ProgressView.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "ProgressView.h"
#import "TaskStatusConstant.h"
@interface ProgressView ()

@end

@implementation ProgressView

- (id)initWithTask:(TaskInfo *)taskInfo
{
    self = [[ProgressView alloc] init];
    self.taskInfo = taskInfo;
    self.progressBar.progress = 0.0f;
    self.progressBar.layer.masksToBounds = YES;
    self.progressBar.layer.cornerRadius = 4;
    //设置进度条的高度
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 7.0f);
    self.progressBar.transform = transform;
    self.taskNameLabel.text = taskInfo.taskName;
    self.taskDetailLabel.text =(NSString*)taskInfo.currentProgress;
    return self;
}

#pragma mark setTaskStateAction 设置任务的状态 暂停 继续
- (IBAction)setTaskStateAction:(UIButton *)sender {
    if (self.taskInfo && ![self.taskInfo.taskId isEqualToString:@""]) {
        NSOperationDownloadQueue *downloadQueue = [NSOperationDownloadQueue sharedInstance];
        if (downloadQueue) {
            FileDownloadOperation *downloadOperation;
            for(FileDownloadOperation *operation in downloadQueue.operations)
            {
                if([operation.taskId isEqualToString:self.taskInfo.taskId] && !operation.cancelled){
                    downloadOperation = operation;
                    break;
                }
            }
            if (downloadOperation && ![self.taskInfo.taskStatus isEqualToString:CANCLED]) {
                [downloadOperation cancel]; //（暂停）取消当前操作
                if(downloadOperation.isExecuting){//如果正在队列中执行，需要等待，队列成功取消的消息
                    self.pauseBtn.enabled = NO;
                }else{//没有在队列中执行的话，可直接取消
                    NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"已暂停" ,@"taskStatus",@"enable",@"btnState",@"继续",@"caption", nil];
                    [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnStateCaptionAndTaskStatus:) withObject:taskStatusDic waitUntilDone:NO];
                }
                self.taskInfo.taskStatus = CANCLED;
            }else{
                [sender setTitle:@"暂停" forState:UIControlStateNormal];
                self.taskInfo.taskStatus = RUNNING;
                FileDownloadOperation *downloadOperation = [[FileDownloadOperation alloc] initWithTaskInfo:self.taskInfo];
                downloadOperation.taskId = self.taskInfo.taskId;
                downloadOperation.completionBlock = ^(void){ //如果是任务执行完成则设置暂停按钮不可用
                    if ([self.taskInfo.taskStatus isEqualToString:FINISHED]) {
                        NSLog(@"completionBlock======ppppp");
                        NSMutableDictionary * btnStateDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"disable" ,@"btnState", nil];
                        [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setPauseBtnState:) withObject:btnStateDic waitUntilDone:NO];
                        //更新进度条的状态信息
                        NSMutableDictionary * taskStatusDic=[[NSMutableDictionary alloc] initWithObjectsAndKeys:self.taskInfo.taskId,@"taskId",@"已完成" ,@"taskStatus", nil];
                        //在主线程刷新UI
                        [[ProgressBarViewController sharedInstance] performSelectorOnMainThread:@selector(setTaskStatusInfo:) withObject:taskStatusDic waitUntilDone:NO];
                    }
                };
                [downloadQueue addOperation:downloadOperation];
                if(downloadOperation.isExecuting){
                    self.taskDetailLabel.text = @"正在下载";
                }else{
                    self.taskDetailLabel.text = @"排队等待";
                }
            }
        }
    }
}

- (void)setPauseBtnState:(BOOL )btnState{
    self.pauseBtn.enabled = btnState;
}

- (void)setTaskStatusInfo:(NSString *)taskStatus{
    self.taskDetailLabel.text = taskStatus;
}

- (void)setPauseBtnStateCaptionAndTaskStatus:(BOOL) btnState caption:(NSString*)caption taskStatus:(NSString*)taskStatus{
    self.pauseBtn.enabled = btnState;
    [self.pauseBtn setTitle:caption forState:UIControlStateNormal];
    self.taskDetailLabel.text = taskStatus;
}
@end
