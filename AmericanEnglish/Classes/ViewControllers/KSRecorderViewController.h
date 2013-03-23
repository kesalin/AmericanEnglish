//
//  KSRecorderViewController.h
//  AmericanEnglish
//
//  Created by kesalin on 8/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSViewController.h"

@class KSRecorderController;

@interface KSRecorderViewController : KSViewController
{
    IBOutlet KSRecorderController *controller;
}

+ (KSRecorderViewController *) createKSRecorderViewController:(CGRect)frame;

@property (nonatomic, retain) KSRecorderController *controller;

- (void) stop;

@end
