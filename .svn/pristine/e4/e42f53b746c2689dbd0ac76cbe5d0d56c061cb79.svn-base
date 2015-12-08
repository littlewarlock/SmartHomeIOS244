//
//  ProgressView.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView ()

@end

@implementation ProgressView

- (id)initWithTask:(TaskInfo *)task
{
    self = [[ProgressView alloc] init];
    self.progressBar.progress = 0.0f;
    self.progressBar.layer.masksToBounds = YES;
    self.progressBar.layer.cornerRadius = 4;
    //设置进度条的高度
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 7.0f);
    self.progressBar.transform = transform;
    self.taskNameLabel.text =task.taskName;
    self.taskDetailLabel.text =(NSString*)task.currentProgress;
    return self;
}

@end
