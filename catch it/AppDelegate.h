//
//  AppDelegate.h
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#define ADApplicationWillResignActiveNotificationIdentifier @"com.lukas.ad.appWRA"
#define ADApplicationWillEnterForegroundNotificationIdentifier @"com.lukas.ad.appWEF"

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
