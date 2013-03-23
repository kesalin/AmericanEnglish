//
//  KSBaseView.m
//  KSFramework
//
//  Created by kesalin on 7/1/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KSBaseView.h"

@implementation KSTableViewCell

@synthesize gradientColorType = _gradientColorType;

- (void)drawRect:(CGRect)rect
{
    float *components = getGradientColor(_gradientColorType);
    if (components != NULL)
    {
        size_t num_locations = 4;
        CGFloat locations[4] = {0.0, 0.4, 0.6, 1.0};
        
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
        
        CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y);
        CGPoint endPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
        CGContextDrawLinearGradient(currentContext, glossGradient, startPoint, endPoint, 0);

        CGContextSaveGState(currentContext);
        CGContextBeginPath (currentContext);
        CGContextSetRGBFillColor(currentContext, 1.0, 1.0, 1.0, 0.7);
        CGContextFillRect(currentContext, CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - 1.0, rect.size.width, 1.0));
        CGContextStrokePath(currentContext);
        CGContextRestoreGState(currentContext);
        
        CGGradientRelease(glossGradient);
        CGColorSpaceRelease(rgbColorspace);
    }
    
    [super drawRect:rect];
}

- (void)drawSelectionBackgrounGradient
{
    UIView* selBGView = [[UIView alloc]initWithFrame:self.bounds];
    CAGradientLayer *gradientSelected = [CAGradientLayer layer];
    gradientSelected.frame = self.bounds;
    gradientSelected.colors = [NSArray arrayWithObjects:
                               (id)[UIColor colorWithRed:0.25 green:0.25 blue:0.85 alpha:1.0].CGColor, 
                               (id)[UIColor colorWithRed:0.55 green:0.55 blue:1.00 alpha:1.0].CGColor,
                               (id)[UIColor colorWithRed:0.25 green:0.25 blue:0.85 alpha:1.0].CGColor, 
                               nil];
	
    [selBGView.layer insertSublayer:gradientSelected atIndex:0];
    self.selectedBackgroundView=selBGView;
    [selBGView release];
}

@end
