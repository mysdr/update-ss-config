//
//  NSUserDefaults+ShadowSocks.m
//  update-ss-config
//
//  Created by 王乾舟 on 2/25/16.
//  Copyright © 2016 王乾舟. All rights reserved.
//

#import "NSUserDefaults+ShadowSocks.h"

@implementation NSUserDefaults(ShadowSocks)

+ (instancetype)shadowsocksUserDefault
{
    static NSUserDefaults* _inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[NSUserDefaults alloc] initWithSuiteName:@"clowwindy.ShadowsocksX"];
    });
    
    return _inst;
}

@end
