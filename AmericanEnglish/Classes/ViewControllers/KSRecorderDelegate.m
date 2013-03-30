//
//  KSRecorderDelegate.m
//  AmericanEnglish
//
//  Created by kesalin on 8/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSRecorderDelegate.h"
#import "KSRecorderViewController.h"
#import "KSDefine.h"
@implementation KSRecorderDelegate

- (void) setup
{
    _parentViewController.tableView.hidden = YES;
    
    CGRect frame             = _parentViewController.view.frame;
    frame.origin.x          = 0;
    frame.origin.y          = 0;
    frame.size.height       -= kKSTabItemHeight;
    
    _recorderController     = [[KSRecorderViewController createKSRecorderViewController:frame] retain];
    [_parentViewController.view addSubview:_recorderController.view];
}

- (void) dealloc
{
    [_recorderController release];
    _recorderController = nil;
    
    [super dealloc];
}

- (void) viewWillDisappear
{
    [_recorderController stop];
}

@end
