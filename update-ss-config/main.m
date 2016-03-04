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

Profile* profileWithConfigDivNode(HTMLNode* divNode)
{
    Profile* profile = nil;
    NSArray* children = [divNode children];
    do
    {
        if ([children count] < 4)
        {
            break;
        }
        
        NSString* server = nil;
        NSString* port = nil;
        NSString* password = nil;
        NSString* method = nil;
        NSString* status = nil;
        
        BOOL notMatchNode = NO;
        for (int i=0; i<children.count; i++)
        {
            HTMLNode* node = children[i];
            NSString* contents = [node contents];
            do
            {
                if ([contents length] != 0 && [contents rangeOfString:@"状态"].location != NSNotFound)
                {
                    status = ([node firstChild] && [[node firstChild] nextSibling]) ? [[[node firstChild] nextSibling] contents] : @"";
                    NSLog(@"==状态:%@",status);
                    break;
                }
                
                NSArray* components = [contents componentsSeparatedByString:@":"];
                if ([components count] != 2)
                {
                    notMatchNode = YES;
                    break ;
                }
                
                if ([components[0] rangeOfString:@"服务器地址"].location != NSNotFound)
                {
                    server = components[1];
                    NSLog(@"==%@", contents);
                    break;
                }
                
                if ([components[0] rangeOfString:@"端口"].location != NSNotFound)
                {
                    port = components[1];
                    NSLog(@"==%@", contents);
                    break;
                }
                
                if ([components[0] rangeOfString:@"密码"].location != NSNotFound)
                {
                    password = components[1];
                    NSLog(@"==%@", contents);
                    break;
                }
                
                if ([components[0] rangeOfString:@"加密方式"].location != NSNotFound)
                {
                    method = components[1];
                    NSLog(@"==%@", contents);
                }
            } while (0);
        }
        
        if ([server length] && [port length] && [method length] && [password length])
        {
            profile = [[Profile alloc] init];
            profile.server = server;
            profile.serverPort = [port integerValue];
            profile.password = password;
            profile.method = method;
            profile.remarks = status;
        }
    } while (0);
    
    if (profile != nil)
    {
        NSLog(@"=================================");
    }
    
    return profile;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSURL* ss = [NSURL URLWithString:@"http://www.ishadowsocks.com/"];
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
            NSArray* configDivs = [body findChildrenOfClass:@"col-lg-4 text-center"];
            if ([configDivs count] == 0)
            {
                NSLog(@"Can not find match divs");
                break;
            }
            
            NSMutableArray* profiles = [NSMutableArray array];
            for (int i= 0; i<[configDivs count]; i++)
            {
                Profile* profile = profileWithConfigDivNode(configDivs[i]);
                if (profile != nil)
                {
                    [profiles addObject:profile];
                }
            }
            
            if ([profiles count] == 0)
            {
                NSLog(@"Get Zero config from server");
                break ;
            }
            
            
            Configuration* configuration = [[Configuration alloc] init];
            configuration.profiles = profiles;
            
            NSLog(@"SaveConfiguration With Count: %zd\n%@", [profiles count], [configuration JSONDictionary]);
            [ProfileManager saveConfiguration:configuration];
        } while (0);
    }
    return 0;
}
