//
// NSURL+YMQueryParameters.m
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

#import "NSURL+YMQueryParameters.h"

@implementation NSURL (YMQueryParameters)

- (NSDictionary *)ym_queryParameters
{
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] init];
    
    NSArray *params = [self.query componentsSeparatedByString:@"&"];
    for (NSString *param in params) {
        NSArray *paramParts = [param componentsSeparatedByString:@"="];
        
        if (paramParts.count == 2) {
            NSString *paramName = [self ym_stringByDecodingURLFormat: [paramParts objectAtIndex:0]];
            NSString *paramValue = [self ym_stringByDecodingURLFormat: [paramParts objectAtIndex:1]];
            [queryDict setValue:paramValue forKey:paramName];
        }
    }
    
    return queryDict;
}

- (NSString *)ym_stringByDecodingURLFormat:(NSString *)urlPart
{
    NSString *result = [urlPart stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

@end
