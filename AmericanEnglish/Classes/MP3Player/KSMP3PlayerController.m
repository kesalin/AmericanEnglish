//
//  KSMP3PlayerController.m
//  AmericanEnglish
//
//  Created by kesalin on 7/21/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSMP3PlayerController.h"
#import "KSLog.h"
#import "KSImageCache.h"
#import "KSDefine.h"
#import "KSUtilities.h"

// amount to skip on rewind or fast forward
#define kKSSkipTime				1.0			
// amount to play between skips
#define kKSSkipInterval			0.2
#define kKSDefaultVolume		1.5
#define kKSMaxVolume            3.0
#define kKSMinVolume            0.0
#define kKSVolumeInterval		0.5

#define kKSPlayButtonImage		[KSImageCache imageNamed:@"player_play"]
#define kKSPauseButtonImage		[KSImageCache imageNamed:@"player_pause"]

void RouteChangeListener(void *                     inClientData,
                         AudioSessionPropertyID     inID,
                         UInt32                     inDataSize,
                         const void *               inData);

// KSMP3PlayerController(PrivateMethods)
// 
@interface KSMP3PlayerController(PrivateMethods)

- (void) registerForBackgroundNotifications;
- (void) unregisterForBackgroundNotifications;

- (void) setInBackgroundFlag;
- (void) clearInBackgroundFlag;

- (void) updateCurrentTime:(NSTimer *)timer;
- (void) rewind:(NSTimer *)timer;
- (void) ffwd:(NSTimer *)timer;

- (void) startPlaybackForPlayer:(AVAudioPlayer*)audioPlayer;
- (void) pausePlaybackForPlayer:(AVAudioPlayer*)audioPlayer;

@end


// KSMP3PlayerController
//
@implementation KSMP3PlayerController

@synthesize fileName;
@synthesize playButton;
@synthesize ffwButton;
@synthesize rewButton;
@synthesize progressBar;
@synthesize currentTime;
@synthesize duration;
@synthesize volume;

@synthesize updateTimer;
@synthesize player;

@synthesize inBackground;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Life cycle

+ (KSMP3PlayerController *) createMP3PlayerController:(CGRect)frame;
{
    KSMP3PlayerController * mp3PlayerCtl = [[KSMP3PlayerController alloc] initWithNibName:@"KSMP3PlayerView" bundle:nil];
    mp3PlayerCtl.view.frame = frame;
    
    return [mp3PlayerCtl autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[playButton setImage:kKSPlayButtonImage forState:UIControlStateNormal];
    
	updateTimer = nil;
	rewTimer = nil;
	ffwTimer = nil;
    
    duration.adjustsFontSizeToFitWidth = YES;
    currentTime.adjustsFontSizeToFitWidth = YES;
	progressBar.minimumValue = 0.0;	
    
    [self registerForBackgroundNotifications];
    
//    OSStatus result = AudioSessionInitialize(NULL, NULL, NULL, NULL);
//	if (result)
//		KSLog(@"Error initializing audio session! %ld", result);
//    else
//        KSLog(@" >> AudioSessionInitialize succeed!");
}

- (void)viewDidUnload
{
    KSLog(@" >>> viewDidUnload");
    
    [super viewDidUnload];

    [self stop];
    self.player = nil;

    [self unregisterForBackgroundNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self stop];
}

- (void)dealloc
{
    [self stop];

	[fileName release];
	[playButton release];
	[ffwButton release];
	[rewButton release];
	[progressBar release];
	[currentTime release];
	[duration release];
	
	[updateTimer release];
	[player release];

    [super dealloc];
}


#pragma mark -
#pragma mark update status

-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)audioPlayer
{
	currentTime.text = [NSString stringWithFormat:@"%d:%02d", (int)audioPlayer.currentTime / 60, (int)audioPlayer.currentTime % 60, nil];
	progressBar.value = audioPlayer.currentTime;
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)audioPlayer
{
	[self updateCurrentTimeForPlayer:audioPlayer];
    
	if (updateTimer) 
		[updateTimer invalidate];
    
	if (audioPlayer.playing)
	{
		[playButton setImage:kKSPauseButtonImage forState:UIControlStateNormal];
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateCurrentTime:) userInfo:audioPlayer repeats:YES];
	}
	else
	{
		[playButton setImage:kKSPlayButtonImage forState:UIControlStateNormal];
		updateTimer = nil;
	}
}

- (void)updateViewForPlayerStateInBackground:(AVAudioPlayer *)audioPlayer
{
	[self updateCurrentTimeForPlayer:audioPlayer];
	
	if (audioPlayer.playing)
		[playButton setImage:kKSPauseButtonImage forState:UIControlStateNormal];
	else
		[playButton setImage:kKSPlayButtonImage forState:UIControlStateNormal];
}

