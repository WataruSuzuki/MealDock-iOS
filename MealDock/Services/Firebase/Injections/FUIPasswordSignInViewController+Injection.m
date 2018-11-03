//
//  FUIPasswordSignInViewController+DI.m
//  MealDock
//
//  Created by Wataru Suzuki 2018/09/14.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

#import "FUIPasswordSignInViewController+Injection.h"
#import "FirebaseUIAuthInjection.h"

@implementation FUIPasswordSignInViewController (Injection)

+ (void)switchMethodInjection {
    [FirebaseUIAuthInjection switchInstanceMethodFrom:@selector(signInWithDefaultValue:andPassword:)
                                To:@selector(signInAndSaveWithDefaultValue:andPassword:)];
}

- (void)signInAndSaveWithDefaultValue:(NSString *)email andPassword:(NSString *)password {
    [[A0SimpleKeychain keychain] setString:email forKey:emailFUIAuth];
    [[A0SimpleKeychain keychain] setString:password forKey:passwordFUIAuth];
    [self signInAndSaveWithDefaultValue:email andPassword:password];
}

@end
