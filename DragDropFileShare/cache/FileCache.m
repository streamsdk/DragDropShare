//
//  FileCache.m
//  DragDropFileShare
//
//  Created by wangsh on 13-10-17.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import "FileCache.h"

static NSMutableArray * imageArray;
static NSMutableSet *_downloadedFiles;
static NSMutableSet *_downloadingFiles;

@implementation FileCache

+(FileCache *)sharedObject{
    
    static FileCache *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[FileCache alloc]init];
        imageArray = [[NSMutableArray alloc]init];
        _downloadedFiles = [[NSMutableSet alloc] init];
        _downloadingFiles = [[NSMutableSet alloc] init];
        
    });
    return sharedInstance;
}

-(void)addDownloadedFile:(NSString *)fileId{
    [_downloadedFiles addObject:fileId];
}

-(BOOL)isFileDownloaded:(NSString *)fileId{
    return [_downloadedFiles containsObject:fileId];
}

-(void)addDownloadingFile:(NSString *)fileId{
    [_downloadingFiles addObject:fileId];
}

-(BOOL)isFileDownloading:(NSString *)fileId{
    return [_downloadingFiles containsObject:fileId];
}


-(void)removeDownloadingFile:(NSString *)fileId{
    [_downloadingFiles removeObject:fileId];
}

-(void)loadDownloadedFiles{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    for (NSString *file in fileList)
          [_downloadedFiles addObject:file];

}

-(void)writeFileTemp:(NSString *)fileName withData:(NSData *)data{
    
    NSString *fName = [[self tempPath] stringByAppendingPathComponent:fileName];
    [data writeToFile:fName atomically:YES];
}

-(void)writeFileDoc:(NSString *)fileName withData:(NSData *)data{
    
    NSString *fName = [[self documentsPath] stringByAppendingPathComponent:fileName];
    [data writeToFile:fName atomically:YES];
}

-(NSData *) readFromFileTemp:(NSString *)fileName {
    
    NSString * fName = [[self tempPath] stringByAppendingPathComponent:fileName];
    
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:fName];
    
    NSData * content = [fileHandle readDataToEndOfFile];
    return content;
}

-(NSData *) readFromFileDoc:(NSString *)fileName {
    
    NSString * fName = [[self documentsPath] stringByAppendingPathComponent:fileName];
    
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:fName];
    
    NSData * content = [fileHandle readDataToEndOfFile];
    return content;
}

-(NSString *) documentsPath {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsdir = [paths objectAtIndex:0];
    return documentsdir;
}

-(NSString *) tempPath {
    
    return NSTemporaryDirectory();
}
@end