-(void)updateViewForPlayerInfo:(AVAudioPlayer*)audioPlayer
{
    NSString *durationString = [NSString stringWithFormat:@"%d:%02d", (int)(audioPlayer.duration / 60), (int)audioPlayer.duration % 60, nil];
	duration.text = durationString;
	progressBar.maximumValue = audioPlayer.duration;
}

#pragma mark -
#pragma mark Timer

- (void)updateCurrentTime:(NSTimer *)timer
{
    AVAudioPlayer * audioPlayer = timer.userInfo;
	[self updateCurrentTimeForPlayer:audioPlayer];
}

- (void)rewind:(NSTimer *)timer
{
	AVAudioPlayer *audioPlayer = timer.userInfo;
	audioPlayer.currentTime -= kKSSkipTime;
	[self updateCurrentTimeForPlayer:audioPlayer];
}

- (void)ffwd:(NSTimer *)timer
{
	AVAudioPlayer *audioPlayer = timer.userInfo;
	audioPlayer.currentTime += kKSSkipTime;	
	[self updateCurrentTimeForPlayer:audioPlayer];
}

#pragma mark -
#pragma mark init

- (void)setupMP3Info:(KSSectionInfo *) sectionInfo displayUnit:(BOOL)displayUnit
{
    if (!sectionInfo)
        return;

    if (currentFileInfo == sectionInfo)
    {
        if (player)
        {
            player.currentTime = 0;
            [self updateCurrentTimeForPlayer:player];
        }

        return;
    }

    NSString *displayName	= [NSString stringWithFormat:@"%@", KSLocal(sectionInfo.title)];
    if (displayUnit)
    {
        NSInteger unitNum       = [KSUtilities unitNumberOf:sectionInfo.unitKey];
        NSString *unitKey       = [NSString stringWithFormat:@"Unit %d", unitNum];
        displayName             = [NSString stringWithFormat:@"%@ %@", unitKey, KSLocal(sectionInfo.title)];
    }
    
	NSString *mp3File       = sectionInfo.mp3;
    if (!mp3File || [mp3File isEqualToString:@""])
    {
        KSLog(@"Error invalid mp3 file!");
        return;
    }
	
    NSRange range           = [mp3File rangeOfString:@"." options:NSBackwardsSearch];
    if (range.location == NSNotFound)
    {
        KSLog(@"Error invalid mp3 file!");
        return;
    }
    
    NSString *mp3Name       = [mp3File substringToIndex:range.location];
    NSString *mp3Type       = [mp3File substringFromIndex:(range.location + 1)];
    NSString *path          = [[NSBundle mainBundle] pathForResource:mp3Name ofType:mp3Type];
    if (KSIsNullOrEmpty(path))
    {
        KSLog(@"Error, file does not exist! %@", path);
        return;
    }

    [currentFileInfo release];
	currentFileInfo         = [sectionInfo retain];

	NSURL *fileURL          = [[NSURL alloc] initFileURLWithPath:path];

    [self stop];
    self.player = nil;
    
	self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	self.player.volume      = kKSDefaultVolume;
    
    volumeCount = 3;
	volume.text = [NSString stringWithFormat:@"%d", volumeCount];
    
    if (self.player)
	{
		fileName.text       = displayName;
		[self updateViewForPlayerInfo:player];
		[self updateViewForPlayerState:player];
		player.numberOfLoops = 0;
		player.delegate = self;
        
        KSLog(@" >> Play %@", displayName);
	}
	
	[[AVAudioSession sharedInstance] setDelegate: self];
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
	if (setCategoryError)
		KSLog(@"Error setting category! %@ %@ %@", displayName, mp3File, [setCategoryError description]);
	
	OSStatus result = AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, RouteChangeListener, self);
	if (result) 
		KSLog(@"Could not add property listener! %@ %@ %ld", displayName, mp3File, result);
	
	[fileURL release];
}

- (void) play
{
    if (player && !player.playing)
        [self startPlaybackForPlayer: player];
}

- (void) pause
{
    if (player && player.playing)
        [self pausePlaybackForPlayer: player];
}

- (void) stop
{
    if (player && player.playing)
    {
        [player stop];
        [self updateViewForPlayerState:player];
    }
}

- (BOOL) isPlaying
{
    BOOL playing = (player && player.playing);
    return playing;
}

-(void) pausePlaybackForPlayer:(AVAudioPlayer*)audioPlayer
{
	[audioPlayer pause];
	[self updateViewForPlayerState:audioPlayer];
}

-(void) startPlaybackForPlayer:(AVAudioPlayer*)audioPlayer
{    
    BOOL isSucceed = [audioPlayer play];
    if (isSucceed)
        [self updateViewForPlayerState:audioPlayer];
    else
        KSLog(@"Could not play %@\n", audioPlayer.url);
}

#pragma -
#pragma mark background notifications

- (void) registerForBackgroundNotifications
{    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice respondsToSelector:@selector(isMultitaskingSupported)] && [currentDevice isMultitaskingSupported])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setInBackgroundFlag) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearInBackgroundFlag) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

