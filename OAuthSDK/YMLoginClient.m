//
// YMLoginClient.m
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
//

#import "YMLoginClient.h"
#import <SSKeychain/SSKeychain.h>
#import "YMAPIClient.h"
#import "NSURL+YMQueryParameters.h"
#import "YMLoginViewController.h"
#import "YMLoginViewController+Internal.h"

NSString * const YMMobileSafariString = @"com.apple.mobilesafari";
NSString * const YMYammerSDKErrorDomain = @"com.yammer.YammerSDK.ErrorDomain";

const NSInteger YMYammerSDKLoginAuthenticationError = 1001;
const NSInteger YMYammerSDKLoginObtainAuthTokenError = 1002;
const NSInteger YMYammerSDKLoginObtainNetworkTokensError = 1003;

NSString * const YMYammerSDKLoginDidCompleteNotification = @"YMYammerSDKLoginDidCompleteNotification";
NSString * const YMYammerSDKLoginDidFailNotification = @"YMYammerSDKLoginDidFailNotification";

NSString * const YMYammerSDKAuthTokenUserInfoKey = @"YMYammerSDKAuthTokenUserInfoKey";
NSString * const YMYammerSDKErrorUserInfoKey  = @"YMYammerSDKErrorUserInfoKey";

NSString * const YMKeychainAuthTokenKey = @"yammerAuthToken";
NSString * const YMKeychainStateKey = @"yammerState";

@interface YMLoginClient ()<YMLoginViewControllerDelegate>

@property (nonatomic, strong) YMAPIClient *client;
@property (nonatomic, strong) YMAPIClient *tokensClient;
@property (nonatomic, strong) NSCache *tokenCache;

@end

@implementation YMLoginClient

+ (YMLoginClient *)sharedInstance
{
    static YMLoginClient *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _client = [[YMAPIClient alloc] init];
        _tokensClient = [[YMAPIClient alloc] init];
        _tokenCache = [[NSCache alloc] init];
    }
    return self;
}

/**
 Attempt to login using mobile browser
 */
