//
//  VCDownloadFileManager.h
//  VCDownloadManager
//
//  Created by wangmingquan on 4/9/17.
//  Copyright © 2017年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**下载文件处理类*/
@interface VCFileManager : NSObject

/**获取url对应临时文件路径，同时创建文件*/
+ (NSString *)tmpFilePathWithUrl:(NSString *)url;

/**获取url对应文件路径，同时创建文件*/
+ (NSString *)filePathWithUrl:(NSString *)url;

/**获取下载队列的存储文件，同时创建*/
+ (NSString *)downloadArrayFilePath;

@end

@interface NSString (VCDownload)

/**获取每一个url对应的唯一字符串*/
- (NSString *)hashString;

@end
