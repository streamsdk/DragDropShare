//
//  FileCache.h
//  DragDropFileShare
//
//  Created by wangsh on 13-10-17.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject

+(FileCache *)sharedObject;

- (void)writeFileDoc:(NSString *)fileName withData:(NSData *)data;

- (void)writeFileTemp:(NSString *)fileName withData:(NSData *)data;

- (NSData *)readFromFileDoc:(NSString *)fileName;

- (NSData *)readFromFileTemp:(NSString *)fileName;

-(void)addDownloadedFile:(NSString *)fileId;

-(BOOL)isFileDownloaded:(NSString *)fileId;

-(void)loadDownloadedFiles;

- (NSString *) documentsPath;

-(void)addDownloadingFile:(NSString *)fileId;

-(BOOL)isFileDownloading:(NSString *)fileId;

-(void)removeDownloadingFile:(NSString *)fileId;

@end
