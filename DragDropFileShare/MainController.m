//
//  MainController.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-15.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "MainController.h"
#import "OBDragDropManager.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendView.h"
#import "ShareDetailViewController.h"
#import "MBProgressHUD.h"
#import "ImageCache.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Friend.h"
#import <arcstreamsdk/STreamHttpRequest.h>
#import "FileCache.h"
#import <arcstreamsdk/STreamCategoryObject.h>
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamObject.h>
#import "NSData+MD5.h"
#import "UploadDB.h"
#import<MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LoadSharingInfo.h"
#import "SharedDetail.h"

@interface MainController ()
{
    UIImageView *fileImageview;
    UILabel *label;
    OBDragDropManager *dragDropManager;
    UIScrollView *rightView ;
    CGFloat height;
    NSMutableDictionary * totalDic;
    
    UIProgressView *progressView;
    NSMutableArray *bytesSentArray;
    UIImage *fileImage;
    NSMutableArray *sharedArray;
    BOOL isVideo;
    NSData *videoData;
    BOOL isAddFiles;
    //search
    UISearchBar *mySearchBar;
    NSMutableArray *searchFriendsArray;
    NSMutableArray * allFriendsArray;
    UIRefreshControl *ref;
    
    //upload
    FriendView *currentDFriend;
    OBOvum *ovums;
    
}

@end

@implementation MainController
@synthesize headViewArray;
@synthesize loading;
@synthesize myTableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)readImageFromFileCache
{    //you can use any string instead "com.mycompany.myqueue"
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue1", 0);
    dispatch_async(backgroundQueue, ^{
        ImageCache *cache = [ImageCache sharedObject];
        FileCache *fileCache =[FileCache sharedObject];
        STreamHttpRequest *request = [[STreamHttpRequest alloc] init];
        int index = 0;
        NSMutableArray *friends = [cache getFriends];
        NSMutableArray *friendsViews = [self getFriendView:[rightView subviews]];
        for (Friend * friend in friends) {
            NSData *data = [request sendRequest:@"GET" bodyData:nil withUrl:friend.friendUrl];
            [cache selfImageDownload:data withFileId:[friend friendId]];
            [fileCache writeFileTemp:[friend friendId] withData:data];
            FriendView *view =  [friendsViews objectAtIndex:index];
            view.image = [UIImage imageWithData:data];            
            [view setNeedsDisplay];
            index++;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
           
        });
    });
}

- (void)loadFriends{
    
    while(loading){
        sleep(1);
    }
}

-(void)loadShowFriends{
    ImageCache *cache = [ImageCache sharedObject];
    totalDic = [cache getTotalCount];
    NSMutableArray * friendsArray =[cache getFriends];
    CGRect frame = CGRectMake(0, 60, self.view.bounds.size.width,125);
    rightView = [[UIScrollView alloc] initWithFrame:frame];
    rightView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:rightView];
    FriendView *imageview ;
    if ((searchFriendsArray != nil) && ([searchFriendsArray count]>0)) {
        [allFriendsArray setArray:searchFriendsArray];
    }else{
        [allFriendsArray setArray:friendsArray];
    }
    rightView.contentSize =CGSizeMake(130*[allFriendsArray count],0);
    for (int i = 0; i<[allFriendsArray count]; i++) {
        Friend *friend = [allFriendsArray objectAtIndex:i];
        
        imageview = [[FriendView alloc]initWithFrame:CGRectMake((130*i), 5, 120, 100)];
        imageview.image = [UIImage imageNamed:@"headImage.jpg"];
        
        NSData *data = [cache getImage:[friend friendId]];
        if (data){
            imageview.image = [UIImage imageWithData:data];
        }else{
            imageview.image = [UIImage imageNamed:@"headImage.jpg"];
        }
        [imageview setFriendId:[friend friendId]];
        [imageview setX:(130 * i)];
        [imageview setY:10];
        [imageview setName:[friend name]];
        imageview.tag =i;
        imageview.userInteractionEnabled = YES;
        [rightView addSubview:imageview];
        
        UILabel * name = [[UILabel alloc]initWithFrame:CGRectMake((130*i), 105, 120, 20)];
        name.backgroundColor = [UIColor clearColor];
        name.text = [friend name];
        name.font = [UIFont systemFontOfSize:12.0f];
        name.textAlignment = NSTextAlignmentCenter;
        [rightView addSubview:name];
    }
    if (!searchFriendsArray && ([searchFriendsArray count]==0)) {
        [self readImageFromFileCache];
    }
        rightView.dropZoneHandler = self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedArray  = [[NSMutableArray alloc]init];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton =YES;
    loading = TRUE;
    isVideo = NO;
    height = 190;
    isAddFiles = NO;
    allFriendsArray = [[NSMutableArray alloc]init];
    ovums = nil;
      self.view.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:1.0];
    bytesSentArray = [[NSMutableArray alloc]init];
    
    //searchBar
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width-75, 45)];
    mySearchBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    mySearchBar.delegate = self;
    mySearchBar.barStyle=UIBarStyleDefault;
    mySearchBar.placeholder=@"Enter Name";
    mySearchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:mySearchBar];
    self.navigationItem.leftBarButtonItem = leftItem;
    UIBarButtonItem * rightitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked)];
    self.navigationItem.rightBarButtonItem = rightitem;
    
    
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 135, self.view.frame.size.width, self.view.frame.size.height - 135)];
    myTableView.showsVerticalScrollIndicator = NO;
