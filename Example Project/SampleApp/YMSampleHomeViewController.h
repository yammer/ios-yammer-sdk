//
// YMSampleHomeViewController.h
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

#import <UIKit/UIKit.h>
#import "YMLoginClient.h"

@interface YMSampleHomeViewController : UIViewController <YMLoginClientDelegate>

@property (nonatomic, assign) BOOL attemptingSampleAPICall;

@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *removeTokenButton;
@property (nonatomic, weak) IBOutlet UIButton *APICallButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UILabel *tokenRemovedLabel;
@property (nonatomic, weak) IBOutlet UIImageView *tokenRemovedImage;
@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, weak) IBOutlet UIButton *statusButton;

// Yammer Sample App

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Yammer Sample Code:
// Here's an example of attempting an API call.  First check to see if the authToken is available.
// If it's not available, then the user must login as the first step in acquiring the authToken.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)attemptYammerApiCall:(id)sender;

// This is the direct call to start the login flow (for testing purposes)
- (IBAction)login:(id)sender;

// This deletes the authToken from the keychain (for testing purposes)
- (IBAction)deleteToken:(id)sender;

- (IBAction)showResults:(id)sender;

@end
