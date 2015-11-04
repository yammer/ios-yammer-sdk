//
//  YMAppDelegate.m
//  YammerOAuth2SampleApp
//
//  Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import "YMAppDelegate.h"

#import "YMSampleHomeViewController.h"
#import "YMLoginClient.h"
#import "UIColor+YamColor.h"

@implementation YMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    [self configureLoginClient];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Yammer Sample App: YMSampleHomeViewController is a sample with some basic functionality
    self.ymSampleHomeViewController = [[YMSampleHomeViewController alloc] init];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.ymSampleHomeViewController];
    
    [self styleNavigationBar:navigationController.navigationBar];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)styleNavigationBar:(UINavigationBar *)navigationBar
{
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.barTintColor = [UIColor yamBlue];
    navigationBar.translucent = NO;
    navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
}

- (void)configureLoginClient
{
    /* Add your client ID here */
    [[YMLoginClient sharedInstance] setAppClientID:@"APP CLIENT ID"];
    
    /* Add your client secret here */
    [[YMLoginClient sharedInstance] setAppClientSecret:@"APP CLIENT SECRET"];
    
    /* Add your authorization redirect URI here */
    [[YMLoginClient sharedInstance] setAuthRedirectURI:@"AUTH REDIRECT URI"];
}

@end
