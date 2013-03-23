//
//  KSCache.m
//  KSFramework
//
//  Created by Kesalin on 6/15/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSCache.h"


@implementation KSCache

- (id)init
{
	if (self = [super init])
    {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appWillTerminNotify:)
													 name:UIApplicationDidEnterBackgroundNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appWillTerminNotify:)
													 name:UIApplicationWillTerminateNotification
												   object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
	
	[super dealloc];
}

#pragma mark -
#pragma mark saveOnExit
- (void)appWillTerminNotify:(NSNotification *)notification
{
    [self saveOnExit];
}

- (void)saveOnExit
{
}

@end
