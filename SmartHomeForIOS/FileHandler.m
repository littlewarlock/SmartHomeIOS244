//
//  FileHandler.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/11/4.
//  Copyright © 2015年 riqiao. All rights reserved.
//

#import "FileHandler.h"
#import "FileDownloadTools.h"
#import "UploadFileTools.h"
#import "NSUUIDTool.h"
#import "FileUploadByBlockTool.h"

@implementation FileHandler

- (id) init
{
    self = [super init];
    if (self) {
        self.condition = [[NSCondition alloc]init];
    }
    return self;
}

#pragma mark -
#pragma mark downLoadFiles 下载文件的处理
- (void)downloadFiles:(NSOperationQueue *)downloadQueue selectedItemsDic: (NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath
{
    BOOL  operationIsExist= false;
    for (NSString *fileName in [selectedItemsDic allKeys]){
        operationIsExist= false;
        for (FileDownloadTools *operation in [downloadQueue operations]) {
            if ([operation.fileName isEqualToString:fileName]) {
                operationIsExist = true;
            }
        }
        if (!operationIsExist) {
            FileDownloadTools *operation = [[FileDownloadTools alloc] initWithFileInfo];
            TaskInfo* task = [[TaskInfo alloc] init];
            task.taskId = [NSUUIDTool gen_uuid];
            task.taskName =fileName;
            task.taskType = @"下载";
            operation.fileName = fileName;
            operation.filePath = cpath;
            operation.progressBarView = [ProgressBarViewController sharedInstance];
            operation.taskId = task.taskId;
            [downloadQueue addOperation:operation];
            [[ProgressBarViewController sharedInstance].taskDic  setObject:task forKey:task.taskId];
            [[ProgressBarViewController sharedInstance] addProgressBarRow:task];
        }
    }
    
}
- (void)uploadFile:(NSString*) fileName localFilePath:(NSString*)localFilePath    serverCpath:(NSString*)serverCpath
{
    NSString* requestHost = [g_sDataManager requestHost];
    NSRange range  = [requestHost rangeOfString:@":"];
    if (range.location != NSNotFound) {
        requestHost = [requestHost substringToIndex:range.location];
    }
    if (![localFilePath isEqualToString:@""] && ![localFilePath isEqualToString:@"/"]) {
        localFilePath = [localFilePath stringByAppendingString:@"/"];
        localFilePath = [localFilePath stringByAppendingString:fileName];
    }
    NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"%@/root/%@", requestHost,[g_sDataManager userName]];
    if (![serverCpath isEqualToString:@"/"]) {
        [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",serverCpath]];
    }
    
    UploadFileTools * ud = [[UploadFileTools alloc] initWithLocalPath:[localFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]  withServer:uploadUrl withName:FTP_USERNAME withPass:FTP_PASSWORD];
    
    TaskInfo* task = [[TaskInfo alloc] init];
    task.taskId = [NSUUIDTool gen_uuid];
    task.taskName =fileName;
    task.taskType = @"上传";
    ud.taskId =  task.taskId;
    [[ProgressBarViewController sharedInstance].taskDic setObject:task forKey:task.taskId];
    [[ProgressBarViewController sharedInstance] addProgressBarRow:task];
    [ud start];
}
#pragma mark -
#pragma mark deleteFiles 删除文件的处理
-(void)deleteFiles:(NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath
{    if(selectedItemsDic.count==0 ){
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择文件" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
    [alertView show];
    return ;
}
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    
    [dic setValue:[g_sDataManager userName] forKey:@"uname"];
    [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
    [dic setValue:cpath forKey:@"cpath"];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    NSString *delFileName =@"";
    BOOL isFirstFile =YES;
    for (NSString *fileName in [selectedItemsDic allKeys]){
        NSLog(@"%zi",selectedItemsDic.count);
        if(isFirstFile){
            delFileName =fileName;
            isFirstFile =NO;
        }else{
            delFileName =[NSString stringWithFormat:@"%@@%@",delFileName,fileName];
        }
    }
    [dic setValue:delFileName forKey:@"dname"];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_DELETE_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"删除成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallBack)]) {
                [self.fileHandlerDelegate requestSuccessCallBack];//调用委托方法
            }
            
        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"删除失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

#pragma mark -
#pragma mark shareFile 共享文件的处理
-(void)shareFile:(NSMutableDictionary*) selectedItemsDic cpath:(NSString*)cpath isShare:(NSString*) isShare{
    
    if(selectedItemsDic.count==0 ){
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择文件" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
    [alertView show];
    return ;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:[g_sDataManager userName] forKey:@"uname"];
    [dic setValue:cpath forKey:@"filePath"];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
    NSString *shareFileName =@"";
    BOOL isFirstFile =YES;
    for (NSString *fileName in [selectedItemsDic allKeys]){
        NSLog(@"%zi",selectedItemsDic.count);
        if(isFirstFile){
            shareFileName =fileName;
            isFirstFile =NO;
        }else{
            shareFileName =[NSString stringWithFormat:@"%@@%@",shareFileName,fileName];
        }
    }
    [dic setValue:shareFileName forKey:@"fileName"];
    [dic setValue:isShare forKey:@"isShare"];
    MKNetworkOperation *op = [engine operationWithPath:REQUEST_SHARE_URL params:dic httpMethod:@"POST" ssl:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"共享文件成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallBack)]) {
                [self.fileHandlerDelegate requestSuccessCallBack];//调用委托方法
            }
            
        }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"共享文件失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}
-(void)renameFile:(NSString*)fileName alertViewDelegate:(nullable id)alertViewDelegate{
    NSString *fileNameNoExt = [fileName stringByDeletingPathExtension];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"重命名文件名称" message:@"" delegate:alertViewDelegate cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    UITextField *textField=[alertView textFieldAtIndex:0];
    textField.text = fileNameNoExt;
    [alertView show];
}

-(void)createFolder :(nullable id)alertViewDelegate{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入文件夹名称" message:@"" delegate:alertViewDelegate cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
    [alertView show];
}


#pragma mark -
#pragma mark clickedButtonAtIndex alertView的委托处理方法
-(void) alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger opType = self.opType;
    if(buttonIndex ==0){
        switch (opType) {
            case 1://移动
            {
                [self signal:@"1"];
                break;
            }
            case 2://复制
            {
                [self signal:@"1"];
                break;
            }
            case 4:
            {
                //得到输入框
                UITextField *textField=[alertView textFieldAtIndex:0];
                NSString *folderName = textField.text;
                if([textField.text isEqualToString:@""] ){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入不能为空" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [alertView show];
                    return;
                }
                BOOL isExist =  NO;
                for(NSString *dicKey in self.tableDataDic) {
                    FileInfo  *fileInfo = [ self.tableDataDic objectForKey:dicKey];
                    if([fileInfo.fileName isEqualToString: folderName]){
                        isExist = YES;
                        break;
                    }
                }
                if(isExist){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文件已存在,请重新输入！" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [alertView show];
                    return;
                }
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                __block NSError *error = nil;
                [dic setValue:self.cpath forKey:@"cpath"];
                [dic setValue:[g_sDataManager userName] forKey:@"uname"];
                [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
                [dic setValue:folderName forKey:@"newName"];
                NSString* requestHost = [g_sDataManager requestHost];
                NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
                MKNetworkOperation *op = [engine operationWithPath:REQUEST_NEWFOLDER_URL params:dic httpMethod:@"POST" ssl:NO];
                [op addCompletionHandler:^(MKNetworkOperation *operation) {
                    NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                    if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"新建文件夹成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                        if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallBack)]) {
                            [self.fileHandlerDelegate requestSuccessCallBack];//调用委托方法
                        }
                        
                    }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"新建文件夹失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                    }
                }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                    NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
                }];
                [engine enqueueOperation:op];
                break;
            }
            case 5: //重命名文件名
            {
                UITextField *textField=[alertView textFieldAtIndex:0];
                if([textField.text isEqualToString:@""] ){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"名称不能为空" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [alertView show];
                    return;
                }
                NSString * fullFileName = self.selectedFileName;
                NSString *fileName = textField.text;
                NSString *extName = [fullFileName pathExtension];
                if(![extName isEqualToString:@""])
                {
                    fileName = [fileName stringByAppendingString:@"."];
                    fileName =[fileName stringByAppendingString:extName];
                }
                BOOL isExist =  NO;
                for(NSString *dicKey in  self.tableDataDic) {
                    FileInfo  *fileInfo = [ self.tableDataDic objectForKey:dicKey];
                    if([fileInfo.fileName isEqualToString: fileName]){
                        isExist = YES;
                        break;
                    }
                }
                if(isExist){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文件已存在,请重新输入！" message:@"" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消",nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                    [alertView show];
                    return;
                }
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                __block NSError *error = nil;
                NSString * newName = nil;
                if ([self.cpath isEqualToString:@"/"]) {
                    newName = [self.cpath stringByAppendingString:fileName];
                    
                }else if([self.cpath isEqualToString:@""]){
                    newName = self.cpath;
                }else if([self.cpath length]>1){
                    NSString *lastChar =[self.cpath substringFromIndex:self.cpath.length];
                    if(![lastChar isEqualToString:@"/"])
                    {
                        newName = [self.cpath stringByAppendingString:@"/"];
                        newName = [newName stringByAppendingString:fileName];
                    }
                    
                }
                NSString * oldName = nil;
                if ([self.cpath isEqualToString:@"/"]) {
                    oldName = [self.cpath stringByAppendingString:fullFileName];
                }else if(![self.cpath isEqualToString:@""])
                {
                    oldName = [self.cpath stringByAppendingString:@"/"];
                    oldName =[oldName stringByAppendingString:fullFileName];
                }
                //oldName=[oldName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //newName=[newName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [dic setValue:[g_sDataManager userName] forKey:@"uname"];
                [dic setValue:[g_sDataManager password] forKey:@"upasswd"];
                [dic setValue:newName forKey:@"newname"];
                [dic setValue:oldName forKey:@"oldname"];
                NSString* requestHost = [g_sDataManager requestHost];
                NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
                MKNetworkOperation *op = [engine operationWithPath:REQUEST_RENAME_URL params:dic httpMethod:@"POST" ssl:NO];
                [op addCompletionHandler:^(MKNetworkOperation *operation) {
                    NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                    if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//操作成功
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名成功" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                        if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallBack)]) {
                            [self.fileHandlerDelegate requestSuccessCallBack];//调用委托方法
                        }
                        
                    }else if ([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                    }else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                        [alert show];
                    }
                }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                    NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"重命名失败" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
                    [alert show];
                }];
                [engine enqueueOperation:op];
                break;
            }

            default:
                break;
        }
    }else if(buttonIndex==1){ //如果点击取消时
        switch (opType) {
            case 1://移动
            {
                [self signal:@"0"];
                break;
            }
            case 2://复制
            {
                [self signal:@"0"];
                break;
            }
                
            default:
                break;
        }
    }
}
- (void)uploadFileWithHttp:(NSOperationQueue *)uploadQueue fileName:(NSString*) fileName localFilePath:(NSString*)localFilePath    serverCpath:(NSString*)serverCpath{
    if (![localFilePath isEqualToString:@""] && ![localFilePath isEqualToString:@"/"]) {
        localFilePath = [localFilePath stringByAppendingString:@"/"];
        localFilePath = [localFilePath stringByAppendingString:fileName];
    }
    NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"/%@",[g_sDataManager userName]];
    if (![serverCpath isEqualToString:@"/"]) {
        [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",serverCpath]];
    }
    BOOL operationIsExist = NO;
//    for (FileUploadByBlockTool *operation in [uploadQueue operations]) {
//        if ([operation.fileName isEqualToString:fileName]) {
//            operationIsExist = YES;
//        }
//    }
    if (!operationIsExist) {
        FileUploadByBlockTool *operation = [[FileUploadByBlockTool alloc] initWithLocalPath:localFilePath ip:[g_sDataManager requestHost]withServer:uploadUrl withName:[g_sDataManager userName] withPass:[g_sDataManager password]];
        TaskInfo* task = [[TaskInfo alloc] init];
        task.taskId = [NSUUIDTool gen_uuid];
        task.taskName =fileName;
        task.taskType = @"上传";
        operation.taskId =  task.taskId;
        operation.fileName = fileName;
        operation.taskId = task.taskId;
        [uploadQueue addOperation:operation];
        [[ProgressBarViewController sharedInstance].taskDic  setObject:task forKey:task.taskId];
        [[ProgressBarViewController sharedInstance] addProgressBarRow:task];
    }
    
}

