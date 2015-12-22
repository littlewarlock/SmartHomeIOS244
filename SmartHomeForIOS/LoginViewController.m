//
//  LoginViewController.m
//
//
//  Created by apple1 on 15/8/31.
//  Copyright (c) 2015年 BJB. All rights reserved.
//
#import "LoginViewController.h"
#import "DataManager.h"
#import "RequestConstant.h"
#import "FileTools.h"
#import "IIViewDeckController.h"
#import "DeckTableViewController.h"
#import "Reachability.h"
#import "LoginHandler.h"

#define WIDTH_LOADINGVIEW_BLACKVIEW   200
#define HEIGHT_LOADINGVIEW_BLACKVIEW  120
#define EDGE_BLACKVIEW_BOTTOM 100
#define TV_Cell_Height 24
#define TAG_TV_LIST 101
#define TAG_TV_SEARCH 102

@interface LoginViewController()

@property (weak, nonatomic) IBOutlet UIView *ipView;

@property (weak, nonatomic) IBOutlet UIView *loginView;

@property (weak, nonatomic) IBOutlet UIView *passwordView;





@end



@implementation LoginViewController{
    AsyncUdpSocket *udpSocket;
    LoginHandler *loginHandler;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置登陆信息的边框
    [self setupBorder];
    [self.textFieldIp setValue:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];

    [self.userNameField setValue:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];

    [self.userPasswordField setValue:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.tvSearch setBackgroundColor:[UIColor colorWithRed:94.0/255 green:94.0/255 blue:94.0/255 alpha:0.5]];
    [self.tvList setBackgroundColor:[UIColor colorWithRed:94.0/255 green:94.0/255 blue:94.0/255 alpha:0.5]];
    [self.tvSearch setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];//设置表尾不显示，就不显示多余的横线
    [self.tvList setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];//设置表尾不显示，就不显示多余的横线
    
    //    [self.tvSearch setBackgroundColor:[UIColor clearColor]];
    //    [self.tvList setBackgroundColor:[UIColor clearColor]];
    //设置本地文档按钮是否可见
    if(self.isShowLocalFileBtn)
    {
        self.localFileBtn.hidden = NO;
    }else{
        self.localFileBtn.hidden = YES;
    }
    [self getIpFromIpInfo];
    static NSString * const IpAdressKey = @"ipAddress";
    NSString *documentsDirectory = [FileTools getUserDataFilePath];
    NSString *ipListPath = [documentsDirectory stringByAppendingPathComponent:@"IpInfo.plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:ipListPath];
    NSArray *array = dictionary[@"IpInfo"];
    if (!array)
    {
        NSLog(@"文件加载失败");
    }
    
    self.arrayIps1 = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        IpInfo *ipInfo = [[IpInfo alloc] init];
        ipInfo.ipAddress= dict[IpAdressKey];
        
        [self.arrayIps1 addObject:ipInfo];
        
    }];
    self.arrayIps2 = [[NSMutableArray alloc]init];
    
    //self.arrayIps2 = [NSMutableArray arrayWithObjects:nil];
    self.tvList.dataSource = self;
    self.tvList.delegate = self;
    self.tvList.tag = TAG_TV_LIST;
    self.tvList.hidden = TRUE;
    self.tvSearch.dataSource = self;
    self.tvSearch.delegate = self;
    self.tvSearch.tag = TAG_TV_SEARCH;
    self.tvSearch.hidden = TRUE;
    
    //Add buttons
    [[self view] addSubview:self.checkBox];
    
    
    NSString *userListPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:userListPath];
    NSMutableArray *savedUserInfoArray = [dictionary objectForKey:@"UserInfo"];
    
    [savedUserInfoArray enumerateObjectsUsingBlock:^(NSDictionary *desDictionary, NSUInteger idx, BOOL *stop) {
        self.userNameField.text=desDictionary[@"userName"];
        self.userPasswordField.text =desDictionary[@"userPassword"];
        self.checkBox.selected =YES;
    }];
    self.checkBox.selected =NO;
    self.isConnetNetServer =NO;
    
    loginHandler = [[LoginHandler alloc] init];
    loginHandler.loginHandlerDelegate = self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tvList reloadData];
}


