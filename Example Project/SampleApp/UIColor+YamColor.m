//
//  UIColor+YamColor.m
//  ios-oauth-demo
//
//  Created by Peter Willsey on 5/18/15.
//  Copyright (c) 2015 Yammer, Inc. All rights reserved.
//

#import "UIColor+YamColor.h"

@implementation UIColor (YamColor)

+ (UIColor *)yamBlue
{
    return [UIColor colorWithRed:0.01f green:0.45f blue:0.78f alpha:1.0f];
}

+ (UIColor *)yamInformationalTextColor
{
    return [UIColor colorWithRed:0.28f green:0.33f blue:0.38f alpha:1.0f];
}

+ (UIColor *)yamAPIResultsTextColor
{
    return [UIColor colorWithRed:0.20f green:0.23f blue:0.25f alpha:1.0f];
}

@end
