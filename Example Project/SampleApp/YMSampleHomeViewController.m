//
//  YMSampleHomeViewController.m
//  YammerOAuth2SampleApp
//
//  Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import "YMSampleHomeViewController.h"
#import "YMAPIResultsViewController.h"
#import "YMAPIClient.h"
#import "UIColor+YamColor.h"
#import "YMNavigationBarTitleView.h"

@interface YMSampleHomeViewController ()

@property (nonatomic, copy) NSString *lastAPIResults;

@end

@implementation YMSampleHomeViewController

- (id)init
{
    if (self = [super initWithNibName:@"HomeView" bundle:nil]) {
        _attemptingSampleAPICall = NO;
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YMYammerSDKLoginDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YMYammerSDKLoginDidFailNotification object:nil];
}

// This is called by clicking the login button in the sample interface.
- (IBAction)login:(id)sender
{    
    [[YMLoginClient sharedInstance] startLogin];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [YMNavigationBarTitleView navigationBarTitleViewWithTitleText:@"Sample API App"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteLogin:) name:YMYammerSDKLoginDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailLogin:) name:YMYammerSDKLoginDidFailNotification object:nil];
    
    [self styleViews];
}

- (void)styleViews
{
    CGFloat cornerRadius = 3.0f;
    CGFloat borderWidth = 1.0f;
    
    [self.loginButton setTitleColor:[UIColor yamBlue] forState:UIControlStateNormal];
    self.loginButton.layer.cornerRadius = cornerRadius;
    self.loginButton.layer.borderWidth = borderWidth;
    self.loginButton.layer.borderColor = [UIColor yamBlue].CGColor;
    
    [self.removeTokenButton setTitleColor:[UIColor yamBlue] forState:UIControlStateNormal];
    self.removeTokenButton.layer.cornerRadius = cornerRadius;
    self.removeTokenButton.layer.borderWidth = borderWidth;
    self.removeTokenButton.layer.borderColor = [UIColor yamBlue].CGColor;
    
    [self.APICallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.APICallButton.layer.cornerRadius = cornerRadius;
    self.APICallButton.layer.borderWidth = borderWidth;
    self.APICallButton.layer.borderColor = [UIColor yamBlue].CGColor;
    self.APICallButton.backgroundColor = [UIColor yamBlue];
}

// This is to test missing token functionality.  If there is no authToken, the app will have to login again before
// making a Yammer API call.  Important Note:  The Safari browser in iOS will hold on to the authToken in a cookie in the
// browser.  So if you have already logged in during testing, and you're trying to test the full login workflow again
// with the login dialog, you will need to delete cookies from Safari first.  You can do this by going to the iOS
// settings app, selecting Safari and then Clear Cookies and Data.
- (IBAction)deleteToken:(id)sender
{
    [[YMLoginClient sharedInstance] clearAuthToken];
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionAutoreverse
                     animations:^{
                         self.tokenRemovedLabel.alpha = 1.0f;
                         self.tokenRemovedImage.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         self.tokenRemovedLabel.alpha = 0.0f;
                         self.tokenRemovedImage.alpha = 0.0f;
                     }];
}

