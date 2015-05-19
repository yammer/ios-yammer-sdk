//
//  YMAPIResultsViewController.h
//  ios-oauth-demo
//
//  Created by Peter Willsey on 5/18/15.
//  Copyright (c) 2015 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMAPIResultsViewController : UIViewController

- (instancetype)initWithResults:(NSString *)results;

@property (nonatomic, weak) IBOutlet UITextView *resultsTextView;

@end
