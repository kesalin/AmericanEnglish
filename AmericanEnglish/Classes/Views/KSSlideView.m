//
//  KSSlideView.m
//  KSFramework
//
//  Created by Kesalin on 6/17/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSSlideView.h"
#import "KSLog.h"
#import "KSDefine.h"
#import "KSImageCache.h"

#import <QuartzCore/QuartzCore.h>

// KSScrollView
// 
@implementation KSScrollView

@synthesize items = _items;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self)
    {
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.scrollsToTop = NO;
		
		_items = [[NSArray alloc] init];
    }
    
    return self;
}

- (void)dealloc 
{
	[_items release];
    
	[super dealloc];
}

- (CGFloat)horizontalLocationAtIndex:(NSUInteger)itemIndex
{
    NSInteger count = [_items count];
    if (count == 0)
    {
        KSLog(@"No items in slide view.");
        return 0.0;
    }
    
    if (itemIndex >= count)
    {
        KSLog(@"Invalid slide item index.");
        return -1.0;
    }
    
    CGFloat originX = kKSSliderBarItemInterval;
    for (int i = 0; i < itemIndex; i++)
    {
        UIView *view = [_items objectAtIndex:i];
        originX += view.frame.size.width + kKSSliderBarItemInterval;
    }
    
    return originX;
}

- (void)setItems:(NSArray *)navigationItems 
{
    [_items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_items release];
    
    _items = [navigationItems retain];
	CGFloat totalWidth = kKSSliderBarItemInterval;
	for (UIView *itemView in navigationItems)
    {
		CGRect rect     = itemView.frame;
		rect.origin.x   = totalWidth;
        rect.origin.y   = (NSInteger)((self.frame.size.height - rect.size.height) / 2);
		itemView.frame  = rect;
        
		[self addSubview:itemView];
		totalWidth += kKSSliderBarItemInterval + itemView.frame.size.width;
	}
    
    CGSize contentSize = CGSizeMake(totalWidth, self.frame.size.height);
	self.contentSize = contentSize;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (!self.dragging)
		[self.nextResponder touchesEnded:touches withEvent:event];
    else
		[super touchesEnded:touches withEvent:event];
}

@end

// KSSlideView
// 
@implementation KSSlideView

@synthesize backgroundView = _backgroundView;
@synthesize leftIndicatorView = _leftIndicatorView;
@synthesize rightIndicatorView = _rightIndicatorView;

#pragma mark -
#pragma mark life cycle

- (id)initWithCoder:(NSCoder *)aDecoder 
{
    self = [super initWithCoder:aDecoder];
	if (self)
    {
        self = [self initWithFrame:self.frame];
    }

	return self;
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
	if (self) 
    {
		self.multipleTouchEnabled		= YES;
		
        //Note: Here add an extra background because when controller push or pop the navigation view animated,
        //it will splash a white empty view, and this will helpful.------ looks like a stupid hack... :(
        _backgroundView                 = [[UIImageView alloc] initWithFrame:CGRectMake(-self.bounds.size.width, 0, self.bounds.size.width * 3, self.bounds.size.height)]; 
		_backgroundView.image			= [KSImageCache imageNamed:@"navigation_background"];
		_backgroundView.backgroundColor	= [UIColor clearColor];
        [self addSubview:_backgroundView];
        
        _indicatorsView					= [[UIView alloc] initWithFrame:self.bounds];
		_indicatorsView.backgroundColor = [UIColor clearColor];
		
		_leftIndicatorView				= [[UIImageView alloc] initWithImage:[KSImageCache imageNamed:@"arrow_left"]];
		_leftIndicatorView.contentMode	= UIViewContentModeCenter;
        _leftIndicatorView.alpha		= 0;
		[_indicatorsView addSubview:_leftIndicatorView];
		
		_rightIndicatorView				= [[UIImageView alloc] initWithImage:[KSImageCache imageNamed:@"arrow_right"]];
		_rightIndicatorView.contentMode = UIViewContentModeCenter;
        _leftIndicatorView.alpha		= 0;
		[_indicatorsView addSubview:_rightIndicatorView];
		
		[self addSubview:_indicatorsView];
		
		CGFloat sideWidth				= _leftIndicatorView.image.size.width;
        CGRect frameRect				= CGRectMake(sideWidth, 0, frame.size.width - 2 * sideWidth, frame.size.height);
		_scrolledContentView			= [[KSScrollView alloc] initWithFrame:frameRect];
		_scrolledContentView.delegate	= self;
		
        [self addSubview:_scrolledContentView];
	}
	return self;
}

