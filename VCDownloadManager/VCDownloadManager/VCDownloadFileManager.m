//
//  VCDownloadFileManager.m
//  VCDownloadManager
//
//  Created by wangmingquan on 4/9/17.
//  Copyright © 2017年 wangmingquan. All rights reserved.
//

#import "VCDownloadFileManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation VCFileManager

+ (NSString *)downloadDir {
    NSString *filePath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    filePath = [NSString stringWithFormat:@"%@/VCDownLoad", cachesDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

+ (NSString *)downloadFileDir {
    NSString *filePath = @"";
    NSString *cachesDir = [VCFileManager downloadDir];
    filePath = [NSString stringWithFormat:@"%@/VCDownLoadFile", cachesDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

+ (NSString *)downloadTmpFileDir {
    NSString *filePath = @"";
    NSString *cachesDir = [VCFileManager downloadDir];
    filePath = [NSString stringWithFormat:@"%@/VCDownLoadTmpFile", cachesDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

#pragma mark - public
+ (NSString *)tmpFilePathWithUrl:(NSString *)url {
    NSString *filePath = [url lastPathComponent];
    NSString *hastring = [url hashString];
    NSString *dirPath = [VCFileManager downloadTmpFileDir];
    filePath = [NSString stringWithFormat:@"%@/%@_%@", dirPath, hastring, filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}

+ (NSString *)filePathWithUrl:(NSString *)url {
    NSString *filePath = [url lastPathComponent];
    NSString *hastring = [url hashString];
    NSString *dirPath = [VCFileManager downloadFileDir];
    filePath = [NSString stringWithFormat:@"%@/%@_%@", dirPath, hastring, filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}

+ (NSString *)downloadArrayFilePath {
    NSString *filePath = @"";
    NSString *cachesDir = [VCFileManager downloadDir];
    filePath = [NSString stringWithFormat:@"%@/VCDownArrayFile", cachesDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return nil;
}

@end

@implementation NSString (VCDownload)

- (NSString *)hashString {
    const char *str = [self UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[self pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [self pathExtension]]];
    return filename;
}

@end
