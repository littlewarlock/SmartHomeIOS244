//
//  NSOperationDownloadQueue.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/12/11.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "NSOperationDownloadQueue.h"

@implementation NSOperationDownloadQueue

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static NSOperationDownloadQueue *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NSOperationDownloadQueue alloc] init];
        [instance setMaxConcurrentOperationCount:1];
    });
    return instance;
}

@end