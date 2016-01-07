//
//  LocalFileViewController.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/6.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "UIButton+UIButtonExt.h"
#import "LocalFileViewController.h"
#import "LoginViewController.h"
#import "FileInfo.h"
#import "VideoViewController.h"
#import "AudioTableViewController.h"
#import "DocumentViewController.h"
#import "FileTools.h"
#import "FileCopyAndMoveTools.h"
#import "FileDownloadTools.h"
#import "KxMenu.h"
#import "UIHelper.h"
#import "UploadFileTools.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "CustomActionSheet.h"
#import "AudioViewController.h"
#import "KxMovieView.h"
#import "DeckTableViewController.h"
#import "BackupTool.h"
#import "FileUploadByBlockTool.h"
#import "AlbumCollectionViewController.h"
#define AU_Cell_Height 52



@interface LocalFileViewController ()
{
    UIBarButtonItem *leftBtn;
    UIButton* rightBtn;
    NSMutableDictionary* selectedTableDataDic; //存储所有选中的行的文件名
    FileDialogViewController *fileDialog;
    NSOperationQueue *downLoadQueue;
    NSOperationQueue *uploadQueue;
    NSOperationQueue *copyAndMoveQueue;
    CustomActionSheet *sheet;
    LocalFileHandler *localFileHandler;
    BOOL isCheckedAll;
    NSInteger currentModel; //0,表示正常模式 1，表示编辑模式 区分底部不同按钮的处理事件
    NSMutableArray *pics;   //照片
    NSMutableArray *audiosUrl;  //音频
    NSMutableArray *audioPlayerThumbsArray;//音频缩略图
    MWPhoto *photo;
    NSArray *audioArray;
    NSArray *videoArray;
    NSArray *picArray;
}
@property KxMovieView *kxvc;
@end

