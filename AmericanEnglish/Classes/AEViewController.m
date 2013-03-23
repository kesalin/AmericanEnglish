//
//  AEViewController.m
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "AEViewController.h"
#import "KSDefine.h"
#import "KSLog.h"
#import "KSSubjectConfig.h"
#import "KSImageCache.h"
#import "KSTabViewController.h"
#import "KSBarButton.h"


// AEViewController(PrivateMethods)
//
@interface AEViewController(PrivateMethods)

- (void) logoAnimationStoped;
- (void) loadTabBarItems;
- (void) goBack:(id)sender;

@end


// AEViewController
//
static int _currentIndex = -1;

@implementation AEViewController

@synthesize tabBar                  = _tabBar;
@synthesize tabBarItems             = _tabBarItems;
@synthesize navigationControllers   = _navigationControllers;

#pragma mark -
#pragma mark AudioSession listeners

void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
    id clientData = (id)inClientData;
    NSNumber *state = [NSNumber numberWithInt:inInterruptionState];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               clientData, @"clientData",
                               state, @"interruptionState", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kKSAudioSessionInterruptionListener object:userInfo];   
}

#pragma mark -
#pragma mark lift cycle

- (void)dealloc
{
    [_logoView release];
    [_tabBar release];
    [_tabBarItems release];
    [_navigationControllers release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initialize audio session for mp3player and recorder.
    // 
    OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
	if (error)
        KSLog(@"ERROR Failed to Initialize Audio Session! %d\n", (NSInteger)error);
    else
        KSLog(@" >> Initialize Audio Session!");
}

- (void)viewDidUnload
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadTabBarItems
{
    KSSubjectConfig *subjectConfig = [KSSubjectConfig sharedInstance];
    _tabBarItems = [[subjectConfig tabBarHeaders] retain];
    _navigationControllers = [[NSMutableArray alloc] initWithCapacity:[_tabBarItems count]];
    
    NSMutableArray *barItems   = [[[NSMutableArray alloc] init] autorelease];
    NSInteger index            = 0;
    
    for (NSDictionary *dict in _tabBarItems)
    {
        // create tab controllers
        //
        //NSString *key           = [dict objectForKey:@"key"];
        NSString *itemTitle     = [dict objectForKey:@"title"];
        NSString *className     = [dict objectForKey:@"handler"];
        UIImage *normalImage    = [dict objectForKey:@"icon_normal"];

        Class class				= NSClassFromString(className);
        UIViewController *controller			= [[class alloc] initWithTabIndex:index];
        UINavigationController *navController	= [[UINavigationController alloc] initWithRootViewController:controller];
        navController.delegate					= self;
        [_navigationControllers addObject:navController];
        [controller release];
        [navController release];        
        
        KSLog(@" >> load tabBarItems %d - %@, handler %@", index, itemTitle, className);
        
        UITabBarItem *barItem		= [[UITabBarItem alloc] initWithTitle:itemTitle image:normalImage tag:index];
        barItem.tag                 = index;
        [barItems addObject:barItem];
        [barItem release];
        
        index++;
    }
    
    if ([_navigationControllers count] > 0)
    {
        _currentIndex = 0;
        
        UINavigationController *navController = [_navigationControllers objectAtIndex:_currentIndex];
        [navController viewWillAppear:YES];
        [self.view addSubview:navController.view];
        [navController viewDidAppear:YES];
    }
    
    // Place the tab bar at the bottom of our view
    //	
	CGRect tabBarFrame			= CGRectMake(0, kKSAppHeight - kKSTabItemHeight, kKSAppWidth, kKSTabItemHeight);
    _tabBar						= [[UITabBar alloc] initWithFrame:tabBarFrame];	
	_tabBar.delegate			= self;
    [_tabBar setItems:barItems animated:NO];
    [_tabBar setSelectedItem:[barItems objectAtIndex:_currentIndex]];

    [self.view addSubview:_tabBar];
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kKSAppWidth, kKSAppHeight)];
    self.view = view;
    [view release];
    
    [self loadTabBarItems];
    
    // logo view
    //
    _logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kKSAppWidth, kKSAppHeight)];
    _logoView.backgroundColor = [UIColor blackColor];
    _logoView.alpha = 1.0;
    
    [self.view addSubview:_logoView];
    
    // logo animation
    //
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(logoAnimationStoped)];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    _logoView.alpha = 0.0;
    
    [UIView commitAnimations];
}

- (void) logoAnimationStoped
{
    [_logoView removeFromSuperview];
    [_logoView release];
    _logoView = nil;
}

#pragma mark -
#pragma mark UIInterfaceOrientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    int currentIndex = MAX(_currentIndex, 0);
    UIViewController *controller = [_navigationControllers objectAtIndex:currentIndex];
    return [controller shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    int currentIndex = MAX(_currentIndex, 0);
    UIViewController *controller = [_navigationControllers objectAtIndex:currentIndex];
    [controller willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    int currentIndex = MAX(_currentIndex, 0);
    UIViewController *controller = [_navigationControllers objectAtIndex:currentIndex];
    [controller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    int currentIndex = MAX(_currentIndex, 0);
    UIViewController *controller = [_navigationControllers objectAtIndex:currentIndex];
    [controller willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    NSInteger count = [navigationController.viewControllers count];
//    if (count > 1)
//    {
//        KSBarButton *button    = [KSBarButton button];
//        button.title            = KSLocal(@"back");
//        button.tag              = (int)navigationController;
//        [button addTarget:self action:@selector(goBack:)];
//        
//        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//        viewController.navigationItem.hidesBackButton = YES;
//        viewController.navigationItem.leftBarButtonItem = buttonItem;
//        [buttonItem release];
//    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
}

- (void)goBack:(id)sender
{
    UIButton *button = sender;
    UINavigationController *navController = (id)(button.tag);
    
    [navController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark TabbarDelegate

- (UIView *) currentViewForTabBar:(UITabBar *)tabBar atIndex:(NSUInteger)itemIndex
{
    UINavigationController *controller = [_navigationControllers objectAtIndex:itemIndex];
    [controller viewWillDisappear:YES];
    
    _currentIndex = itemIndex;
    return controller.view;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger itemIndex = item.tag;
    NSLog(@" >> tabbar index %d", itemIndex);
    
    if (_currentIndex == itemIndex)
        return;
    
    if (_currentIndex >= 0 && _currentIndex < [_navigationControllers count])
    {
        UINavigationController *lastController = [_navigationControllers objectAtIndex:_currentIndex];
        UIView *lastView = lastController.view;
        [lastController viewWillDisappear:YES];
        [lastController popToRootViewControllerAnimated:NO];
        [lastView removeFromSuperview];
        [lastController viewDidDisappear:YES];
    }
    
    _currentIndex = itemIndex;

    UINavigationController *controller = [_navigationControllers objectAtIndex:itemIndex];
    [controller viewWillAppear:YES];
    [self.view addSubview:controller.view];
    [controller viewDidAppear:YES];
    
    [self.view bringSubviewToFront:_tabBar];
}


@end
