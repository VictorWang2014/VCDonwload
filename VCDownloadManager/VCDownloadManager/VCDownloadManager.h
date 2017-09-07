//
//  VCDownloadManager.h
//  VCDownloadManager
//
//  Created by wangmingquan on 4/9/17.
//  Copyright © 2017年 wangmingquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCDownloadItem.h"

/**后台下载类 支持下载大文件以及断点续传*/
@interface VCDownloadManager : NSObject

/**是否开机自启动下载上次未完成的下载项*/
@property (nonatomic, assign) BOOL isDownloadAppInit;

/**最大的线程并发数*/
@property (nonatomic, assign) int maxOperationCount;


/**全局单例*/
+ (VCDownloadManager *)shareInstance;

/**
 * 后台下载或继续下载某一个url
 * @param url 链接
 */
- (void)downloadWithUrl:(NSString *)url;

/**
 * 后台下载或继续下载某一个url 成功完成的回调
 * @param url 链接
 * @param complete 成功回调
 */
- (void)downloadWithUrl:(NSString *)url complete:(completeBlock)complete;

/**
 * 后台下载或继续下载某一个url 用于大的文件下载事实监控下载进度
 * @param url 链接
 * @param progress 下载过程的回调
 * @param complete 成功回调
 */
- (void)downloadWithUrl:(NSString *)url progress:(progressBlock)progress complete:(completeBlock)complete;


/**
 * 继续下载某一个url
 * @param url 链接
 */
- (void)resumeDownloadWithUrl:(NSString *)url;

/**
 * 继续下载某一个url 成功完成的回调
 * @param url 链接
 * @param complete 成功回调
 */
- (void)resumeDownloadWithUrl:(NSString *)url complete:(completeBlock)complete;

/**
 * 继续下载某一个url 用于大的文件下载事实监控下载进度
 * @param url 链接
 * @param progress 下载过程的回调
 * @param complete 成功回调
 */
- (void)resumeDownloadWithUrl:(NSString *)url progress:(progressBlock)progress complete:(completeBlock)complete;

/**
 * 暂停下载某一个url
 * @param url 链接
 */
- (void)suspendDownloadWith:(NSString *)url;

/**暂停所有下载*/
- (void)suspendAllOperation;


@end



/**自定义下载线程，对于改线程*/
@interface VCDownloadOperation : NSOperation

@property (nonatomic, strong) VCDownloadItem *item;

/**暂停下载*/
- (void)suspend;

@end





