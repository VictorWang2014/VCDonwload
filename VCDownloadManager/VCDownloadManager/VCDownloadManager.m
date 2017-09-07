//
//  VCDownloadManager.m
//  VCDownloadManager
//
//  Created by wangmingquan on 4/9/17.
//  Copyright © 2017年 wangmingquan. All rights reserved.
//

#import "VCDownloadManager.h"
#import "VCDownloadFileManager.h"
#import "VCDownloadItem.h"

static NSLock *_lock = nil;

void UncaughtExceptionHandler(NSException *exception) {
    [[VCDownloadManager shareInstance] suspendAllOperation];
}

@interface VCDownloadManager ()

/**线程队列*/
@property (nonatomic, strong) NSOperationQueue *queue;

/**下载队列，正在下载和等待下载*/
@property (nonatomic, strong) NSMutableArray *downloadArray;

@end

@implementation VCDownloadManager

+ (VCDownloadManager *)shareInstance {
    static VCDownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VCDownloadManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 2;
        [self loadDownloadArray];
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    }
    return self;
}

#pragma mark - public
- (void)downloadWithUrl:(NSString *)url {
    [self downloadWithUrl:url progress:nil complete:nil];
}

- (void)downloadWithUrl:(NSString *)url complete:(completeBlock)complete {
    [self downloadWithUrl:url progress:nil complete:nil];
}

- (void)downloadWithUrl:(NSString *)url progress:(progressBlock)progress complete:(completeBlock)complete {
    [self downloadWithUrl:url isresume:NO progress:progress complete:complete];
}

- (void)resumeDownloadWithUrl:(NSString *)url {
    [self resumeDownloadWithUrl:url progress:nil complete:nil];
}

- (void)resumeDownloadWithUrl:(NSString *)url complete:(completeBlock)complete {
    [self resumeDownloadWithUrl:url progress:nil complete:nil];
}

- (void)resumeDownloadWithUrl:(NSString *)url progress:(progressBlock)progress complete:(completeBlock)complete {
    [self downloadWithUrl:url isresume:YES progress:progress complete:complete];
}

- (void)suspendDownloadWith:(NSString *)url {
    __block int index = -1;
    [self.downloadArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VCDownloadItem *item = (VCDownloadItem *)obj;
        if ([item.url isEqualToString:url]) {
            index = (int)idx;
            *stop = YES;
        }
    }];
    if (index != -1) {
        VCDownloadItem *item = [self.downloadArray objectAtIndex:index];
        if (item.type == DownloadTypeDownloading) {
            [item.operation suspend];
        }
    }
}

#pragma mark - private
- (void)downloadWithUrl:(NSString *)url isresume:(BOOL)isresume progress:(progressBlock)progress complete:(completeBlock)complete {
    NSAssert(url.length > 0, @"url not available");
    __block int index = -1;
    [_lock lock];
    [self.downloadArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VCDownloadItem *item = (VCDownloadItem *)obj;
        if ([item.url isEqualToString:url]) {
            index = (int)idx;
            *stop = YES;
        }
    }];
    VCDownloadItem *item = nil;
    if (index == -1) {
        item = [[VCDownloadItem alloc] init];
        item.url = url;
        item.fileName = [[url lastPathComponent] stringByDeletingPathExtension];
        item.type = DownloadTypeWaitLoad;
        [self.downloadArray addObject:item];
    } else {
        item = [self.downloadArray objectAtIndex:index];
    }
    item.progress = progress;
    item.complete = complete;
    if (isresume) {
        NSString *tmpFilePath = [VCFileManager tmpFilePathWithUrl:item.url];
        if (!([NSData dataWithContentsOfFile:tmpFilePath].length > 0)) {//没有临时文件存在
            return;
        }
    } else {
        NSString *tmpFilePath = [VCFileManager tmpFilePathWithUrl:item.url];
        if ([NSData dataWithContentsOfFile:tmpFilePath].length > 0 || item.type == DownloadTypeSuspend || (item.type == DownloadTypeDownloading)) {//有临时文件存在
            return;
        }
    }
    VCDownloadOperation *operation = [[VCDownloadOperation alloc] init];
    item.operation = operation;
    operation.item = item;
    operation.name = [item.url lastPathComponent];
    [self.queue addOperation:operation];
    [_lock unlock];
}

