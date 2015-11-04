//
// YMAPIResultsViewController.m
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
