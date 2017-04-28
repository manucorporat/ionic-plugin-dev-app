/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

/*
 NOTE: plugman/cordova cli should have already installed this,
 but you need the value UIViewControllerBasedStatusBarAppearance
 in your Info.plist as well to set the styles in iOS 7
 */

#import "CDVIonicDevApp.h"
#import <objc/runtime.h>
#include <arpa/inet.h>


@interface CDVIonicDevApp () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property(nonatomic, strong) NSNetServiceBrowser *browser;
@property(nonatomic, strong) NSNetService *service;

@end

@implementation CDVIonicDevApp

- (void)pluginInitialize
{
    self.browser = [[NSNetServiceBrowser alloc] init];
    [self.browser setDelegate:self];
    [self.browser searchForServicesOfType:@"_http._tcp." inDomain:@"local."];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    if(![[service name] isEqualToString:@"ionic-app-scripts"]) {
        return;
    }
    self.service = service;
    [service setDelegate:self];
    [service resolveWithTimeout:0.0];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"STOPPED!");
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"ERROR %@", errorDict);
}

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    NSLog(@"DID RESOLVE");
    NSData *address = [[service addresses] firstObject];
    if(address != nil) {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        NSString *str = [NSString stringWithFormat:@"http://%s:%ld/", inet_ntoa(socketAddress->sin_addr), (long)[service port]];
        NSURL *url = [NSURL URLWithString:str];
        [self.webViewEngine loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void) dealloc
{
    [self.browser stop];
}

@end
