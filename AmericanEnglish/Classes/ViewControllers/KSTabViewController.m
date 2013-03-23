//
//  KSTabViewController.m
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSTabViewController.h"
#import "KSSubjectConfig.h"
#import "AEViewController.h"
#import "KSViewController.h"
#import "KSDefine.h"
#import "KSLog.h"
#import "KSTableView.h"
#import "KSBaseView.h"
#import "KSSubDelegate.h"
#import "KSAudiosCategoryDelegate.h"
#import "KSGrammarDelegate.h"

@interface KSTabViewController(PrivateMethods)

- (void) updateSubDelegate:(NSInteger)navigationIndex;
- (void) layoutViews:(UIInterfaceOrientation)interfaceOrientation;

@end

// KSTabViewController
//
@implementation KSTabViewController

@synthesize key = _key;
@synthesize currentTabIndex = _currentTabIndex;
@synthesize navigationSelectedIndex = _navigationSelectedIndex;
@synthesize navigationView = _navigationView;
@synthesize navgationItems = _navgationItems;
@synthesize tableView = _tableView;
@synthesize mp3PlayerController = _mp3PlayerController;

#pragma mark -
#pragma mark Lifecycle

- (void)dealloc
{
    [_mp3PlayerController   release];
    [_key                   release];
    [_navigationView        release];
    [_tableView             release];
    [_navgationItems        release];
    
    [super dealloc];
}

- (id)initWithTabIndex:(KSTabIndex)tabIndex
{
    self = [super init];
    if (self)
    {
        _currentTabIndex = tabIndex;
        
        KSSubjectConfig *subjectConfig = [KSSubjectConfig sharedInstance];

        NSArray* items          = [subjectConfig navigationItemsForTabIndex:_currentTabIndex];
        _navgationItems         = [[NSArray alloc] initWithArray:items];
        
        NSArray *tabBarItems    = self.ksTabController.tabBarItems;
        NSDictionary *item      = [tabBarItems objectAtIndex:_currentTabIndex];
        _key                    = [[NSString alloc] initWithString:[item objectForKey:@"key"]];
        NSString *title         = [item objectForKey:@"title"];
        self.title              = KSLocal(title);
        
        KSLog(@" >> create tabView %@", self.title);
    }
	
    return self;
}

- (void)loadView
{
    UIView *ksView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = ksView;
    [ksView release];
    
    CGFloat y = 0;
    // create navigaiont view
    //
    KSSubjectConfig *subjectConfig  = [KSSubjectConfig sharedInstance];
    _navigationSelectedIndex        = [subjectConfig defaultNavigationItemIndexForTabIndex:_currentTabIndex];
    NSDictionary *defaultNavItem    = [_navgationItems objectAtIndex:_navigationSelectedIndex];
    _isWithNavigation               = ![[defaultNavItem objectForKey:@"hidden_navigation"] boolValue];
    if (_isWithNavigation && _navigationView == nil)
    {
        _navigationView             = [[KSNavigationView alloc] initWithItemProperties:_navgationItems];
        _navigationView.delegate    = self;
        
        [self.view addSubview:_navigationView];
        
        y                           += _navigationView.frame.size.height;
    }
    
    // create MP3PlayerController
    //
    _isWithMP3Player                = [[defaultNavItem objectForKey:@"with_player"] boolValue];
    if (_isWithMP3Player)
    {
        CGRect rect                 = CGRectMake(0, y, kKSAppWidth, kKSMP3PlayerHeight);
        _mp3PlayerController        = [[KSMP3PlayerController createMP3PlayerController:rect] retain];

        [self.view addSubview:_mp3PlayerController.view];
    }
    
    // create table view
    //
    if (_tableView == nil)
    {
        CGFloat height          = self.view.frame.size.height - kKSNaviItemHeight - kKSTabItemHeight;
        if (_isWithMP3Player)
        {
            y                  += kKSMP3PlayerHeight;
            height             -= kKSMP3PlayerHeight;
        }

        CGRect tableViewFrame   = CGRectMake(0, y, kKSAppWidth, height);
        _tableView              = [[KSTableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
        _tableView.delegate     = self;
        _tableView.dataSource   = self;
        
        [self.view addSubview:_tableView];
    }
    
    // create subDelegate
    //
    [self updateSubDelegate:_navigationSelectedIndex];
}

- (void)layoutViews:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat y               = 0;
    if (_isWithNavigation && _navigationView)
    {
        _navigationView.frame   = CGRectMake(0, y, kKSAppWidth, kKSNaviItemHeight);
        y                       += kKSNaviItemHeight;
    }
    
    if (_isWithMP3Player && _mp3PlayerController)
    {
        _mp3PlayerController.view.frame = CGRectMake(0, y, kKSAppWidth, kKSMP3PlayerHeight);
        y                   += kKSMP3PlayerHeight;
    }
    
    CGFloat height          = self.view.frame.size.height;
    if (_isWithNavigation && _navigationView)
        height              -= kKSNaviItemWidth;
    if (_isWithMP3Player && _mp3PlayerController)
        height              -= kKSMP3PlayerHeight;
    _tableView.frame        = CGRectMake(0, y, kKSAppWidth, height);
}

- (void)viewWillAppear:(BOOL)animated
{
    KSLog(@" >> %@, viewWillAppear", self.key);
    
    [super viewWillAppear:animated];
    
    [self.ksTabController setTabBarHidden:NO animated:YES];
    [self layoutViews:self.interfaceOrientation];
    
    if ([self mp3PlayerExists] && _subDelegate)
    {
        KSSectionInfo *sectionInfo      = [_subDelegate currentSectionInfo];
        [_mp3PlayerController setupMP3Info:sectionInfo displayUnit:YES];
    }
    
    if (_subDelegate)
        [_subDelegate viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    KSLog(@" >> %@, viewDidAppear", self.key);
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@" >> %@, viewWillDisappear", self.key);
    
    [super viewWillDisappear:animated];
    
    if (_subDelegate)
        [_subDelegate viewWillDisappear];

    if (_mp3PlayerController)
        [_mp3PlayerController stop];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@" >> %@, viewDidDisappear", self.key);
    
    [super viewDidDisappear:animated];
    
    if (_subDelegate)
        [_subDelegate viewDidDisappear];
}

