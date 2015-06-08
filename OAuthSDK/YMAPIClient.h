// The MIT License (MIT)
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

extern NSString * const YMBaseURL;

/**
 Represents an object that contains a queue of HTTP operations.
 At the moment, this is essentially a lightweight wrapper around AFHTTPSessionManager.
 */
@interface YMAPIClient : NSObject
@property (nonatomic, copy) NSString *authToken;

/**
 Default initializer.
 @param authToken The OAuth token.
 */
- (id)initWithAuthToken:(NSString *)authToken;

/**
 Performs an async GET request.
 @param path The path
 @param parameters The request parameters
 @param success The success block
 @param failure The failure block
 */
- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

/**
 Performs an async POST request.
 @param path The path
 @param parameters The request parameters
 @param success The success block
 @param failure The failure block
 */
- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSInteger statusCode, NSError *error))failure;

/**
 Performs an async DELETE request.
 @param path The path
 @param parameters The request parameters
 @param success The success block
 @param failure The failure block
 */
- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

/**
 Performs an async PUT request.
 @param path The path
 @param parameters The request parameters
 @param success The success block
 @param failure The failure block
 */
- (void)putPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;


@end
