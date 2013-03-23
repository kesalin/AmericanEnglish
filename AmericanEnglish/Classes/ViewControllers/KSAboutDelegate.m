//
//  KSAboutDelegate.m
//  AmericanEnglish
//
//  Created by kesalin on 8/6/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSAboutDelegate.h"
#import "KSAboutView.h"
#import "KSDefine.h"

@implementation KSAboutDelegate

- (void) setup
{
    _parentViewController.tableView.hidden = YES;
    
    KSAboutView * aboutView = [KSAboutView loadFromNib];
    CGRect frame            = _parentViewController.view.frame;
    frame.origin.x          = 0;
    frame.origin.y          = 0;
    frame.size.height       -= kKSTabItemHeight;
    aboutView.frame         = frame;
    
    [_parentViewController.view addSubview:aboutView];
}

@end
