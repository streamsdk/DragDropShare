//
//  ShareDetailViewController.h
//  DragDropFileShare
//
//  Created by wangsh on 13-10-21.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
@interface ShareDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    UITableView * myTableView ;
    UISegmentedControl *segmentedControl;
}
@property (nonatomic,retain) NSMutableArray *dataArray ;
@property (nonatomic,retain) NSMutableArray  *bytesSent;
@end
