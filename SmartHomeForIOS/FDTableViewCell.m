//
//  FDTableViewCell.m
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/8.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import "FDTableViewCell.h"
#import "FileTools.h"


@implementation FDTableViewCell

@synthesize select;
@synthesize fileinfo;
@synthesize hasUpdate;
@synthesize isSync;



- (id)initWithFile:(FileInfo *)file{
    
    UIButton *button= [self getCellButton];
    //  根据ftype不同分别初始化cell
    if ([file.fileType isEqualToString:@"folder"]) {
        self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:file.fileName];
        
        self.imageView.image = [ImageFactory getImage:file.fileSubtype size:1];
        //[UIImage imageNamed:@"documents-icon"]
        
        self.textLabel.text = file.fileName;
        [self.textLabel setTextColor:[UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1] ];
        [self setDetailText];
    }else{
        self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:file.fileName];
        [self.contentView addSubview:button];
        
        CGSize scaleToSize = {50.0,50.0};
        BOOL bRet = [[NSFileManager defaultManager] fileExistsAtPath:file.fileUrl];
        if (bRet) {
            NSDictionary* audioDataDic=[FileTools getAudioDataInfoFromFileURL:[NSURL fileURLWithPath:file.fileUrl]];
            UIImage *image =  [audioDataDic objectForKey:@"Artwork"];
            if(image){
                self.imageView.image =  [PhotoTools getScaleImage:image scaleToSize:scaleToSize];
            }else{
                NSArray *picArray=  [NSArray arrayWithObjects:@"jpg",@"png",@"jpeg", nil];
                BOOL isPic = [picArray containsObject:[[file.fileUrl pathExtension] lowercaseString]];
                if(isPic){
                    image=[UIImage imageNamed:file.fileUrl];
                    image=[PhotoTools getScaleImage:image scaleToSize:scaleToSize];
                }
                if(image){
                    self.imageView.image = image;
                }else{
                    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:file.fileUrl] options:nil];
                    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                    gen.appliesPreferredTrackTransform = YES;
                    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                    NSError *error = nil;
                    CMTime actualTime;
                    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                    if(thumb && !error){
                        self.imageView.image = [PhotoTools getScaleImage:thumb scaleToSize:scaleToSize];
                        CGImageRelease(image);
                    }else{
                        self.imageView.image = [ImageFactory getImage:file.fileSubtype size:1];
                    }
                }
            }
        }else{
            self.imageView.image = [ImageFactory getImage:file.fileSubtype size:1];
        }
        self.textLabel.text = file.fileName;
        [self.textLabel setTextColor:[UIColor colorWithRed:82.0/255 green:82.0/255 blue:82.0/255 alpha:1] ];
        [self setDetailText];
        
    }
    select = NO;
    
    
    iconImage = [[UIImageView alloc] init];
    [self.contentView addSubview:iconImage];
    self.fileinfo = file;
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


@end
