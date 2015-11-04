//
// YMNavigationBarTitleView.m
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

#import "YMNavigationBarTitleView.h"

static const CGFloat YMNavBarTitleViewImageRightPadding = 5.0f;

@interface YMNavigationBarTitleView ()

@property (nonatomic, strong) UIImage *logoImage;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation YMNavigationBarTitleView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame titleText:nil];
}

- (instancetype)initWithFrame:(CGRect)frame titleText:(NSString *)titleText
{
    self = [super initWithFrame:frame];
    if (self) {
        _logoImage = [UIImage imageNamed:@"YammerLogo"];
        _logoImageView = [[UIImageView alloc] initWithImage:_logoImage];
        [self addSubview:_logoImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = titleText;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    self.logoImageView.frame = (CGRect) {
        .origin = CGPointZero,
        .size = {
            self.logoImage.size.width,
            self.logoImage.size.height
        }
    };
    
    [self.titleLabel sizeToFit];
    
    self.titleLabel.frame = (CGRect) {
        .origin = {
            .x = self.logoImage.size.width + YMNavBarTitleViewImageRightPadding,
            .y = ceilf((self.logoImage.size.height - CGRectGetHeight(self.titleLabel.frame)) / 2.0f)
        },
        .size = {
            CGRectGetWidth(self.titleLabel.frame),
            CGRectGetHeight(self.titleLabel.frame)
        }
    };
}

- (void)sizeToFit
{
    [self.titleLabel sizeToFit];
    
    self.frame = (CGRect) {
        .origin = CGPointZero,
        .size = {
            .width = self.logoImage.size.width + YMNavBarTitleViewImageRightPadding + CGRectGetWidth(self.titleLabel.frame),
            .height = self.logoImage.size.height
        }
    };
}

- (NSString *)titleText
{
    return self.titleLabel.text;
}

- (void)setTitleText:(NSString *)titleText
{
    self.titleLabel.text = titleText;
    [self setNeedsLayout];
}

+ (instancetype)navigationBarTitleViewWithTitleText:(NSString *)titleText;
{
    YMNavigationBarTitleView *titleView = [[YMNavigationBarTitleView alloc] init];
    titleView.titleText = titleText;
    [titleView sizeToFit];
    
    return titleView;
}

@end