//设置登陆信息的边框
- (void)setupBorder
{
    //ip信息
    self.ipView.layer.borderWidth = 1;
    self.ipView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    //用户名信息
    self.loginView.layer.borderWidth = 1;
    self.loginView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    //密码
    self.passwordView.layer.borderWidth = 1;
    self.passwordView.layer.borderColor = [[UIColor whiteColor] CGColor];

}
//下拉列表按钮按下
- (IBAction)listBtn:(UIButton *)sender {
    if (self.arrayIps1.count>0) {
        self.tvSearch.hidden = TRUE;
        self.tvList.hidden=!self.tvList.hidden;//每次点击都改变按钮的状态
    }else{
        self.tvList.hidden=YES;
        
    }
    if(self.tvList.hidden){
        //在此实现隐藏列表时的方法
    }else{
        //在此实现显示列表时的方法
    }
}


-(void)sendSearchBroadcast: (NSString *) localHost{
    //这里发送广播
    [self sendToUDPServer:@"SMARTHOMEv1.0" address:localHost port:8888];
}

-(void)sendToUDPServer:(NSString*) msg address:(NSString*)address port:(int)port{
    udpSocket=[[AsyncUdpSocket alloc]initWithDelegate:self]; //得到udp util
    [udpSocket enableBroadcast:YES error:nil];
    NSData *data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    //[udpSocket sendData:data toHost:address port:port withTimeout:0 tag:1]; //发送udp
    [udpSocket sendData :data toHost:@"255.255.255.255" port:port withTimeout:5 tag:0];
    [udpSocket receiveWithTimeout:5 tag:0];
    
}

//下面是发送的相关回调函数
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag
          fromHost:(NSString *)host port:(UInt16)port{
    NSString* rData= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"onUdpSocket:didReceiveData:---%@",rData);
    //base 64
    NSData *dataDecodeBefore=[rData dataUsingEncoding:NSUTF8StringEncoding];
    dataDecodeBefore=  [GTMBase64 decodeData:dataDecodeBefore];
    NSString *dataDecodeAfter=[[NSString alloc] initWithData:dataDecodeBefore encoding:NSUTF8StringEncoding] ;
    NSLog(@"onUdpSocket:decode ip:---%@",dataDecodeAfter);
    self.tvSearch.hidden=NO;
    if(![self.arrayIps2 containsObject:dataDecodeAfter]){
        [self.arrayIps2 addObject:dataDecodeAfter];
        [self.tvSearch reloadData];
    }
    if (self.loadingView && !self.isConnetNetServer)
    {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    [udpSocket receiveWithTimeout:-1 tag:0];
    return NO;
    
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"didNotSendDataWithTag----");
    if (self.loadingView)
    {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    [udpSocket close];
    [loginHandler.udpSocket close];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
    [alertView show];
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"didNotReceiveDataWithTag----");
    if (self.loadingView)
    {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    if (!self.arrayIps2 || self.arrayIps2.count<=0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无搜索结果!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alertView show];
    }
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"didSendDataWithTag----");
    
}

-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
    NSLog(@"onUdpSocketDidClose----");
    if (self.loadingView)
    {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
}


