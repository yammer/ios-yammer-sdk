//
// YMLoginViewController.m
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

#import "YMLoginViewController.h"
#import "YMLoginClient.h"
#import "NSURL+YMQueryParameters.h"
#import "YMLoginViewController+Internal.h"

#pragma mark - Yammer UIColor category

@interface UIColor (Yammer)
+ (UIColor *)yamBlue;
@end

@implementation UIColor (Yammer)
+ (UIColor *)yamBlue { return [UIColor colorWithRed:0.01f green:0.45f blue:0.78f alpha:1.0f]; }
@end

#pragma mark - Constants

NSString * const YMNavigationBarTitle = @"Yammer Authentication";

NSString * const YMMissingStateOrTokenErrorDescription = @"No token or state returned";

NSString * const YMQueryParamState = @"state";
NSString * const YMQueryParamCode = @"code";
NSString * const YMQueryParamError = @"error";
NSString * const YMQueryParamErrorReason = @"error_reason";
NSString * const YMQueryParamErrorDescription = @"error_description";

const NSInteger YMFrameLoadInterruptedError = 102;

@interface YMLoginViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation YMLoginViewController

#pragma mark - Initializer

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;

        _request = request;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = self.webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = YMNavigationBarTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(cancel)];
    
    [self.webView loadRequest:self.request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self styleNavigationBar];
}

#pragma mark - Private methods

- (void)styleNavigationBar
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor yamBlue];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
}

- (void)cancel
{
    if ([self.delegate respondsToSelector:@selector(loginViewControllerCancelled:)]) {
        [self.delegate loginViewControllerCancelled:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:[YMLoginClient sharedInstance].authRedirectURI]) {
         NSDictionary *params = [request.URL ym_queryParameters];
        
        NSString *state = params[YMQueryParamState];
        NSString *code = params[YMQueryParamCode];
        NSString *error = params[YMQueryParamError];
        NSString *errorReason = params[YMQueryParamErrorReason];
        NSString *errorDescription = params[YMQueryParamErrorDescription];
        
        if (error) {
            NSString *errorString = error;
            if (errorReason) {
                errorString = [errorString stringByAppendingString:errorReason];
            }
            if (errorDescription) {
                errorString = [errorString stringByAppendingString:errorDescription];
            }
            
            NSLog(@"error: %@", errorString);
            
            NSError *error = [NSError errorWithDomain:YMYammerSDKErrorDomain code:YMYammerSDKLoginAuthenticationError userInfo:@{NSLocalizedDescriptionKey: errorString}];
            
            if ([self.delegate respondsToSelector:@selector(loginViewController:didFailWithError:)]) {
                [self.delegate loginViewController:self didFailWithError:error];
            }
        }
        
        if (code && state) {
            if ([self.delegate respondsToSelector:@selector(loginViewController:didObtainCode:state:)]) {
                [self.delegate loginViewController:self didObtainCode:code state:state];
            }
        } else if ([self.delegate respondsToSelector:@selector(loginViewController:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:YMYammerSDKErrorDomain code:YMYammerSDKLoginAuthenticationError userInfo:@{NSLocalizedDescriptionKey: YMMissingStateOrTokenErrorDescription}];
            
            [self.delegate loginViewController:self didFailWithError:error];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code != YMFrameLoadInterruptedError) {
        if ([self.delegate respondsToSelector:@selector(loginViewController:didFailWithError:)]) {
            [self.delegate loginViewController:self didFailWithError:error];
        }
    }
}

@end
