//
//  FUIPasswordSignInViewController+DI.m
//  MealDock
//
//  Created by 鈴木航 on 2018/09/14.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

#import "FUIPasswordSignInViewController+Injection.h"
#import <objc/runtime.h>

@implementation FUIPasswordSignInViewController (Injection)

+ (void)switchMethodInjection {
    // メソッドを入れ替える
//    [self switchInstanceMethodFrom:@selector(signInWithDefaultValue:andPassword:)
//                                To:@selector(signInAndSaveWithDefaultValue:andPassword:)];
}

+ (void)switchInstanceMethodFrom:(SEL)from To:(SEL)to {
    // メソッドの入れ替えの実態はここ
    Method fromMethod = class_getInstanceMethod(self, from);
    Method toMethod = class_getInstanceMethod(self, to);
    method_exchangeImplementations(fromMethod, toMethod);
}

- (void)signInAndSaveWithDefaultValue:(NSString *)email andPassword:(NSString *)password {
    [self signInWithDefaultValue:email andPassword:password];
}

@end
