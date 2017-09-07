//
//  VCDownloadItem.h
//  VCDownloadManager
//
//  Created by wangmingquan on 4/9/17.
//  Copyright © 2017年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DownloadType) {
    DownloadTypeWaitLoad,           // 等待下载
    DownloadTypeDownloading,        // 正在下载
    DownloadTypeSuspend,            // 暂停下载
    DownloadTypeComplete,           // 完成下载
    DownloadTypeError,              // 下载出错
};

@class VCDownloadItem;

/**下载完成*/
typedef void(^completeBlock)(NSError *error, VCDownloadItem *item);
/**下载过程 文件大小  已下载的文件大小*/
typedef void(^progressBlock)(long long totalLength, long long currentLength, VCDownloadItem *item);



@class VCDownloadOperation;

@interface VCDownloadItem : NSObject <NSCoding>

/**下载的链接*/
@property (nonatomic, strong) NSString *url;

/**文件名*/
@property (nonatomic, strong) NSString *fileName;

/**下载状态*/
@property (nonatomic, assign) DownloadType type;

/**恢复数据*/
@property (nonatomic, strong) NSData *resumeData;

/**下载任务*/
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

/**下载线程*/
@property (nonatomic, strong) VCDownloadOperation *operation;

/**完成block*/
@property (nonatomic, copy) completeBlock complete;

/**过程block*/
@property (nonatomic, copy) progressBlock progress;

@end
