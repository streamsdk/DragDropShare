//
//  LoadSharingInfo.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-29.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "LoadSharingInfo.h"
#import "DownloadDetail.h"
#import "ImageCache.h"
#import <arcstreamsdk/STreamCategoryObject.h>

@implementation LoadSharingInfo

+ (LoadSharingInfo *)sharedObject{
    
    static LoadSharingInfo *loadSharingInfo;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
      
        loadSharingInfo = [[LoadSharingInfo alloc] init];
    });
    
    return loadSharingInfo;
}

- (void)loadSharingInfoSyc:(NSString *)userId{
    
    STreamCategoryObject *sto = [[STreamCategoryObject alloc] initWithCategory:userId];
    [sto load];
    [self updateCache:sto];
    
}

- (void)updateCache:(STreamCategoryObject *)sto{
    
    ImageCache *cache = [ImageCache sharedObject];
    [cache removeSharedFiles];
    NSMutableArray *sos = [sto streamObjects];
    for (STreamObject * so in sos) {
        NSString *sharedBy = [so getValue:@"sharedBy"];
        NSString *fileId = [so getValue:@"shared"];
        NSString *fileName = [so getValue:@"filename"];
        NSString * fileTime = [NSString stringWithFormat:@"%@",[so getValue:@"sharedTime"]];
        DownloadDetail *downloadDetail = [[DownloadDetail alloc] init];
        [downloadDetail setSharedBy:sharedBy];
        [downloadDetail setFileId:fileId];
        [downloadDetail setFileName:fileName];
        [downloadDetail setShareTime:fileTime];
        [cache addSharedFile:downloadDetail];
        
//        if (![totalCount objectForKey:sharedBy]){
//            [totalCount setObject:[NSNumber numberWithInt:1] forKey:sharedBy];
//        }else{
//            NSNumber *count = [totalCount objectForKey:sharedBy];
//            int newCount = [count intValue] + 1;
//            [totalCount setObject:[NSNumber numberWithInt:newCount] forKey:sharedBy];
//        }
    }
    
//    [cache setTotalCount:totalCount];
}

- (void)loadSharingInfoAsyc: (NSString *)userId{
    
    STreamCategoryObject *sto = [[STreamCategoryObject alloc] initWithCategory:userId];
    [sto load:^(BOOL succeed, NSString *response){
        if (succeed){
            [self updateCache:sto];
        }
    }];
    
}

@end
