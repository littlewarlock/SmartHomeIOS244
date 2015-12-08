//
//  BackupTool.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/11/24.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "BackupTool.h"
#import "FileTools.h"
#import "RequestConstant.h"
#import "DataManager.h"
#import "FileUploadByBlockTool.h"
#import "ProgressView.h"
#import "NSUUIDTool.h"
#import "ProgressBarViewController.h"

@implementation BackupTool

- (id)init:(NSArray *)sourceFilesArray sourceDirsArray:(NSArray*)sourceDirsArray localCurrentDir:(NSString*)localCurrentDir targetDir:(NSString*)targetDir userName:(NSString*)userName password:(NSString*)password{
    self = [super init];
    if (self == nil)
        return nil;
    self.sourceFilesArray = sourceFilesArray;
    self.sourceDirsArray = sourceDirsArray;
    self.localCurrentDir = localCurrentDir;
    targetDir = [targetDir stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.targetDir = targetDir;
    self.userName = userName;
    self.password = password;
    return self;
}

- (void)main {
    @try {
      //1.获取所有的文件夹,及其子目录下的文件
        NSMutableArray *allDirsArray= [[NSMutableArray alloc]init];
        NSMutableArray *allFilesArray= [[NSMutableArray alloc]init];
        [allDirsArray addObjectsFromArray:self.sourceDirsArray];
        [allFilesArray addObjectsFromArray:self.sourceFilesArray];
        for (int i =0; i<self.sourceDirsArray.count; i++) {
            NSArray *dirsArray = [FileTools getAllDirs:self.sourceDirsArray[i]];
            NSMutableArray *dirsCompleteArray = [[NSMutableArray alloc]init];//存储所有的完整路径
            for (int j=0; j<dirsArray.count; j++) { //将子目录（目录名）拼接上父目录的绝对路径
                if(dirsArray[j] && ![dirsArray[j] isEqualToString:@""]){
                    dirsCompleteArray[j] = [self.sourceDirsArray[i] stringByAppendingPathComponent:dirsArray[j]];
                }
            }
            [allDirsArray addObjectsFromArray:dirsCompleteArray];
            NSArray *filesArray = [FileTools getAllFilesUrl:self.sourceDirsArray[i]];
            [allFilesArray addObjectsFromArray:filesArray];
        }
        //2.创建目录
        NSString* requestHost = [g_sDataManager requestHost];
        NSString* requestUrl = [NSString stringWithFormat:@"%@/%@",requestHost,REQUEST_NEWFOLDER_URL];
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
        for(int i=0;i<allDirsArray.count;i++){
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            __block NSError *error = nil;
            NSString *folderName = [allDirsArray[i] lastPathComponent];
            NSString *dirPath =  allDirsArray[i];
            NSRange localCurrentDirRange = [dirPath rangeOfString:self.localCurrentDir];//匹配得到的下标
            NSString *cpath;
            if (localCurrentDirRange.location != NSNotFound) {
                NSRange range = {localCurrentDirRange.length,[allDirsArray[i] length]-localCurrentDirRange.length};
                NSString *sourceDir = [dirPath substringWithRange:range];//截取范围
                if ([sourceDir isEqualToString:[sourceDir lastPathComponent]]) {
                    cpath = self.targetDir;
                }else{
                    cpath = [self.targetDir stringByAppendingPathComponent:[sourceDir stringByDeletingLastPathComponent]];
                }
            }
            NSLog(@"cpath=====%@",cpath);
            [dic setValue:cpath forKey:@"cpath"];
            [dic setValue:[g_sDataManager userName] forKey:@"uname"];
            [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
            [dic setValue:folderName forKey:@"newName"];
            dispatch_semaphore_t semaphore =dispatch_semaphore_create(0);
            MKNetworkOperation *op = [engine operationWithPath:@"" params:dic httpMethod:@"POST" ssl:NO];
            [op addCompletionHandler:^(MKNetworkOperation *operation) {
                NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
                {
                    dispatch_semaphore_signal(semaphore);
                }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
                    dispatch_semaphore_signal(semaphore);
                }
            }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                dispatch_semaphore_signal(semaphore);
                NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            }];
            [engine enqueueOperation:op];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        //3.获取备份文件的总长度
        long long totalBytes = 0;
        for (int i =0; i<allFilesArray.count; i++) {
            totalBytes += [FileTools getFileSize:allFilesArray[i]];
        }
        //4.上传文件
        NSOperationQueue *uploadQueue = [[NSOperationQueue alloc] init];
        [uploadQueue setMaxConcurrentOperationCount:1];
        ProgressView* progressView =[[ProgressBarViewController sharedInstance].progressBarDic objectForKey:self.taskId];
        progressView.totalBytes = totalBytes;
        if(totalBytes==0){ //如果备份的只是所有目录，没有任何文件，总字节数是0，设置为1字节
            totalBytes=1;
            progressView.transferedBytes=1;
            [progressView.progressBar setProgress:1 animated:NO];
        }
        for (int i =0; i<allFilesArray.count; i++){
            NSString *filePath =  allFilesArray[i];
            NSRange localCurrentDirRange = [filePath rangeOfString:self.localCurrentDir];//匹配得到的下标
            NSString *cpath;
            NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"%@",[g_sDataManager userName]];
            if (![self.targetDir isEqualToString:@"/"]) {
                uploadUrl = [uploadUrl stringByAppendingPathComponent:self.targetDir];
            }
            if (localCurrentDirRange.location != NSNotFound) {
                NSRange range = {localCurrentDirRange.length,[filePath length]-localCurrentDirRange.length};
                NSString *sourceDir = [filePath substringWithRange:range];//截取范围
                if ([sourceDir isEqualToString:[sourceDir lastPathComponent]]) {
                    cpath = uploadUrl;
                }else{
                    cpath = [uploadUrl stringByAppendingPathComponent:[sourceDir stringByDeletingLastPathComponent]];
                }
            }
            FileUploadByBlockTool *operation = [[FileUploadByBlockTool alloc] initWithLocalPath:allFilesArray[i] ip:[g_sDataManager requestHost]withServer:cpath withName:[g_sDataManager userName] withPass:[g_sDataManager password]];
            operation.taskId =  self.taskId;
            operation.totalBytes = totalBytes;
            operation.isBackup = YES;
            operation.fileName = [allFilesArray[i] lastPathComponent];
            [uploadQueue addOperation:operation];
        }
        
    }@catch (NSException *exception) {
        
    }
}
@end
