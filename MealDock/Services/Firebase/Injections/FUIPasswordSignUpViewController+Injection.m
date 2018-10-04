//
//  FUIPasswordSignUpViewController+Injection.m
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/16.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

#import "FUIPasswordSignUpViewController+Injection.h"
#import "FirebaseUIAuthInjection.h"

@implementation FUIPasswordSignUpViewController (Injection)

+ (void)switchMethodInjection {
    [FirebaseUIAuthInjection switchInstanceMethodFrom:@selector(signUpWithEmail:andPassword:andUsername:)
                                                   To:@selector(signUpAndSaveKeychainWithEmail:andPassword:andUsername:)];
}

- (void)signUpAndSaveKeychainWithEmail:(NSString *)email
                           andPassword:(NSString *)password
                           andUsername:(NSString *)username {
    [[A0SimpleKeychain keychain] setString:email forKey:emailFUIAuth];
    [[A0SimpleKeychain keychain] setString:password forKey:passwordFUIAuth];
    [[A0SimpleKeychain keychain] setString:username forKey:usernameFUIAuth];
    [self signUpAndSaveKeychainWithEmail:email andPassword:password andUsername:username];
}

@end
