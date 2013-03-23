//
//  AEAppDelegate.h
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AEViewController;

@interface AEAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AEViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AEViewController *viewController;

@end

