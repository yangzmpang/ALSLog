//
//  ALSLogConfig.m
//  logTest
//
//  Created by  杨子民 on 2017/8/14.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import "ALSLogConfig.h"
#import "MyCustomFormatter.h"
#import "CocoaLumberjack.h"

@implementation ALSLogConfig
{
    
}

- (instancetype)init
{
    _local_level = ALSLogLevelAll;
    _remote_level = RemoteLogLevelVerbose;
    
    _dd_log = [[DDLog alloc] init];
    _dd_tty_logger = [[DDTTYLogger alloc] init];
      [_dd_tty_logger setColorsEnabled:YES];
    
    // 设置彩色属性
    [_dd_tty_logger setForegroundColor:DDMakeColor(214,  57,  30) backgroundColor:DDMakeColor(255,  255,  255) forFlag:DDLogFlagError];
    [_dd_tty_logger setForegroundColor:DDMakeColor(204, 121,  32) backgroundColor:DDMakeColor(255,  255,  255) forFlag:DDLogFlagWarning];
    [_dd_tty_logger setForegroundColor:DDMakeColor(0, 113,  62) backgroundColor:DDMakeColor(255,  255,  255) forFlag:DDLogFlagDebug];
    [_dd_tty_logger setForegroundColor:DDMakeColor(0, 128,  168) backgroundColor:DDMakeColor(255,  255,  255) forFlag:DDLogFlagVerbose];
    [_dd_tty_logger setForegroundColor:DDMakeColor(209, 112,  19) backgroundColor:DDMakeColor(255,  255,  255) forFlag:DDLogFlagInfo];
    
    return self;
}

- (void)SetFileLog:(NSTimeInterval)rollingTime  maxfilecount:(NSInteger)maxFileCount  maxfilesize:(NSInteger)maxFileSize
{
    DDFileLogger* fileLogger = [[DDFileLogger alloc] init]; // 文件日志
    fileLogger.rollingFrequency = rollingTime;
    fileLogger.logFileManager.maximumNumberOfLogFiles = maxFileCount;
    fileLogger.maximumFileSize = maxFileSize;
    _dd_file_logger = fileLogger;
}

- (void)AddConsoleToLog
{
    [_dd_log addLogger:_dd_tty_logger withLevel:(DDLogLevel)_local_level]; // 加入日志列表
}

- (void)AddFileToLog
{
    [_dd_log addLogger:_dd_file_logger]; // 加入日志列表
}

- (void)SetLogFormattor:(void*)formattor
{
    MyCustomFormatter* formattorlocal = (__bridge MyCustomFormatter*)formattor;
    _dd_tty_logger.logFormatter = formattorlocal;
}

@end
