//
//  ShareDetailViewController.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-21.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "ShareDetailViewController.h"
#import "ImageCache.h"
#import "FileCache.h"
#import "MBProgressHUD.h"
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import "UploadDB.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DownloadDetail.h"
#import "SharedDetail.h"
#import "LoadSharingInfo.h"

@interface ShareDetailViewController ()
{
    ImageCache *cache;
    UIButton *dbutton;
    CGFloat rowHeight;
    NSInteger rowCount;
    NSMutableArray * readFileArray;
    MPMoviePlayerViewController *pvc;
    NSString * buttonTitle;
}
@end

@implementation ShareDetailViewController
@synthesize dataArray;
@synthesize bytesSent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (NSString *)getTimeDiff:(long long)diff{
    
    int seconds = (int)(diff);
    if (seconds <= 60)
        return [NSString stringWithFormat:@"%dseconds ago", seconds];
    int mins = seconds / 60;
    if (mins <= 60)
        return [NSString stringWithFormat:@"%dmins ago", mins];
    int hours = seconds / 3600;
    if (hours <= 24)
        return [NSString stringWithFormat:@"%dhours ago", hours];
    int days = hours / 24;
    if (days <= 30)
        return [NSString stringWithFormat:@"%ddays ago", days];
    int months = days / 365;
    if (months <= 12)
        return [NSString stringWithFormat:@"%dmonth ago", months];
    
    int years = months / 12;
    return [NSString stringWithFormat:@"%dyear ago", years];
    
}
-(void)refreshData{
    LoadSharingInfo * loadInfo = [LoadSharingInfo sharedObject];
    [loadInfo loadSharingInfoSyc:[cache getLoginUserName]];
}
-(void)refreshClicked{
    MBProgressHUD * HUD= [[MBProgressHUD alloc]init];
    HUD.labelText = @"Loading...";
    [self.view addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self refreshData];
    }completionBlock:^{
        if (segmentedControl.selectedSegmentIndex == 0) {
            dataArray = [cache getFriendsSharedFiles];
            [self sortWithArray];
        }
        [HUD  removeFromSuperview];
         [myTableView reloadData];
    }];
}
-(void)sortWithArray{
    rowCount = [dataArray count];
    [dataArray sortUsingComparator:^NSComparisonResult(id detail1,id detail2){
        DownloadDetail * d1 = (DownloadDetail *)detail1;
        DownloadDetail * d2 =(DownloadDetail *)detail2;
        NSString * t1 =[d1 shareTime];
        NSString * t2 = [d2 shareTime];
        return [t2 compare:t1];
    }];
}
-(void)initTableView{
    dataArray = [[NSMutableArray alloc]init];
    [myTableView removeFromSuperview];
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height-120-49)];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:myTableView];
}
-(void)friendSharedView {
    rowHeight=44;
    [self initTableView];
    dataArray = [cache getFriendsSharedFiles];
    [self sortWithArray];
}
-(void)youSharedView {
    rowHeight=44;
    [self initTableView];
    dataArray  = [cache getSharedFiles];
    [dataArray sortUsingComparator:^NSComparisonResult(id detail1,id detail2){
        
        SharedDetail * d1 = (SharedDetail *)detail1;
        SharedDetail * d2 =(SharedDetail *)detail2;
        NSString * t1 =[d1 sharedTime];
        NSString * t2 = [d2 sharedTime];
        return [t2 compare:t1];
    }];
    rowCount = [dataArray count];
}

-(void)fileShowView {
    
    [self initTableView];
    FileCache * fileCache = [FileCache sharedObject];
    NSMutableArray * fileArray = [cache getFriendsSharedFiles];
    for (int  i= 0; i<[fileArray count]; i++) {
        DownloadDetail *dd = [fileArray objectAtIndex:i];
        BOOL isTheFileDownloaded = [fileCache isFileDownloaded:[dd fileName]];
        if (isTheFileDownloaded)
            [ dataArray addObject:[fileArray objectAtIndex:i]];
    }
    rowCount = [dataArray count]%2 == 0 ?[dataArray count]/2:[dataArray count]/2+1;
    rowHeight = rowCount==0 ? 44 :160;

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;

    cache = [ImageCache sharedObject];
    readFileArray = [[NSMutableArray alloc]init];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"Friend Shared",@"Downloaded File",@"You Shared",nil];
    
    segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    
    segmentedControl.frame = CGRectMake(0, 70.0, self.view.bounds.size.width, 40.0);
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl.selectedSegmentIndex = 0;//设置默认选择项索引
    
    [self.view addSubview:segmentedControl];
    [segmentedControl addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];
    [self friendSharedView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([dataArray count]==0)
        return 1;
    else
        return rowCount;
}