- (void)handlerDidReceiveData:(NSString *) handlerReturnIP{
    if (self.loadingView){
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    self.postLoginIp = loginHandler.postLoginIp;
    [self loginAction :nil];
    NSLog(@"handlerDidReceiveData----");
}

- (void)handlerDidNotSendDataWithTag{
    if (self.loadingView)
    {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
    [alertView show];
}

- (void)handlerDidNotReceiveDataWithTag{
    NSLog(@"handlerDidNotSendDataWithTag----");
    if (self.loadingView){
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    //内网搜索无结果采用外网登录
    if(![self isIP:self.postLoginIp]){
        self.isConnetNetServer =YES;
        [self loginAction:nil];
        self.isConnetNetServer =NO;
    }
}
- (void)handlerDidSendDataWithTag{
    
}

- (void)handlerOnUdpSocketDidClose{
    if (self.loadingView)
    {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
}

//检索按钮按下
- (IBAction)searchBtn:(UIButton *)sender {
    self.tvList.hidden = TRUE;
    self.tvSearch.hidden=TRUE;
    [self.arrayIps2 removeAllObjects];
    //self.loadingView = [UIHelper addLoadingViewWithSuperView: self.view text:@"正在获取IP" :nil];
    self.loadingView = [self addLoadingViewWithSuperView:self.view text:@"正在获取IP" ];
    [self sendSearchBroadcast: @""];//发送广播
}

- (UIView*) addLoadingViewWithSuperView:(UIView*)view text:(NSString*)text
{
    return [self addLoadingViewWithSuperView:view text:text isAddToScreen:YES ] ;
}

- (UIView*) addLoadingViewWithSuperView:(UIView*)view text:(NSString*)text isAddToScreen:(BOOL)isAddToScreen
{
    // 1. 定制loadingView
    CGRect bounds;
    if (isAddToScreen)
    {
        bounds= [UIScreen mainScreen].bounds;
    }
    else
    {
        bounds = view.bounds;
    }
    UIView* loadingView = [[UIView alloc] initWithFrame:bounds];
    loadingView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer*tapGesture;
    tapGesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)];
    
    [loadingView addGestureRecognizer:tapGesture];
    // 2. 定制矩形框
    UIView* rectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_LOADINGVIEW_BLACKVIEW,HEIGHT_LOADINGVIEW_BLACKVIEW)];
    rectView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5f];
    rectView.layer.cornerRadius = 5.0f;
    if (isAddToScreen)
    {
        rectView.center = CGPointMake(bounds.size.width/2,bounds.size.height/2-EDGE_BLACKVIEW_BOTTOM);
    }
    else
    {
        rectView.center = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    }
    [loadingView addSubview:rectView];
    
    // 3. 定制风火轮
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(rectView.frame.size.width/2, rectView.frame.size.height/2-15);
    [activityView startAnimating];
    [rectView addSubview:activityView];
    // 4. text
    if (text)
    {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,HEIGHT_LOADINGVIEW_BLACKVIEW - 20-10,WIDTH_LOADINGVIEW_BLACKVIEW,20)];
        label.text = text;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentCenter;
        [rectView addSubview:label];
    }
    
    // 显示
    [view addSubview:loadingView];
    
    return loadingView;
}
- (void) cancel :(UIGestureRecognizer *)sender {
    
    [sender.view removeFromSuperview  ];
    sender = nil;
    [udpSocket close];
    [loginHandler.udpSocket close];
}



//实现checkboxClick方法
- (IBAction)checkBtn:(UIButton *)sender {
    self.checkBox.selected=!self.checkBox.selected;
    if(self.checkBox.selected ==  NO){
        [ FileTools removeUserFromPliset];
    }
}
//UITableViewDataSource协议中的方法
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag==TAG_TV_LIST) {
        //下拉列表
        static NSString* cellId = @"cellId";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:cellId];
        }
        cell.layer.borderWidth = 0;
        
        IpInfo *selectedIp = self.arrayIps1[indexPath.row];
        cell.textLabel.text = selectedIp.ipAddress;
        cell.textLabel.font = [UIFont systemFontOfSize: 20.0];
        UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryButton.frame = CGRectMake(150,5,20,20);
        [accessoryButton setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
        [accessoryButton addTarget:self action:@selector(accessoryButtonIsTapped:event:)
                  forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = accessoryButton;
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else{
        //检索列表
        static NSString* cellId = @"cellId";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:cellId];
        }
        cell.layer.borderWidth = 0;
        cell.textLabel.text = self.arrayIps2[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize: 20.0];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}
