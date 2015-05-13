//
//  YMAppDelegate.h
//  YammerOAuth2SampleApp
//
//  Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLoginClient.h"

@class YMSampleHomeViewController;
@class YMLoginClient;

@interface YMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) YMSampleHomeViewController *ymSampleHomeViewController;

@end
