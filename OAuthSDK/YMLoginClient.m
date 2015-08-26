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

#import "YMLoginClient.h"
#import "PDKeychainBindings.h"
#import "YMAPIClient.h"
#import "NSURL+YMQueryParameters.h"

/////////////////////////////////////////////////////////
// Yammer iOS Client SDK
/////////////////////////////////////////////////////////

NSString * const YMMobileSafariString = @"com.apple.mobilesafari";
NSString * const YMYammerSDKErrorDomain = @"com.yammer.YammerSDK.ErrorDomain";

const NSInteger YMYammerSDKLoginAuthenticationError = 1001;
const NSInteger YMYammerSDKLoginObtainAuthTokenError = 1002;

NSString * const YMYammerSDKLoginDidCompleteNotification = @"YMYammerSDKLoginDidCompleteNotification";
NSString * const YMYammerSDKLoginDidFailNotification = @"YMYammerSDKLoginDidFailNotification";

NSString * const YMYammerSDKAuthTokenUserInfoKey = @"YMYammerSDKAuthTokenUserInfoKey";
NSString * const YMYammerSDKErrorUserInfoKey  = @"YMYammerSDKErrorUserInfoKey";

NSString * const YMQueryParamCode = @"code";
NSString * const YMQueryParamError = @"error";
NSString * const YMQueryParamErrorReason = @"error_reason";
NSString * const YMQueryParamErrorDescription = @"error_description";

// Note: In this sample app, we assuming single-network access.  If you have to work with mutliple networks you may
// want to save your authTokens differently (per network)
NSString * const YMKeychainAuthTokenKey = @"yammerAuthToken";
NSString * const YMKeychainStateKey = @"yammerState";

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

/////////////////////////////////////////////////////////
// Step 1: Attempt to login using Safari browser
/////////////////////////////////////////////////////////
- (void)startLogin
{
    NSAssert(self.appClientID, @"App client ID cannot be nil");
    NSAssert(self.appClientSecret, @"App client secret cannot be nil");
    NSAssert(self.authRedirectURI, @"Redirect URI cannot be nil");
    
    NSString *stateParam = [self uniqueIdentifier];
    [[PDKeychainBindings sharedKeychainBindings] setObject:stateParam forKey:YMKeychainStateKey];
    
    NSDictionary *params = @{@"client_id": self.appClientID,
                             @"redirect_uri": self.authRedirectURI,
                             @"state": stateParam};

    NSString *baseUrlString = [NSString stringWithFormat:@"%@/dialog/oauth", YMBaseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseUrlString]];

    AFHTTPRequestSerializer * requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    NSError *error;
    NSURLRequest *serializedRequest = [requestSerializer requestBySerializingRequest:request withParameters:params error:&error];

    if (error) {
        NSLog(@"Failed to serialize request: %@", error);
    }

    // Yammer SDK: This will launch mobile (iOS) Safari and begin the two-step login process.
    // The app delegate will intercept the callback from the login page.  See app delegate for method call.
    [[UIApplication sharedApplication] openURL:serializedRequest.URL];
}

- (NSString *)uniqueIdentifier
{
    return [[NSUUID UUID] UUIDString];
}

