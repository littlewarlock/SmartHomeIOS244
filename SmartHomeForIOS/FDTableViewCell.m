//
//  FDTableViewCell.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/8.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "FDTableViewCell.h"
#import "FileTools.h"
#import "DataManager.h"
#import "RequestConstant.h"
@implementation FDTableViewCell

@synthesize select;
@synthesize fileinfo;
@synthesize hasUpdate;
@synthesize isSync;



- (id)initWithFile:(FileInfo *)file{
    self.fileinfo = file;
    UIButton *button= [self getCellButton];
    //  根据ftype不同分别初始化cell
    if ([file.fileType isEqualToString:@"folder"]) {
        self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:file.fileName];
        
        self.imageView.image = [ImageFactory getImage:file.fileSubtype size:1];
        if([file.isShare isEqualToString:@"1"]){
            self.imageView.image =  [UIImage imageNamed:@"share-icon"];
        }
        self.textLabel.text = file.fileName;
        [self.textLabel setTextColor:[UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1] ];
        [self setDetailText];
    }else{
        self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:file.fileName];
        [self.contentView addSubview:button];
        
        CGSize scaleToSize = {34.0,24.0};
        BOOL bRet = [[NSFileManager defaultManager] fileExistsAtPath:file.fileUrl];
        if (bRet) {
            self.imageView.image = [ImageFactory getImage:file.fileSubtype size:1];
            
            NSArray *audioArray=  [NSArray arrayWithObjects:@"mp3", nil];
            BOOL isAudio = [audioArray containsObject:[[file.fileUrl pathExtension] lowercaseString]];
            if(isAudio){
                
            self.imageView.image =  [UIImage imageNamed:@"music-icon"];
             CGSize scaleToSize = self.imageView.image.size;
            NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:[NSURL fileURLWithPath:file.fileUrl]];
            UIImage *image =  [audioDataDic objectForKey:@"Artwork"];
                if(image){
                    self.imageView.image =  [PhotoTools getScaleImage:image scaleToSize:scaleToSize];
                }
            }
            
            NSArray *picArray=  [NSArray arrayWithObjects:@"jpg",@"png",@"jpeg", nil];
            BOOL isPic = [picArray containsObject:[[file.fileUrl pathExtension] lowercaseString]];
            if(isPic){
                UIImage *image=[UIImage imageNamed:file.fileUrl];
                image=[PhotoTools getScaleImage:image scaleToSize:scaleToSize];
                if(image){
                    self.imageView.image = image;
                }
            }

                    //本地添加视频缩略图
