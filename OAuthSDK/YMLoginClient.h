//
// Created by Jerry Destremps on 6/26/13.
// Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const YMYammerSDKLoginDidCompleteNotification;
extern NSString * const YMYammerSDKLoginDidFailNotification;

extern NSString * const YMYammerSDKAuthTokenUserInfoKey;
extern NSString * const YMYammerSDKErrorUserInfoKey;

@protocol YMLoginClientDelegate;

@interface YMLoginClient : NSObject

@property (nonatomic, weak) id<YMLoginClientDelegate> delegate;

@property (nonatomic, copy) NSString *appClientID;
@property (nonatomic, copy) NSString *appClientSecret;
@property (nonatomic, copy) NSString *authRedirectURI;

+ (YMLoginClient *)sharedInstance;

- (void)startLogin;
- (BOOL)handleLoginRedirectFromUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
- (NSString *)storedAuthToken;
- (void)clearAuthToken;

@end

@protocol YMLoginClientDelegate

- (void)loginClient:(YMLoginClient *)loginClient didCompleteWithAuthToken:(NSString *)authToken;
- (void)loginClient:(YMLoginClient *)loginClient didFailWithError:(NSError *)error;

@end