@implementation LocalFileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"本地文档";
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame =CGRectMake(200, 0, 32, 32);
    [left setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [left addTarget: self action: @selector(returnBeforeWindowAction:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* itemLeft=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=itemLeft;
    
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame =CGRectMake(200, 0, 50, 30);
    [rightBtn setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn addTarget: self action: @selector(switchTableViewModel:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=item;
    [self.fileListTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.fileListTableView setSeparatorInset:UIEdgeInsetsZero]  ;
    selectedTableDataDic = [[NSMutableDictionary alloc] init];
    
    downLoadQueue = [[NSOperationQueue alloc] init];
    [downLoadQueue setMaxConcurrentOperationCount:1];
    uploadQueue = [[NSOperationQueue alloc] init];
    [uploadQueue setMaxConcurrentOperationCount:1];
    copyAndMoveQueue = [[NSOperationQueue alloc] init];
    [copyAndMoveQueue setMaxConcurrentOperationCount:1];
    
    localFileHandler = [[LocalFileHandler alloc] init];
    localFileHandler.localFileHandlerDelegate = self;
    localFileHandler.tableDataDic = self.tableDataDic;
    
    audioArray=  [NSArray arrayWithObjects:@"mp3", nil];
    videoArray=  [NSArray arrayWithObjects:@"mp4",@"mov",@"m4v",@"wav",@"flac",@"ape",@"wma",
                  @"avi",@"wmv",@"rmvb",@"flv",@"f4v",@"swf",@"mkv",@"dat",@"vob",@"mts",@"ogg",@"mpg",@"h264", nil];
    picArray=  [NSArray arrayWithObjects:@"jpg",@"jpeg",@"png", nil];
    pics = [[NSMutableArray alloc] init];
    audiosUrl = [[NSMutableArray alloc] init];
    audioPlayerThumbsArray = [[NSMutableArray alloc] init];
    [self loadFileData];
}


-(void) viewDidAppear:(BOOL)animated
{
    [pics removeAllObjects];
    [audiosUrl removeAllObjects];
    [audioPlayerThumbsArray removeAllObjects];
    [selectedTableDataDic removeAllObjects];
    [self loadFileData];
}

#pragma mark -
#pragma mark footerButtonEventHandleAction 底部按钮点击处理事件
- (void)footerButtonEventHandleAction:(id)sender {
    if(currentModel==0){//正常模式下的处理
        if(sender==self.footerBtn_1){ //主页
            if(self.isOpenFromAppList){
                DeckTableViewController* leftController = [[DeckTableViewController alloc] initWithNibName:@"DeckTableViewController" bundle:nil];
                leftController = [[UINavigationController alloc] initWithRootViewController:leftController];
                
                UIViewController *centerController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
                
                centerController = [[UINavigationController alloc] initWithRootViewController:centerController];
                
                IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController
                                                                                                leftViewController:leftController];
                
                deckController.delegateMode = IIViewDeckDelegateOnly;
                // self.window.rootViewController = deckController;
                [self presentViewController:deckController animated:NO completion:nil];
            }else{
                LocalFileViewController *localFileView = [[LocalFileViewController alloc] initWithNibName:@"LocalFileViewController" bundle:nil];
                UINavigationController *localFileNav = [[UINavigationController alloc] initWithRootViewController:localFileView];
                [self presentViewController:localFileNav animated:NO completion:nil];
            }
        }
        else if(sender==self.footerBtn_2){//下载
            [self downloadAction];
        }
        else if(sender==self.footerBtn_3){//刷新
            [self requestSuccessCallback];
        }
        else if(sender==self.footerBtn_4){//新建文件夹
            localFileHandler.opType=6;
            localFileHandler.cpath = self.cpath;
            localFileHandler.tableDataDic = self.tableDataDic;
            [localFileHandler createFolderAction];
            self.fileListTableView.allowsMultipleSelectionDuringEditing=NO;
        }
    }else if(currentModel==1){
        if(sender==self.footerBtn_1){ //全选
            isCheckedAll = !isCheckedAll;
            if (isCheckedAll) {
                [self selectAllRows];
                UIImage *image = [UIImage imageNamed:@"checkall"];
                [self.footerBtn_1 setImage:image forState:(UIControlStateNormal)];
            }else{
                [self deSelectAllRows];
                UIImage *image = [UIImage imageNamed:@"checkbox-down"];
                [self.footerBtn_1 setImage:image forState:(UIControlStateNormal)];
            }
        }
        else if(sender==self.footerBtn_2){//上传
            [self uploadAction];
        }
        else if(sender==self.footerBtn_3){//备份
            self.opType = @"8";
            NSString* userName = [g_sDataManager userName];
            if (!userName || [userName isEqualToString:@""]) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传文件需要先登录，请先登录！" delegate:self cancelButtonTitle:@"现在登录" otherButtonTitles:@"稍后登录",nil];
                [alert show];
                return;
            }
            if (selectedTableDataDic.count==0){
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择要备份的文件或文件夹！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                return;
            }else{
                fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
                fileDialog.isShowFile =YES;
                fileDialog.isServerFile = YES;
                fileDialog.isSelectFileMode =NO;
                fileDialog.cpath =@"/";
                fileDialog.fileDialogDelegate = self;
                [self.navigationController pushViewController:fileDialog  animated:YES];
            }
        }
        else if(sender==self.footerBtn_4){//更多
            sheet= [CustomActionSheet styleDefault];
            sheet.delegate = self;
            if (selectedTableDataDic.count==0) {
                [sheet setButtonState:1 buttonState:NO];
                [sheet setButtonState:2 buttonState:NO];
                [sheet setButtonState:3 buttonState:NO];
                [sheet setButtonState:4 buttonState:NO];
            }else if(selectedTableDataDic.count==1) {
                [sheet setButtonState:1 buttonState:YES];
                [sheet setButtonState:2 buttonState:YES];
                [sheet setButtonState:3 buttonState:YES];
                [sheet setButtonState:4 buttonState:YES];
            }else if(selectedTableDataDic.count>=2) {
                [sheet setButtonState:1 buttonState:YES];
                [sheet setButtonState:2 buttonState:YES];
                [sheet setButtonState:3 buttonState:NO];
                [sheet setButtonState:4 buttonState:YES];
            }
            [sheet showSheet:self];
        }
    }
}

-(void)uploadAction{
    self.opType=@"2";
    NSString* userName = [g_sDataManager userName];
    if (!userName || [userName isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上传文件需要先登录，请先登录！" delegate:self cancelButtonTitle:@"现在登录" otherButtonTitles:@"稍后登录",nil];
        [alert show];
        return;
    }
    if (selectedTableDataDic.count>0) {
        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
        fileDialog.isShowFile =YES;
        fileDialog.isServerFile = YES;
        fileDialog.isSelectFileMode =NO;
        fileDialog.cpath =@"/";
        fileDialog.fileDialogDelegate = self;
        [self.navigationController pushViewController:fileDialog  animated:YES];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请先选择文件" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}
-(void)downloadAction{
    localFileHandler.opType=7;
    self.opType=@"7";
    //如果用户未登录提示用户登录
    NSString* userName = [g_sDataManager userName];
    if (!userName || [userName isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"下载文件需要先登录，请先登录！" delegate:self cancelButtonTitle:@"现在登录" otherButtonTitles:@"稍后登录",nil];
        [alert show];
    }else{
        fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
        fileDialog.isShowFile =YES;
        fileDialog.isServerFile = YES;
        fileDialog.isSelectFileMode = YES;
        fileDialog.fileDialogDelegate = self;
        fileDialog.cpath = @"/";
        [self.navigationController pushViewController: fileDialog animated:YES ];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableDataDic.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileInfo *fileinfo = (FileInfo *)[_tableDataDic objectForKey: [NSString stringWithFormat:@"%zi",indexPath.row]];
    FDTableViewCell *cell = (FDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:fileinfo.fileName];
    if (cell == nil) {
        cell = [[FDTableViewCell alloc] initWithFile:fileinfo];
    }
    if ([cell.fileinfo.fileType isEqualToString:@"folder"]) {
        UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryButton.frame = CGRectMake(100,5,50,50);
        [accessoryButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
        [accessoryButton addTarget:self action:@selector(accessoryButtonIsTapped:event:)forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = accessoryButton;
    }
    
//    if([picArray containsObject:[[fileinfo.fileUrl pathExtension] lowercaseString]]){
//        [pics addObject:fileinfo.fileUrl];
//    }else if([audioArray containsObject:[[fileinfo.fileUrl pathExtension] lowercaseString]]){
//        [audiosUrl addObject:fileinfo.fileUrl];
//        NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:[NSURL fileURLWithPath:fileinfo.fileUrl]];
//        UIImage *image = [audioDataDic objectForKey:@"Artwork"];
//        if (image) {
//            [audioPlayerThumbsArray addObject:image];
//        }else{
//            [audioPlayerThumbsArray addObject:[UIImage imageNamed:@"audio_default"]];
//        }
//    }
    BOOL isAudio = [audioArray containsObject:[[cell.fileinfo.fileUrl pathExtension] lowercaseString]];
    BOOL isVideo = [videoArray containsObject:[[cell.fileinfo.fileUrl pathExtension] lowercaseString]];
    BOOL isPic = [picArray containsObject:[[cell.fileinfo.fileUrl pathExtension] lowercaseString]];
    
    if(isAudio){
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAudio:)];
        [cell addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
    }else if(isVideo){
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo:)];
        [cell addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
    }else if(isPic){
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPic:)];
        [cell addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
    }else{
        if(![cell.fileinfo.fileType isEqualToString:@"folder"]){
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOther:)];
            [cell addGestureRecognizer:tapRecognizer];
            tapRecognizer.delegate = self;
        }
    }
    
    cell.fileinfo = fileinfo;
    [cell setDetailText];
    return cell;
}
#pragma mark -
#pragma mark UITableViewDelegate协议中的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:self.fileListTableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark 右侧箭头点击时的处理事件
- (void)accessoryButtonIsTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.fileListTableView];
    NSIndexPath *indexPath = [self.fileListTableView indexPathForRowAtPoint:currentTouchPosition];
    if(indexPath != nil)
    {
        [self tableView:self.fileListTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}
- (BOOL)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.fileListTableView.allowsMultipleSelectionDuringEditing) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileInfo *fileinfo = (FileInfo *)[_tableDataDic objectForKey: [NSString stringWithFormat:@"%zi",indexPath.row]];
    //    如果是文件夹的时候进入下一层画面
    if(!self.fileListTableView.allowsMultipleSelectionDuringEditing){
        //如果是根目录点击的是相册cell则打开相册view
        if([fileinfo.fileType isEqualToString:@"folder"] && [self.cpath isEqualToString:kDocument_Folder] && (indexPath.row==0) ){
            
            if(self.isOpenFromAppList){
                AlbumCollectionViewController *localFileView = [[AlbumCollectionViewController alloc] initWithNibName:@"AlbumCollectionViewController" bundle:nil];
                localFileView.isOpenFromAppList = YES;
                [self.navigationController pushViewController:localFileView  animated:YES];
            }else{
                AlbumCollectionViewController *localFileView = [[AlbumCollectionViewController alloc] initWithNibName:@"AlbumCollectionViewController" bundle:nil];
                UINavigationController *localFileNav =[[UINavigationController alloc]initWithRootViewController:localFileView];
                [self.navigationController presentViewController:localFileNav animated:NO completion:nil];
            }
            
        }
        else if ([fileinfo.fileType isEqualToString:@"folder"] )
        {
            if(self.isOpenFromAppList){
                LocalFileViewController *localFileView = [[LocalFileViewController alloc] initWithNibName:@"LocalFileViewController" bundle:nil];
                localFileView.isOpenFromAppList =YES;
                localFileView.cpath =[self.cpath stringByAppendingPathComponent: fileinfo.fileName];
                [self.navigationController pushViewController:localFileView  animated:YES];
            }else{
                LocalFileViewController *localFileView = [[LocalFileViewController alloc] initWithNibName:@"LocalFileViewController" bundle:nil];
                localFileView.folderLocationStr = [NSString stringWithFormat:@"%@%@/", self.folderLocationStr, fileinfo.fileName];
                localFileView.cpath = [NSString stringWithFormat:@"%@/%@", self.cpath , fileinfo.fileName];
                localFileView.cfolder = fileinfo.fileName;
                UINavigationController *localFileNav =[[UINavigationController alloc]initWithRootViewController:localFileView];
                [self.navigationController presentViewController:localFileNav animated:NO completion:nil];
            }
        }
    }else{
        if ([fileinfo.fileType isEqualToString:@"folder"] && [self.cpath isEqualToString:kDocument_Folder] && (indexPath.row==0) ) {
            return;
        }
        FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
        self.curCel =cell;
        if(cell && !([[selectedTableDataDic allKeys] containsObject:cell.fileinfo.fileUrl])){
            [selectedTableDataDic setObject:cell.fileinfo.fileUrl forKey:cell.fileinfo.fileUrl];
            [self setFooterButtonState]; //更新按钮的状态
            if([self.cpath isEqualToString:kDocument_Folder] ){
                if (selectedTableDataDic.count>0 && selectedTableDataDic.count == self.tableDataDic.count-1) {
                    isCheckedAll = YES;
                    UIImage *image = [UIImage imageNamed:@"checkall"];
                    [self.footerBtn_1 setImage:image forState:(UIControlStateNormal)];
                }
            }else{
                if (selectedTableDataDic.count>0 && selectedTableDataDic.count == self.tableDataDic.count) {
                    isCheckedAll = YES;
                    UIImage *image = [UIImage imageNamed:@"checkall"];
                    [self.footerBtn_1 setImage:image forState:(UIControlStateNormal)];
                }
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * indexP =[NSIndexPath indexPathForRow:0 inSection:0];
    if (indexP == indexPath && [self.cpath isEqualToString:kDocument_Folder]) {
        return NO;
    }
    return YES;
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
//UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AU_Cell_Height;
}

#pragma mark -
#pragma mark handleTap 点击图片时触发的事件
- (void)showPic:(UITapGestureRecognizer *)sender
{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
            BOOL displayActionButton = NO;
            BOOL displaySelectionButtons = NO;
            BOOL displayNavArrows = NO;
            BOOL enableGrid = NO;
            BOOL startOnGrid = NO;
            BOOL autoPlayOnAppear = NO;
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = displayActionButton;
            browser.displayNavArrows = displayNavArrows;
            browser.displaySelectionButtons = displaySelectionButtons;
            browser.alwaysShowControls = displaySelectionButtons;
            browser.zoomPhotosToFill = YES;
            browser.enableGrid = enableGrid;
            browser.startOnGrid = startOnGrid;
            browser.enableSwipeToDismiss = NO;
            browser.autoPlayOnAppear = autoPlayOnAppear;
            NSUInteger picIndex= 0;
            for(int i =0;i<pics.count;i++){
                if([[pics objectAtIndex: i] isEqualToString:self.curCel.fileinfo.fileUrl]){
                    picIndex = i;
                }
            }
            NSUInteger index= picIndex;//[pics indexOfObject:cell.fileinfo.fileName];
            [browser setCurrentPhotoIndex:index];
            [self.navigationController pushViewController:browser animated:YES];
        }
    }
}

#pragma mark -
#pragma mark playVideo 播放视频触发的事件
- (void)playVideo:(UITapGestureRecognizer *)sender
{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
//            KxMovieView *playerView= [[KxMovieView alloc] initWithNibName:@"KxMovieView" bundle:nil];
//            playerView.filePath =(NSMutableString*)self.curCel.fileinfo.fileUrl;
//            [self.navigationController pushViewController:playerView animated:YES ];
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
            if (self.kxvc != NULL) {
                [self.kxvc.view removeFromSuperview ];
            }
            self.kxvc = [KxMovieView movieViewControllerWithContentPath:(NSMutableString*)self.curCel.fileinfo.fileUrl parameters:parameters];
            [self addChildViewController:self.kxvc];
            self.kxvc.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height);
            self.kxvc.filePath = (NSMutableString*)self.curCel.fileinfo.fileUrl;
            [self.kxvc fullscreenMode:nil];
            [self.kxvc bottomBarAppears];
            [self.view addSubview:self.kxvc.view];
            self.navigationController.navigationBarHidden = YES;
        }
    }
}

