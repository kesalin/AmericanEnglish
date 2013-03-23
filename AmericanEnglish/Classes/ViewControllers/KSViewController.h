//
//  KSViewController.h
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// UIViewController (KSNavigationBar)
//
@interface UIViewController (RightBarButtonItem)

@property (nonatomic, copy) NSString *rightItemTitle;

//override by subclass
- (void)rightItemButtonTouched:(id)sender;

@end

// UIViewController (KSTabBar)
//
@class AEViewController;

@interface UIViewController (KSTabBar)

@property (nonatomic, retain, readonly) AEViewController *ksTabController;

- (void)setTabBarHidden:(BOOL)hidden;
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

// KSViewController
//
@interface KSViewController : UIViewController
{
    
}

- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated;

@end
