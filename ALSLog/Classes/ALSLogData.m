//
//  ALSLogData.m
//  logTest
//
//  Created by  杨子民 on 2017/8/16.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import "ALSLogData.h"

static ALSLogData *_sharedManager = nil;
@implementation ALSLogData
{
    
}

- (instancetype)init
{
    _log_dic = [NSMutableDictionary dictionary];
    _show_log_array = [[NSMutableSet alloc] init];
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t predicate = 0;
    
    dispatch_once(&predicate, ^ (void) {
        _sharedManager = [[ALSLogData alloc] init];
    });
    
    return _sharedManager;
}

@end