- (void)startLoginWithContextViewController:(UIViewController *)viewController
{
    NSAssert(self.appClientID, @"App client ID cannot be nil");
    NSAssert(self.appClientSecret, @"App client secret cannot be nil");
    NSAssert(self.authRedirectURI, @"Redirect URI cannot be nil");
    NSAssert(viewController, @"Context view controller cannot be nil");
    
    NSString *stateParam = [self uniqueIdentifier];
    [SSKeychain setPassword:stateParam forService:[self serviceName] account:YMKeychainStateKey];
    
    NSDictionary *params = @{@"client_id"       : self.appClientID,
                             @"redirect_uri"    : self.authRedirectURI,
                             @"state"           : stateParam};

    NSString *baseUrlString = [NSString stringWithFormat:@"%@/dialog/oauth", YMBaseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseUrlString]];

    AFHTTPRequestSerializer * requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    NSError *error;
    NSURLRequest *serializedRequest = [requestSerializer requestBySerializingRequest:request withParameters:params error:&error];

    if (error) {
        NSLog(@"Failed to serialize request: %@", error);
    }
    
    if (viewController) {
        YMLoginViewController *loginViewController = [[YMLoginViewController alloc] initWithRequest:serializedRequest];
        loginViewController.delegate = self;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (NSString *)uniqueIdentifier
{
    return [[NSUUID UUID] UUIDString];
}

/**
 Get the Oauth token from the server using the code, client ID and client secret
 */
- (void)obtainAuthTokenForCode:(NSString *)code
{
    // Query params
    NSDictionary *params = @{@"client_id"       : self.appClientID,
                             @"client_secret"   : self.appClientSecret,
                             @"code"            : code};

    __weak typeof(self) weakSelf = self;
    
    [self.client postPath:@"/oauth2/access_token.json"
               parameters:params
                  success:^(id responseObject) {
                      NSDictionary *jsonDict = (NSDictionary *) responseObject;
                      NSDictionary *accessToken = jsonDict[@"access_token"];
                      NSString *authToken = accessToken[@"token"];
                      
                      // Save the authToken in the KeyChain
                      [weakSelf storeAuthTokenInKeychain:authToken withTokenKey:YMKeychainAuthTokenKey];
                      
                      // Retrieve all network tokens
                      [self retrieveAllNetworkTokensWithToken:authToken completion:^(NSError *error) {
                          if (!error) {
                              [weakSelf.delegate loginClient:weakSelf didCompleteWithAuthToken:authToken];
                              [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidCompleteNotification
                                                                                  object:weakSelf
                                                                                userInfo:@{YMYammerSDKAuthTokenUserInfoKey: authToken}];
                          } else {
                              [self clearAuthTokens];
                              
                              [weakSelf.delegate loginClient:weakSelf didFailWithError:error];
                              [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidFailNotification
                                                                                  object:weakSelf
                                                                                userInfo:@{YMYammerSDKErrorUserInfoKey: error}];
                          }
                      }];
                  }
                  failure:^(NSInteger statusCode, NSError *error) {
                      NSMutableDictionary *userInfo = [@{NSLocalizedDescriptionKey: @"Unable to retrieve authentication token from code"} mutableCopy];
                      
                      if (error) {
                          userInfo[NSUnderlyingErrorKey] = error;
                          userInfo[NSLocalizedFailureReasonErrorKey] = [error localizedDescription];
                      }
                      
                      NSError *newError = [NSError errorWithDomain:YMYammerSDKErrorDomain
                                                              code:YMYammerSDKLoginObtainAuthTokenError
                                                          userInfo:userInfo];
                      
                      [weakSelf.delegate loginClient:weakSelf didFailWithError:newError];
                      [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidFailNotification
                                                                          object:weakSelf
                                                                        userInfo:@{YMYammerSDKErrorUserInfoKey: newError}];
                  }
     ];
}

- (void)refreshNetworkTokensWithCompletion:(void (^)(NSError *error))completion
{
    [self retrieveAllNetworkTokensWithToken:[self storedAuthToken] completion:completion];
}

- (void)retrieveAllNetworkTokensWithToken:(NSString *)authToken completion:(void (^)(NSError *error))completion
{
    if (authToken) {
        self.tokensClient.authToken = authToken;
        
        [self.tokensClient getPath:@"/api/v1/oauth/tokens.json"
                        parameters:nil
                           success:^(id responseObject) {
                               for (NSDictionary *networks in responseObject) {
                                   [self storeAuthTokenInKeychain:networks[@"token"] withTokenKey:networks[@"network_permalink"]];
                               }
                               completion(nil);
                           }
                           failure:^(NSError *error) {
                               NSLog(@"An error occurred loading network tokens!");
                               completion(error);
                           }
         ];
    } else {
        NSError *error = [[NSError alloc] initWithDomain:YMYammerSDKErrorDomain
                                                    code:YMYammerSDKLoginObtainNetworkTokensError
                                                userInfo:@{NSLocalizedDescriptionKey : @"Auth token does not exist."}];
        completion(error);
    }
}

- (void)clearAuthTokens
{
    [self.tokenCache removeAllObjects];

    NSArray *accounts = [SSKeychain accountsForService:[self serviceName]];
    
    for (NSDictionary *accountDictionary in accounts) {
        [SSKeychain deletePasswordForService:[self serviceName]
                                     account:accountDictionary[kSSKeychainAccountKey]];
    }
}

- (void)storeAuthTokenInKeychain:(NSString *)authToken withTokenKey:(NSString *)tokenKey
{
    if (!authToken || !tokenKey) {
        return;
    }
    
    [self.tokenCache setObject:authToken forKey:tokenKey];
    
    [SSKeychain setPassword:authToken forService:[self serviceName] account:tokenKey];
}

- (NSString *)storedAuthToken
{
    return [self retrieveAuthTokenForKey:YMKeychainAuthTokenKey];
}

- (NSString *)storedAuthTokenForNetworkPermalink:(NSString *)networkPermalink
{
    return [self retrieveAuthTokenForKey:networkPermalink];
}

- (NSString *)retrieveAuthTokenForKey:(NSString *)tokenKey
{
    if (!tokenKey) {
        return nil;
    }
    
    NSString *authToken = [self.tokenCache objectForKey:tokenKey];
    if (authToken) {
        return authToken;
    }
    
    authToken = [SSKeychain passwordForService:[self serviceName] account:tokenKey];
    if (authToken) {
        [self.tokenCache setObject:authToken forKey:tokenKey];
    }
    
    return authToken;
}

- (NSString *)serviceName
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

#pragma mark - Login view controller delegate

- (void)loginViewController:(YMLoginViewController *)loginViewController didObtainCode:(NSString *)code state:(NSString *)state
{
    [loginViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSString *storedState = [SSKeychain passwordForService:[self serviceName] account:YMKeychainStateKey];
    if ([state isEqualToString:storedState]) {
        [SSKeychain deletePasswordForService:[self serviceName] account:YMKeychainStateKey];
        
        [self obtainAuthTokenForCode:code];
    }
}

- (void)loginViewController:(YMLoginViewController *)loginViewController didFailWithError:(NSError *)error
{
    [self.delegate loginClient:self didFailWithError:error];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidFailNotification object:self userInfo:@{YMYammerSDKErrorUserInfoKey: error}];
}

@end