//
//  ALSLogData.h
//  logTest
//
//  Created by  杨子民 on 2017/8/16.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ALSLog/ALSLog.h>

@interface ALSLogData : NSObject
{
    
}

@property(nonatomic,strong)NSMutableSet<NSString*>*show_log_array;
@property(nonatomic,strong)NSMutableDictionary< NSString*, ALSLog*>* log_dic;


+ (instancetype)sharedManager;
@end
