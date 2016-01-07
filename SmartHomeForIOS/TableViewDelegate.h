//
//  TableViewDelegate.h
//  CustomIOSAlertView
//
//  Created by riqiao on 16/1/4.
//  Copyright © 2016年 Wimagguc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewDelegate : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property(strong, nonatomic) NSArray *fileNamesArray;
@property(strong, nonatomic) NSMutableDictionary* selectedFileNamesDic;
@end