//    myTableView.scrollEnabled = NO;
    myTableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    myTableView.separatorStyle = NO;
    myTableView.dataSource = self;
    myTableView.delegate = self;
    
    UIView *backgrdView = [[UIView alloc] initWithFrame:myTableView.frame];
    backgrdView.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    myTableView.backgroundView = backgrdView;
    [self.view addSubview:myTableView];

    //commit test
    dragDropManager = [OBDragDropManager sharedManager];
    MBProgressHUD * HUD= [[MBProgressHUD alloc]init];
    HUD.labelText = @"Loading Friends...";
    [self.view addSubview:HUD];
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self loadFriends];
    }completionBlock:^{
        [self loadShowFriends];
//        rightView.dropZoneHandler = self;
    }];
    
}

#pragma mark - TableViewdelegate&&TableViewdataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [sharedArray count]+2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellName = @"cate_cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
    }
    if (indexPath.row == 0) {
        [label removeFromSuperview];
        label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, cell.frame.size.width-10, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:11.0f];
        label.autoresizingMask =UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;;
        label.backgroundColor = [UIColor clearColor];
        [cell addSubview:label];
        
    }else if(indexPath.row == 1){
        fileImageview = [[UIImageView alloc]initWithFrame: CGRectMake((cell.frame.size.width-170)/2, 0, 170, 170)];
        if (fileImage )
            fileImageview.image = fileImage;
        else
            fileImageview.image = [UIImage imageNamed:@"share.png"];
        fileImageview.userInteractionEnabled = YES;
        fileImageview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
        [fileImageview addGestureRecognizer:recognizer];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectClicked)];
        [fileImageview addGestureRecognizer:singleTap];
        [cell addSubview: fileImageview];
    }else{
        progressView = [[UIProgressView alloc]initWithFrame:CGRectMake((cell.frame.size.width - 200)/2, 24, 200, 6)];
        progressView.progress = 0.0f;
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
        [cell addSubview:progressView];
        cell.textLabel.text = [NSString stringWithFormat:@"The file is being shared to %@",[sharedArray objectAtIndex:indexPath.row - 2]];
        cell.textLabel.font = [UIFont systemFontOfSize:11.0f];
    }
    
    return cell;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        return height;
    }else{
        return 30;
    }
}
#pragma mark - OBOvumSource

