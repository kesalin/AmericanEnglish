//
//  AEViewController.h
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEViewController : UIViewController <UITabBarDelegate, UINavigationControllerDelegate>
{
    UIImageView *       _logoView;
    UITabBar *          _tabBar;
    NSArray *           _tabBarItems;
    NSMutableArray *    _navigationControllers;
}

@property (nonatomic, retain, readonly) UITabBar    *tabBar;
@property (nonatomic, retain, readonly) NSArray     *tabBarItems;
@property (nonatomic, retain, readonly) NSArray     *navigationControllers;


@end