//                    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:file.fileUrl] options:nil];
//                    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//                    gen.appliesPreferredTrackTransform = YES;
//                    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
//                    NSError *error = nil;
//                    CMTime actualTime;
//                    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
//                    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
            NSArray *videoArray=  [NSArray arrayWithObjects:@"mp4",@"mov",@"m4v",@"wav",@"flac",@"ape",@"wma",
                                   @"avi",@"wmv",@"rmvb",@"flv",@"f4v",@"swf",@"mkv",@"dat",@"vob",@"mts",@"ogg",@"mpg",@"h264", nil];
            BOOL isVideo = [videoArray containsObject:[[file.fileUrl pathExtension] lowercaseString]];
            if(isVideo){
                
                
//                const char* queueName = [[[NSDate date] description] UTF8String];
//                dispatch_queue_t myQueue = dispatch_queue_create(queueName, NULL);
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                
//                dispatch_async(myQueue, ^{
//                    //新线程中要操作的（例如数据库的读取，存储等）
//                    UIImage *image = [FileTools getVideoDuartionAndThumb:file.fileUrl];
//                    NSError *error = nil;
//                    if(image && !error){
//                        self.imageView.image = [PhotoTools getScaleImage:image scaleToSize:scaleToSize];
//                    }
//                    dispatch_async(mainQueue, ^{
//                        //主线程中要操作的（例如UI页面刷新）
//                    });
//                });
//                
                
                UIImage *image = [FileTools getVideoDuartionAndThumb:file.fileUrl];
                NSError *error = nil;
                if(image && !error){
                    self.imageView.image = [PhotoTools getScaleImage:image scaleToSize:scaleToSize];
                }
            }

        }else{
            self.imageView.image = [ImageFactory getImage:file.fileSubtype size:1];
            
            NSArray *audioArray=  [NSArray arrayWithObjects:@"mp3", nil];
            BOOL isAudio = [audioArray containsObject:[[file.fileName pathExtension] lowercaseString]];
             CGSize scaleToSize = [UIImage imageNamed:@"music-icon"].size;
            if(isAudio){
                NSError *error = nil;
                if([UIImage imageNamed:@"music-icon"] && !error){
                    self.imageView.image =  [UIImage imageNamed:@"music-icon"];
                }
            }
            
            NSArray *picArray=  [NSArray arrayWithObjects:@"jpg",@"png",@"jpeg", nil];
            BOOL isPic = [picArray containsObject:[[file.fileName pathExtension] lowercaseString]];
            if(isPic){
                
                NSMutableString *picUrl = [NSMutableString stringWithFormat:@"http://%@/%@",[g_sDataManager requestHost],REQUEST_PIC_URL];
                picUrl =[NSMutableString stringWithFormat:@"%@?uname=%@&filePath=%@&fileName=%@",picUrl,[[g_sDataManager userName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[file.cpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[file.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]];
                    UIImage *image = [UIImage imageWithData:data];
                    NSError *error = nil;
                    if(image && !error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image =  [PhotoTools getScaleImage:image scaleToSize:scaleToSize];
                        });
                    }
                });
            }
            
            NSArray *videoArray=  [NSArray arrayWithObjects:@"mp4",@"mov",@"m4v",@"wav",@"flac",@"ape",@"wma",
                                   @"avi",@"wmv",@"rmvb",@"flv",@"f4v",@"swf",@"mkv",@"dat",@"vob",@"mts",@"ogg",@"mpg",@"h264", nil];
            BOOL isVideo = [videoArray containsObject:[[file.fileName pathExtension] lowercaseString]];
            if(isVideo){
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //self.imageView.image =  [UIImage imageNamed:@"music-icon"];
                    //显示云端视频缩略图
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    __block NSError *error = nil;
                    [dic setValue:[g_sDataManager userName] forKey:@"uname"];
                    [dic setValue:file.cpath forKey:@"filePath"];
                    [dic setValue:self.fileinfo.fileName forKey:@"fileName"];
                    
                    NSString* requestHost = [g_sDataManager requestHost];
                    NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
                    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
                    
                    MKNetworkOperation *op = [engine operationWithPath:REQUEST_VIDEO_URL params:dic httpMethod:@"POST" ssl:NO];
                    [op addCompletionHandler:^(MKNetworkOperation *operation) {
                        NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
                        NSString *videoPath =  [responseJSON objectForKey:@"videopath"];
                        
                        NSRange range  = [videoPath rangeOfString:@"/smarty_storage"];
                        NSString *subVideoPath = [videoPath  substringFromIndex:range.location];
                        NSString *videoUrl = [NSString stringWithFormat:@"%@%@%@",@"http://",requestHost,subVideoPath];
                        UIImage *imageMK = [FileTools getVideoDuartionAndThumb:videoUrl];
                        
                        if(imageMK){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.imageView.image = [PhotoTools getScaleImage:imageMK scaleToSize:scaleToSize];
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                            self.imageView.image = [ImageFactory getImage:file.fileSubtype size:1];
                            });
                        }
                    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
                        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
                    }];
                    [engine enqueueOperation:op];

 
                });
                
                
//                //self.imageView.image =  [UIImage imageNamed:@"music-icon"];
//                              //显示云端视频缩略图
//                            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//                            __block NSError *error = nil;
//                            [dic setValue:[g_sDataManager userName] forKey:@"uname"];
//                            [dic setValue:file.cpath forKey:@"filePath"];
//                            [dic setValue:self.fileinfo.fileName forKey:@"fileName"];
//                
//                            NSString* requestHost = [g_sDataManager requestHost];
//                            NSString* requestUrl = [NSString stringWithFormat:@"%@",requestHost];
//                            MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:requestUrl customHeaderFields:nil];
//                
//                            MKNetworkOperation *op = [engine operationWithPath:REQUEST_VIDEO_URL params:dic httpMethod:@"POST" ssl:NO];
//                            [op addCompletionHandler:^(MKNetworkOperation *operation) {
//                                NSDictionary *responseJSON=[NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
//                                NSString *videoPath =  [responseJSON objectForKey:@"videopath"];
//                
//                                NSRange range  = [videoPath rangeOfString:@"/smarty_storage"];
//                                NSString *subVideoPath = [videoPath  substringFromIndex:range.location];
//                                NSString *videoUrl = [NSString stringWithFormat:@"%@%@%@",@"http://",requestHost,subVideoPath];
//                                UIImage *imageMK = [FileTools getVideoDuartionAndThumb:videoUrl];
//                                if(imageMK){
//                                    self.imageView.image = [PhotoTools getScaleImage:imageMK scaleToSize:scaleToSize];
//                                }else{
//                                    self.imageView.image = [ImageFactory getImage:file.fileSubtype size:1];
//                                }
//                            }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
//                                NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
//                            }];
//                            [engine enqueueOperation:op];
            }
            
            NSArray *documentArray=  [NSArray arrayWithObjects:@"doc",@"docx",@"xls",@"xlsx",@"txt", nil];
            BOOL isDocument = [documentArray containsObject:[[file.fileName pathExtension] lowercaseString]];
            if(isDocument){
                NSError *error = nil;
                if([UIImage imageNamed:@"text-icon"] && !error){
                    self.imageView.image =  [PhotoTools getScaleImage:[UIImage imageNamed:@"text-icon"] scaleToSize:scaleToSize];
                }
            }
            
            
            
        }
        self.textLabel.text = file.fileName;
        [self.textLabel setTextColor:[UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1] ];
        [self setDetailText];
        
    }
    select = NO;
    
    
    iconImage = [[UIImageView alloc] init];
    [self.contentView addSubview:iconImage];

    return self;
}

