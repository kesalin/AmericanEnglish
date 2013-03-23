//
//  KSRecorderController.m
//  AmericanEnglish
//
//  Created by kesalin on 8/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSRecorderController.h"
#import "KSLog.h"
#import "KSDefine.h"
#import "KSImageCache.h"

@implementation KSRecorderController

@synthesize player;
@synthesize recorder;

@synthesize btn_record;
@synthesize btn_play;
@synthesize fileDescription;
@synthesize lvlMeter_in;
@synthesize playbackWasInterrupted;

#pragma mark -
#pragma mark File description

char *OSTypeToStr(char *buf, OSType t)
{
	char *p = buf;
	char str[4], *q = str;
	*(UInt32 *)str = CFSwapInt32(t);
	for (int i = 0; i < 4; ++i) {
		if (isprint(*q) && *q != '\\')
			*p++ = *q++;
		else {
			sprintf(p, "\\x%02x", *q++);
			p += 4;
		}
	}
	*p = '\0';
	return buf;
}

-(void)setFileDescriptionForFormat: (CAStreamBasicDescription)format withName:(NSString*)name
{
	char buf[5];
	const char *dataFormat = OSTypeToStr(buf, format.mFormatID);
	NSString* description = [[NSString alloc] initWithFormat:@"(%d ch. %s @ %g Hz)", (unsigned int)(format.NumberChannels()), dataFormat, format.mSampleRate, nil];
	fileDescription.text = description;
	[description release];	
}

#pragma mark -
#pragma mark Playback routines
-(void)stopPlayQueue
{
	player->StopQueue();
	[lvlMeter_in setAq: nil];
	btn_record.enabled = YES;
}

-(void)pausePlayQueue
{
	player->PauseQueue();
	playbackWasPaused = YES;
}

- (void)stopRecord
{
	// Disconnect our level meter from the audio queue
	[lvlMeter_in setAq: nil];
	
	recorder->StopRecord();
	
	// dispose the previous playback queue
	player->DisposeQueue(true);
    
	// now create a new queue for the recorded file
    recordFilePath = (CFStringRef)[kKSSaveRecordFilePath stringByAppendingPathComponent: @"recordedFile.caf"];
    KSLog(@" >> save recorder caf file:%@", recordFilePath);
	player->CreateQueueForFile(recordFilePath);
    
	// Set the button's state back to "record"
    UIImage *image  = [KSImageCache imageNamed:@"blue_button"];
    [btn_record setBackgroundImage:image forState:UIControlStateNormal];
	[btn_record setTitle:@"Record" forState:UIControlStateNormal];

	btn_play.enabled = YES;
}

#pragma mark -
#pragma mark UI actions

- (void) stopNew
{
    if (!avRecorder || ![avRecorder isRecording])
        return;
    
    btn_play.enabled = YES;

    // Set the button's state back to "record"
    UIImage *image  = [KSImageCache imageNamed:@"blue_button"];
    [btn_record setBackgroundImage:image forState:UIControlStateNormal];
	[btn_record setTitle:@"Record" forState:UIControlStateNormal];
    
    [avRecorder stop];
    
    NSLog(@" >> stop recorder:%@", avRecorderFilePath);
}