- (void) unregisterForBackgroundNotifications
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice respondsToSelector:@selector(isMultitaskingSupported)] && [currentDevice isMultitaskingSupported])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

- (void) setInBackgroundFlag
{
	inBackground = YES;
}

- (void) clearInBackgroundFlag
{
	inBackground = NO;
}

#pragma mark -
#pragma mark AudioSession handlers

void RouteChangeListener(void *                     inClientData,
                         AudioSessionPropertyID     inID,
                         UInt32                     inDataSize,
                         const void *               inData)
{
	KSMP3PlayerController* This = (KSMP3PlayerController*)inClientData;
	
	if (inID == kAudioSessionProperty_AudioRouteChange)
    {
		CFDictionaryRef routeDict = (CFDictionaryRef)inData;
		NSNumber* reasonValue = (NSNumber*)CFDictionaryGetValue(routeDict, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		
		int reason = [reasonValue intValue];
        
		if (reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
			[This pausePlaybackForPlayer:This.player];
	}
}

#pragma mark -
#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)audioPlayer successfully:(BOOL)flag
{
	if (flag == NO)
		KSLog(@"Playback finished unsuccessfully");
    
	[audioPlayer setCurrentTime:0.];
	[self updateViewForPlayerState:audioPlayer];
    
    if (_delegate && [_delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
        [_delegate performSelector:@selector(audioPlayerDidFinishPlaying:) withObject:self];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)audioPlayer error:(NSError *)error
{
	KSLog(@"ERROR IN DECODE: %@\n", error); 
}

// we will only get these notifications if playback was interrupted
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)audioPlayer
{
	KSLog(@"Interruption begin. Updating UI for new state");

	// the object has already been paused,	we just need to update UI
	if (inBackground)
	{
		[self updateViewForPlayerStateInBackground:audioPlayer];
	}
	else
	{
		[self updateViewForPlayerState:audioPlayer];
	}
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)audioPlayer
{
	KSLog(@"Interruption ended. Resuming playback");

	[self startPlaybackForPlayer:audioPlayer];
}


#pragma mark -
#pragma mark MP3Player delegate

- (void) playButtonPressed:(UIButton *)sender
{
    if (!player)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(audioPlayerPlayButtonPressed:)])
            [_delegate performSelector:@selector(audioPlayerPlayButtonPressed:) withObject:self];
        
        return;
    }

    if (player.playing == YES)
		[self pausePlaybackForPlayer: player];
	else
		[self startPlaybackForPlayer: player];
}

- (void) rewButtonPressed:(UIButton *)sender
{
//	if (rewTimer)
//        [rewTimer invalidate];
//
//    rewTimer = [NSTimer scheduledTimerWithTimeInterval:kKSSkipInterval target:self selector:@selector(rewind:) userInfo:player repeats:YES];
}

- (void) rewButtonReleased:(UIButton *)sender
{
//    if (rewTimer)
//        [rewTimer invalidate];
//	rewTimer = nil;
    
    if (_delegate && [_delegate respondsToSelector:@selector(audioPlayerPrevButtonPressed:)])
        [_delegate performSelector:@selector(audioPlayerPrevButtonPressed:) withObject:self];
}

- (void) ffwButtonPressed:(UIButton *)sender
{
//	if (ffwTimer)
//        [ffwTimer invalidate];
//
//    ffwTimer = [NSTimer scheduledTimerWithTimeInterval:kKSSkipInterval target:self selector:@selector(ffwd:) userInfo:player repeats:YES];
}

- (void) ffwButtonReleased:(UIButton *)sender
{
//	if (ffwTimer)
//        [ffwTimer invalidate];
//	ffwTimer = nil;

    if (_delegate && [_delegate respondsToSelector:@selector(audioPlayerNextButtonPressed:)])
        [_delegate performSelector:@selector(audioPlayerNextButtonPressed:) withObject:self];
}

- (void) volumeUpButtonPressed:(UIButton *)sender
{
    ++volumeCount;
    volumeDown.enabled = YES;
    player.volume += kKSVolumeInterval;
    if (player.volume >= kKSMaxVolume)
    {
        volumeCount = 6;
        player.volume = kKSMaxVolume;
        volumeUp.enabled = NO;
    }

    volume.text = [NSString stringWithFormat:@"%d", volumeCount];
}

- (void) volumeDownButtonPressed:(UIButton *)sender
{
    --volumeCount;
    volumeUp.enabled = YES;
    player.volume -= kKSVolumeInterval;
    if (player.volume <= kKSMinVolume)
    {
        volumeCount = 0;
        player.volume = kKSMinVolume;
        volumeDown.enabled = NO;
    }
    
    volume.text = [NSString stringWithFormat:@"%d", volumeCount];
}

- (void) progressSliderMoved:(UISlider *)sender
{
    player.currentTime = sender.value;
	[self updateCurrentTimeForPlayer:player];
}

@end
