//
//  HogeFuga.m
//  MealDock
//
//  Created by 鈴木航 on 2018/10/18.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

#import "OIDAuthState+Joiner.h"

@implementation OIDAuthState (Joiner)

- (instancetype)initWithRefreshToken:(NSString *)token
                     andResponse:(OIDAuthorizationResponse *)response
{
    self = [super init];
    if (self) {
        _pendingActionsSyncObject = [[NSObject alloc] init];
        _refreshToken = token;
        _scope = nil;
        _lastAuthorizationResponse = response;
        _lastTokenResponse = nil;
        _authorizationError = nil;
    }
    return self;
}

@end
