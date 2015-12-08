//
//  TestTableViewCell.m
//  SmartHomeForIOS
//
//  Created by apple2 on 15/9/22.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "TestTableViewCell.h"
#import "CameraListViewController.h"

@implementation TestTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)chooseAppAction:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(chooseAppAction:)]) {
//        NSString *ss=  [NSString stringWithFormat: @"hgc%d",(long)sender.tag];
//        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"HGCTitle" message:ss delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alter show];
        
        [_delegate chooseAppAction:sender];//调用委托方法，来实现页面的跳转
    }
    
}
- (IBAction)buttonAlarmPressed:(id)sender {
    if ([_delegate respondsToSelector:@selector(buttonAlarmPressed:)]) {
        [_delegate buttonAlarmPressed:sender];
    }
}



@end
