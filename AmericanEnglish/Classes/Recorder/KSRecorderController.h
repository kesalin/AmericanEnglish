//
//  KSRecorderController.h
//  AmericanEnglish
//
//  Created by kesalin on 8/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AQLevelMeter.h"
#import "AQPlayer.h"
#import "AQRecorder.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface KSRecorderController : NSObject <AVAudioRecorderDelegate>
{
 	IBOutlet UIButton*          btn_record;
	IBOutlet UIButton*          btn_play;
	IBOutlet UILabel*			fileDescription;
	IBOutlet AQLevelMeter*		lvlMeter_in;
    
	AQPlayer*					player;
	AQRecorder*					recorder;
	BOOL						playbackWasInterrupted;
	BOOL						playbackWasPaused;
	
	CFStringRef					recordFilePath;	   
    
    NSString *                  avRecorderFilePath;
    AVAudioRecorder *           avRecorder;
}

@property (nonatomic, retain)	UIButton            *btn_record;
@property (nonatomic, retain)	UIButton            *btn_play;
@property (nonatomic, retain)	UILabel				*fileDescription;
@property (nonatomic, retain)	AQLevelMeter		*lvlMeter_in;

@property (readonly)			AQPlayer			*player;
@property (readonly)			AQRecorder			*recorder;
@property						BOOL				playbackWasInterrupted;

- (IBAction)record: (id) sender;
- (IBAction)play: (id) sender;
- (void)stop;

@end
