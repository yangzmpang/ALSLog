#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ALSLog.h"
#import "ALSLogConfig.h"
#import "ALSLogData.h"
#import "MyCustomFormatter.h"

FOUNDATION_EXPORT double ALSLogVersionNumber;
FOUNDATION_EXPORT const unsigned char ALSLogVersionString[];