- (id)getCellButton
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(width-30, 18.0, 24.0, 24.0)];
    [button setImage:[ImageFactory getCheckImage:NO] forState:UIControlStateNormal];
    [button setImage:[ImageFactory getCheckImage:YES] forState:UIControlStateSelected];
    button.tag=_CHECK_BOX_BUTTON_;
    //  [button addTarget:self action:@selector(buttonTarget:)   forControlEvents:UIControlEventTouchUpInside];
    button.hidden=YES;
    return button;
}




- (void)setIsSync:(BOOL)flag{
    if (flag) {
        UIImageView *syncicon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"syncing.png"]];
        syncicon.frame = CGRectMake(10.0, 25.0, 30.0, 30.0);
        [self addSubview:syncicon];
    }
}

- (void)setIcon:(BOOL)flag {
    if (flag) {
        [iconImage setFrame:CGRectMake(10, 30, 27, 27)];
    }
    else {
        [iconImage setFrame:CGRectMake(10, 30, 27, 27)];
    }
    [iconImage setImage:[UIImage imageNamed:@"status_done_small"]];
}

- (void)setDetailText {
    
    if([self.fileinfo.fileType isEqualToString:@"folder"]){
        [self.detailTextLabel setTextColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:199.0/255 alpha:1] ];
        
        int i=0;
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]enumeratorAtPath:self.fileinfo.fileUrl];
        for (NSString *fileName in enumerator)
        {
            if(![[fileName pathExtension] isEqualToString:@""]){
                i++;
            }
        }
        
        BOOL bRet = [[NSFileManager defaultManager] fileExistsAtPath:self.fileinfo.fileUrl];
        
        if(bRet){
            self.detailTextLabel.text = [NSString stringWithFormat: @"%@ 共%zi个文件", fileinfo.fileChangeTime,i];
            
        }else{
            self.detailTextLabel.text = [NSString stringWithFormat: @"%@ %@", fileinfo.fileChangeTime,fileinfo.fileSize];
        }
        
    }else{
        [self.detailTextLabel setTextColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:199.0/255 alpha:1] ];
        self.detailTextLabel.text = [NSString stringWithFormat: @"%@ %@", fileinfo.fileChangeTime,fileinfo.fileSize];
        //self.detailTextLabel.text =fileinfo.fileChangeTime;
        
    }
    //    }else{//云端
    //        [self.detailTextLabel setTextColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:199.0/255 alpha:1] ];
    //        self.detailTextLabel.text = fileinfo.fileSize;
    //    }
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

//-(UIImage*)getVideoDuartionAndThumb:(NSString *)videoURL
//{
//    
//    _decoder = [[KxMovieDecoderVer2 alloc] init];
//    
//    [_decoder openFile:videoURL error:nil];
//    NSArray *ar =  [_decoder decodeFrames:1.0f];
//    KxMovieFrameVer2 *frame;
//    
//    for (KxMovieFrameVer2 *frames in ar)
//    {
//        if (frames.type == KxMovieFrameTypeVideo) {
//            frame =  ar.lastObject;
//            break;
//        }
//    }
//    
//    KxVideoFrameRGBVer2 *rgbFrame = (KxVideoFrameRGBVer2 *)frame;
//    UIImage *imageKX = [rgbFrame asImage];
//    
//    return imageKX;
//}


@end
