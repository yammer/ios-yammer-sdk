//
// YMLoginClient.h
//
// Copyright (c) 2015 Microsoft
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const YMYammerSDKLoginDidCompleteNotification;
FOUNDATION_EXPORT NSString * const YMYammerSDKLoginDidFailNotification;

FOUNDATION_EXPORT NSString * const YMYammerSDKAuthTokenUserInfoKey;
FOUNDATION_EXPORT NSString * const YMYammerSDKErrorUserInfoKey;

@protocol YMLoginClientDelegate;

@interface YMLoginClient : NSObject

@property (nonatomic, weak) id<YMLoginClientDelegate> delegate;

@property (nonatomic, copy) NSString *appClientID;
@property (nonatomic, copy) NSString *appClientSecret;
@property (nonatomic, copy) NSString *authRedirectURI;

+ (YMLoginClient *)sharedInstance;

- (void)startLogin;

- (BOOL)handleLoginRedirectFromUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/**
 Asynchronously load the tokens from all networks using the stored Oauth token
 and store them in the keychain using the network's permalink
 @param completion A block that is called on completion
 */
- (void)refreshNetworkTokensWithCompletion:(void (^)(NSError *error))completion;

- (NSString *)storedAuthToken;

/**
 Returns a network token based on the network's permalink
 @param networkPermalink The network's permalink
 @return The auth token for the network
 */
- (NSString *)storedAuthTokenForNetworkPermalink:(NSString *)networkPermalink;

- (void)clearAuthTokens;

@end

@protocol YMLoginClientDelegate

- (void)loginClient:(YMLoginClient *)loginClient didCompleteWithAuthToken:(NSString *)authToken;
- (void)loginClient:(YMLoginClient *)loginClient didFailWithError:(NSError *)error;

@end
