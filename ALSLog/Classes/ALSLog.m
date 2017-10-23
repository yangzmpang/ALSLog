//
//  ALSLog.m
//  logTest
//
//  Created by  杨子民 on 2017/8/11.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import "ALSLog.h"


#import <Sentry/Sentry.h>
#import "MyCustomFormatter.h"
#import "SentryLog.h"
#import "ALSLogConfig.h"
#import "Sentry.h"
#import "SentryClient+Internal.h"
#import "ALSLogData.h"
#import "CocoaLumberjack.h"


#define DDLogErrorToDDLog2(ddlog, tag,frmt, ...)   LOG_MAYBE_TO_DDLOG(ddlog, YES,                LOG_LEVEL_DEF, DDLogFlagError,   0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogWarnToDDLog2(ddlog,tag, frmt, ...)    LOG_MAYBE_TO_DDLOG(ddlog, LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, 0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogInfoToDDLog2(ddlog,tag, frmt, ...)    LOG_MAYBE_TO_DDLOG(ddlog, LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogDebugToDDLog2(ddlog, tag,frmt, ...)   LOG_MAYBE_TO_DDLOG(ddlog, LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogVerboseToDDLog2(ddlog, tag,frmt, ...) LOG_MAYBE_TO_DDLOG(ddlog, LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, tag, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

static ALSLog *_sharedManager = nil;
@interface ALSLog()
{
    
}

// 程序使用模式
@property(nonatomic,strong)ALSLogConfig* current_config;

- (void)SetSingleDefaultConfigure;
- (void)Add_Logger:(ALSLogConfig*)config;
- (NSArray*)Get_Log_Config;
- (DDFileLogger*)GetDefaultFileLogger;
- (NSString*)GetLogName;

@end

@implementation ALSLog
{
    
}

- (instancetype)init
{
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t predicate = 0;
    
    dispatch_once(&predicate, ^ (void) {
        _sharedManager = [[ALSLog alloc] init];
    });
    
    return _sharedManager;
}


- (BOOL)SetupSentry:(NSString*)url
{
    NSError *error = nil;
    if ( url == nil )
        url = @"https://c7338a2a9a1049bb9f053c621caad33e:df29f451282f4429b15807d09f5fb309@sentry.io/200434";
    
    SentryClient *client = [[SentryClient alloc] initWithDsn:url didFailWithError:&error];
    SentryClient.sharedClient = client;
    [SentryClient.sharedClient startCrashHandlerWithError:&error];
    
    if ( error ){
        return NO;
    }
    
    return YES;
}

- (void)Add_Logger:(ALSLogConfig*)config
{
    if ( nil == _logArray ){
        _logArray = [[NSMutableArray alloc] init];
    }
    
    [_logArray addObject:config];
    [config.dd_log addLogger:config.dd_file_logger withLevel:(DDLogLevel)config.local_level];
}

- (NSArray*)Get_Log_Config
{
    return _logArray;
}

- (BOOL)SetLogConfig:(ALSLogConfig*)config
{
    for (id key in _logArray)
    {
        if ( key == config ){
             _current_config = key;
            return YES;
        }
    }
    
    _current_config = config;
    return YES;
}

- (ALSLogConfig*)GetLogConfig
{
    return _current_config;
}

- (DDFileLogger*)GetDefaultFileLogger
{
    DDFileLogger* fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    fileLogger.maximumFileSize = 1024 * 1024 * 5;
    
    return fileLogger;
}

- (void)SetSingleDefaultConfigure
{
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelVerbose];
    [DDTTYLogger sharedInstance].logFormatter = [[MyCustomFormatter alloc] init];

    // 自定义的日志文件
    [DDLog addLogger:[self GetDefaultFileLogger]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    if ( nil == _current_config ){
        _current_config = [[ALSLogConfig alloc] init];
    
        _current_config.dd_log = [DDLog sharedInstance];
        _current_config.dd_file_logger = [self GetDefaultFileLogger];
    }
    
    _current_config.local_level = ALSLogLevelVerbose;
    _current_config.remote_level = RemoteLogLevelVerbose;
}

- (ALSLogConfig*)SetDefaultConfigure:(NSString*)configName
{
    ALSLogConfig* config = [[ALSLogConfig alloc] init];
    
    config.log_config_name = configName;
    config.dd_log = [[DDLog alloc] init];
    config.local_level = ALSLogLevelAll;
    config.remote_level = RemoteLogLevelVerbose;
    
    config.dd_tty_logger = [[DDTTYLogger alloc] init];
    config.dd_tty_logger.logFormatter = [[MyCustomFormatter alloc] init];
    [config.dd_log addLogger:config.dd_tty_logger withLevel:(DDLogLevel)config.local_level];
    
    config.dd_file_logger = [self GetDefaultFileLogger];
    [config.dd_log addLogger:config.dd_file_logger];
    
    [self SetLogConfig:config];
    return config;
}

