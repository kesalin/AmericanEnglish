//
//  KSNavigationView.h
//  KSFramework
//
//  Created by Kesalin on 6/17/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// KSNavigationViewDelegate
//
@class KSNavigationView;

@protocol KSNavigationViewDelegate <NSObject>

@optional
- (void)navigationView:(KSNavigationView *)navigationView itemSelected:(NSInteger)index;

@end

// KSNavigationView
//
@class KSSlideView;
@class KSNavigationItem;

@interface KSNavigationView : UIView
{
    
@private
    KSSlideView *   _scroller;
    
	KSNavigationItem *	_lastSelection;
    KSNavigationItem *  _fakeItem;
    
	id              _delegate;
    NSMutableArray *_navgationItems;
    
    NSArray *       _properties;
    NSInteger       _highlightedIndex;
}

@property (nonatomic, retain, readonly) KSSlideView *scroller;
@property (nonatomic, assign) id<KSNavigationViewDelegate> delegate;
@property (nonatomic, retain) NSArray *properties;

@property (nonatomic, readwrite) NSInteger highlightedIndex;

- (id) initWithItemProperties:(NSArray *)properties;
- (void) reload;

- (void) prevItemSelected;
- (void) nextItemSelected;

@end
