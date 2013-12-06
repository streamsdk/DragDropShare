//
//  FirstTestViewController.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-13.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

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
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

@interface FirstTestViewController () <FBLoginViewDelegate>

@end

@implementation FirstTestViewController

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
    [super viewDidLoad];
	// Create Login View so that the app will be granted "status_update" permission.
    self.navigationController.navigationBarHidden = YES;

    FBLoginView *loginview = [[FBLoginView alloc] init];
    
    loginview.frame = CGRectOffset(loginview.frame, 25, 200);
#ifdef __IPHONE_7_0
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        loginview.frame = CGRectOffset(loginview.frame, 25, 200);
    }
#endif
#endif
#endif
    loginview.delegate = self;
    
//    [self.view addSubview:loginview];
    
    [loginview sizeToFit];
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:self.view.frame];
    if (IS_IPHONE5)
       [imageView setImage:[UIImage imageNamed:@"iphone5login.png"]];
    else
       [imageView setImage:[UIImage imageNamed:@"iphone4slogin.png"]];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    [imageView addSubview:loginview];
    
    
   // 客户key: D359612B036D9C70C22BC76362C9630D
   // 安全key: B46C553C2F277FB2202E602B3C72498D
   // 应用ID/key: 089683A36FDA9CD632550F4613E04817
   
    //Client Key: 9BBA51D798FCD1F98CF46036847E6FF8
    //Secret Key: F667FA792C2241ECEFACA0A73DCFC998
    //Application ID: F2CEA0C547C3A9E27CBC66A66140E9E9
    for (int i=0; i < 5; i++){
        NSString *res = [STreamSession authenticate:@"F2CEA0C547C3A9E27CBC66A66140E9E9" secretKey:@"F667FA792C2241ECEFACA0A73DCFC998" clientKey:@"9BBA51D798FCD1F98CF46036847E6FF8"];
        
        NSLog(@"%@", res);
        if ([res isEqualToString:@"auth ok"]){
            break;
        }else{
            sleep(5);
        }
    }

}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSLog(@"FBLoginView encountered an error=%@", error);
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    NSString *myUserName = [NSString stringWithFormat:@"Hello %@!", user.first_name];
    NSLog(@"myUserName: %@",myUserName);
    // setting the profileID property of the FBProfilePictureView instance
    // causes the control to fetch and display the profile picture for the user
   NSString *userId = user.id;
    NSLog(@"userId: %@", userId);
    
    ImageCache *cache = [ImageCache sharedObject];
    
    if (!_done){
        _done  = true;
        [cache setLoginUserName:userId];
        
        STreamUser *suser = [[STreamUser alloc] init];
        [suser isUserExists:userId response:^(BOOL exist, NSString *error){
            
            if (!exist){
                NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];
                [metaData setObject:myUserName forKey:@"userFacebookName"];
                [metaData setObject:@"iphone" forKey:@"device"];
                
                [suser signUp:userId withPassword:@"" withMetadata:metaData response:^(BOOL succeed, NSString *error){
                    
                }];
                
                STreamCategoryObject *stc = [[STreamCategoryObject alloc] init];
                [stc setCategoryName:[NSMutableString stringWithString:userId]];
                [stc createNewCategoryObject:^(BOOL succeed, NSString *res){
                    
                }];
            }
        }];
        
        LoadSharingInfo *load = [LoadSharingInfo sharedObject];
        [load loadSharingInfoAsyc:userId];
        
        
        FBRequest *friendsRequest = [FBRequest requestWithGraphPath:@"me/friends"
                                                         parameters:[NSDictionary dictionaryWithObject:@"picture.type(large),id,email,name,first_name,username"
                                                                                                forKey:@"fields"] HTTPMethod:@"GET"];
        MainController *mc = [[MainController alloc] init];

        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                      NSDictionary* result,
                                                      NSError *error) {
            NSArray* friends = [result objectForKey:@"data"];
            NSLog(@"Found: %lu friends", (unsigned long)[friends count]);
            NSMutableArray *aFriends = [[NSMutableArray alloc] init];
            for (NSDictionary<FBGraphUser>* friend in friends) {
                FBGraphObject *pic = [friend objectForKey:@"picture"];
                FBGraphObject *str = [pic objectForKey:@"data"];
                NSString *pUrl = [str objectForKey:@"url"];
                Friend *f = [[Friend alloc] init];
                [f setName:friend.name];
                [f setFirstName:friend.first_name];
                [f setFriendId:friend.id];
                [f setFriendUrl:pUrl];
                [aFriends addObject:f];
                NSLog(@"I have a friend named %@ with id %@     witUrl: %@   withFirstName: %@", friend.name, friend.id, pUrl, friend.first_name);
            }
            [cache setFriends:aFriends];
            
            [mc setLoading:FALSE];
        }];
    
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
        
        }
}
-(BOOL)shouldAutorotate{
    return NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
