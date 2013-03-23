//
//  KSBarButton.m
//  KSFramework
//
//  Created by Kesalin on 6/17/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSBarButton.h"
#import "KSImageCache.h"
#import "KSDefine.h"

// KSBarButton(PrivateMethods)
//
@interface KSBarButton(PrivateMethods)

- (void)initInternal;

@end


// KSBarButton
//
@implementation KSBarButton

+ (id)button
{
    KSBarButton *button = [super button];
    if (button)
    {
        [button initInternal];
        button.frame = CGRectMake(0, 0, 50, 30);
    }
    
    return button;
}

- (void)initInternal
{
    UIImage *image      = [KSImageCache imageNamed:@"white_button"];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    self.textLabel.font = kKSFontArial15;
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self)
    {
        [self initInternal];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initInternal];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setTitle:(NSString *)title
{
    self.textLabel.text = title;
    [self.textLabel sizeToFit];
}

- (NSString *)title
{
    return self.textLabel.text;
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