- (void)loadDownloadArray {
    NSString *filePath = [VCFileManager downloadArrayFilePath];
    NSArray *ar = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    self.downloadArray = [NSMutableArray array];
    if (ar.count > 0) {
        self.downloadArray = [NSMutableArray arrayWithArray:ar];
    }
}

- (void)saveDownloadArray {
    NSString *filePath = [VCFileManager downloadArrayFilePath];
    if (self.downloadArray.count > 0) {
        [NSKeyedArchiver archiveRootObject:self.downloadArray toFile:filePath];
    }
}

- (void)suspendAllOperation {
    [_lock lock];
    [self.downloadArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VCDownloadItem *item = obj;
        if (item.type == DownloadTypeDownloading) {
            [item.operation suspend];
        }
    }];
    [_lock unlock];
    [self saveDownloadArray];
}

- (void)resumeAllOperation {
    [_lock lock];
    [self.downloadArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VCDownloadItem *item = obj;
        VCDownloadOperation *operation = [[VCDownloadOperation alloc] init];
        item.operation = operation;
        operation.item = item;
        operation.name = [item.url lastPathComponent];
        [self.queue addOperation:operation];
    }];
    [_lock unlock];
}

#pragma mark - setter getter
- (void)setMaxOperationCount:(int)maxOperationCount {
    self.queue.maxConcurrentOperationCount = 1;
}

- (int)maxOperationCount {
    return (int)self.queue.maxConcurrentOperationCount;
}

@end



@interface VCDownloadOperation ()<NSURLSessionDownloadDelegate> {
    BOOL _isfinish;
    BOOL _iscancel;
    BOOL _isexcute;
    BOOL _isresume;
}

@end

@implementation VCDownloadOperation

- (void)main {

}

- (void)start {
    [self download];
}

- (BOOL)isFinished
{
    return _isfinish;
}

- (BOOL)isCancelled {
    return _iscancel;
}

- (BOOL)isExecuting {
    return _isexcute;
}

#pragma mark - private
- (void)cancel {
    if (!_isexcute) {
        return;
    }
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _isfinish = YES;
    _iscancel = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)finish {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _isfinish = YES;
    _isexcute = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)excute {
    [self willChangeValueForKey:@"isExecuting"];
    _isexcute = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)download {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    [_lock lock];
    if (_isresume) {
        NSString *tmpFilePath = [VCFileManager tmpFilePathWithUrl:self.item.url];
        NSURLSessionDownloadTask *task = [session downloadTaskWithResumeData:[NSData dataWithContentsOfFile:tmpFilePath]];
        [task resume];
        self.item.task = task;
    } else {
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[NSURL URLWithString:self.item.url]];
        [task resume];
        self.item.task = task;
    }
    self.item.type = DownloadTypeDownloading;
    [_lock unlock];
    [self excute];
}

#pragma mark - public
- (void)suspend {
    if (!_iscancel) {
        [self.item.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            NSString *tmpFilePath = [VCFileManager tmpFilePathWithUrl:self.item.url];
            [[NSFileManager defaultManager] removeItemAtPath:tmpFilePath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:tmpFilePath contents:resumeData attributes:nil];
            [_lock lock];
            self.item.task = nil;
            self.item.type = DownloadTypeSuspend;
            [_lock unlock];
        }];
        [self cancel];
    }
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (self.item.progress) {
        self.item.progress(totalBytesExpectedToWrite, totalBytesWritten, self.item);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *filePath = [VCFileManager filePathWithUrl:self.item.url];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
    [_lock lock];
    self.item.task = nil;
    self.item.type = DownloadTypeComplete;
    [_lock unlock];
    if (self.item.complete) {
        self.item.complete(nil, self.item);
    }    [self finish];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [_lock lock];
    self.item.task = nil;
    self.item.type = DownloadTypeError;
    [_lock unlock];
    if (self.item.complete) {
        self.item.complete(error, self.item);
    }
    [self cancel];
}

@end


