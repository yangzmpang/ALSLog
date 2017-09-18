//
//  ALSViewController.m
//  ALSLog
//
//  Created by yangzmpang on 09/13/2017.
//  Copyright (c) 2017 yangzmpang. All rights reserved.
//

#import "ALSViewController.h"
#import <ALSLog/ALSLog.h>

@interface ALSViewController ()

@end

@implementation ALSViewController

- (void)config {
    ALSLogConfig* config2 = [[ALSLogConfig alloc] init];
    config2.log_config_name = @"release_log";
    config2.mode = ALSDebugMode; // 使用模式这个相当于自定义的方式由用户指定
    config2.local_level = ALSLogLevelAll; // 本地的级别，用于控制输出那些级别的日志
    config2.remote_level = RemoteLogLevelVerbose; // 远程日志级别
    
    [config2 SetLogFormattor: (__bridge void *)([[MyCustomFormatter alloc] init])];
    
    [config2 AddConsoleToLog];
    
    [config2 SetFileLog:60*60*24 maxfilecount:7 maxfilesize:1024*2024*5]; // 日志文件 重写时间 最大的日志文件个数 每个文件最大尺寸
    [config2 AddFileToLog];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
