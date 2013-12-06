//
//  MainController.h
//  DragDropFileShare
//
//  Created by wangsh on 13-10-15.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBDragDrop.h"
@interface MainController : UIViewController  <OBOvumSource, OBDropZone, UIPopoverControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    BOOL loading;
}
@property(nonatomic, retain) NSMutableArray* headViewArray;
@property(strong, nonatomic)UITableView *myTableView;
@property (assign)BOOL loading;
@end
