//
//  FirebaseUIAuthInjection.m
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/16.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

#import "FirebaseUIAuthInjection.h"
#import <objc/runtime.h>
#import "FUIPasswordSignInViewController+Injection.h"
#import "FUIPasswordSignUpViewController+Injection.h"

NSString * const emailFUIAuth = @"user-email";
NSString * const passwordFUIAuth = @"user-password";
NSString * const usernameFUIAuth = @"user-name";

@implementation FirebaseUIAuthInjection

+ (void)kakushiAzi {
    [FUIPasswordSignUpViewController switchMethodInjection];
    [FUIPasswordSignInViewController switchMethodInjection];
}

+ (void)switchInstanceMethodFrom:(SEL)from To:(SEL)to {
    Method fromMethod = class_getInstanceMethod(self, from);
    Method toMethod = class_getInstanceMethod(self, to);
    method_exchangeImplementations(fromMethod, toMethod);
}

@end
