//
//  UploadDB.h
//  DragDropFileShare
//
//  Created by wangsh on 13-10-23.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface UploadDB : NSObject
{
    
}
-(void) initDB;

-(void)insertDBUserID:(NSString *)userID sharedFileID:(NSString *)sharedFileID sharedMD5:(NSString *)sharedMD5 withTime:(NSString *)time;

-(void)readInitDB;

-(NSMutableArray *)readFriendSharedDB:(NSString *)friendId;


@end
