//
//  AlbumCollectionViewController.h
//  SmartHomeForIOS
//
//  Created by riqiao on 15/9/21.
//  Copyright (c) 2015年 riqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileInfo.h"
#import "FileTools.h"
#import "CollectionViewCell.h"
#import "MWPhotoBrowser.h"
#import "FileDialogViewController.h"

@interface AlbumCollectionViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate,MWPhotoBrowserDelegate,FileDialogDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *albumGrid;

@end
