//
// Created by clowwindy on 11/3/14.
// Copyright (c) 2014 clowwindy. All rights reserved.
//

#import "ProfileManager.h"
#import "NSUserDefaults+ShadowSocks.h"

#define CONFIG_DATA_KEY @"config"

@implementation ProfileManager {

}

+ (Configuration *)configuration {
    NSData *data = [[NSUserDefaults shadowsocksUserDefault] dataForKey:CONFIG_DATA_KEY];
    Configuration *configuration = [[Configuration alloc] initWithJSONData:data];
    return configuration;
}

+ (void)saveConfiguration:(Configuration *)configuration {
    if (configuration.profiles.count == 0) {
        configuration.current = -1;
    }
    if (configuration.current != -1 && configuration.current >= configuration.profiles.count) {
        configuration.current = 0;
    }
    [[NSUserDefaults shadowsocksUserDefault] setObject:[configuration JSONData] forKey:CONFIG_DATA_KEY];
    
    [[NSUserDefaults shadowsocksUserDefault] synchronize];
}

@end
