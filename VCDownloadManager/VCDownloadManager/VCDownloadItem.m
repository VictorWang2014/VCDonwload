//
//  VCDownloadItem.m
//  VCDownloadManager
//
//  Created by wangmingquan on 4/9/17.
//  Copyright © 2017年 wangmingquan. All rights reserved.
//

#import "VCDownloadItem.h"

@implementation VCDownloadItem

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _url = [aDecoder decodeObjectForKey:@"url"];
        _fileName = [aDecoder decodeObjectForKey:@"filename"];
        _type = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_fileName forKey:@"filename"];
    [aCoder encodeInteger:_type forKey:@"type"];
}

@end
