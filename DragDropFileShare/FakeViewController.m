//
//  FakeViewController.m
//  DragDropFileShare
//
//  Created by wangsh on 13-11-12.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "FakeViewController.h"
#import "FirstTestViewController.h"
#import "dragdropshareAppDelegate.h"
#import <arcstreamsdk/STreamHttpRequest.h>
#import "Friend.h"
#import "ImageCache.h"
#import "FileCache.h"
#import "MainController.h"
#import <arcstreamsdk/STreamSession.h>
#import <arcstreamsdk/STreamUser.h>
#import <arcstreamsdk/STreamCategoryObject.h>
#import "DownloadDetail.h"
#import "LoadSharingInfo.h"
#import "ShareDetailViewController.h"
#import "TabBarViewController.h"
#import <arcstreamsdk/STreamFile.h>

@interface FakeViewController ()

@end

@implementation FakeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    ImageCache *cache = [ImageCache sharedObject];
    NSString *res = [STreamSession authenticate:@"089683A36FDA9CD632550F4613E04817" secretKey:@"B46C553C2F277FB2202E602B3C72498D" clientKey:@"D359612B036D9C70C22BC76362C9630D"];
    
    NSLog(@"%@", res);
    
    NSString *userId = @"100006591280029";
        [cache setLoginUserName:userId];
        LoadSharingInfo *load = [LoadSharingInfo sharedObject];
       [load loadSharingInfoAsyc:userId];
    
    MainController *mc = [[MainController alloc] init];

    Friend *f = [[Friend alloc] init];
    [f setName:@"Wang Chen"];
    [f setFirstName:@"Wang"];
    [f setFriendId:@"100006837242934"];
    [f setFriendUrl:@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/1076265_100006837242934_1187480037_n.jpg"];
    
    
    
    Friend *f1 = [[Friend alloc] init];
    [f1 setName:@"Tim Slogn"];
    [f1 setFirstName:@"Tim"];
    [f1 setFriendId:@"100006947616331"];
    [f1 setFriendUrl:@"https://fbcdn-profile-a.akamaihd.net/static-ak/rsrc.php/v2/yp/r/yDnr5YfbJCH.gif"];

    
    Friend *f2 = [[Friend alloc] init];
    [f2 setName:@"Mary Boy"];
    [f2 setFirstName:@"Mary Boy"];
    [f2 setFriendId:@"100006481326639"];
    [f2 setFriendUrl:@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/1118272_100006481326639_744926896_n.jpg"];
    
    Friend *f3 = [[Friend alloc] init];
    [f3 setName:@"Squeegee Squad"];
    [f3 setFirstName:@"Squeegee"];
    [f3 setFriendId:@"100006622800674"];
    [f3 setFriendUrl:@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/1118182_100006622800674_1809320494_n.jpg"];

    
   
    Friend *f5 = [[Friend alloc] init];
    [f5 setName:@"MaomaoMom"];
    [f5 setFirstName:@"MaomaoMom"];
    [f5 setFriendId:@"100005370309717"];
    [f5 setFriendUrl:@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash3/274068_100005370309717_966609253_n.jpg"];

     NSMutableArray *aFriends = [[NSMutableArray alloc] init];
    [aFriends addObject:f];
    [aFriends addObject:f3];
    [aFriends addObject:f2];
    [aFriends addObject:f1];
   // [aFriends addObject:f4];
    [aFriends addObject:f5];
    
    [cache setFriends:aFriends];
    

    ShareDetailViewController * sharedVC =[[ShareDetailViewController alloc]init];
    
    UITabBarItem *mainBar=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:1001];
    UITabBarItem *sharedBar=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:1002];
    
    mc.tabBarItem = mainBar;
    sharedVC.tabBarItem = sharedBar;
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    
    UINavigationController * mainNav = [[UINavigationController alloc]initWithRootViewController:mc];
    UINavigationController * sharedNav =[[UINavigationController alloc]initWithRootViewController:sharedVC];
    
    [array addObject:mainNav];
    [array addObject:sharedNav];
    
    TabBarViewController * tabBar = [[TabBarViewController alloc]init];
    tabBar.viewControllers = array;
    [self presentViewController:tabBar animated:YES completion:NULL];
    

    [mc setLoading:FALSE];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
