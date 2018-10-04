//
//  FirebaseUIAuthInjection.h
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/16.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

#import <FirebaseUI/FirebaseAuthUI.h>
#import <SimpleKeychain/SimpleKeychain.h>

extern NSString * const initializedFUIAuth;
extern NSString * const emailFUIAuth;
extern NSString * const passwordFUIAuth;
extern NSString * const usernameFUIAuth;

@interface FirebaseUIAuthInjection : NSObject

+ (void)kakushiAzi;
+ (void)switchInstanceMethodFrom:(SEL)from To:(SEL)to;

@end
