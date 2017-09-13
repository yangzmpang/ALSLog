//
//  MyCustomFormatter.m
//  Lumberjack
//
//  Created by  杨子民 on 2017/8/9.
//
//
#import "MyCustomFormatter.h"
#import <libkern/OSAtomic.h>
#import "DDLog.h"

@interface MyCustomFormatter() <DDLogFormatter>
{
    int atomicLoggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}
@end

@implementation MyCustomFormatter

- (NSString *)stringFromDate:(NSDate *)date {
    int32_t loggerCount = OSAtomicAdd32(0, &atomicLoggerCount);
    
    if (loggerCount <= 1) {
        // Single-threaded mode.
        
        if (threadUnsafeDateFormatter == nil) {
            threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
            [threadUnsafeDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        
        return [threadUnsafeDateFormatter stringFromDate:date];
    } else {
        // Multi-threaded mode.
        // NSDateFormatter is NOT thread-safe.
        
        NSString *key = @"MyCustomFormatter_NSDateFormatter";
        
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
        NSDateFormatter *dateFormatter = [threadDictionary objectForKey:key];
        
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            [threadDictionary setObject:dateFormatter forKey:key];
        }
        
        return [dateFormatter stringFromDate:date];
    }
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->_flag)
    {
        case DDLogFlagError    :
            logLevel = @"E";
            break;
        case DDLogFlagWarning  :
            logLevel = @"W";
            break;
        case DDLogFlagInfo     :
            logLevel = @"I";
            break;
        case DDLogFlagDebug    :
            logLevel = @"D";
            break;
        default                :
            logLevel = @"V";
            break;
    }

    NSString *dateAndTime = [self stringFromDate:(logMessage.timestamp)];
    return [NSString stringWithFormat:@"[%@ |%@ |threadid:%@|time:%@]%@", logMessage->_tag, logLevel, logMessage->_threadID, dateAndTime,logMessage->_message];
}

- (void)didAddToLogger:(id <DDLogger>)logger {
    OSAtomicIncrement32(&atomicLoggerCount);
}

- (void)willRemoveFromLogger:(id <DDLogger>)logger {
    OSAtomicDecrement32(&atomicLoggerCount);
}

@end