- (NSString*)GetLogName
{
    NSString* name;
    for( NSString*key in [ALSLogData sharedManager].log_dic)
    {
        id obj =  [[ALSLogData sharedManager].log_dic objectForKey:key];
        if ( obj == self ){
            name = key;
            break;
        }
    }
    
    return name;
}

- (BOOL)IsInShowLogArray
{
    NSString* name = [self GetLogName];
    for ( NSString* n in [ALSLogData sharedManager].show_log_array ){
        if ( [n isEqualToString:name] )
            return YES;
    }
    
    return NO;
}

- (void)LLog_args:(ALS_LOG_TYPE)type msg:(NSString *)msg arg:(va_list)args
{
    NSString *strFormat = [[NSString alloc] initWithFormat:msg arguments:args];
    DDLogLevel ddLogLevel = (DDLogLevel)_current_config.local_level;
    switch (type)
    {
        case ALSTypeError:
            DDLogErrorToDDLog2(_current_config.dd_log, _current_config.log_config_name ,@"%@", strFormat);
            //NSLog(strFormat);
            break;
        case ALSTypeWarning:
            DDLogWarnToDDLog2(_current_config.dd_log, _current_config.log_config_name, @"%@",strFormat);
            break;
        case ALSTypeInfo:
            DDLogInfoToDDLog2(_current_config.dd_log,_current_config.log_config_name, @"%@",strFormat);
            break;
        case ALSTypeDebug:
            DDLogDebugToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
            break;
        case ALSTypeVerbose:
            DDLogVerboseToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
    }
}

- (void)RLog_args:(ALS_LOG_TYPE)type msg:(NSString*)msg arg:(va_list)args
{
    NSString *strFormat = [[NSString alloc] initWithFormat:msg arguments:args];
    SentryClient.logLevel = (SentryLogLevel)_current_config.remote_level;
    
    [self remoteLog:strFormat logtype:type];
}

- (void)LR_Log_args:(ALS_LOG_TYPE)type msg:(NSString*)msg arg:(va_list)args
{
    NSString *strFormat = [[NSString alloc] initWithFormat:msg arguments:args];
    DDLogLevel ddLogLevel = (DDLogLevel)_current_config.local_level;
    SentryClient.logLevel = (SentryLogLevel)_current_config.remote_level;
    
    if ( _current_config.log_switchs == ALSRemoteLogOn )
        [self remoteLog:strFormat logtype:type];
    
    if ( _current_config.log_switchs == ALSLocalLogOn )
    {
        switch (type)
        {
            case ALSTypeError:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogErrorToDDLog2(_current_config.dd_log, _current_config.log_config_name,@"%@", strFormat);
                break;
            case ALSTypeWarning:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogWarnToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
                break;
            case ALSTypeInfo:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogInfoToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
                break;
            case ALSTypeDebug:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogDebugToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
                break;
            case ALSTypeVerbose:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogVerboseToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
            default:
                break;
        }
    }
}

// 本地日志
- (void)LLog:(ALS_LOG_TYPE)type msg:(NSString *)msg, ...
{
    if ( _current_config.log_switchs == ALSLocalLogOff ||
        _current_config.log_switchs == ALSCloseAll ){
        NSLog( @"LLog switchs close....." );
        return;
    }
    
    if ( [self IsInShowLogArray] == NO ){
        NSLog( @"LLog is show return ...");
        return;
    }
    
    va_list ap;
    va_start(ap, msg);
    [self LLog_args:type msg:msg arg:ap];
    va_end(ap);
}

- (void)remoteLog:(NSString*)message logtype:(ALS_LOG_TYPE)logtype
{
    NSString* type = @"";
    switch(logtype){
    case ALSTypeError:
            type = @"error";
            break;
    case ALSTypeWarning:
            type = @"warning";
            break;
    case ALSTypeInfo:
            type = @"info";
            break;
    case ALSTypeDebug:
            type = @"debug";
            break;
    case ALSTypeVerbose:
            type = @"verbose";
            break;
    default:
            type = @"debug";
            break;
    }
    
    SentryEvent *event = [[SentryEvent alloc] initWithLevel:kSentrySeverityFatal];
    event.message = message;
    event.timestamp =  [NSDate date];
    event.logger = type;
    event.threads = SentryClient.sharedClient._snapshotThreads;
    
    [SentryClient.sharedClient sendEvent:event withCompletionHandler:NULL];
 }

