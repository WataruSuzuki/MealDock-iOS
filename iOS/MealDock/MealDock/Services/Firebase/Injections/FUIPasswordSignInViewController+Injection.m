//
//  FUIPasswordSignInViewController+DI.m
//  MealDock
//
//  Created by 鈴木航 on 2018/09/14.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

#import "FUIPasswordSignInViewController+Injection.h"
#import <objc/runtime.h>
#import <SimpleKeychain/SimpleKeychain.h>

NSString * const emailFUIAuth = @"user-email";
NSString * const passwordFUIAuth = @"user-password";

@implementation FUIPasswordSignInViewController (Injection)

+ (void)switchMethodInjection {
    [self switchInstanceMethodFrom:@selector(signInWithDefaultValue:andPassword:)
                                To:@selector(signInAndSaveWithDefaultValue:andPassword:)];
}

+ (void)switchInstanceMethodFrom:(SEL)from To:(SEL)to {
    Method fromMethod = class_getInstanceMethod(self, from);
    Method toMethod = class_getInstanceMethod(self, to);
    method_exchangeImplementations(fromMethod, toMethod);
}

- (void)signInAndSaveWithDefaultValue:(NSString *)email andPassword:(NSString *)password {
    [[A0SimpleKeychain keychain] setString:email forKey:emailFUIAuth];
    [[A0SimpleKeychain keychain] setString:password forKey:passwordFUIAuth];
    [self signInAndSaveWithDefaultValue:email andPassword:password];
}

@end
