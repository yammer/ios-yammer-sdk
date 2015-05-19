//
//  YMAPIResultsViewController.m
//  ios-oauth-demo
//
//  Created by Peter Willsey on 5/18/15.
//  Copyright (c) 2015 Yammer, Inc. All rights reserved.
//

#import "YMAPIResultsViewController.h"
#import "YMNavigationBarTitleView.h"
#import "UIColor+YamColor.h"

@interface YMAPIResultsViewController ()

@property (nonatomic, copy) NSString *results;

@end

@implementation YMAPIResultsViewController

- (instancetype)init
{
    return [self initWithResults:nil];
}

- (instancetype)initWithResults:(NSString *)results
{
    if (self = [super initWithNibName:@"APIResultsView" bundle:nil]) {
        _results = results;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self styleViews];

    self.navigationItem.titleView = [YMNavigationBarTitleView navigationBarTitleViewWithTitleText:@"API Results"];

    self.resultsTextView.text = self.results;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.resultsTextView setContentOffset:CGPointZero animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)styleViews
{
    self.resultsTextView.textColor = [UIColor yamAPIResultsTextColor];
}

@end