-(void)copyFiles:(NSMutableDictionary*) paramsDic{
    [self.condition lock];
    NSString *targetPath;
    NSString *sourcePath;
    NSMutableDictionary *selectedItemsDic;
    if([[paramsDic allKeys]containsObject:@"targetPath"]){
        targetPath = [paramsDic objectForKey:@"targetPath"];
    }
    if([[paramsDic allKeys]containsObject:@"selectedItemsDic"]){
        selectedItemsDic = [paramsDic objectForKey:@"selectedItemsDic"];
    }
    if ([[paramsDic allKeys]containsObject:@"sourcePath"]) {
        sourcePath =[paramsDic objectForKey:@"sourcePath"];
    }
    if(selectedItemsDic.count>0){
        for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
            NSDictionary * filesDic = [self getAllFilesByPath:targetPath];
            if (filesDic && [[filesDic allKeys] containsObject:fileNameTmp]) { //如果目标目录下已存在该文件，则等待
                NSString *message = [NSString stringWithFormat:@"目标目录下已经存在一个名为：%@的文件，覆盖掉原有的目录吗？",fileNameTmp];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil] ;
                    [alert show];
                });
                [self.condition wait];
                if ([self.flag isEqualToString:@"0"]) {
                    continue;
                }
            }
            NSString *postTargetPath;
            NSString *postSourcePath;
            postTargetPath = targetPath;
            postSourcePath = sourcePath;
            if ([postTargetPath isEqualToString:@""] || ![postTargetPath isEqualToString:@"/"]) {
                postTargetPath=[postTargetPath stringByAppendingString :@"/"];
            }
            postTargetPath=[postTargetPath stringByAppendingString :fileNameTmp];
            if ([postSourcePath isEqualToString:@""] || ![postSourcePath isEqualToString:@"/"]) {
                postSourcePath=[postSourcePath stringByAppendingString :@"/"];
            }
            postSourcePath = [postSourcePath stringByAppendingString :fileNameTmp];
            NSString* requestHost = [g_sDataManager requestHost];
            NSString* requestUrl = [NSString stringWithFormat:@"http://%@/%@",requestHost,REQUEST_COPY_URL];
            
            NSURL *copyFileUrl = [NSURL URLWithString:[requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:copyFileUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
            [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
            NSError * copyFileError = nil;
            NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&sourcepath=%@&targetpath=%@",[g_sDataManager userName],[g_sDataManager password],postSourcePath,postTargetPath];
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
            [request setHTTPBody:postData];
            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&copyFileError];
            if (!copyFileError) {
                NSError * jsonError=nil;
                NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:received options:kNilOptions error:&jsonError];
                NSLog(@"responseJSON。。。。。=======%@",responseJSON);
                if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//获取目录成功
                {

                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"复制成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil] ;
            [alert show];
        });
    }
    [self.condition unlock];
}

