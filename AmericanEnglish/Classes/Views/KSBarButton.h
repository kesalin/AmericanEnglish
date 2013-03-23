//
//  KSBarButton.h
//  KSFramework
//
//  Created by Kesalin on 6/17/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSButton.h"

@interface KSBarButton : KSButton

@property (nonatomic, copy)NSString *title;

- (void)addTarget:(id)target action:(SEL)action;

@end
