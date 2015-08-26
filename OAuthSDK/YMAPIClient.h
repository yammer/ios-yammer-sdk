// YMAPIClient.h
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
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const YMBaseURL;

typedef void(^successCallback)(id __nullable responseObject);
typedef void(^failureStatusCodeCallback)(NSInteger statusCode, NSError *error);
typedef void(^failureCallback)(NSError *error);

/**
 Represents an object that contains a queue of HTTP operations.
 At the moment, this is essentially a lightweight wrapper around AFHTTPSessionManager.
 */
@interface YMAPIClient : NSObject

@property (nonatomic, copy, nullable) NSString *authToken;

/**
 Default initializer.
 @param authToken The OAuth token.
 */
- (instancetype)initWithAuthToken:(nullable NSString *)authToken;

/**
 Performs an async GET request.
 @param path The path
 @param parameters The request parameters
 @param success The success block
 @param failure The failure block
 */
- (void)getPath:(NSString *)path
     parameters:(nullable NSDictionary *)parameters
        success:(nullable successCallback)success
        failure:(nullable failureCallback)failure;

/**
 Performs an async POST request.
 @param path The path
 @param parameters The request parameters
 @param success The success block
 @param failure The failure block
 */
- (void)postPath:(NSString *)path
      parameters:(nullable NSDictionary *)parameters
         success:(nullable successCallback)success
         failure:(nullable failureStatusCodeCallback)failure;

/**
 Performs an async DELETE request.
 @param path The path
 @param parameters The request parameters
 @param success The success block
 @param failure The failure block
 */
- (void)deletePath:(NSString *)path
        parameters:(nullable NSDictionary *)parameters
           success:(nullable successCallback)success
           failure:(nullable failureCallback)failure;

/**
 Performs an async PUT request.
 @param path The path
 @param parameters The request parameters
 @param success The success block
 @param failure The failure block
 */
- (void)putPath:(NSString *)path
     parameters:(nullable NSDictionary *)parameters
        success:(nullable successCallback)success
        failure:(nullable failureCallback)failure;

NS_ASSUME_NONNULL_END

@end
