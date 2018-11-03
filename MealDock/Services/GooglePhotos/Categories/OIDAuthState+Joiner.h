//
//  HogeFuga.h
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/18.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppAuth/AppAuth.h>

@interface OIDAuthState (JoinUser)

- (instancetype)initWithRefreshToken:(NSString *)token
                     andResponse:(OIDAuthorizationResponse *)response;

@end