-(OBOvum *) createOvumFromView:(UIView*)sourceView
{
    OBOvum *ovum = [[OBOvum alloc] init];
    ovum.dataObject = fileImageview;
    return ovum;
}
-(UIView *) createDragRepresentationOfSourceView:(UIView *)sourceView inWindow:(UIWindow*)window
{
    CGRect frame = [sourceView convertRect:sourceView.bounds toView:sourceView.window];
    frame = [window convertRect:frame fromWindow:sourceView.window];
    
    UIView *dragView = [[UIView alloc] initWithFrame:frame];
    dragView.backgroundColor = sourceView.backgroundColor;
    dragView.layer.cornerRadius = 5.0;
    dragView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
    dragView.layer.borderWidth = 1.0;
    dragView.layer.masksToBounds = YES;
    return dragView;
}

-(void) dragViewWillAppear:(UIView *)dragView inWindow:(UIWindow*)window atLocation:(CGPoint)location
{
    dragView.transform = CGAffineTransformIdentity;
    dragView.alpha = 0.0;
    [dragView setFrame:CGRectMake(120, 320, 80, 80)];
    UIImage * image = [self imageWithImageSimple:fileImageview.image scaledToSize:CGSizeMake(80, 80)];
    [UIView animateWithDuration:0.25 animations:^{
        dragView.center = location;
        dragView.transform = CGAffineTransformMakeScale(1, 1);
        dragView.alpha = 1.0;
        
        dragView.backgroundColor = [UIColor colorWithPatternImage:image];
    }];
}

#pragma mark - OBDropZone

