//
//  ViewController.m
//  VCDownloadManager
//
//  Created by wangmingquan on 4/9/17.
//  Copyright © 2017年 wangmingquan. All rights reserved.
//

#import "ViewController.h"
#import "VCDownloadManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
    [bu setTitle:@"1" forState:UIControlStateNormal];
    [bu setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [bu addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    bu.frame = CGRectMake(100, 100, 100, 30);
    [self.view addSubview:bu];
    bu = [UIButton buttonWithType:UIButtonTypeCustom];
    [bu setTitle:@"2" forState:UIControlStateNormal];
    [bu setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [bu addTarget:self action:@selector(buttonclick2:) forControlEvents:UIControlEventTouchUpInside];
    bu.frame = CGRectMake(100, 140, 100, 30);
    [self.view addSubview:bu];
    bu = [UIButton buttonWithType:UIButtonTypeCustom];
    [bu setTitle:@"3" forState:UIControlStateNormal];
    [bu setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [bu addTarget:self action:@selector(buttonclick3:) forControlEvents:UIControlEventTouchUpInside];
    bu.frame = CGRectMake(100, 180, 100, 30);
    [self.view addSubview:bu];
    bu = [UIButton buttonWithType:UIButtonTypeCustom];
    [bu setTitle:@"4" forState:UIControlStateNormal];
    [bu setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [bu addTarget:self action:@selector(buttonclick4:) forControlEvents:UIControlEventTouchUpInside];
    bu.frame = CGRectMake(100, 220, 100, 30);
    [self.view addSubview:bu];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)buttonclick:(UIButton *)bu {
    [[VCDownloadManager shareInstance] downloadWithUrl:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4" progress:^(long long totalLength, long long currentLength, VCDownloadItem *item) {
        
    } complete:^(NSError *error, VCDownloadItem *item) {
        
    }];
}

- (void)buttonclick2:(UIButton *)bu {
    [[VCDownloadManager shareInstance] downloadWithUrl:@"http://120.25.226.186:32812/resources/videos/minion_03.mp4"];
}

- (void)buttonclick3:(UIButton *)bu {
    [[VCDownloadManager shareInstance] downloadWithUrl:@"http://120.25.226.186:32812/resources/videos/minion_04.mp4"];
}

- (void)buttonclick4:(UIButton *)bu {
    [[VCDownloadManager shareInstance] downloadWithUrl:@"http://120.25.226.186:32812/resources/videos/minion_05.mp4"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