- (BOOL)prefersStatusBarHidden
{
    if(self.navigationController.navigationBarHidden){
        return YES;//隐藏为YES，显示为NO
    }
    else{
        return NO;
    }
}

#pragma mark -
#pragma mark playAudio 播放音频触发的事件
- (void)playAudio:(UITapGestureRecognizer *)sender
{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
            AudioViewController *audioPlayerView= [[AudioViewController alloc] initWithNibName:@"AudioViewController" bundle:nil];
            
            audioPlayerView.playerURL = audiosUrl;
            
            NSUInteger  audioIndex =0;
            
            for(int i =0;i<audiosUrl.count;i++){
                if([[audiosUrl objectAtIndex: i] isEqualToString:self.curCel.fileinfo.fileUrl]){
                    audioIndex = i;
                }
            }
            
            audioPlayerView.songIndex =audioIndex;
            audioPlayerView.picURL =audioPlayerThumbsArray;
            audioPlayerView.netOrLocalFlag =@"1";
            
            if(self.isOpenFromAppList){
                audioPlayerView.isOpenFromAppList = YES;
                [self.navigationController pushViewController:audioPlayerView  animated:YES];
            }else{
                UINavigationController *audioPlayerViewNav =[[UINavigationController alloc]initWithRootViewController:audioPlayerView];
                [self.navigationController presentViewController:audioPlayerViewNav animated:NO completion:nil];
            }
            
            //[self presentViewController:audioPlayerView animated:YES completion:nil];
        }
    }
    
}