/////////////////////////////////////////////////////////
// Step 2: See if we got the "code" in the response
/////////////////////////////////////////////////////////
- (BOOL)handleLoginRedirectFromUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    BOOL isValid = NO;

    // Make sure redirect is coming from mobile safari and URL has correct prefix
    if ([sourceApplication isEqualToString:YMMobileSafariString] && [url.absoluteString hasPrefix:self.authRedirectURI]) {
        NSDictionary *params = [url ym_queryParameters];

        NSString *state = params[@"state"];
        NSString *code = params[YMQueryParamCode];
        NSString *error = params[YMQueryParamError];
        NSString *error_reason = params[YMQueryParamErrorReason];
        NSString *error_description = params[YMQueryParamErrorDescription];
        
        NSString *storedState = [[PDKeychainBindings sharedKeychainBindings] objectForKey:YMKeychainStateKey];
        if ([state isEqualToString:storedState]) {
            [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:YMKeychainStateKey];
        } else {
            return NO;
        }

        if (code || error) {
            isValid = YES;
        }

        if (error) {
            NSString *errorString = error;
            if (error_reason) {
                errorString = [errorString stringByAppendingString:error_reason];
            }
            if (error_description) {
                errorString = [errorString stringByAppendingString:error_description];
            }

            // DEVELOPER: Put your error display/processing code here...
            NSLog(@"error: %@", errorString);
            
            NSError *error = [NSError errorWithDomain:YMYammerSDKErrorDomain code:YMYammerSDKLoginAuthenticationError userInfo:@{NSLocalizedDescriptionKey: errorString}];
            
            [self.delegate loginClient:self didFailWithError:error];
            [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidFailNotification object:self userInfo:@{YMYammerSDKErrorUserInfoKey: error}];
        } else if (code) {
            NSLog(@"Credentials accepted, code received, on to part 2 of login process.");

            [self obtainAuthTokenForCode:code];
        }
    }

    return isValid;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Step 3: Once you have the code, you must continue the login process in order to get the auth token.
//         This requires another call to the server with the code, clientId, and client secret
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)obtainAuthTokenForCode:(NSString *)code
{
    // Query params
    NSDictionary *params = @{
                             @"client_id"       : self.appClientID,
                             @"client_secret"   : self.appClientSecret,
                             @"code"            : code
                             };

    // Yammer SDK: Note that once we have the authToken, we use a different constructor to create the client:
    // - (id)initWithAuthToken:(NSString *)authToken.
    // But we don't have the authToken yet, so we use this:
    YMAPIClient *client = [[YMAPIClient alloc] init];

    __weak typeof(self) weakSelf = self;

    [client postPath:@"/oauth2/access_token.json"
          parameters:params
             success:^(id responseObject) {
                 
                 NSDictionary *jsonDict = (NSDictionary *) responseObject;
                 NSDictionary *access_token = jsonDict[@"access_token"];
                 NSString *authToken = access_token[@"token"];
                 
                 // For debugging purposes only
                 NSLog(@"Yammer Login JSON: %@", responseObject);
                 NSLog(@"authToken: %@", authToken);
                 
                 // Save the authToken in the KeyChain
                 [weakSelf storeAuthTokenInKeychain:authToken];
                 
                 [weakSelf.delegate loginClient:weakSelf didCompleteWithAuthToken:authToken];
                 [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidCompleteNotification object:weakSelf userInfo:@{YMYammerSDKAuthTokenUserInfoKey: authToken}];
             }
             failure:^(NSInteger statusCode, NSError *error) {
                 NSMutableDictionary *userInfo = [@{NSLocalizedDescriptionKey: @"Unable to retrieve authentication token from code"} mutableCopy];
                 if (error) {
                     userInfo[NSUnderlyingErrorKey] = error;
                     userInfo[NSLocalizedFailureReasonErrorKey] = [error localizedDescription];
                 }
                 
                 NSError *newError = [NSError errorWithDomain:YMYammerSDKErrorDomain code:YMYammerSDKLoginObtainAuthTokenError userInfo:userInfo];
                 
                 [weakSelf.delegate loginClient:weakSelf didFailWithError:newError];
                 [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidFailNotification object:weakSelf userInfo:@{YMYammerSDKErrorUserInfoKey: newError}];
             }
     ];
}

- (void)clearAuthToken
{
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:YMKeychainAuthTokenKey];
}

- (void)storeAuthTokenInKeychain:(NSString *)authToken
{
    PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
    [bindings setObject:authToken forKey:YMKeychainAuthTokenKey];
}

- (NSString *)storedAuthToken
{
    return [[PDKeychainBindings sharedKeychainBindings] objectForKey:YMKeychainAuthTokenKey];
}

@end