-(OBDropAction) ovumEntered:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
    
    CGFloat red = 0.33 + 0.66 * location.y / self.view.frame.size.height;
    view.layer.borderColor = [UIColor colorWithRed:red green:0.0 blue:0.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 5.0;
    
    return OBDropActionMove;
}
-(NSMutableArray *)getFriendView:(NSArray *)allStaff{
    
    NSMutableArray *friendViews = [[NSMutableArray alloc] init];
    for (id staff in allStaff){
        if ([staff isKindOfClass:[FriendView class]])
            [friendViews addObject:staff];
    }
    return friendViews;
}
- (void)uploadAndShare:(FriendView *)currentDroppedFriend ovum:(OBOvum *)ovum {
    
    if (currentDroppedFriend){
        if (progressView.progress != 0) {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"This file is being uploaded, please wait..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            return ;
        }
        UploadDB *db = [[UploadDB alloc]init];
        NSString *friendId = [currentDroppedFriend friendId];
        NSDate *now = [[NSDate alloc] init];
        long long millionsSecs = [now timeIntervalSince1970];
        ImageCache *cache = [ImageCache sharedObject];
        NSData * dataToUpload = nil;
        if (isVideo) {
           dataToUpload = videoData;
        }else{
            UIImageView *uImageView = [ovum dataObject];
            UIImage * image = [self imageWithImageSimple:uImageView.image scaledToSize:CGSizeMake(1024, 1024)];
            dataToUpload = UIImageJPEGRepresentation(image, 1.0);
        }
        
        NSString *fMD5 = [dataToUpload MD5];
        
        NSString *uploadFileId = [cache getUploadedFile:fMD5];
        if (uploadFileId){
            int i = arc4random();
            long long unique = millionsSecs + i;
            NSString *longValue = [NSString stringWithFormat:@"%llu", unique];
            STreamCategoryObject *sto = [[STreamCategoryObject alloc] initWithCategory:friendId];
            STreamObject *so = [[STreamObject alloc] init];
            [so addStaff:@"shared" withObject:uploadFileId];
            [so addStaff:@"sharedTime" withObject:[NSNumber numberWithLongLong:(millionsSecs*1000)]];
            [so addStaff:@"sharedBy" withObject:[cache getLoginUserName]];
            NSString * fileName = nil;
            if (isVideo) {
                fileName = [NSString stringWithFormat:@"%@.MOV", longValue];
                [so addStaff:@"filename" withObject:fileName];
            }else{
                fileName =[NSString stringWithFormat:@"%@.jpg", longValue];
                [so addStaff:@"filename" withObject: fileName];
            }
            isVideo = NO;

            [sto addStreamObject:so];
            
            [sto createNewCategoryObject:^(BOOL succeed, NSString *error){
                NSLog(@"%@", error);
                if (succeed){
                    
                }else{
                    NSMutableArray *sharedData = [[NSMutableArray alloc] init];
                    [sharedData addObject:so];
                    [sto updateStreamCategoryObjects:sharedData];
                }
            }];
            SharedDetail * sd = [[SharedDetail alloc]init];
            [sd setId:uploadFileId];
            [sd setShareBy:friendId];
            [sd setSharedTime:[NSString stringWithFormat:@"%llu",millionsSecs]];
            [cache setSharedFile:sd];
            
            [db insertDBUserID:friendId sharedFileID:uploadFileId sharedMD5:fMD5 withTime:[NSString stringWithFormat:@"%llu",millionsSecs]];
            [cache setSharedFile:uploadFileId forUserId:friendId];
            
        }else{
            
            [sharedArray addObject:[currentDroppedFriend name]];
            [myTableView reloadData];
            int i = arc4random();
            long long unique = millionsSecs + i;
            NSString *longValue = [NSString stringWithFormat:@"%llu", unique];
            STreamFile *sFile = [[STreamFile alloc] init];
            NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
            [sFile setFileMetadata:metaData];
            [sFile postData:dataToUpload finished:^(NSString *staff){
                NSLog(@"%@", staff);
                STreamCategoryObject *sto = [[STreamCategoryObject alloc] initWithCategory:friendId];
                STreamObject *so = [[STreamObject alloc] init];
                [so addStaff:@"shared" withObject:[sFile fileId]];
                [so addStaff:@"sharedTime" withObject:[NSNumber numberWithLongLong:(millionsSecs*1000)]];
                [so addStaff:@"sharedBy" withObject:[cache getLoginUserName]];
                NSString * fileName = nil;
                if (isVideo) {
                    fileName = [NSString stringWithFormat:@"%@.MOV", longValue];
                    [so addStaff:@"filename" withObject:fileName];
                }else{
                    fileName =[NSString stringWithFormat:@"%@.jpg", longValue];
                    [so addStaff:@"filename" withObject: fileName];
                }
                isVideo = NO;
                [sto addStreamObject:so];
                
                [sto createNewCategoryObject:^(BOOL succeed, NSString *error){
                    NSLog(@"%@", error);
                    if (succeed){
                        
                    }else{
                        NSMutableArray *sharedData = [[NSMutableArray alloc] init];
                        [sharedData addObject:so];
                        [sto updateStreamCategoryObjects:sharedData];
                        progressView.progress = 0.0f;
                    }
                }];
               
                SharedDetail * shared = [[SharedDetail alloc]init];
                [shared setId:[sFile fileId]];
                [shared setShareBy:friendId];
                [shared setSharedTime:[NSString stringWithFormat:@"%llu",millionsSecs]];
                [cache setSharedFile:shared];
                
                [db insertDBUserID:friendId sharedFileID:[sFile fileId] sharedMD5:fMD5 withTime:[NSString stringWithFormat:@"%llu",millionsSecs]];
                [cache setSharedFile:[sFile fileId] forUserId:friendId];
                [cache addUploadedFile:fMD5 withFileId:[sFile fileId]];
                
            }byteSent:^(float bytesSent){
                progressView.progress = bytesSent;
                if (bytesSent == 1.0) {
                    sharedArray = [[NSMutableArray alloc]init];
                    label.text = @"";
                    [label removeFromSuperview];
                    [myTableView reloadData];
                }
                NSLog(@"%f",bytesSent);
            }];
        }
    }
}

-(void) ovumExited:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location{
    
    NSArray *allStaff = [view subviews];
    NSMutableArray *friends = [self getFriendView:allStaff];
    currentDFriend = nil;
    for (int i=0; i < [friends count]; i++){
        FriendView *f1 = [friends objectAtIndex:i];
        if (location.x < 130){
            currentDFriend = f1;
            break;
        }
        if (i <= ([friends count] - 2)){
            FriendView *f2 = [friends objectAtIndex:(i+1)];
            if ([f2 isKindOfClass:[FriendView class]]){
               if (location.x  > f1.x && location.x < f2.x){
                 int diff1 = location.x - f1.x;
                 int diff2 = f2.x - location.x;
                 if (diff1 < diff2){
                    currentDFriend = f1;
                 }else{
                    currentDFriend = f2;
                 }
               }
            }
        }else{
            int upperX = f1.x + 130;
            if (location.x < upperX){
                currentDFriend = f1;
            }
        }
        
        if(currentDFriend)
            break;
    }
    ovums = ovum;
    if ([fileImageview.image isEqual:[UIImage imageNamed:@"share.png"]]) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Please select a file to share..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return ;
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"Are you sure to share this file with %@？",currentDFriend.name] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView .delegate = self;
        [alertView show];

    }
}

