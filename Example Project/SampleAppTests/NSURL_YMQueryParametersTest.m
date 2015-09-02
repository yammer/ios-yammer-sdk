//
// NSURL+YMQueryParametersTest.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <YammerSDK/NSURL+YMQUeryParameters.h>

@interface NSURL_YMQueryParametersTest : XCTestCase

@end

@implementation NSURL_YMQueryParametersTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testYm_queryParameters
{
    NSString *queryString = @"https://www.yammer.com/test?param1=value1&param2=value2&param3=value3%20test&param4=value4+extra";
    NSURL *queryStringURL = [NSURL URLWithString:queryString];
    NSDictionary *queryParametersDictionary = [queryStringURL ym_queryParameters];
    
    XCTAssert([[queryParametersDictionary allKeys] count] == 4);
    XCTAssert([queryParametersDictionary[@"param2"] isEqualToString:@"value2"]);
    XCTAssert([queryParametersDictionary[@"param3"] isEqualToString:@"value3 test"]);
    XCTAssert([queryParametersDictionary[@"param4"] isEqualToString:@"value4 extra"]);
}

@end
