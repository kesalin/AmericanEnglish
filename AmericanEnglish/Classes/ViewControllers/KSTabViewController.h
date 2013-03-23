//
//  KSTabViewController.h
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSViewController.h"
#import "KSTableView.h"
#import "KSNavigationView.h"
#import "KSMP3PlayerController.h"

enum _TabIndex
{
    KSTabIndexAudios,
    
    KSTabIndexMax,
};
typedef NSInteger KSTabIndex;

// KSTabViewController
//
@class KSTableView;
@class KSTableViewCell;
@class KSSubDelegate;

@interface KSTabViewController : KSViewController <UITableViewDelegate, UITableViewDataSource, KSNavigationViewDelegate>
{
    NSString *                 _key;
    KSTabIndex                 _currentTabIndex;
    NSInteger                  _navigationSelectedIndex;
    
    KSNavigationView *         _navigationView;
    NSArray *                  _navgationItems;
    
    KSTableView *              _tableView;
    KSSubDelegate *            _subDelegate;

    KSMP3PlayerController *    _mp3PlayerController;
    BOOL                       _isWithMP3Player;
    BOOL                       _isWithNavigation;
}

@property (nonatomic, retain, readonly) NSString    *key;
@property (nonatomic, readonly) KSTabIndex          currentTabIndex;
@property (nonatomic, retain) KSNavigationView      *navigationView;
@property (nonatomic, retain) KSTableView           *tableView;
@property (nonatomic, retain, readonly) NSArray     *navgationItems;
@property (nonatomic, assign, readonly) NSInteger   navigationSelectedIndex;
@property (nonatomic, retain, readonly) KSMP3PlayerController *mp3PlayerController;

- (id) initWithTabIndex:(KSTabIndex)tabIndex;

- (void) layoutViews:(UIInterfaceOrientation)interfaceOrientation;

- (BOOL) mp3PlayerExists;

@end