- (void)dealloc 
{
    [_backgroundView release];
	[_leftIndicatorView release];
	[_rightIndicatorView release];
	[_scrolledContentView release];
    [_indicatorsView release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark UI Methods

- (void) setFrame: (CGRect) frameRect
{
    [self setNeedsLayout];
    [super setFrame: frameRect];
}

- (void) setBounds: (CGRect) boundsRect
{
    [self setNeedsLayout];
    [super setBounds: boundsRect];
}

- (void) layoutSubviews
{
    if (![self.layer needsLayout])
        return;
    
    CGRect rect						= self.frame;
    
    CGRect leftFrame				= _leftIndicatorView.frame;
    leftFrame.origin.y				= rect.size.height / 2 - _leftIndicatorView.image.size.height / 2 - 1;
    _leftIndicatorView.frame		= leftFrame;
    
    CGRect rightFrame				= _rightIndicatorView.frame;
    rightFrame.origin.y				= rect.size.height / 2 - _leftIndicatorView.image.size.height / 2 - 1;
    rightFrame.origin.x				= rect.size.width - _rightIndicatorView.frame.size.width;
    _rightIndicatorView.frame		= rightFrame;
    
    CGFloat leftWidth				= leftFrame.size.width;
    CGFloat rightWidth				= rightFrame.size.width;
    
    CGRect middleFrame				= CGRectMake(leftWidth, 0, rect.size.width - (leftWidth + rightWidth), rect.size.height);
    _scrolledContentView.frame		= middleFrame;
    
    CGSize contentSize				= _scrolledContentView.contentSize;
    if (contentSize.width > middleFrame.size.width)
    {
        _rightIndicatorView.alpha	= 1;
    }
    else
    {
        _rightIndicatorView.alpha	= 0;
        middleFrame.origin.x		= (rect.size.width - contentSize.width) / 2;
        middleFrame.size.width		= contentSize.width;
        _scrolledContentView.frame	= middleFrame;
    }    
}

- (void)drawRect:(CGRect)rect 
{
    // Drawing code
    [super drawRect:rect];
}

- (void)setItems:(NSArray *)menuItems 
{
	[_scrolledContentView setItems:menuItems];

	if (_scrolledContentView.contentSize.width > [[UIScreen mainScreen] bounds].size.width)
		_rightIndicatorView.alpha = 1;
    else
        _rightIndicatorView.alpha = 0;
}

- (CGFloat)horizontalLocationAtIndex:(NSUInteger)itemIndex
{
    return [_scrolledContentView horizontalLocationAtIndex:itemIndex];
}

- (void)sideView:(UIView *)sideView setVisible:(BOOL)show animated: (BOOL) isAnimated
{
    if (isAnimated)
    {
        [UIView beginAnimations:nil context:sideView];
        
        if (!show)
            [UIView setAnimationDuration:1];
        else
            [UIView setAnimationDuration:0.5];
    }
    
	[sideView setAlpha:show];
    
    if (isAnimated)
    {
        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    [self sideView:_leftIndicatorView  setVisible: NO animated: YES];
//    [self sideView:_rightIndicatorView setVisible: NO animated: YES];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if (!decelerate) {
//        [self sideView:_leftIndicatorView  setVisible: NO animated: YES];
//        [self sideView:_rightIndicatorView setVisible: NO animated: YES];
//    }
//}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self sideView:_leftIndicatorView  setVisible: NO animated: YES];
//    [self sideView:_rightIndicatorView setVisible: NO animated: YES];
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
	CGFloat contentX = scrollView.contentOffset.x;
    CGFloat contentWith = scrollView.contentSize.width;
    BOOL leftVisible = (contentX > 0);
    BOOL rightVisible = (contentWith - scrollView.frame.size.width > contentX);
    
	[self sideView:_leftIndicatorView  setVisible:leftVisible animated: YES];
	[self sideView:_rightIndicatorView setVisible:rightVisible animated: YES];
}

@end
