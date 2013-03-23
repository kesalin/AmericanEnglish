/*
 
 File: CALevelMeter.mm
 Abstract: n/a
 Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 
 */

#import "CALevelMeter.h"

#import "LevelMeter.h"
#import "GLLevelMeter.h"

#import <QuartzCore/QuartzCore.h>

@interface CALevelMeter (CALevelMeter_priv)
- (void)layoutSubLevelMeters;
- (void)pauseTimer;
- (void)resumeTimer;
- (void)registerForBackgroundNotifications;
- (void)unregisterForBackgroundNotifications;
@end


@implementation CALevelMeter

@synthesize showsPeaks = _showsPeaks;
@synthesize vertical = _vertical;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
		_showsPeaks = YES;
		_channelNumbers = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
		_vertical = NO;
		_useGL = YES;
		_meterTable = new MeterTable(kMinDBvalue);
		[self layoutSubLevelMeters];
		[self registerForBackgroundNotifications];
	}
	return self;
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
	if (self) {
		_showsPeaks = YES;
		_channelNumbers = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
		_vertical = NO;
		_useGL = YES;
		_meterTable = new MeterTable(kMinDBvalue);
		[self layoutSubLevelMeters];
		[self registerForBackgroundNotifications];
	}
	return self;
}

- (void)registerForBackgroundNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pauseTimer)
												 name:UIApplicationWillResignActiveNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resumeTimer)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void)unregisterForBackgroundNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)layoutSubLevelMeters
{
	int i;
	for (i=0; i<[_subLevelMeters count]; i++)
	{
		UIView *thisMeter = [_subLevelMeters objectAtIndex:i];
		[thisMeter removeFromSuperview];
	}
	[_subLevelMeters release];
	
	NSMutableArray *meters_build = [[NSMutableArray alloc] initWithCapacity:[_channelNumbers count]];
	
	CGRect totalRect;
	
	if (_vertical) totalRect = CGRectMake(0., 0., [self frame].size.width + 2., [self frame].size.height);
	else  totalRect = CGRectMake(0., 0., [self frame].size.width, [self frame].size.height + 2.);
	
	for (i=0; i<[_channelNumbers count]; i++)
	{
		CGRect fr;
		
		if (_vertical) {
			fr = CGRectMake(
							totalRect.origin.x + (((CGFloat)i / (CGFloat)[_channelNumbers count]) * totalRect.size.width), 
							totalRect.origin.y, 
							(1. / (CGFloat)[_channelNumbers count]) * totalRect.size.width - 2., 
							totalRect.size.height
							);
		} else {
			fr = CGRectMake(
							totalRect.origin.x, 
							totalRect.origin.y + (((CGFloat)i / (CGFloat)[_channelNumbers count]) * totalRect.size.height), 
							totalRect.size.width, 
							(1. / (CGFloat)[_channelNumbers count]) * totalRect.size.height - 2.
							);
		}
		
		LevelMeter *newMeter;

		if (_useGL) newMeter = [[GLLevelMeter alloc] initWithFrame:fr];
		else newMeter = [[LevelMeter alloc] initWithFrame:fr];
		
		newMeter.numLights = 30;
		newMeter.vertical = self.vertical;
		[meters_build addObject:newMeter];
		[self addSubview:newMeter];
		[newMeter release];
	}	
	
	_subLevelMeters = [[NSArray alloc] initWithArray:meters_build];
	
	[meters_build release];
}


- (void)_refresh
{
	BOOL success = NO;

	// if we have no queue, but still have levels, gradually bring them down
	if (_player == NULL)
	{
		CGFloat maxLvl = -1.;
		CFAbsoluteTime thisFire = CFAbsoluteTimeGetCurrent();
		// calculate how much time passed since the last draw
		CFAbsoluteTime timePassed = thisFire - _peakFalloffLastFire;
		for (LevelMeter *thisMeter in _subLevelMeters)
		{
			CGFloat newPeak, newLevel;
			newLevel = thisMeter.level - timePassed * kLevelFalloffPerSec;
			if (newLevel < 0.) newLevel = 0.;
			thisMeter.level = newLevel;
			if (_showsPeaks)
			{
				newPeak = thisMeter.peakLevel - timePassed * kPeakFalloffPerSec;
				if (newPeak < 0.) newPeak = 0.;
				thisMeter.peakLevel = newPeak;
				if (newPeak > maxLvl) maxLvl = newPeak;
			}
			else if (newLevel > maxLvl) maxLvl = newLevel;
			
			[thisMeter setNeedsDisplay];
		}
		// stop the timer when the last level has hit 0
		if (maxLvl <= 0.)
		{
			[_updateTimer invalidate];
			_updateTimer = nil;
		}
		
		_peakFalloffLastFire = thisFire;
		success = YES;
	} else {
		[_player updateMeters];
		for (int i=0; i<[_channelNumbers count]; i++)
		{
			NSInteger channelIdx = [(NSNumber *)[_channelNumbers objectAtIndex:i] intValue];
			LevelMeter *channelView = [_subLevelMeters objectAtIndex:channelIdx];
			
			if (channelIdx >= [_channelNumbers count]) goto bail;
			if (channelIdx > 127) goto bail;
			
			channelView.level = _meterTable->ValueAt([_player averagePowerForChannel:i]);
			if (_showsPeaks) channelView.peakLevel = _meterTable->ValueAt([_player peakPowerForChannel:i]);
			else
				channelView.peakLevel = 0.;
			[channelView setNeedsDisplay];
			success = YES;		
		}
	}
	
bail:
	
	if (!success)
	{
		for (LevelMeter *thisMeter in _subLevelMeters) { thisMeter.level = 0.; [thisMeter setNeedsDisplay]; }
		NSLog(@"ERROR: metering failed\n");
	}
}


- (void)dealloc
{
    [self unregisterForBackgroundNotifications];
    
	[_updateTimer invalidate];
	[_channelNumbers release];
	[_subLevelMeters release];
	delete _meterTable;
	
	[super dealloc];
}


- (AVAudioPlayer*)player { return _player; }
- (void)setPlayer:(AVAudioPlayer*)v
{	
	if ((_player == NULL) && (v != NULL))
	{
		if (_updateTimer) [_updateTimer invalidate];
		_updateTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(_refresh)];
		[_updateTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	} else if ((_player != NULL) && (v == NULL)) {
		_peakFalloffLastFire = CFAbsoluteTimeGetCurrent();
	}
	
	_player = v;
	
	if (_player)
	{
		_player.meteringEnabled = YES;
		// now check the number of channels in the new queue, we will need to reallocate if this has changed
		if (_player.numberOfChannels != [_channelNumbers count])
		{
			NSArray *chan_array;
			if (_player.numberOfChannels < 2)
				chan_array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], nil];
			else
				chan_array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1], nil];
				[self setChannelNumbers:chan_array];
			[chan_array release];				
		}
	} else {
		for (LevelMeter *thisMeter in _subLevelMeters) {
			[thisMeter setNeedsDisplay];
		}
	}
}


- (NSArray *)channelNumbers { return _channelNumbers; }
- (void)setChannelNumbers:(NSArray *)v
{
	[v retain];
	[_channelNumbers release];
	_channelNumbers = v;
	[self layoutSubLevelMeters];
}

- (BOOL)useGL { return _useGL; }
- (void)setUseGL:(BOOL)v
{
	_useGL = v;
	[self layoutSubLevelMeters];
}

- (void)pauseTimer
{
	[_updateTimer invalidate];
	_updateTimer = nil;
}

- (void)resumeTimer
{
	if (_player)
	{
		_updateTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(_refresh)];
		[_updateTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
}

@end
