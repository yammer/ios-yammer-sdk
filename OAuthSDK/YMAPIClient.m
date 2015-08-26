// YMAPIClient.m
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
#import "YMAPIClient.h"
#import "NSURL+YMQueryParameters.h"
#import <sys/utsname.h>

NS_ASSUME_NONNULL_BEGIN

NSString * const YMBaseURL = @"https://www.yammer.com";

@interface YMAPIClient ()

@property (nonatomic, strong, readonly) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSURL *baseURL;

@end

@implementation YMAPIClient
{
    AFHTTPSessionManager *_sessionManager;
    NSString * __nullable _authToken;
}

- (instancetype)init
{
    return [self initWithAuthToken:nil];
}

- (instancetype)initWithAuthToken:(nullable NSString *)authToken
{
    self = [super init];
    if (self) {
        _baseURL = [NSURL URLWithString:YMBaseURL];
        _authToken = authToken;
    }
    return self;
}

- (void)setAuthToken:(nullable NSString *)authToken
{
    _authToken = authToken;
    [self updateAuthToken];
}

- (void)updateAuthToken
{
    [_sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.authToken] forHTTPHeaderField:@"Authorization"];
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager)
        return _sessionManager;
    
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_sessionManager.requestSerializer setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    
    if (self.authToken) {
        [self updateAuthToken];
    }
    
    return _sessionManager;
}

//example: Yammer/4.0.0.141 (iPhone; iPhone OS 5.0.1; tr_TR; en)
- (NSString *)userAgent
{
    //Yammer/{app_version} ({Device type, eg: iPhone/iPad/iPod}; {iOS version}; {locale}; {language})
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    // Device Name (e.g. iPhone2,1 or iPad3,1 or x86_64 for simulator)
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *localeName = [[NSLocale currentLocale] localeIdentifier];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString *userAgent = [NSString stringWithFormat:@"Yammer/%@ (%@; %@ %@; %@; %@)", appVersion, deviceModel, systemName, systemVersion, localeName, language];
    return userAgent;
}

- (void)getPath:(NSString *)path
     parameters:(nullable NSDictionary *)parameters
        success:(nullable successCallback)success
        failure:(nullable failureCallback)failure
{
    NSLog(@"GET %@", path);
    [self.sessionManager GET:path
                  parameters:parameters
                     success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                         success(responseObject);
                     }
                     failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                         failure(error);
                     }];
}

- (void)postPath:(NSString *)path
      parameters:(nullable NSDictionary *)parameters
         success:(nullable successCallback)success
         failure:(nullable failureStatusCodeCallback)failure
{
    NSLog(@"POST %@", path);
    [self.sessionManager POST:path
                   parameters:parameters
                      success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                          success(responseObject);
                      }
                      failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                          // Forward the error
                          NSHTTPURLResponse *response = (NSHTTPURLResponse *) error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                          failure(response.statusCode, error);
                      }];
}

- (void)deletePath:(NSString *)path
        parameters:(nullable NSDictionary *)parameters
           success:(nullable successCallback)success
           failure:(nullable failureCallback)failure
{
    NSLog(@"DELETE %@", path);
    [self.sessionManager DELETE:path
                     parameters:parameters
                        success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                            success(responseObject);
                        }
                        failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                            failure(error);
                        }];
}

- (void)putPath:(NSString *)path
     parameters:(nullable NSDictionary *)parameters
        success:(nullable successCallback)success
        failure:(nullable failureCallback)failure
{
    NSLog(@"PUT %@", path);
    [self.sessionManager PUT:path
                  parameters:parameters
                     success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                         success(responseObject);
                     }
                     failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                         failure(error);
                     }];
}

NS_ASSUME_NONNULL_END

@end