-(void) ovumDropped:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location{
    NSLog(@"");
}

-(void) handleDropAnimationForOvum:(OBOvum*)ovum withDragView:(UIView*)dragView dragDropManager:(OBDragDropManager*)dragDropManager
{
    NSLog(@"");
}

-(OBDropAction) ovumMoved:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
    view.layer.borderColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 5.0;
    return OBDropActionNone;
}

#pragma mark - Tool Methods

-(void)selectClicked{
    isAddFiles = YES;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Select File" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"System Library",@"Camera",@"Local Video",@"Video", nil];
    alert.delegate = self;
    [alert show];
//     [self addPhoto];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (isAddFiles) {
        if (buttonIndex == 1) {
            [self addPhoto];
        }
        if (buttonIndex == 2) {
            [self takePhoto];
        }
        
        if (buttonIndex == 3) {
            [self addVideo];
        }
        if (buttonIndex == 4) {
            [self takeVideo];
        }

        isAddFiles = NO;
    }else if (buttonIndex == 1) {
        [self uploadAndShare:currentDFriend ovum:ovums];
        }
    
}
- (void)addPhoto
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.navigationBar.tintColor = [UIColor colorWithRed:72.0/255.0 green:106.0/255.0 blue:154.0/255.0 alpha:1.0];
    imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    [self presentViewController:imagePicker animated:YES completion:NULL];
}
-(void)takePhoto{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Your device does not support this"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        [self presentViewController:imagePickerController animated:YES completion:NULL];
    }
}
-(void)addVideo
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.navigationBar.tintColor = [UIColor colorWithRed:72.0/255.0 green:106.0/255.0 blue:154.0/255.0 alpha:1.0];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    [self presentViewController:imagePicker animated:YES completion:NULL];
}
-(void)takeVideo {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Your device does not support this"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }else{
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
            isVideo = YES;
            NSURL *videoPath = [info objectForKey:UIImagePickerControllerMediaURL];
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoPath];
            videoData = [NSData dataWithContentsOfURL:videoPath];
            fileImage = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
            fileImageview.image = fileImage;
            label.text = @"Long press and drag the file to friend's profile image";
            NSLog(@"video = %@",videoPath);
            
    }else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]){
        
        fileImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
        fileImageview.image = fileImage;
        label.text = @"Long press and drag the file to friend's profile image";
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark searchBarDelegate
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    ImageCache *cache = [ImageCache sharedObject];
    NSMutableArray * friends =[cache getFriends];
    searchFriendsArray = [[NSMutableArray alloc]init];
    NSLog(@"%d",[searchFriendsArray count]);
    
    if (searchBar.text!=nil && searchBar.text.length>0) {
        
        for (Friend *friend in friends) {
            if ([friend.name rangeOfString:searchBar.text options:NSCaseInsensitiveSearch].length >0 ) {
                [searchFriendsArray addObject:friend];
                NSLog(@"%d",[searchFriendsArray count]);
            }
        }
        if ([searchFriendsArray count]==0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"No results found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }else{
             [allFriendsArray setArray:searchFriendsArray];
        }
    }
    
    [self loadShowFriends];

}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
   
    [searchBar resignFirstResponder];
    
}  
-(void)cancelClicked
{
    mySearchBar.text = @"";
    mySearchBar.placeholder=@"Enter Name";
    [searchFriendsArray removeAllObjects];
    [self loadShowFriends];
   [mySearchBar resignFirstResponder];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

