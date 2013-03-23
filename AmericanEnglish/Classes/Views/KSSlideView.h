//
//  KSSlideView.h
//  KSFramework
//
//  Created by Kesalin on 6/17/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// KSScrollView
//
@interface KSScrollView : UIScrollView
{
	NSArray	*		_items;
}

@property (nonatomic, retain) NSArray *items;

@end

// KSSlideView
//
@interface KSSlideView : UIView <UIScrollViewDelegate>
{
 	CGFloat			_originalX;
	UIImageView	*	_leftIndicatorView;
	UIImageView	*	_rightIndicatorView;
    UIView	*       _indicatorsView;
	KSScrollView*	_scrolledContentView;
    UIImageView *   _backgroundView;
}

@property(nonatomic, retain, readonly)UIImageView *backgroundView;
@property(nonatomic, retain, readonly)UIImageView *leftIndicatorView;
@property(nonatomic, retain, readonly)UIImageView *rightIndicatorView;

- (void)setItems:(NSArray *)items;

- (CGFloat)horizontalLocationAtIndex:(NSUInteger)itemIndex;

@end