- (void)readImageFromFileCache:(NSString *)fileId
{
    //you can use any string instead "com.mycompany.myqueue"
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    
    dispatch_async(backgroundQueue, ^{
        
        FileCache *fileCache =[FileCache sharedObject];
        NSData * data = [fileCache readFromFileDoc:fileId];
        if ([fileId hasSuffix:@".mp3"] || [fileId hasSuffix:@".mp4"]){
            [cache selfImageDownload:data withFileId:fileId];
        }else{
            UIImage * image =[UIImage imageWithData:data];
            UIImage *image2 = [self imageWithImageSimple:image scaledToSize:CGSizeMake(150, 150)];
            NSData * data2  = UIImageJPEGRepresentation(image2, 0.5);
              [cache selfImageDownload:data2 withFileId:fileId];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [myTableView reloadData];
        });
    });
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellName = @"cellName";
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if (segmentedControl.selectedSegmentIndex == 0) {
        if ([dataArray count]!=0) {
            
            UIButton * downButton = [UIButton buttonWithType:UIButtonTypeCustom];
            downButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
            [downButton setFrame:CGRectMake(cell.frame.size.width -110, 6, 100, 30)];
            downButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
            [downButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [[downButton layer] setBorderColor:[[UIColor blueColor] CGColor]];
            [[downButton layer] setBorderWidth:1];
            [[downButton layer] setCornerRadius:5];
            downButton.tag = indexPath.row;
            [cell addSubview:downButton];
            
            UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, cell.frame.size.width -120, cell.frame.size.height)];
            lable.backgroundColor = [UIColor clearColor];
            lable.lineBreakMode = NSLineBreakByCharWrapping;
            lable.numberOfLines = 0;
            lable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
            lable.font = [UIFont systemFontOfSize:13.0f];
            lable.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:lable];
            
            DownloadDetail *dd = [dataArray objectAtIndex:indexPath.row];
            NSString *shareTime = [dd shareTime];
            long  long lastModifiedTime = [shareTime longLongValue];
            NSDate *now = [[NSDate alloc] init];
            long long millionsSecs = [now timeIntervalSince1970];
            millionsSecs = millionsSecs * 1000;
            long long diff = (millionsSecs  - lastModifiedTime)/1000;
            NSString *timeDiff = [self getTimeDiff:diff];
            NSMutableArray * allfriends = [cache getFriends];
            for (Friend * f in allfriends) {
                if ([[dd sharedBy] isEqualToString:f.friendId]) {
                    lable.text = [NSString stringWithFormat:@"%@ shared a file %@",[f firstName],timeDiff];
                }
            }
            FileCache * fileCache = [FileCache sharedObject];
            BOOL isTheFileDownloaded = [fileCache isFileDownloaded:[dd fileName]];
            BOOL isTheFileDownloading = [fileCache isFileDownloading:[dd fileId]];
            if (isTheFileDownloaded){
                [downButton setTitle:@"downloaded" forState:UIControlStateNormal];
                [downButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
            
            if (isTheFileDownloading){
                [downButton setTitle:@"downloading" forState:UIControlStateNormal];
            }
            if (!isTheFileDownloading && !isTheFileDownloaded){
                [downButton setTitle:@"download" forState:UIControlStateNormal];
                [downButton addTarget:self action:@selector(downloadClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else{
            cell.textLabel.text = @"No friends shared any files with you";
            cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
        }
    }
    if (segmentedControl.selectedSegmentIndex == 1) {
        
        if ([dataArray count]!=0) {
            for (int i = 0; i < 2; i++ ) {
                if (2*indexPath.row +i < [dataArray count]){
                    UIButton * filesButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    filesButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
                    [filesButton setFrame:CGRectMake((cell.frame.size.width-300)/3*(i+1)+(150*i), 5, 150, 150)];
                    [filesButton setImage:[UIImage imageNamed:@"headImage.jpg"] forState:UIControlStateNormal];
                    [filesButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    filesButton.tag = indexPath.row*2+i;
                    [cell addSubview:filesButton];
                    
                    UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake((cell.frame.size.width-300)/3*(i+1)+(150*i), 125, 20, 20)];
                    image.userInteractionEnabled = YES;
                    [filesButton addSubview:image];
                    DownloadDetail *dd = [dataArray objectAtIndex:indexPath.row*2+i];
                    
                    if ([cache isImageExist:[dd fileName]]){
                        NSString * filename = [dd fileName];
                        if ([filename hasSuffix:@".mp3"]){
                            [filesButton setImage:[UIImage imageNamed:@"music.png"] forState:UIControlStateNormal];
                        }else if ([filename hasSuffix:@".mp4"]||[filename hasSuffix:@".MOV"]){
                              [filesButton setImage:[UIImage imageNamed:@"video.png"] forState:UIControlStateNormal];
//                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                            NSString *documentsdir = [paths objectAtIndex:0];
//                            NSString * path =[documentsdir stringByAppendingPathComponent:filename];
//                            NSURL *url=[NSURL fileURLWithPath:path];
//                            MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:url];
//                            [filesButton setImage:[player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame] forState:UIControlStateNormal];
                        }else
                            [filesButton setImage:[UIImage imageWithData: [cache getImage:dd.fileName]] forState:UIControlStateNormal];
                    }else{
                        [filesButton setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
                        [self readImageFromFileCache:[dd fileName]];
                    }
                }
            }
        } else{
            cell.textLabel.text = @"You have not downlowned any files!";
            cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
        }
    }
    if (segmentedControl.selectedSegmentIndex == 2) {
        if ([dataArray count]!=0) {
            SharedDetail * detail = [dataArray objectAtIndex:indexPath.row];
            UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, cell.frame.size.width-20, cell.frame.size.height)];
            lable.backgroundColor = [UIColor clearColor];
            lable.lineBreakMode = NSLineBreakByCharWrapping;
            lable.numberOfLines = 0;
            lable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
            lable.font = [UIFont systemFontOfSize:13.0f];
            lable.textAlignment = NSTextAlignmentLeft;
            [cell addSubview:lable];
            NSString * shareTime = [detail sharedTime];
            long long lastModifiedTime = [shareTime longLongValue];
            NSDate *now = [[NSDate alloc] init];
            long long millionsSecs = [now timeIntervalSince1970];
            long long diff = millionsSecs - lastModifiedTime;
            NSString *timeDiff = [self getTimeDiff:diff];
            NSMutableArray * allfriends = [cache getFriends];
            for (Friend * f in allfriends) {
                if ([[detail shareBy] isEqualToString:f.friendId])
                    lable.text = [NSString stringWithFormat:@"you shared a file with %@ %@",[f firstName],timeDiff];
            }
        }else{
            cell.textLabel.text = @"you have not shared any files with your friends";
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return cell;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}
-(void)buttonClicked:(UIButton *)button{
    DownloadDetail *dd = [dataArray objectAtIndex:button.tag];
    NSString *filename = [dd fileName];
    if ([filename hasSuffix:@".mp3"] || [filename hasSuffix:@".mp4"]||[filename hasSuffix:@".MOV"]){
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsdir = [paths objectAtIndex:0];
        NSString * path =[documentsdir stringByAppendingPathComponent:filename];
        NSURL *url=[NSURL fileURLWithPath:path];
        pvc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [self presentViewController:pvc animated:YES completion:NULL];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification  object:nil];
    }
    
}
//播放结束事件

-(void)moviePlayBackDidFinish:(NSNotification *)notification
{
    [pvc dismissViewControllerAnimated:YES completion:NULL];
}

-(void)downloadClicked:(UIButton *)button{
    dbutton = button;
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Are you sure to download this file?" delegate:button cancelButtonTitle:@"cancel" otherButtonTitles:@"OK" , nil];
    alertView.delegate = self;
    [alertView show];

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    FileCache * fileCache = [FileCache sharedObject];
    if (buttonIndex == 1) {
        [dbutton setTitle:@"downloading" forState:UIControlStateNormal];
        STreamFile * file = [[STreamFile alloc]init];
        DownloadDetail *dd = [dataArray objectAtIndex:dbutton.tag];
        NSString *fileId = [dd fileId];
        [fileCache addDownloadingFile:fileId];
        
        [file downloadAsData:fileId downloadedData:^(NSData *imageData, NSString *oId) {
            if ([imageData length] != 0){
              [cache selfImageDownload:imageData withFileId:[dd fileName]];
              [fileCache writeFileDoc:[dd fileName] withData:imageData];
              [fileCache addDownloadedFile:[dd fileName]];
              [dbutton setTitle:@"downloaded" forState:UIControlStateNormal];
              [dbutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }else{
                [dbutton setTitle:@"data corrupted" forState:UIControlStateNormal];
            }
            [fileCache removeDownloadingFile:fileId];
        }];
    }
    
}
-(void)segmentAction:(UISegmentedControl *)Seg{
        
        NSInteger Index = Seg.selectedSegmentIndex;
    
    if (Index == 0) {
        [self friendSharedView];
    }
    if (Index == 1) {
        [self fileShowView];
    }
    
    if (Index == 2) {
         [self youSharedView];
    }
}
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [myTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
