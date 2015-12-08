//
//  ProgressView.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/10/15.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskInfo.h"

@interface ProgressView :UIView
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (assign, nonatomic)long long  transferedBytes;//已经传输了多少字节
@property (assign, nonatomic)long long  totalBytes;//总共多少字节
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

- (id)initWithTask:(TaskInfo *)task;
@end
