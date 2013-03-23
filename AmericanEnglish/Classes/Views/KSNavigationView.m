//
//  KSNavigationView.m
//  KSFramework
//
//  Created by Kesalin on 6/17/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSNavigationView.h"
#import "KSSubjectConfig.h"
#import "KSSlideView.h"
#import "KSButton.h"
#import "KSImageCache.h"
#import "KSDefine.h"
#import "KSLog.h"

#import <QuartzCore/QuartzCore.h>

// KSNavigationItem
//
@interface KSNavigationItem : KSButton

+ (id)item;

- (void)markSelected;
- (void)markNormal;

@end

// KSNavigationItem
//
@implementation KSNavigationItem

+ (id)item
{
    KSNavigationItem *item              = [super buttonWithType:UIButtonTypeCustom];
    item.layer.cornerRadius             = 10.0;
    item.layer.masksToBounds            = YES;
    item.adjustsImageWhenHighlighted    = NO;
    item.iconView.image                 = [KSImageCache imageNamed:@"red_gradient_24"];
    
    return item;
}

- (void)markSelected
{
    [self setImage:[KSImageCache imageNamed:@"red_gradient_24"] forState:UIControlStateNormal];
    self.textLabel.textColor = [UIColor whiteColor];
}

- (void)markNormal
{
    [self setImage:nil forState:UIControlStateNormal];
    self.textLabel.textColor = [UIColor darkGrayColor];
}

@end


// KSNavigationView(PrivateMethods)
//
@interface KSNavigationView(PrivateMethods)

- (void)navigationItemTouched:(id)sender;
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

// KSNavigationView
//
@implementation KSNavigationView

@synthesize scroller = _scroller;
@synthesize delegate = _delegate;
@synthesize properties = _properties;
@dynamic highlightedIndex;

#pragma mark -
#pragma mark life cycle

- (void)dealloc
{
	[_navgationItems release];
    [_properties release];
    [_fakeItem release];
    [_scroller release];
	 
    [super dealloc];
}

