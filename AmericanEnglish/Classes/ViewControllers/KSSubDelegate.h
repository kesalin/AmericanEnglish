//
//  KSSubDelegate.h
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSTabViewController.h"
#import "KSMP3PlayerController.h"

@interface KSSubDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, KSMP3PlayerControllerDelegate>
{
    NSString *              _key;
    NSDictionary *          _config;
    KSTabViewController *   _parentViewController;  // weak reference
}

@property (readonly, retain) NSString *             key;
@property (readonly, retain) NSDictionary *         config;
@property (readonly, assign) KSTabViewController *  parentViewController;

- (id) initWithController:(KSTabViewController *) parent withKey:(NSDictionary *)navItemConfig;
- (void) setup;
- (void) viewDidUnload;
- (void) viewWillAppear;
- (void) viewDidAppear;
- (void) viewWillDisappear;
- (void) viewDidDisappear;

- (KSSectionInfo *) currentSectionInfo;

@end
