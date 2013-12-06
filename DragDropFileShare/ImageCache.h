//
//  ImageDownload.h
//  Photo
//
//  Created by wangshuai on 13-9-16.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadDetail.h"
#import "SharedDetail.h"
@interface ImageCache : NSObject
{
    
}

+ (ImageCache *)sharedObject;

-(void)selfImageDownload:(NSData *)file withFileId:(NSString *)fileId;

-(NSData *)getImage:(NSString *)fileId;

-(void)setFriends:(NSMutableArray *)friends;;

-(NSMutableArray *)getFriends;

-(void)removeSharedFiles;

-(void)setLoginUserName:(NSString *)userName;

-(NSMutableString *)getLoginUserName;

-(void)setTotalCount:(NSMutableDictionary *)totalCount;

-(NSMutableDictionary *)getTotalCount;

-(void)addSharedFile:(DownloadDetail *)detail;

-(NSMutableArray *)getFriendsSharedFiles;

-(void)setSharedFile:(SharedDetail *)detail;

-(NSMutableArray *)getSharedFiles;

-(void)addUploadedFile:(NSString *)filemd5 withFileId:(NSString *)fileId;

-(NSString *)getUploadedFile:(NSString *)fileMD5;

-(void)setSharedFile:(NSString *)fileId forUserId:(NSString *)userId;

-(NSMutableArray *)getAllSharedFiles:(NSString *)userId;

-(BOOL)isImageExist:(NSString *)fileId;

-(void)updateSharedFile:(NSString *)oldFileId newFileId:(NSString *)newFileId forUserId:(NSString *)userId;



@end
