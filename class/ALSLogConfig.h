//
//  ALSLogConfig.h
//  logTest
//
//  Created by  杨子民 on 2017/8/14.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, ALSLogFlag){
    ALSLogFlagError      = (1 << 0),
    ALSLogFlagWarning    = (1 << 1),
    ALSLogFlagInfo       = (1 << 2),
    ALSLogFlagDebug      = (1 << 3),
    ALSLogFlagVerbose    = (1 << 4)
};

// 远程调试等级
typedef NS_ENUM(NSInteger, ALS_REMOTE_Level) {
    RemoteLogLevelNone = 1,
    RemoteLogLevelError,
    RemoteLogLevelDebug,
    RemoteLogLevelVerbose
};

typedef NS_ENUM(NSUInteger, ALS_LOCAL_Level){
    ALSLogLevelOff           = 0,
    ALSLogLevelError        = (ALSLogFlagError),
    ALSLogLevelWarning   = (ALSLogFlagError   | ALSLogFlagWarning),
    ALSLogLevelInfo          = (ALSLogFlagWarning | ALSLogFlagInfo),
    ALSLogLevelDebug     = (ALSLogFlagInfo    | ALSLogFlagDebug),
    ALSLogLevelVerbose   = (ALSLogFlagDebug   | ALSLogFlagVerbose),
    ALSLogLevelAll       = NSUIntegerMax
};

// 日志类型
typedef NS_ENUM(NSUInteger, ALS_LOG_TYPE)
{
    ALSTypeError = 0,
    ALSTypeWarning,
    ALSTypeInfo,
    ALSTypeDebug,
    ALSTypeVerbose,
};

// 日志开关
typedef NS_ENUM(NSUInteger, ALS_LOG_SWITCHS)
{
    ALSLocalLogOn = 0,
    ALSLocalLogOff,
    ALSRemoteLogOn,
    ALSRemoteLogOff,
    ALSCloseAll,
    ALSOpenAll
};

// 调试模式
typedef NS_ENUM(NSUInteger, ALS_LOG_MODE)
{
    ALSDebugMode = 0, // debug 模式
    ALSPreReleaseMode, // release 预发模式
    ALSReleaseMode, // release 正式模式
};

@class DDLog;
@class DDFileLogger;
@class DDTTYLogger;
@interface ALSLogConfig : NSObject
{
    
}

@property(nonatomic,strong)DDLog* dd_log;
@property(nonatomic,strong)DDFileLogger* dd_file_logger;
@property(nonatomic,strong)DDTTYLogger* dd_tty_logger;
@property(nonatomic,assign)ALS_LOG_MODE  mode;   // debug release pre-release 三种模式
@property(nonatomic,assign)ALS_LOCAL_Level local_level;
@property(nonatomic,assign)ALS_REMOTE_Level remote_level;
@property(nonatomic,strong)NSString* log_config_name;
@property(nonatomic,assign)ALS_LOG_SWITCHS log_switchs; // 日志开关

- (void)SetFileLog:(NSTimeInterval)rollingTime  maxfilecount:(NSInteger)maxFileCount  maxfilesize:(NSInteger)maxFileSize;

- (void)SetLogFormattor:(void*)formattor;
- (void)AddConsoleToLog;
- (void)AddFileToLog;
@end