#pragma mark -
#pragma mark showOther 打开其他格式文件触发的事件
- (void)showOther:(UITapGestureRecognizer *)sender
{
    CGPoint initialPinchPoint = [sender locationInView:self.fileListTableView];
    NSIndexPath* tappedCellPath = [self.fileListTableView  indexPathForRowAtPoint:initialPinchPoint];
    if(sender.state == UIGestureRecognizerStateEnded && !self.fileListTableView.allowsMultipleSelection)
    {
        if(tappedCellPath)
        {
            self.curCel = (FDTableViewCell* )[self.fileListTableView cellForRowAtIndexPath:tappedCellPath];
            NSFileManager *fileManager =[NSFileManager defaultManager];
            NSString *docPath = self.curCel.fileinfo.fileUrl;
            if(![fileManager fileExistsAtPath:docPath]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
                [alert show];
            }else{
                self.documentInteractionController =  [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:docPath]];
                [self.documentInteractionController setDelegate:self];
                if (![self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请安装打开该类文件的应用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
                    [alert show];
                }
            }
        }
    }
}
#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return pics.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < pics.count)
    {
        UIImage *image = [[UIImage alloc]init]; //创建image
        image = [image initWithContentsOfFile:pics[index]]; //获取图片
        photo = [MWPhoto photoWithImage:image];
        return photo;
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return false;
}


- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

//加载本地文件数据
- (void)loadFileData
{
    NSString* documentsPath=@"";
    if(self.cpath!=nil && [self.cpath length]>0)
    {
        documentsPath =self.cpath;
        NSLog(@"documentsPath=%@",documentsPath);
    }
    else
    {
        documentsPath=kDocument_Folder;
    }
    self.tableDataDic = [FileTools getAllFiles:documentsPath skipDescendents:YES isShowAlbum:YES]; //根据路径获取该路径下的文件和目录
    self.cpath = documentsPath;
    
    
    NSEnumerator *enumerator = [self.tableDataDic keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        FileInfo *fileinfo = (FileInfo*)[self.tableDataDic objectForKey:key];
        if([picArray containsObject:[[fileinfo.fileUrl pathExtension] lowercaseString]]){
            [pics addObject:fileinfo.fileUrl];
        }else if([audioArray containsObject:[[fileinfo.fileUrl pathExtension] lowercaseString]]){
            [audiosUrl addObject:fileinfo.fileUrl];
            NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:[NSURL fileURLWithPath:fileinfo.fileUrl]];
            UIImage *image = [audioDataDic objectForKey:@"Artwork"];
            if (image) {
                [audioPlayerThumbsArray addObject:image];
            }else{
                [audioPlayerThumbsArray addObject:[UIImage imageNamed:@"audio_default"]];
            }
        }
    }
    
    [_fileListTableView reloadData];
}