- (IBAction)showResults:(id)sender
{
    YMAPIResultsViewController *resultsViewController = [[YMAPIResultsViewController alloc] initWithResults:self.lastAPIResults];
    [self.navigationController pushViewController:resultsViewController animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Yammer Sample Code:
// Here's an example of attempting an API call.  First check to see if the authToken is available.
// If it's not available, then the user must login as the first step in acquiring the authToken.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)attemptYammerApiCall:(id)sender
{
    // Get the authToken if it exists
    NSString *authToken = [[YMLoginClient sharedInstance] storedAuthToken];

    // If the authToken exists, then attempt the sample API call.
    if (authToken) {
        NSLog(@"authToken: %@", authToken);
        [self makeSampleAPICall:authToken];
    } else {

        // This is an example of how you might
        self.attemptingSampleAPICall = YES;

        // If no auth token is found, go to step one of the login flow.
        // The setPostLoginProcessDelegate is one possible way do something after login.  In this case, we set that delegate
        // to self so that when the login controller is done logging in successfully, the processAfterLogin method
        // is called in this class.  Usually in an application that post-login process will just be an
        // app home page or something similar, so this dynamic delegate is not really necessary, but provides some
        // added flexibility in routing the app to a delegate after login.
        [[YMLoginClient sharedInstance] startLogin];
    }
}

// Once we know the authToken exists, attempt an actual API call
- (void)makeSampleAPICall:(NSString *)authToken
{
    NSLog(@"Making sample API call");

    // Query params (in this case there are no params, but if there were, this is how you'd add them)
    NSDictionary *params = @{ @"threaded": @"extended", @"limit": @30 };
    
    YMAPIClient *client = [[YMAPIClient alloc] initWithAuthToken:authToken];
    
    [self prepareForSampleAPICall];
    
    __weak typeof(self) weakSelf = self;
    
    // the postPath is where the path is appended to the baseUrl
    // the params are the query params
    [client getPath:@"/api/v1/messages/following.json"
         parameters:params
            success:^(id responseObject) {
                NSLog(@"Sample API Call JSON: %@", responseObject);
                weakSelf.lastAPIResults = [responseObject description];
                
                [weakSelf sampleAPICallSuccess];
            }
            failure:^(NSError *error) {
                NSLog(@"error: %@", error);
                
                [weakSelf sampleAPICallFailureWithMessage:error.localizedDescription];
            }
     ];
}

- (void)prepareForSampleAPICall
{
    [self.activityIndicator startAnimating];
    [self.statusButton setTitle:@"Calling API ..." forState:UIControlStateNormal];
    self.statusButton.userInteractionEnabled = NO;
    self.statusButton.alpha = 1.0f;
    
    self.statusImageView.alpha = 0.0f;
}

- (void)sampleAPICallSuccess
{
    [self.activityIndicator stopAnimating];
    
    [self.statusButton setTitle:@"API Results >" forState:UIControlStateNormal];
    self.statusButton.userInteractionEnabled = YES;
    self.statusButton.alpha = 1.0f;
    
    self.statusImageView.image = [UIImage imageNamed:@"Icon-Success"];
    [UIView animateWithDuration:1.0f animations:^{
        self.statusImageView.alpha = 1.0f;
    }];
}

- (void)sampleAPICallFailureWithMessage:(NSString *)message
{
    [self.activityIndicator stopAnimating];
    
    [self.statusButton setTitle:message forState:UIControlStateNormal];
    self.statusButton.userInteractionEnabled = NO;
    self.statusButton.alpha = 1.0f;
    
    self.statusImageView.image = [UIImage imageNamed:@"Icon-Error"];
    [UIView animateWithDuration:1.0f animations:^{
        self.statusImageView.alpha = 1.0f;
    }];
}

- (void)showAlertViewForError:(NSError *)error title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:[error description]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Login controller delegate methods

- (void)loginClient:(YMLoginClient *)loginClient didCompleteWithAuthToken:(NSString *)authToken
{
    // Uncomment if you want to use delegate instead of notifications
    //[self handleSuccessWithToken:authToken];
}

- (void)loginClient:(YMLoginClient *)loginClient didFailWithError:(NSError *)error
{
    // Uncomment if you want to use delegate instead of notifications
    //[self handleFailureWithError:error];
}

#pragma mark - Login controller notification handling methods

- (void)didCompleteLogin:(NSNotification *)note
{
    NSString *authToken = note.userInfo[YMYammerSDKAuthTokenUserInfoKey];
    [self handleSuccessWithToken:authToken];
}

- (void)didFailLogin:(NSNotification *)note
{
    NSError *error = note.userInfo[YMYammerSDKErrorUserInfoKey];
    [self handleFailureWithError:error];
}

#pragma mark - Common error/success handling methods

- (void)handleSuccessWithToken:(NSString *)authToken
{    
    // This is an example of only processing something after login if we were attempting to do something before the
    // login process was triggered.  In this case, we have an attemptingSampleAPICall boolean that tells us we were
    // trying to make the sample API call before login was triggered, so now we can resume that process here.
    if (self.attemptingSampleAPICall) {
        
        // Reset the flag so we only come back here during logins that were triggered as part of trying to make the
        // sample API call.
        self.attemptingSampleAPICall = NO;
        
        // If the authToken exists, then attempt the sample API call.
        if (authToken) {
            [self makeSampleAPICall: authToken];
        } else {
            NSLog(@"Could not make sample API call.  AuthToken does not exist");
        }
    }
}

- (void)handleFailureWithError:(NSError *)error
{
    // Replace this with whatever you want.  This is just an example of handling an error with an alert.
    [self showAlertViewForError:error title:@"Authentication error"];
}

@end