- (void) recordNew
{
    if (!avRecorder)
    {
        NSError *err = nil;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
        if(err){
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return;
        }
        
        [audioSession setActive:YES error:&err];
        err = nil;
        if(err){
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            return;
        }
        
        NSMutableDictionary * recordSetting = [[NSMutableDictionary alloc] init];

        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];    
        
        [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        
        // Create a new dated file
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        NSString *caldate = [now description];
        avRecorderFilePath = [[NSString stringWithFormat:@"%@/%@.caf", KSDocumentPath(), caldate] retain];
        NSURL *url = [NSURL fileURLWithPath:avRecorderFilePath];

        err = nil;
        avRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
        if(!avRecorder)
        {
            NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Warning"
                                       message: [err localizedDescription]
                                      delegate: nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        
        //prepare to record
        [avRecorder setDelegate:self];
        [avRecorder prepareToRecord];
        avRecorder.meteringEnabled = YES;
        
        BOOL audioHWAvailable = audioSession.inputIsAvailable;
        if (!audioHWAvailable)
        {
            UIAlertView *cantRecordAlert =
            [[UIAlertView alloc] initWithTitle: @"Warning"
                                       message: @"Audio input hardware not available"
                                      delegate: nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
            [cantRecordAlert show];
            [cantRecordAlert release]; 
            return;
        }
    }
    
    if(![avRecorder isRecording])
    {
        btn_play.enabled = NO;
        
        // Set the button's state to "stop"
        UIImage *image  = [KSImageCache imageNamed:@"blue_button_pressed"];
        [btn_record setBackgroundImage:image forState:UIControlStateNormal];
        [btn_record setTitle:@"Stop" forState:UIControlStateNormal];

        // start recording
        [avRecorder recordForDuration:(NSTimeInterval) 10];
    }
    else
    {
        [self stopNew];
    }
}

- (void)stop
{
    if (player->IsRunning())
        [self stopPlayQueue];
    
    if (recorder->IsRunning())
        [self stopRecord];
}

- (IBAction)play: (id) sender
{
	if (player->IsRunning())
	{
		if (playbackWasPaused)
        {
            KSLog(@" >> Recorder: start");

			OSStatus result = player->StartQueue(true);
			if (result == noErr)
				[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
		}
		else
        {
            KSLog(@" >> Recorder: stop");
            
			[self stopPlayQueue];
        }
	}
	else
	{	
        KSLog(@" >> Recorder: start");
        
		OSStatus result = player->StartQueue(false);
		if (result == noErr)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
	}
}

- (IBAction)record: (id) sender
{
#if 0   // just for AVAudioRecorder test.

    [self recordNew];
    
    return;
#endif

	if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
        KSLog(@" >> Recorder: stop");

		[self stopRecord];
	}
	else // If we're not recording, start.
	{
        KSLog(@" >> Recorder: play");
        
		btn_play.enabled = NO;	
		
		// Set the button's state to "stop"
        UIImage *image  = [KSImageCache imageNamed:@"blue_button_pressed"];
        [btn_record setBackgroundImage:image forState:UIControlStateNormal];
        [btn_record setTitle:@"Stop" forState:UIControlStateNormal];
        
		// Start the recorder
		recorder->StartRecord(CFSTR("recordedFile.caf"));
		
		[self setFileDescriptionForFormat:recorder->DataFormat() withName:@"Recorded File"];
		
		// Hook the level meter up to the Audio Queue for the recorder
		[lvlMeter_in setAq: recorder->Queue()];
	}	
}

#pragma mark -
#pragma mark AudioSession listeners

//void interruptionListener(	void *	inClientData,
//                          UInt32	inInterruptionState)
//{
//	KSRecorderController *THIS = (KSRecorderController*)inClientData;
//	if (inInterruptionState == kAudioSessionBeginInterruption)
//	{
//		if (THIS->recorder->IsRunning()) {
//			[THIS stopRecord];
//		}
//		else if (THIS->player->IsRunning()) {
//			//the queue will stop itself on an interruption, we just need to update the UI
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
//			THIS->playbackWasInterrupted = YES;
//		}
//	}
//	else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS->playbackWasInterrupted)
//	{
//		// we were playing back when we were interrupted, so reset and resume now
//		THIS->player->StartQueue(true);
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
//		THIS->playbackWasInterrupted = NO;
//	}
//}

-(void) audioSessionInterruptionListener:(NSNotification *)notification
{
    NSLog(@"\n audioSessionInterruptionListener.........\n");
    
    NSDictionary *userInfo          = [notification userInfo];
    KSRecorderController *THIS      = (KSRecorderController *)[userInfo objectForKey:@"clientData"];
    NSNumber * iInInterruptionState = [userInfo objectForKey:@"interruptionState"];
    NSInteger interruptionState     = [iInInterruptionState intValue];
    
    if (interruptionState == kAudioSessionBeginInterruption)
	{
		if (THIS->recorder->IsRunning()) {
			[THIS stopRecord];
		}
		else if (THIS->player->IsRunning()) {
			//the queue will stop itself on an interruption, we just need to update the UI
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
			THIS->playbackWasInterrupted = YES;
		}
	}
	else if ((interruptionState == kAudioSessionEndInterruption) && THIS->playbackWasInterrupted)
	{
		// we were playing back when we were interrupted, so reset and resume now
		THIS->player->StartQueue(true);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
		THIS->playbackWasInterrupted = NO;
	}

}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
	KSRecorderController *THIS = (KSRecorderController*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;			
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			/*CFStringRef oldRoute = (CFStringRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
             if (oldRoute)	
             {
             printf("old route:\n");
             CFShow(oldRoute);
             }
             else 
             printf("ERROR GETTING OLD AUDIO ROUTE!\n");
             
             CFStringRef newRoute;
             UInt32 size; size = sizeof(CFStringRef);
             OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
             if (error) printf("ERROR GETTING NEW AUDIO ROUTE! %d\n", error);
             else
             {
             printf("new route:\n");
             CFShow(newRoute);
             }*/
            
			if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
			{			
				if (THIS->player->IsRunning()) {
					[THIS pausePlayQueue];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
				}		
			}
            
			// stop the queue if we had a non-policy route change
			if (THIS->recorder->IsRunning()) {
				[THIS stopRecord];
			}
		}	
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32)) {
			UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
			THIS->btn_record.enabled = (isAvailable > 0) ? YES : NO;
		}
	}
}

