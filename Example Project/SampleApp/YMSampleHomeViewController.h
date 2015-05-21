//
//  YMSampleHomeViewController.h
//  YammerOAuth2SampleApp
//
//  Copyright (c) 2013 Yammer, Inc. All rights reserved.
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