// 远程日志
- (void)RLog:(ALS_LOG_TYPE)type msg:(NSString*)msg, ...
{
    if ( _current_config.log_switchs == ALSRemoteLogOff ||
        _current_config.log_switchs == ALSCloseAll ){
        NSLog( @"RLog switchs close....." );
        return;
    }

    if ( [self IsInShowLogArray] == NO ){
        NSLog( @"RLog is show return ...");
        return;
    }
    
    va_list ap;
    va_start(ap, msg);
    [self RLog_args:type msg:msg arg:ap];
    va_end(ap);
    
    /*
    const char* format = [msg UTF8String];
    NSInteger len = [msg length];
    
    char* buffer = malloc( len + 1 );
    
    va_list ap;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvarargs"
    va_start(ap, format);
#pragma clang diagnostic pop
    
    SentryClient.logLevel = (SentryLogLevel)_current_config.remote_level;
    
    vsnprintf(buffer, len+1, format, ap);
    NSString *strFormat = [[NSString alloc] initWithCString:(const char*)buffer
                                                   encoding:NSASCIIStringEncoding];
    
    [self remoteLog:strFormat logtype:type];

    va_end(ap);
    if ( buffer ){
        free(buffer);
        buffer = NULL;
    }
     */
}

// 本地和远程都生成日志
- (void)LR_Log:(ALS_LOG_TYPE)type msg:(NSString*)msg, ...
{
    if ( _current_config.log_switchs == ALSCloseAll ){
        NSLog( @"LR_Log switchs close....." );
        return;
    }

    if ( [self IsInShowLogArray] == NO ){
        NSLog( @"LRLog is show return ...");
        return;
    }

    va_list ap;
    va_start(ap, msg);
    [self LR_Log_args:type msg:msg arg:ap];
    va_end(ap);
    
    /*
    const char* format = [msg UTF8String];
    NSInteger len = [msg length];
    
    char* buffer = malloc( len + 1 );
    
    va_list ap;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvarargs"
    va_start(ap, format);
#pragma clang diagnostic pop
    
    vsnprintf(buffer, len+1, format, ap);
    NSString *strFormat = [[NSString alloc] initWithCString:(const char*)buffer
                                                   encoding:NSASCIIStringEncoding];
    
    DDLogLevel ddLogLevel = (DDLogLevel)_current_config.local_level;
    SentryClient.logLevel = (SentryLogLevel)_current_config.remote_level;
    
     if ( _current_config.log_switchs == ALSRemoteLogOn )
        [self remoteLog:strFormat logtype:type];
    
    if ( _current_config.log_switchs == ALSLocalLogOn )
    {
        switch (type)
        {
            case ALSTypeError:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogErrorToDDLog2(_current_config.dd_log, _current_config.log_config_name,@"%@", strFormat);
                break;
            case ALSTypeWarning:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogWarnToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
                break;
            case ALSTypeInfo:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogInfoToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
                break;
            case ALSTypeDebug:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogDebugToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
                break;
            case ALSTypeVerbose:
                if ( _current_config.log_switchs == ALSLocalLogOn )
                    DDLogVerboseToDDLog2(_current_config.dd_log,_current_config.log_config_name,@"%@",strFormat);
            default:
                break;
        }
    }
    
    va_end(ap);
    if ( buffer ){
        free(buffer);
        buffer = NULL;
    }
     */
}

- (BOOL)CreateLogInstance:(NSString*)log_name
{
    ALSLog *item = [[ALSLogData sharedManager].log_dic objectForKey:log_name];
    if ( nil == item ){
        ALSLog * log = [[ALSLog alloc] init];
        [[ALSLogData sharedManager].log_dic setObject:log forKey:log_name];
        [[ALSLogData sharedManager].show_log_array addObject:log_name];
        [log SetDefaultConfigure:log_name];
        return YES;
    }
    return NO;
}

- (BOOL)CreateLogInstance:(NSString*)log_name config:(ALSLogConfig*)config
{
    ALSLog *item = [[ALSLogData sharedManager].log_dic objectForKey:log_name];
    if ( nil == item ){
        ALSLog * log = [[ALSLog alloc] init];
        [[ALSLogData sharedManager].log_dic setObject:log forKey:log_name];
        [[ALSLogData sharedManager].show_log_array addObject:log_name];
        [log SetLogConfig:config]; // 设置配置，一个ALSLog 对应一个config
    }
    
    return YES;
}

- (ALSLog*)GetLogByname:(NSString*)log_name;
{
    ALSLog *item = [[ALSLogData sharedManager].log_dic objectForKey:log_name];
    return item;
}

- (BOOL)RemoveLogByname:(NSString*)log_name
{
    ALSLog *item = [[ALSLogData sharedManager].log_dic objectForKey:log_name];
    if ( item ){
        [[ALSLogData sharedManager].log_dic removeObjectForKey:log_name];
        return YES;
    }
    return NO;
}

- (void)SetLogShowList:(NSMutableSet<NSString*>*)show_log_array;
{
    [ALSLogData sharedManager].show_log_array = show_log_array;
}

@end
