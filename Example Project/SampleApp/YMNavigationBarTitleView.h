//
//  YMNavigationBarTitleView.h
//  ios-oauth-demo
//
//  Created by Peter Willsey on 5/19/15.
//  Copyright (c) 2015 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMNavigationBarTitleView : UIView

@property (nonatomic, copy) NSString *titleText;

- (instancetype)initWithFrame:(CGRect)frame titleText:(NSString *)titleText;

+ (instancetype)navigationBarTitleViewWithTitleText:(NSString *)titleText;

@end