- (void)viewDidUnload
{
    if (_subDelegate)
        [_subDelegate viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)rightItemButtonTouched:(id)sender
{
    if (_subDelegate && [_subDelegate respondsToSelector:@selector(rightItemButtonTouched:)])
        [_subDelegate performSelector:@selector(rightItemButtonTouched:) withObject:sender];
}

#pragma mark -
#pragma mark navigationView delegate

- (void) updateSubDelegate:(NSInteger)selectedIndex
{
    if (selectedIndex < 0 || selectedIndex >= [_navgationItems count])
    {
        KSLog(@"Error! %@ Invalid selected navigation item for updateSubDelegate!", self.key);
        return;
    }
    
    // clear current
    //
    if (_subDelegate)
    {
        KSLog(@" updateSubDelegate, [%@] clear [%@]", self.key, _subDelegate.key);
        
        if (_tableView.delegate == _subDelegate)
            _tableView.delegate = self;
        if (_tableView.dataSource == _subDelegate)
            _tableView.dataSource = self;
        if (_mp3PlayerController && _mp3PlayerController.delegate == _subDelegate) 
            _mp3PlayerController.delegate = nil;
        
        [_subDelegate release];
        _subDelegate = nil;
        
        self.rightItemTitle = nil;
    }

    // create new
    //
    if (_navgationItems > 0)
    {
        NSDictionary * navItem  = [_navgationItems objectAtIndex:selectedIndex];
        if (navItem)
        {
            NSString * delegatekey      = [navItem objectForKey:@"key"];
            NSString * delegateName     = [navItem objectForKey:@"delegate"];

            if (!KSIsNullOrEmpty(delegateName))
            {
                KSLog(@" >> [%@] - [%@], create delegate: [%@]", _key, delegatekey, delegateName);
                
                Class class             = NSClassFromString(delegateName);
                _subDelegate            = [[class alloc] initWithController:self withKey:navItem];
                
                if (_mp3PlayerController)
                {
                    _mp3PlayerController.delegate   = _subDelegate;
                    KSSectionInfo *sectionInfo      = [_subDelegate currentSectionInfo];
                    [_mp3PlayerController setupMP3Info:sectionInfo displayUnit:YES];
                }

                _tableView.delegate     = _subDelegate;
                _tableView.dataSource   = _subDelegate;
                [_tableView reloadData];
            }
        }
    }
}

- (void)navigationView:(KSNavigationView *)navigationView itemSelected:(NSInteger)index
{
    if (_navigationSelectedIndex != index)
    {
        _navigationSelectedIndex = index;
        
        [self updateSubDelegate:_navigationSelectedIndex];
        
        [_tableView reloadData];
    }
}

- (void)parseResultData
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark tableView drag...left and right

- (void)dragLeft
{
    [_navigationView prevItemSelected];
}

- (void)dragRight
{
    [_navigationView nextItemSelected];
}

- (void)tableView:(UITableView *)tableView dragging:(id)direction
{
    int dsc = (int)direction;
    if (dsc == 1)
        [self dragRight];
    
    else if (dsc == -1)
        [self dragLeft];
}

#pragma mark -
#pragma mark tableView delegate, dataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kKSTableViewSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kKSTableViewCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)sectionItemTouchedUpInside:(id)sender
{
    //    KSMultiTextButton *button = sender;
    //    int tag = button.tag;
    //    int i = tag & 0xFF;
    
    [_tableView reloadData];
}

#pragma mark -
#pragma mark 

- (BOOL) mp3PlayerExists
{
    BOOL exists = (_isWithMP3Player && _mp3PlayerController);
    return exists;
}

@end
