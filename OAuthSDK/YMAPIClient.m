//
//  YMAPIClient.m
//
// Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import "YMLoginClient.h"
#import "YMAPIClient.h"
#import "NSURL+YMQueryParameters.h"
#import <sys/utsname.h>

NSString * const YMBaseURL = @"https://www.yammer.com";

@interface YMAPIClient ()

@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) NSURL *baseURL;

@end

@implementation YMAPIClient
{
    AFHTTPRequestOperationManager *_operationManager;
    NSString *_authToken;
}

- (instancetype)init
{
    return [self initWithAuthToken:nil];
}

- (instancetype)initWithAuthToken:(NSString *)authToken
{
    self = [super init];
    if (self) {
        _baseURL = [NSURL URLWithString:YMBaseURL];
        _authToken = authToken;
    }
    return self;
}

- (void)setAuthToken:(NSString *)authToken
{
    _authToken = authToken;
    [self updateAuthToken];
}

- (NSString *)authToken
{
    return _authToken;
}

- (void)updateAuthToken
{
    [_operationManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", self.authToken] forHTTPHeaderField:@"Authorization"];
}

- (AFHTTPRequestOperationManager *)operationManager
{
    if (_operationManager)
        return _operationManager;

    _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseURL];
    [_operationManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_operationManager.requestSerializer setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    
    if (self.authToken) {
        [self updateAuthToken];
    }
    
    return _operationManager;
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
     parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure
{
    NSLog(@"GET %@", path);
    [self.operationManager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSInteger statusCode, NSError *error))failure
{
    NSLog(@"POST %@", path);
    [self.operationManager POST:path
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      success(responseObject);
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      // Forward the error
                      NSHTTPURLResponse *response = [operation response];
                      NSInteger statusCode = [response statusCode];
                      failure(statusCode, error);
                  }];
}

@end