#pragma mark -
#pragma mark Initialization routines

- (void)awakeFromNib
{		
    NSLog(@" >> KSRecorderController awakeFromNib...");

	// Allocate our singleton instance for the recorder & player object
	recorder = new AQRecorder();
	player = new AQPlayer();
    
//	OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
//	if (error)
//        KSLog(@"ERROR INITIALIZING AUDIO SESSION! %d\n", (NSInteger)error);
//	else 
	{
        KSLog(@" >> AudioSessionInitialize succeed!");
		
        UInt32 category = kAudioSessionCategory_PlayAndRecord;	
		OSStatus error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error)
            KSLog(@"couldn't set audio category!");
        
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
		if (error)
            KSLog(@"ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (NSInteger)error);

		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);
		
		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error)
            KSLog(@"ERROR GETTING INPUT AVAILABILITY! %d\n", (NSInteger)error);
		btn_record.enabled = (inputAvailable) ? YES : NO;
		
		// we also need to listen to see if input availability changes
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
		if (error)
            KSLog(@"ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (NSInteger)error);
        
		error = AudioSessionSetActive(true); 
		if (error)
            KSLog(@"AudioSessionSetActive (true) failed");
        
        KSLog(@" >> AudioSession set OK!");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionListener:) name:kKSAudioSessionInterruptionListener object:nil];

	UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
	[lvlMeter_in setBackgroundColor:bgColor];
	[lvlMeter_in setBorderColor:bgColor];
	[bgColor release];
	
	// disable the play button since we have no recording to play yet
	btn_play.enabled = NO;
	playbackWasInterrupted = NO;
	playbackWasPaused = NO;
    
    UIImage *image  = [KSImageCache imageNamed:@"blue_button_pressed"];
    [btn_play setBackgroundImage:image forState:UIControlStateHighlighted];
    [btn_record setBackgroundImage:image forState:UIControlStateHighlighted];
}

#pragma mark -
#pragma mark Notification routines

- (void)playbackQueueStopped:(NSNotification *)note
{
    UIImage *image  = [KSImageCache imageNamed:@"blue_button"];
    [btn_play setBackgroundImage:image forState:UIControlStateNormal];
    [btn_play setTitle:@"Play" forState:UIControlStateNormal];

	[lvlMeter_in setAq: nil];
	btn_record.enabled = YES;
}

- (void)playbackQueueResumed:(NSNotification *)note
{
    UIImage *image  = [KSImageCache imageNamed:@"blue_button_pressed"];
    [btn_play setBackgroundImage:image forState:UIControlStateNormal];
    [btn_play setTitle:@"Stop" forState:UIControlStateNormal];
    
	btn_record.enabled = NO;
	[lvlMeter_in setAq: player->Queue()];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kKSAudioSessionInterruptionListener object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playbackQueueStopped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playbackQueueResumed" object:nil];
    
    [avRecorder release];
    [avRecorderFilePath release];

	[btn_record release];
	[btn_play release];
	[fileDescription release];
	[lvlMeter_in release];
	
	delete player;
	delete recorder;
	
	[super dealloc];
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate

/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    
}

/* audioRecorderBeginInterruption: is called when the audio session has been interrupted while the recorder was recording. The recorder will have been paused. */
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    
}

/* audioRecorderEndInterruption:withFlags: is called when the audio session interruption has ended and this recorder had been interrupted while recording. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags NS_AVAILABLE_IPHONE(4_0)
{
    
}

/* audioRecorderEndInterruption: is called when the preferred method, audioRecorderEndInterruption:withFlags:, is not implemented. */
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
{
    
}

@end