//自定义方法
- (void)accessoryButtonIsTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tvList];
    NSIndexPath *indexPath = [self.tvList indexPathForRowAtPoint:currentTouchPosition];
    if(indexPath != nil)
    {
        [self tableView:self.tvList accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self.arrayIps1 removeObjectAtIndex: indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //UITableView自动调节高度
    int iHeight = TV_Cell_Height * self.arrayIps1.count;
    if(iHeight < self.tvList.frame.size.height){
        CGRect rect = self.tvList.frame;
        rect.size.height = TV_Cell_Height * self.arrayIps1.count;
        self.tvList.frame = rect;
        self.tvList.hidden = TRUE;
    }
    //删除
    if (tableView.tag==TAG_TV_LIST) {
        //下拉列表
        NSString *documentsDirectory = [FileTools getUserDataFilePath];
        NSString *ipListPath = [documentsDirectory stringByAppendingPathComponent:@"IpInfo.plist"];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:ipListPath];
        NSMutableArray *oldAdressArr  =  [dictionary objectForKey:@"IpInfo"];
        [dictionary removeObjectForKey:@"IpInfo"];
        [oldAdressArr removeObjectAtIndex:indexPath.row];
        [dictionary setObject:oldAdressArr forKey:@"IpInfo"];
        [dictionary writeToFile:ipListPath atomically:YES];
        
    }else{
        //检索列表
    }
}
//UITableViewDataSource协议中的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag==TAG_TV_LIST) {
        //下拉列表
        return self.arrayIps1.count;
        
    }else{
        //检索列表
        return self.arrayIps2.count;
    }
}
//UITableViewDelegate协议中的方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag==TAG_TV_LIST) {
        //下拉列表
        return 52;
        
    }else if(tableView.tag==TAG_TV_SEARCH){
        //检索列表
        return 52;
    }else{
        
        return TV_Cell_Height;
    }
}
//UITableViewDelegate协议中的方法
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag==TAG_TV_LIST) {
        //下拉列表
        IpInfo *selectedIp = self.arrayIps1[indexPath.row];
        [self setLoginIp : selectedIp.ipAddress];
        self.tvList.hidden = TRUE;
    }else{
        //检索列表
        [self setLoginIp : self.arrayIps2[indexPath.row]];
        self.tvSearch.hidden = TRUE;
    }
}
//登录按钮按下
- (IBAction)loginAction:(UIButton *)sender {
//    if([[self.userNameField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString: @""] ||
//       [[self.userPasswordField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString: @""]
    if([self.userNameField.text  isEqualToString: @""] ||
       [self.userPasswordField.text  isEqualToString: @""]
       ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"用户名或密码不能为空!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [alertView show];
        return;
    }
    
    self.loadingView = [self addLoadingViewWithSuperView:self.view text:[NSString stringWithFormat: @"正在登录%@",self.textFieldIp.text] ];
    if(![self isIP:self.postLoginIp] && !self.isConnetNetServer ){//id mac 登录 转成ip
        [self.arrayIps2 removeAllObjects];
        loginHandler.udpSocket = udpSocket;
        loginHandler.postLoginIp = self.postLoginIp;
        [loginHandler sendSearchBroadcast: @""];//发送广播
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __block NSError *error = nil;
    [dic setValue:self.userNameField.text forKey:@"uname"];
    [dic setValue:self.userPasswordField.text forKey:@"upasswd"];
    NSString * requestHost = [NSString stringWithFormat:@"%@:%@",self.postLoginIp,REQUEST_PORT];
    if (self.isConnetNetServer) {
        requestHost = [NSString stringWithFormat:@"%@%@%@",@"123.57.223.91",@"/find/",self.postLoginIp];
    }
    // 登录110
    // NSString * requestHost = [NSString stringWithFormat:@"%@",self.textFieldIp .text];
    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    [header setValue:@"text/xml; charset=utf-8" forKey:@"Content-Type"];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:[requestHost stringByAppendingString:@"/smarty_storage/phone"] customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:@"login.php" params:dic httpMethod:@"POST" ssl:NO];
//    self.userNameField.text = [self.userNameField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    self.userPasswordField.text = [self.userPasswordField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.userNameField.text = self.userNameField.text ;
    self.userPasswordField.text = self.userPasswordField.text;
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        
        if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"1"])//登陆成功
        {
            
            if (self.loadingView)
            {
                [self.loadingView removeFromSuperview];
                self.loadingView = nil;
            }
            [FileTools saveIPInPlist :self.textFieldIp.text];
            if(self.checkBox.selected){
                [FileTools saveUserInPlist:self.userNameField.text passWord:self.userPasswordField.text];
            }else{
                [FileTools removeUserFromPliset];
            }
            
            [g_sDataManager setUserName:self.userNameField.text ];
            [g_sDataManager setPassword:self.userPasswordField.text];
            [g_sDataManager setRequestHost:requestHost];
            if (![[NSFileManager defaultManager] fileExistsAtPath:kDocument_Folder]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:kDocument_Folder withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *cachePath = [kDocument_Folder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", [g_sDataManager userName]]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if(self.isPushHomeView)
            {
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
                [self.navigationController popViewControllerAnimated:NO];
                if ([self.loginViewDelegate respondsToSelector:@selector(loginCallbackAction:)]) {
                    [self.loginViewDelegate loginCallbackAction:nil];//调用委托方法
                }
            }
            NSDictionary *sessionId =  [responseJSON objectForKey:@"session_id"];
            NSString *userId = [NSString stringWithFormat:@"%@",[sessionId objectForKey:@"userId"]];
            NSString *userType = [NSString stringWithFormat:@"%@",[sessionId objectForKey:@"userType"]];
            [g_sDataManager setUserId:userId ];
            [g_sDataManager setUserType:userType ];
            
            self.isConnetNetServer =NO;
        }else  if([[NSString stringWithFormat:@"%@",[responseJSON objectForKey:@"result"]] isEqualToString: @"0"]){
            if (self.loadingView)
            {
                [self.loadingView removeFromSuperview];
                self.loadingView = nil;
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"用户名或密码错误!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            self.isConnetNetServer =NO;
            return;
        }else {
            if (self.loadingView){
                [self.loadingView removeFromSuperview];
                self.loadingView = nil;
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"服务器错误" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
            [alertView show];
            self.isConnetNetServer =NO;
            return;
        }
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        if (self.loadingView){
            [self.loadingView removeFromSuperview];
            self.loadingView = nil;
        }
        
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"服务器无响应,请尝试4G网络或核实地址是否正确" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        self.isConnetNetServer =NO;
        [alertView show];
    }];
    
    [engine enqueueOperation:op];
}


- (IBAction)textFieldDoneEditing:(id)sender {
    [self setSavedPasswordInTextField];
    [sender resignFirstResponder];
}

//ip text field 内容发生改变
- (IBAction)ipTextFieldEditngChanged:(id)sender {
    [self setLoginIp:self.textFieldIp.text];
    
}

- (IBAction)backgroundAction:(id)sender {
    self.tvList.hidden=true;
    self.tvSearch.hidden=true;
    [self.textFieldIp resignFirstResponder];
    [self setLoginIp:self.textFieldIp.text];
    [self.userNameField resignFirstResponder];
    [self.userPasswordField resignFirstResponder];
}


//本地文档按钮按下
- (IBAction)showLocalFileAction:(id)sender {
    LocalFileViewController *localFileView = [[LocalFileViewController alloc] initWithNibName:@"LocalFileViewController" bundle:nil];
    UINavigationController *localFileNav = [[UINavigationController alloc] initWithRootViewController:localFileView];
    [self presentViewController:localFileNav animated:NO completion:nil];
}


-(void) setSavedPasswordInTextField{
    NSString *documentsDirectory = [FileTools getUserDataFilePath];
    NSString *userInfoPlistPath = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *dictionarys = [[NSMutableDictionary alloc] initWithContentsOfFile:userInfoPlistPath];
    NSMutableArray *oldAdressArr  =  [dictionarys objectForKey:@"UserInfo"];
    
    [oldAdressArr enumerateObjectsUsingBlock:^(NSDictionary *desDictionary, NSUInteger idx, BOOL *stop) {
        
        if ( [[desDictionary objectForKey:@"userName"] compare:self.userNameField.text options:NSCaseInsensitiveSearch] == NO) {
            self.userPasswordField.text =desDictionary[@"userPassword"];
        }
    }];
}


-(void) getIpFromIpInfo{
    NSString *documentsDirectory = [FileTools getUserDataFilePath];
    NSString *ipListPath = [documentsDirectory stringByAppendingPathComponent:@"IpInfo.plist"];
    
    NSMutableDictionary *dictionarys = [[NSMutableDictionary alloc] initWithContentsOfFile:ipListPath];
    NSMutableArray *oldAdressArr  =  [dictionarys objectForKey:@"IpInfo"];
    
    [oldAdressArr enumerateObjectsUsingBlock:^(NSDictionary *desDictionary, NSUInteger idx, BOOL *stop) {
        [self setLoginIp :desDictionary[@"ipAddress"]];
        *stop =YES;
    }];
}

-(void) setLoginIp:(NSString*)searchedOrSavedAdressStr {
    
    if([searchedOrSavedAdressStr containsString:@"="] && ![self isIP:searchedOrSavedAdressStr]){//非ip也非id 转成ip
        NSRange range  = [searchedOrSavedAdressStr rangeOfString:@"="];
        //NSString *subIP = [searchedOrSavedAdressStr  substringFromIndex:range.location+1];
        self.textFieldIp.text = [searchedOrSavedAdressStr  substringToIndex:range.location];
        self.postLoginIp =[searchedOrSavedAdressStr  substringToIndex:range.location];
    }else if(![searchedOrSavedAdressStr containsString:@"="] && [self isIP:searchedOrSavedAdressStr]){//ip 登录
        self.textFieldIp.text = searchedOrSavedAdressStr;
        self.postLoginIp =searchedOrSavedAdressStr;
    }else if(![searchedOrSavedAdressStr containsString:@"="] && ![self isIP:searchedOrSavedAdressStr]){//id mac 登录 转成ip
        //self.ifConvertIdToIp = YES;
        self.textFieldIp.text = searchedOrSavedAdressStr;
        self.postLoginIp =searchedOrSavedAdressStr;
    }
    
}

-(BOOL) isIP:(NSString*) ipStr{
    NSArray  * array= [ipStr componentsSeparatedByString:@"."];
    BOOL allIsDigit =YES;
    BOOL isLaw =YES;
    for (int i=0;i<array.count;i++){
        for(int j=0;j<[NSString stringWithFormat:@"%@", array[i] ].length && allIsDigit;j++){
            if(!isdigit([array[i] characterAtIndex:j])){
                allIsDigit =NO;
                break;
            }
        }
        if(!allIsDigit){
            break;
        }
        if ([array[i] integerValue]<0 || [array[i] integerValue]>255
            || [NSString stringWithFormat:@"%@", array[i] ].length==0) {
            isLaw =NO;
            break;
        }
    }
    if(array.count==4 && allIsDigit && isLaw){
        //NSLog(@"输入是ip\n");
        return YES;
    }else{
        //NSLog(@"输入不是ip\n");
        return NO;
    }
    
}

@end
