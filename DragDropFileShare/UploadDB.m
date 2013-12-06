//
//  UploadDB.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-23.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "UploadDB.h"
#import "ImageCache.h"
#import "SharedDetail.h"

@implementation UploadDB

- (NSString *)dataFilePath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"fileid.sqlite"];
    
}

-(void)initDB {
    
    sqlite3 *database;
    
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS FILEID (ROW INTEGER PRIMARY KEY AUTOINCREMENT, USERID TEXT, SHAREDFILEID TEXT, SHAREDMD5 TEXT, TIME TEXT);";
    
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error creating table: %s", errorMsg);
    }
}

-(void)insertDBUserID:(NSString *)userID sharedFileID:(NSString *)sharedFileID sharedMD5:(NSString *)sharedMD5 withTime:(NSString *)time
{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Failed to open database");
    }
    
    char *update = "INSERT INTO FILEID (USERID, SHAREDFILEID, SHAREDMD5, TIME) VALUES (?, ?, ?, ?);";
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [userID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [sharedFileID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [sharedMD5 UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [time UTF8String], -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSLog( @"Error updating table: %s", errorMsg);
    sqlite3_finalize(stmt);
    sqlite3_close(database);
}

-(NSMutableArray *)readFriendSharedDB:(NSString *)friendId{
     sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSMutableArray *timeArray = [[NSMutableArray alloc] init];
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT TIME,USERID FROM FILEID WHERE USERID = %@",friendId];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *time1  = (char*)sqlite3_column_text(statement,0);
            NSString * time2 =[[NSString alloc]initWithUTF8String:time1];
            [timeArray addObject:time2];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return timeArray;
}


-(void)readInitDB {
    
    sqlite3 *database;
    ImageCache *cache = [ImageCache sharedObject];
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *sqlQuery = @"SELECT * FROM FILEID";
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *userId = (char*)sqlite3_column_text(statement, 1);
            char *sharedFileId =(char*) sqlite3_column_text(statement, 2);
            char *sharedmd5 = (char*)sqlite3_column_text(statement, 3);
            char *time1  = (char*)sqlite3_column_text(statement, 4);
            
            NSString * userID = [[NSString alloc]initWithUTF8String:userId];
            NSString *sharedFileID = [[NSString alloc]initWithUTF8String:sharedFileId];
            NSString *sharedMD5 = [[NSString alloc]initWithUTF8String:sharedmd5];
            
            NSString * time2 =[[NSString alloc]initWithUTF8String:time1];
            long  time = (long)[time2 longLongValue];
            SharedDetail * detail = [[SharedDetail alloc]init];
            [detail setId:sharedFileID];
            [detail setSharedTime:time2];
            [detail setShareBy:userID];
            [cache setSharedFile:detail];
            [cache addUploadedFile:sharedMD5 withFileId:sharedFileID];
            [cache setSharedFile:sharedFileID forUserId:userID];
            
            
            NSLog(@"userID:%@  SHAREDFILEID:%@  time:%lu",userID,sharedFileID,time);
        }
    }
   sqlite3_finalize(statement);
    sqlite3_close(database);
}
@end
