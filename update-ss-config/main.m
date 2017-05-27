//
//  main.m
//  update-ss-config
//
//  Created by 王乾舟 on 3/4/16.
//  Copyright © 2016 王乾舟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileManager.h"
#import "Configuration.h"
#import "Profile.h"
#import "HTMLParser.h"

Profile* profileWithConfigTR(HTMLNode* TR)
{
    Profile* profile = nil;
    NSArray* children = [TR children];
    do
    {
        if ([children count] != 15)
        {
            break;
        }
        
        NSString* server = [children[3] contents];
        NSString* port = [children[5] contents];
        NSString* password = [children[7] contents];
        NSString* method = [children[9] contents];
        NSString* status = [children[11] contents];
        
        if ([server length] && [port length] && [method length] && [password length]
            && [status rangeOfString:@"已失效"].location == NSNotFound)
        {
            profile = [[Profile alloc] init];
            profile.server = server;
            profile.serverPort = [port integerValue];
            profile.password = password;
            profile.method = method;
            profile.remarks = status;
        }
    } while (0);
    
    if (profile)
    {
        NSLog(@"%@", profile);
    }
    
    return profile;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSURL* ss = [NSURL URLWithString:@"http://h6v6.com/"];
        NSError* error = nil;
        HTMLParser* parser = [[HTMLParser alloc] initWithContentsOfURL:ss error:&error];
        do
        {
            if (error != nil && parser == nil)
            {
                NSLog(@"GET SRC ERROR:%@", error);
                break;
            }
            
            HTMLNode* body = parser.body;
            
            NSArray* configTables = [body findChildTags:@"table"];
            if ([configTables count] != 1)
            {
                NSLog(@"Can not find match config table");
                break;
            }
            
            NSMutableArray<HTMLNode*> *TRs = [[configTables[0] findChildTags:@"tr"] mutableCopy];
            if ([TRs count] < 3)
            {
                NSLog(@"Can not find match tr");
                break;
            }
            
            [TRs removeObjectAtIndex:0]; //first line is table header
            
            NSMutableArray* profiles = [NSMutableArray array];
            [TRs enumerateObjectsUsingBlock:^(HTMLNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Profile* profile = profileWithConfigTR(obj);
                if (profile != nil)
                {
                    [profiles addObject:profile];
                }
            }];
            
            if ([profiles count] == 0)
            {
                NSLog(@"Get Zero config from server");
                break ;
            }
            
            
            Configuration* configuration = [[Configuration alloc] init];
            configuration.profiles = profiles;
            
            NSLog(@"SaveConfiguration With Count: %zd\n", [profiles count]);
            [ProfileManager saveConfiguration:configuration];
        } while (0);
    }
    return 0;
}