#pragma mark -
#pragma mark moveFiles 复制文件的处理
-(void)moveFiles:(NSMutableDictionary*) paramsDic{
    [self.condition lock];
    NSString *targetPath;
    NSString *sourcePath;
    NSMutableDictionary *selectedItemsDic;
    if([[paramsDic allKeys]containsObject:@"targetPath"]){
        targetPath = [paramsDic objectForKey:@"targetPath"];
    }
    if([[paramsDic allKeys]containsObject:@"selectedItemsDic"]){
        selectedItemsDic = [paramsDic objectForKey:@"selectedItemsDic"];
    }
    if ([[paramsDic allKeys]containsObject:@"sourcePath"]) {
        sourcePath =[paramsDic objectForKey:@"sourcePath"];
    }
    if(selectedItemsDic.count>0){
        for (NSString *fileNameTmp in [selectedItemsDic allKeys]){
            NSDictionary * filesDic = [self getAllFilesByPath:targetPath];
            if (filesDic && [[filesDic allKeys] containsObject:fileNameTmp]) { //如果目标目录下已存在该文件，则等待
                NSString *message = [NSString stringWithFormat:@"目标目录下已经存在一个名为：%@的文件，覆盖掉原有的目录吗？",fileNameTmp];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil] ;
                    [alert show];
                });
                [self.condition wait];
                if ([self.flag isEqualToString:@"0"]) {
                    continue;
                }
            }
            NSString *postTargetPath;
            NSString *postSourcePath;
            postTargetPath = targetPath;
            postSourcePath = sourcePath;
            if ([postTargetPath isEqualToString:@""] || ![postTargetPath isEqualToString:@"/"]) {
                postTargetPath=[postTargetPath stringByAppendingString :@"/"];
            }
            postTargetPath=[postTargetPath stringByAppendingString :fileNameTmp];
            if ([postSourcePath isEqualToString:@""] || ![postSourcePath isEqualToString:@"/"]) {
                postSourcePath=[postSourcePath stringByAppendingString :@"/"];
            }
            postSourcePath = [postSourcePath stringByAppendingString :fileNameTmp];
            NSString* requestHost = [g_sDataManager requestHost];
            NSString* requestUrl = [NSString stringWithFormat:@"http://%@/%@",requestHost,REQUEST_MOVE_URL];
            
            NSURL *copyFileUrl = [NSURL URLWithString:[requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:copyFileUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
            [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
            NSError * copyFileError = nil;
            NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&sourcepath=%@&targetpath=%@",[g_sDataManager userName],[g_sDataManager password],postSourcePath,postTargetPath];
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
            [request setHTTPBody:postData];
            NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&copyFileError];
            if (!copyFileError) {
                NSError * jsonError=nil;
                NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:received options:kNilOptions error:&jsonError];
                NSLog(@"responseJSON。。。。。=======%@",responseJSON);
                if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//获取目录成功
                {
                    
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"移动成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil] ;
            [alert show];
            if ([self.fileHandlerDelegate respondsToSelector:@selector(requestSuccessCallBack)]) {
                [self.fileHandlerDelegate requestSuccessCallBack];//调用委托方法
            }
        });
    }
    [self.condition unlock];
}
#pragma mark -
#pragma mark getAllFilesByPath 返回指定目录下的所有文件
-(NSDictionary*)getAllFilesByPath:(NSString*)path{
    NSMutableDictionary *filesDic = [[NSMutableDictionary alloc] init];
    NSString* requestHost = [g_sDataManager requestHost];
    NSString* requestUrl = [NSString stringWithFormat:@"http://%@/%@",requestHost,REQUEST_FETCH_URL];
    
    NSURL *fetchFileUrl = [NSURL URLWithString:[requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:fetchFileUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSError * fetchFileError = nil;
    NSString* post=[NSString stringWithFormat:@"uname=%@&upasswd=%@&cpath=%@",[g_sDataManager userName],[g_sDataManager password],path];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];//设置参数
    [request setHTTPBody:postData];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&fetchFileError];
    if (!fetchFileError) {
        NSError * jsonError=nil;
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:received options:kNilOptions error:&jsonError];
        NSLog(@"responseJSON。。。。。=======%@",responseJSON);
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"value"]] isEqualToString: @"1"])//获取目录成功
        {
            NSArray *responseJSONResult=responseJSON[@"result"];
            if([responseJSONResult isEqual:@"file not exit"]){
                return nil;
            }
            [responseJSONResult enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                if (responseJSONResult && responseJSONResult.count>0) {
                    FileInfo *fileInfo = [[FileInfo alloc] init];
                    fileInfo.fileName = dict[@"fileName"];
                    fileInfo.fileSize = dict[@"fileSize"];
                    fileInfo.fileChangeTime = dict[ @"fileChangeTime"];
                    fileInfo.fileType = dict[@"fileType"];
                    fileInfo.fileSubtype =@"folder";
                    fileInfo.isShare = dict[@"isShare"];
                    [filesDic setObject:fileInfo forKey:fileInfo.fileName];
                }else{
                    *stop = YES;
                }
            }];
        }
    }
    return filesDic;
}

-(void)signal:(NSString*)flag{
    self.flag = flag;
    [self.condition broadcast];
}
@end
