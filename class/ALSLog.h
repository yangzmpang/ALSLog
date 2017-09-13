//
//  ALSLog.h
//  logTest
//
//  Created by  杨子民 on 2017/8/11.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ALSLog/ALSLogConfig.h>
#import <ALSLog/MyCustomFormatter.h>

@class ALSLogConfig;

#define  ALSLOG  [ALSLog sharedManager]
#define  LLOG( name, type, frmt, ...) \
if ( [[ALSLog sharedManager] GetLogByname:name] ) \
   [[[ALSLog sharedManager] GetLogByname:name] LLog:type msg:frmt, ##__VA_ARGS__ ];

#define  RLOG( name, type, frmt, ...) \
if ( [[ALSLog sharedManager] GetLogByname:name] ) \
[[[ALSLog sharedManager] GetLogByname:name] RLog:type msg:frmt, ##__VA_ARGS__ ];

#define  LRLOG( name, type, frmt, ...) \
if ( [[ALSLog sharedManager] GetLogByname:name] ) \
[[[ALSLog sharedManager] GetLogByname:name] LR_Log:type msg:frmt, ##__VA_ARGS__ ];

#define  LLOG2( log_mac, type, frmt, ...) \
if ( log_mac ) \
[log_mac LLog:type msg:frmt, ##__VA_ARGS__ ];

#define  RLOG2( log_mac, type, frmt, ...) \
if ( log_mac ) \
[log_mac RLog:type msg:frmt, ##__VA_ARGS__ ];

#define  LRLOG2( log_mac, type, frmt, ...) \
if ( log_mac ) \
[log_mac LR_Log:type msg:frmt, ##__VA_ARGS__ ];

@interface ALSLog : NSObject
{
    
}

@property(nonatomic, strong)NSMutableArray<ALSLogConfig*>* logArray;



// 安装 sentry  这个在：application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 调用
- (BOOL)SetupSentry:(NSString*)url;

// 创建一个log实例 默认的config
- (BOOL)CreateLogInstance:(NSString*)log_name;

// 不同的config 生成不同的实例
- (BOOL)CreateLogInstance:(NSString*)log_name config:(ALSLogConfig*)config;

// 根据名字获取实例
- (ALSLog*)GetLogByname:(NSString*)log_name;


// 日志文件默认设置
- (ALSLogConfig*)SetDefaultConfigure:(NSString*)configName;

// 设置配置文件
- (BOOL)SetLogConfig:(ALSLogConfig*)config;
// 得到配置文件
- (ALSLogConfig*)GetLogConfig;
// delete som log
- (BOOL)RemoveLogByname:(NSString*)log_name;
// 设置显示日志的列表
- (void)SetLogShowList:(NSMutableSet<NSString*>*)show_log_array;

+ (instancetype)sharedManager;

// 本地日志
- (void)LLog:(ALS_LOG_TYPE)type msg:(NSString*)msg, ...;

// 远程日志
- (void)RLog:(ALS_LOG_TYPE)type msg:(NSString*)msg,...;

// 本地和远程都生成日志
- (void)LR_Log:(ALS_LOG_TYPE)type msg:(NSString*)msg,...;

@end
