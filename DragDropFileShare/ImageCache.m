//
//  ImageDownload.m
//  Photo
//
//  Created by wangshuai on 13-9-16.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "ImageCache.h"
#import "FileCache.h"

static NSMutableDictionary *_imageDictionary;
static NSMutableDictionary *_selfImageDictionary;
static FileCache *fileCache;
static NSMutableArray *_cachedSelfImageFiles;
static NSMutableArray *_aFriends;
static NSMutableString *loginUserName;
static NSMutableDictionary *_fileIdDic;
static NSMutableDictionary *_totalDictionary;
static NSMutableDictionary *_uploadedFiles;
static NSMutableDictionary *_filesIDDic;
static NSMutableDictionary *_downloadItems;
static NSMutableArray * _downloadFiles;
static NSMutableArray * _SharedFiles;

@implementation ImageCache


+ (ImageCache *)sharedObject{
    
    static ImageCache *sharedInstance;
    static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
        
         sharedInstance = [[ImageCache alloc] init];
         fileCache = [FileCache sharedObject];
         _cachedSelfImageFiles = [[NSMutableArray alloc] init];
         _imageDictionary = [[NSMutableDictionary alloc] init];
         _selfImageDictionary = [[NSMutableDictionary alloc] init];
         _aFriends = [[NSMutableArray alloc] init];
         _totalDictionary = [[NSMutableDictionary alloc]init];
         _fileIdDic = [[NSMutableDictionary alloc]init];
         _filesIDDic = [[NSMutableDictionary alloc]init];
         _uploadedFiles = [[NSMutableDictionary alloc] init];
         _downloadItems = [[NSMutableDictionary alloc] init];
         _downloadFiles = [[NSMutableArray alloc]init];
         _SharedFiles = [[NSMutableArray alloc]init];
         
     });
    
    return sharedInstance;
    
}
-(void)removeSharedFiles{
    [_downloadFiles  removeAllObjects];
}
-(void)addSharedFile:(DownloadDetail *)detail{
   
    [_downloadFiles addObject:detail];
}

/*-(void)addSharedFile:(NSString *)fileId forUserId:(NSString *)userId{
    
    NSMutableArray *fileIds = [_fileIdDic objectForKey:userId];
    if (fileIds){
        [fileIds addObject:fileId];
    }else{
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        [ids addObject:fileId];
        [_fileIdDic setObject:ids forKey:userId];
    }
}*/

-(void)updateSharedFile:(NSString *)oldFileId newFileId:(NSString *)newFileId forUserId:(NSString *)userId{
    
    NSMutableArray *fileIds = [_fileIdDic objectForKey:userId];
    if (fileIds){
        [fileIds removeObject:oldFileId];
        [fileIds addObject:newFileId];
    }
}


-(NSMutableArray *)getFriendsSharedFiles{
    return _downloadFiles;
}

-(void)setSharedFile:(NSString *)fileId forUserId:(NSString *)userId{
    
    NSMutableArray *fileIds = [_filesIDDic objectForKey:userId];
    if (fileIds){
        [fileIds addObject:fileId];
    }else{
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        [ids addObject:fileId];
        [_filesIDDic setObject:ids forKey:userId];
    }
}
-(NSMutableArray *)getAllSharedFiles:(NSString *)userId{
    return [_filesIDDic objectForKey:userId];
}

-(void)addUploadedFile:(NSString *)filemd5 withFileId:(NSString *)fileId{
    [_uploadedFiles setObject:fileId forKey:filemd5];
}

-(NSString *)getUploadedFile:(NSString *)fileMD5{
    return [_uploadedFiles objectForKey:fileMD5];
}

-(void)setTotalCount:(NSMutableDictionary *)totalCount{
    
    _totalDictionary = totalCount;
}

-(NSMutableDictionary *)getTotalCount{
    return _totalDictionary;
}
-(void)setLoginUserName:(NSString *)userName{
    loginUserName = [[NSMutableString alloc] init];
    [loginUserName appendString:userName];
}


-(NSMutableString *)getLoginUserName{
    return loginUserName;
}

-(void)setFriends:(NSMutableArray *)friends{
    _aFriends = friends;
}

-(NSMutableArray *)getFriends{
    return _aFriends;
}
-(void)setSharedFile:(SharedDetail *)detail{
    [_SharedFiles addObject:detail];
}

-(NSMutableArray *)getSharedFiles{
    return _SharedFiles;
}

-(void)selfImageDownload:(NSData *)file withFileId:(NSString *)fileId{
    if ([_cachedSelfImageFiles count] >= 40){
        
        for (int i=0; i < 1; i++){
            NSString *fId = [_cachedSelfImageFiles objectAtIndex:i];
            [_selfImageDictionary removeObjectForKey:fId];
            [_cachedSelfImageFiles removeObjectAtIndex:i];
        }
        
    }
    [_cachedSelfImageFiles addObject:fileId];
    [_selfImageDictionary setObject:file forKey:fileId];
}

-(BOOL)isImageExist:(NSString *)fileId{
    return [[_selfImageDictionary allKeys] containsObject:fileId];
}

-(NSData *)getImage:(NSString *)fileId{
    NSData *data =  [_selfImageDictionary objectForKey:fileId];
    if (data){
  
    }else{
        data = [fileCache readFromFileTemp:fileId];
        if (data){
            [_selfImageDictionary setObject:data forKey:fileId];
//            NSLog(@"READ FROM FILE CACHE");
        }
    }
    
    return data;
}
@end