- (void)reload
{
    int index = 0;
    _lastSelection = nil;
    
    _navgationItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary *item in self.properties)
    {
        BOOL isHidden = [[item objectForKey:@"hidden"] boolValue];
        if (isHidden)
            continue;
        
        KSNavigationItem *button = [KSNavigationItem item];
        NSString *title			= [item objectForKey:@"title"];
        button.textLabel.text   = KSLocal(title);
        
        NSString *fontName		= [item objectForKey:@"font"];
        NSInteger fontSize		= 14;
        NSNumber *fontSizeObj	= [item objectForKey:@"fontSize"];
        if (fontSizeObj)
            fontSize			= [fontSizeObj intValue];
        if (!fontName)
            fontName			= kKSDefaultFontName;//kKSZhFontName;

        button.textLabel.font = [UIFont fontWithName:fontName size:fontSize];
        
        UIColor *color      = [UIColor lightGrayColor];
        NSString *txtColor  = [item objectForKey:@"color"];
        if (txtColor)
        {
            NSArray *obj    = [txtColor componentsSeparatedByString:@","];
            CGFloat red, green, blue, alpha;
            red = green = blue = 0.0, alpha = 1.0;
            int count       = [obj count];
            
            if (count >= 4) alpha   = [[obj objectAtIndex:3] floatValue];
            if (count >= 3) blue    = [[obj objectAtIndex:2] floatValue];
            if (count >= 2) green   = [[obj objectAtIndex:1] floatValue];
            if (count >= 1) red     = [[obj objectAtIndex:0] floatValue];
            color                   = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        }
        button.textLabel.textColor  = color;
        
        NSString *btnSize           = [item objectForKey:@"size"];
        if (btnSize)
        {
            CGSize size             = CGSizeFromString(btnSize);
            button.frame            = CGRectMake(0, 0, size.width, kKSNaviItemHeight);
        } 
        else
        {
            [button.textLabel sizeToFit];
            button.frame    = CGRectMake(0, 0, ceil(button.textLabel.frame.size.width) + 6, kKSNaviItemHeight);
        }
        
        button.tag          = index++;
        [button addTarget:self action:@selector(navigationItemTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        NSNumber *selected  = [item objectForKey:@"isDefault"];
        if ([selected boolValue])
        {
            _lastSelection  = button;
            [button markSelected];
        }
        else
        {
            [button markNormal];
        }
        
        [_navgationItems addObject:button];
    }
    
    if (_lastSelection == nil && [_navgationItems count] > 0)
    {
        _lastSelection = [_navgationItems objectAtIndex:0];
        [_lastSelection markSelected];
    }
    
    [_scroller setItems:_navgationItems];
}

- (id)initWithItemProperties:(NSArray *)properties
{
    CGRect frame = CGRectMake(0, 0, kKSAppWidth, kKSNaviItemHeight);
    self = [super initWithFrame:frame];
	if (self)
    {
        _properties = [[NSArray alloc] initWithArray:properties];

        _scroller = [[KSSlideView alloc] initWithFrame:self.frame];
        
        [self reload];
        
        UIButton *fakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fakeButton.layer.cornerRadius = 10.0;
        fakeButton.layer.masksToBounds = YES;
        fakeButton.alpha = 0;
        [fakeButton setImage:[KSImageCache imageNamed:@"red_gradient_24"] forState:UIControlStateNormal];
        
        UIView *lastObject = [[_scroller subviews] lastObject];
        [_scroller insertSubview:fakeButton belowSubview:lastObject];
        _fakeItem = [fakeButton retain];
        
        if (_lastSelection)
            _fakeItem.frame = _lastSelection.frame;
        
        [self addSubview:_scroller];
	}
    return self;
}

#pragma mark -
#pragma mark action methods

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [_fakeItem setAlpha:0];

    KSNavigationItem *button = (KSNavigationItem *)context;
    [button markSelected];
    
    int currentIndex = [_navgationItems indexOfObject:button];
    int lastIndex    = [_navgationItems indexOfObject:_lastSelection];
    
    if (currentIndex != 0 && currentIndex != [_navgationItems count] - 1)
    {
        UIView *item;
        CGRect frame;
        
        if (currentIndex < lastIndex)
        {
            item = [_navgationItems objectAtIndex:currentIndex - 1];
            
            frame = item.frame;
            frame.origin.x -= 6;
        }
        else
        {
            item = [_navgationItems objectAtIndex:currentIndex + 1];
            
            frame = item.frame;
            frame.size.width += 6;
        }
        
        UIScrollView *scrollView = (UIScrollView *)button.superview;
        [scrollView scrollRectToVisible:frame animated:YES];
    }
    
    if ([_delegate respondsToSelector:@selector(navigationView:itemSelected:)])
        [_delegate navigationView:self itemSelected:button.tag];
    
    _lastSelection = button;
}


- (void)navigationItemTouched:(id)sender
{
	KSNavigationItem *button = (KSNavigationItem *)sender;

	if (button != _lastSelection)
    {
        [_lastSelection markNormal];

#if 1
        [self animationDidStop:nil finished:nil context:button];
#else
        [_fakeItem.layer removeAllAnimations];
        [_fakeItem setFrame:_lastSelection.frame];
        [_fakeItem setAlpha:1];

        [UIView beginAnimations:@"navigationItemAnimation" context:button];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationOptionCurveEaseOut];
 
        [_fakeItem setFrame:button.frame];
        
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView commitAnimations];
#endif
	}
}

#pragma mark -
#pragma mark UI methods

- (void) layoutSubviews
{
	[super layoutSubviews];
    
    CGRect rect             = self.frame;
    CGRect middleRect       = _scroller.frame;
    middleRect.size.width   = rect.size.width;
    _scroller.frame         = middleRect;
}

- (NSInteger)highlightedIndex
{
    return _highlightedIndex;
}

- (void)setHighlightedIndex:(NSInteger)index
{
    if (index >= 0 && index < [_navgationItems count])
    {
        KSNavigationItem *item = [_navgationItems objectAtIndex:index];
        [self navigationItemTouched:item];
        
        _highlightedIndex = index;
    }
}

- (void)prevItemSelected
{
    NSUInteger index = [_navgationItems indexOfObject:_lastSelection];
    if (index == 0 )
        return;
    
    KSNavigationItem * item = [_navgationItems objectAtIndex:index - 1];
    [self navigationItemTouched:item];
}

- (void)nextItemSelected
{
    NSUInteger index = [_navgationItems indexOfObject:_lastSelection];
    if (index == [_navgationItems count] - 1 )
        return;
    
    KSNavigationItem * item = [_navgationItems objectAtIndex:index + 1];
    [self navigationItemTouched:item];
}
@end
