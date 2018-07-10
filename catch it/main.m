//
//  main.m
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        NSString *appDelegateClassName = NSStringFromClass([AppDelegate class]);
        int main = UIApplicationMain(argc, argv, nil, appDelegateClassName);
        return main;
    }
}
