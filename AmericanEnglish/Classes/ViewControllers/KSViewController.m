//
//  KSViewController.m
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSViewController.h"
#import "AEAppDelegate.h"
#import "AEViewController.h"
#import "KSDefine.h"

// UIViewController (RightBarButtonItem)
//
@implementation UIViewController (KSNavigationBar)

- (void)setRightItemTitle:(NSString *)title
{
    if (title == nil)
	{
        self.navigationItem.rightBarButtonItem = nil;
    }
	else
	{
		//        HBBarButton *button    = [HBBarButton button];
		//        button.title            = title;
		//        [button addTarget:self action:@selector(rightItemButtonTouched:)];
		//        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(rightItemButtonTouched:)];
        self.navigationItem.rightBarButtonItem = barItem;
        [barItem release];
    }
}

- (NSString *)rightItemTitle
{
    //HBBarButton *button = (HBBarButton *)self.navigationItem.rightBarButtonItem.customView;
    //return button.title;
	return self.navigationItem.rightBarButtonItem.title;
}

- (void)rightItemButtonTouched:(id)sender
{
}

@end

// KSViewController(PrivateMethods)
//
@interface KSViewController(PrivateMethods)

- (void)registerNotification;
- (void)unregisterNotification;

@end

// KSViewController
//
@implementation KSViewController


- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization.
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization.
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationController.navigationBar.tintColor = kKSNavigationTintColorBlack;
    
	[self registerNotification];	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
	[self unregisterNotification];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated
{
    [self.navigationController pushViewController:controller animated:animated];
}

#pragma mark -
#pragma mark notifications

- (void)registerNotification
{
    //    HBDataManager *dm = [HBDataManager defaultManager];
    //    for (NSString *key in self.concerningKeys)
    //    {
    //        [dm addObserver:self withKey:key];
    //    }
}

- (void)unregisterNotification 
{
    //    HBDataManager *dm = [HBDataManager defaultManager];
    //    for (NSString *key in self.concerningKeys) 
    //    {
    //        [dm removeObserver:self withKey:key];
    //    }
}

@end

//
// KSViewController (KSTabBar)
//
@implementation UIViewController (KSTabBar)

- (AEViewController *)ksTabController
{
    AEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    AEViewController *tabController = delegate.viewController;
    
    return tabController;
}

- (void)hideTabBar:(BOOL)hidden
{
    AEViewController *tabController = self.ksTabController;
    tabController.tabBar.hidden = hidden;
}

- (void)setTabBarHidden:(BOOL)hidden
{
    [self setTabBarHidden:hidden animated:NO];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    AEViewController *tabController = self.ksTabController;
    
    if (hidden == [tabController.tabBar isHidden])
        return;

    tabController.tabBar.hidden = NO;
    CGRect frame = tabController.tabBar.frame;
    
    if (animated)
    {
        [UIView beginAnimations:@"KSTabBarAnimation" context:(void *)(int)hidden];
        [UIView setAnimationDuration:0.5];
        frame.origin.y = hidden ? frame.origin.y + frame.size.height : frame.origin.y - frame.size.height;
        tabController.tabBar.frame = frame;
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView commitAnimations];
    }
    else
    {
        frame.origin.y = hidden ? frame.origin.y + frame.size.height : frame.origin.y - frame.size.height;
        tabController.tabBar.frame = frame;
        [self hideTabBar:hidden];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:@"KSTabBarAnimation"]) {
        
        BOOL hidden = (BOOL)(int)context;
        [self hideTabBar:hidden];
    }
}

@end
