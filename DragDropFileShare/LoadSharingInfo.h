//
//  LoadSharingInfo.h
//  DragDropFileShare
//
//  Created by wangsh on 13-10-29.
//  Copyright (c) 2013年 wangsh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadSharingInfo : NSObject

+ (LoadSharingInfo *)sharedObject;


- (void)loadSharingInfoAsyc: (NSString *)userId;

- (void)loadSharingInfoSyc:(NSString *)userId;



@end