- (void)returnBeforeWindowAction:(id)sender {
    if (self.isOpenFromAppList){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
    if(cell && [[selectedTableDataDic allKeys] containsObject:cell.fileinfo.fileUrl]){
        [selectedTableDataDic removeObjectForKey:cell.fileinfo.fileUrl];
        [self setFooterButtonState]; //更新按钮的状态
        isCheckedAll = NO;
        UIImage *image = [UIImage imageNamed:@"checkbox-down"];
        [self.footerBtn_1 setImage:image forState:(UIControlStateNormal)];
    }
}

#pragma mark -
#pragma mark setFooterButtonState 设置底部按钮的状态
- (void)setFooterButtonState {
    if(selectedTableDataDic.count>0){
        BOOL isContainFoler = NO;
        NSFileManager* fm = [NSFileManager defaultManager];
        for (NSString *fileUrl in [selectedTableDataDic allKeys]){
            [fm fileExistsAtPath:fileUrl isDirectory:&isContainFoler];
            if (isContainFoler) {
                break;
            }
        }
        if (isContainFoler) {//如果包含文件夹则上传按钮禁用
            UIImage *image2 = [UIImage imageNamed:@"dounload-prohibt"];
            [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
            self.footerBtn_2.enabled = NO;
        }else{
            UIImage *image2 = [UIImage imageNamed:@"upload"];
            [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
            self.footerBtn_2.enabled = YES;
        }
        self.footerBtn_3.enabled = YES;
    }else{
        UIImage *image2 = [UIImage imageNamed:@"dounload-prohibt"];
        UIImage *image3 = [UIImage imageNamed:@"share-prohibt"];
        [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
        self.footerBtn_2.enabled = NO;
        [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
        self.footerBtn_3.enabled = NO;
    }
}

#pragma mark -
#pragma mark switchTableViewModel 设置TableView的状态（可选、不可选）
- (void)switchTableViewModel:(UIBarButtonItem *)sender {
    self.fileListTableView.allowsMultipleSelectionDuringEditing=!self.fileListTableView.allowsMultipleSelectionDuringEditing;
    if (self.fileListTableView.allowsMultipleSelectionDuringEditing) {
        self.fileListTableView.allowsMultipleSelectionDuringEditing=YES;
        currentModel = 1;
        [self.fileListTableView setEditing:YES animated:YES];
        [rightBtn setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1] forState:UIControlStateNormal];
        [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
        UIImage *image1 = [UIImage imageNamed:@"checkbox-down"];
        UIImage *image2 = [UIImage imageNamed:@"dounload-prohibt"];
        UIImage *image3 = [UIImage imageNamed:@"share-prohibt"];
        UIImage *image4 = [UIImage imageNamed:@"more"];
        [self.footerBtn_1 setImage:image1 forState:(UIControlStateNormal)];
        self.footerLabel_1.text=@"全选";
        [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
        self.footerLabel_2.text=@"上传";
        self.footerBtn_2.enabled = NO;
        [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
        self.footerLabel_3.text=@"备份";
        self.footerBtn_3.enabled = NO;
        [self.footerBtn_4 setImage:image4 forState:(UIControlStateNormal)];
        self.footerLabel_4.text=@"更多";
    }else{
        currentModel =0;
        self.fileListTableView.allowsMultipleSelectionDuringEditing=NO;
        [self.fileListTableView setEditing:NO animated:YES];
        [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:0.0/255 green:160.0/255 blue:226.0/255 alpha:1]forState:UIControlStateNormal];
        rightBtn.backgroundColor = [UIColor clearColor];
        [rightBtn.layer setCornerRadius:0];
        [selectedTableDataDic removeAllObjects];
        UIImage *image1 = [UIImage imageNamed:@"home"];
        UIImage *image2 = [UIImage imageNamed:@"download"];
        UIImage *image3 = [UIImage imageNamed:@"refurbish"];
        UIImage *image4 = [UIImage imageNamed:@"new-folder"];
        [self.footerBtn_1 setImage:image1 forState:(UIControlStateNormal)];
        self.footerLabel_1.text=@"主页";
        [self.footerBtn_2 setImage:image2 forState:(UIControlStateNormal)];
        self.footerBtn_2.enabled = YES;
        self.footerLabel_2.text=@"下载";
        [self.footerBtn_3 setImage:image3 forState:(UIControlStateNormal)];
        self.footerBtn_3.enabled = YES;
        self.footerLabel_3.text=@"刷新";
        [self.footerBtn_4 setImage:image4 forState:(UIControlStateNormal)];
        self.footerLabel_4.text=@"新建目录";
    }
}


#pragma mark -
#pragma mark selectAllRows 设置TableView的全选
- (void) selectAllRows{
    for (int row=0; row<self.tableDataDic.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.fileListTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        if(!([self.cpath isEqualToString:kDocument_Folder] && row==0)){
            FDTableViewCell * cell=(FDTableViewCell*)[self tableView:self.fileListTableView cellForRowAtIndexPath:indexPath];
            if(cell && !([[selectedTableDataDic allKeys] containsObject:cell.fileinfo.fileUrl])){
                [selectedTableDataDic setObject:cell.fileinfo forKey:cell.fileinfo.fileUrl];
            }
        }
        
    }
}
#pragma mark -
#pragma mark deSelectAllRows 取消TableView的全选
- (void) deSelectAllRows{
    for (int row=0; row<self.tableDataDic.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.fileListTableView deselectRowAtIndexPath:indexPath animated:NO ];
        [selectedTableDataDic removeAllObjects];
    }
}

#pragma mark -
#pragma mark chooseFileDirAction的委托方法
- (void)chooseFileDirAction:(UIButton *)sender{
    bool isLegal = YES;
    for (NSString *fileUrl in [selectedTableDataDic allKeys]){//移动、复制对象所在的目录和要移动复制的目标目录所在的子目录
        if([fileDialog.cpath rangeOfString:fileUrl].location !=NSNotFound)
        {
            NSString *subPath = [fileDialog.cpath componentsSeparatedByString:fileUrl][1];
            NSArray *subPathComponentArray = [subPath componentsSeparatedByString:@"/"];
            NSString *firstSubPathComponent = subPathComponentArray[0];
            if([firstSubPathComponent isEqualToString:@""] ){
                isLegal = NO;
                break;
            }
        }
        if ([fileDialog.cpath isEqualToString:self.cpath]) {//移动、复制对象所在的目录和要移动复制的目标目录所在的目录相同
            isLegal = NO;
            break;
        }
    }
    
    if(selectedTableDataDic.count>0){
        switch ([self.opType intValue]) {
            case 2:{//上传
                NSString* cpath = fileDialog.cpath;
                NSMutableString * uploadUrl =[NSMutableString stringWithFormat:@"/%@",[g_sDataManager userName]];
                if (![cpath isEqualToString:@"/"]) {
                    [uploadUrl appendString:[NSMutableString stringWithFormat:@"%@",cpath]];
                }
                for (NSString *filePath in [selectedTableDataDic allKeys]){
                    NSString *fileName = [filePath lastPathComponent];
                    BOOL operationIsExist = NO;
                    //                    for (FileUploadByBlockTool *operation in [uploadQueue operations]) {
                    //                        if ([operation.fileName isEqualToString:fileName]) {
                    //                            operationIsExist = YES;
                    //                        }
                    //                    }
                    if (!operationIsExist) {
                        FileUploadByBlockTool *operation = [[FileUploadByBlockTool alloc] initWithLocalPath:filePath ip:[g_sDataManager requestHost]withServer:uploadUrl withName:[g_sDataManager userName] withPass:[g_sDataManager password]];
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
                [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
                break;
            }
                
            case 3:{//复制
                if(!isLegal){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"操作非法:不能操作至对象子目录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
                for (NSString *fileUrl in [selectedTableDataDic allKeys]){
                    NSString* cpath = fileDialog.cpath;
                    cpath=[cpath stringByAppendingString :@"/"];
                    cpath=[cpath stringByAppendingString :[fileUrl lastPathComponent]];
                    //[FileTools copyFileByUrl:fileUrl   toPath:cpath];
                    BOOL  opreationIsExist= false;
                    opreationIsExist= false;
                    for (FileCopyAndMoveTools *operation in [copyAndMoveQueue operations]) {
                        if ([operation.fileUrl isEqualToString:fileUrl]) {
                            opreationIsExist = true;
                        }
                    }
                    if (!opreationIsExist) {
                        FileCopyAndMoveTools *opreation = [[FileCopyAndMoveTools alloc] initWithFileInfo];
                        opreation.fileUrl = fileUrl;
                        opreation.destinationUrl = cpath;
                        opreation.opType = @"copy";
                        [copyAndMoveQueue addOperation:opreation];
                    }
                }
                [self loadFileData];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"文件已复制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                [self requestSuccessCallback];
                break;
            }
            case 4:{//移动
                if(!isLegal){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"操作非法:不能操作至对象子目录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
                for (NSString *fileUrl in [selectedTableDataDic allKeys]){
                    NSString* cpath = fileDialog.cpath;
                    cpath=[cpath stringByAppendingString :@"/"];
                    cpath=[cpath stringByAppendingString :[fileUrl lastPathComponent]];
                    BOOL  opreationIsExist= NO;
                    for (FileCopyAndMoveTools *operation in [copyAndMoveQueue operations]) {
                        if ([operation.fileUrl isEqualToString:fileUrl]) {
                            opreationIsExist = YES;
                        }
                    }
                    if (!opreationIsExist) {
                        FileCopyAndMoveTools *opreation = [[FileCopyAndMoveTools alloc] initWithFileInfo];
                        opreation.fileUrl = fileUrl;
                        opreation.destinationUrl = cpath;
                        opreation.opType = @"move";
                        [copyAndMoveQueue addOperation:opreation];
                    }
                }
                [self loadFileData];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"文件已移动" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                [self requestSuccessCallback];
                break;
            }
            case 8:{//备份
                BOOL isFolder = NO;
                NSMutableArray *sourceDirsArray = [[NSMutableArray alloc]init];
                NSMutableArray *sourceFilesArray = [[NSMutableArray alloc]init];
                NSFileManager* fm = [NSFileManager defaultManager];
                for (NSString *fileUrl in [selectedTableDataDic allKeys]){
                    [fm fileExistsAtPath:fileUrl isDirectory:&isFolder];
                    if (isFolder) {
                        [sourceDirsArray addObject:fileUrl];
                    }else{
                        [sourceFilesArray addObject:fileUrl];
                    }
                }
                //设置进度条，所有的备份的文件和文件夹共享一个进度条
                TaskInfo* task = [[TaskInfo alloc] init];
                task.taskId = [NSUUIDTool gen_uuid];
                task.taskType = @"备份";
                task.taskName =@"";
                [[ProgressBarViewController sharedInstance].taskDic  setObject:task forKey:task.taskId];
                [[ProgressBarViewController sharedInstance] addProgressBarRow:task];
                NSOperationQueue *backupQueue = [[NSOperationQueue alloc]init];
                BackupTool *backupTool = [[BackupTool alloc]init:sourceFilesArray sourceDirsArray:sourceDirsArray localCurrentDir:self.cpath targetDir:fileDialog.cpath userName:[g_sDataManager userName] password:[g_sDataManager password]];
                backupTool.taskId = task.taskId;
                [backupQueue addOperation:backupTool];
                [self requestSuccessCallback];
                [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
                break;
            }
            default:
                break;
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先选择文件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [self requestSuccessCallback];
}


#pragma mark -
#pragma mark chooseFileAction FileDialogViewController委托方法
- (void)chooseFileAction:(UIButton *)sender{
    BOOL  opreationIsExist= false;
    opreationIsExist= false;
    NSString *fileName = fileDialog.selectedFile;
    for (FileDownloadTools *operation in [downLoadQueue operations]) {
        if ([operation.fileName isEqualToString:fileName]) {
            opreationIsExist = true;
        }
    }
    if (!opreationIsExist) {
        FileDownloadTools *opreation = [[FileDownloadTools alloc] initWithFileInfo];
        TaskInfo* task = [[TaskInfo alloc] init];
        task.taskId = [NSUUIDTool gen_uuid];
        task.taskName =fileName;
        task.taskType = @"下载";
        opreation.fileName = fileName;
        opreation.filePath = fileDialog.cpath;
        opreation.cachePath =self.cpath;
        opreation.progressBarView = [ProgressBarViewController sharedInstance];
        opreation.taskId = task.taskId;
        [downLoadQueue addOperation:opreation];
        [[ProgressBarViewController sharedInstance].taskDic  setObject:task forKey:task.taskId];
        [[ProgressBarViewController sharedInstance] addProgressBarRow:task];
    }
    [self.navigationController pushViewController:[ProgressBarViewController sharedInstance] animated:YES];
}

#pragma mark -
#pragma mark loginCallbackAction LoginViewController委托方法
- (void)loginCallbackAction:(UIButton *)sender{
    [self uploadAction];
}

-(void) alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex ==0){ //下载时用户未登录
        [UIHelper showLoginViewWithDelegate:self loginViewDelegate:nil];
    }
}

#pragma mark -
#pragma mark CustomActionSheet 的代理方法
-(void)cancleAction{
    [sheet dismissSheet:self];
}

#pragma mark -
#pragma mark customActionSheet 的代理方法
-(void) customActionSheet:(NSInteger)buttonIndex{
    if(buttonIndex==1){ //复制
        self.opType=@"3";
        [sheet dismissSheet:self];
        if (selectedTableDataDic.count>0) {
            fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
            fileDialog.isShowFile =YES;
            fileDialog.isServerFile = NO;
            fileDialog.cpath =kDocument_Folder;
            fileDialog.rootUrl = kDocument_Folder;
            fileDialog.isSelectFileMode =NO;
            fileDialog.fileDialogDelegate = self;
            [self.navigationController pushViewController: fileDialog animated:YES ];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先选择文件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }else if(buttonIndex==2){//移动
        
        [sheet dismissSheet:self];
        self.opType=@"4";
        if (selectedTableDataDic.count>0) {
            fileDialog= [[FileDialogViewController alloc] initWithNibName:@"FileDialogViewController" bundle:nil];
            fileDialog.isShowFile =YES;
            fileDialog.isServerFile = NO;
            fileDialog.cpath =kDocument_Folder;
            fileDialog.rootUrl = kDocument_Folder;
            fileDialog.isSelectFileMode =NO;
            fileDialog.fileDialogDelegate = self;
            [self.navigationController pushViewController: fileDialog animated:YES ];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先选择文件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
        
    }else if(buttonIndex==3){//重命名
        
        localFileHandler.cpath = self.cpath;
        localFileHandler.opType=5;
        localFileHandler.queue =copyAndMoveQueue;
        [localFileHandler renameFile:(FileInfo *)self.curCel.fileinfo ];
        
    }else if(buttonIndex==4){//删除
        localFileHandler.opType=1;
        self.curCel.fileinfo.isSelect=YES;
        [self.fileListTableView setEditing:YES animated:YES];
        self.fileListTableView.allowsMultipleSelectionDuringEditing=YES;
        [localFileHandler deleteFiles:selectedTableDataDic];
        
        [selectedTableDataDic removeAllObjects];
        [self setFooterButtonState];
        
    }
}

#pragma mark -
#pragma mark FileHandler 的代理方法 刷新
- (void)requestSuccessCallback{
    [self loadFileData];
    [self.fileListTableView reloadData];
    [selectedTableDataDic removeAllObjects];
    if (sheet) {
        [sheet dismissSheet:self];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.folderLocationStr = 0;
        self.cpath = 0;
        self.cfolder = 0;
        self.opType =@"-1";
    }
    return self;
}

@end
