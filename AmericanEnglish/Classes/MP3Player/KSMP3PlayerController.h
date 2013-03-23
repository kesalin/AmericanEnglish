//
//  KSMP3PlayerController.h
//  AmericanEnglish
//
//  Created by kesalin on 7/21/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "KSViewController.h"
#import "KSSectionInfo.h"

// KSMP3PlayerControllerDelegate
//

@class KSMP3PlayerController;

@protocol KSMP3PlayerControllerDelegate <NSObject>

@optional
- (void) audioPlayerDidFinishPlaying:(KSMP3PlayerController *)mp3PlayerController;
- (void) audioPlayerPlayButtonPressed:(KSMP3PlayerController *)mp3PlayerController;
- (void) audioPlayerNextButtonPressed:(KSMP3PlayerController *)mp3PlayerController;
- (void) audioPlayerPrevButtonPressed:(KSMP3PlayerController *)mp3PlayerController;

@end

// KSMP3PlayerController
//

@interface KSMP3PlayerController : KSViewController <AVAudioPlayerDelegate>
{
    IBOutlet UIImageView    *bgView;
    IBOutlet UILabel		*fileName;
	IBOutlet UIButton		*playButton;
	IBOutlet UIButton		*ffwButton;
	IBOutlet UIButton		*rewButton;
    IBOutlet UIButton       *volumeDown;
    IBOutlet UIButton       *volumeUp;
	IBOutlet UISlider		*progressBar;
	IBOutlet UILabel		*currentTime;
	IBOutlet UILabel		*duration;
    IBOutlet UILabel		*volume;
    
    AVAudioPlayer           *player;
	NSTimer					*updateTimer;
	NSTimer					*rewTimer;
	NSTimer					*ffwTimer;
	
	BOOL                    inBackground;
    
    id<KSMP3PlayerControllerDelegate> _delegate;
	KSSectionInfo *			currentFileInfo;
    
    NSInteger               volumeCount;
}

@property (nonatomic, retain)	UILabel			*fileName;
@property (nonatomic, retain)	UIButton		*playButton;
@property (nonatomic, retain)	UIButton		*ffwButton;
@property (nonatomic, retain)	UIButton		*rewButton;
@property (nonatomic, retain)	UISlider		*progressBar;
@property (nonatomic, retain)	UILabel			*currentTime;
@property (nonatomic, retain)	UILabel			*duration;
@property (nonatomic, retain)	UILabel			*volume;

@property (nonatomic, retain)	NSTimer			*updateTimer;
@property (nonatomic, retain)	AVAudioPlayer	*player;

@property (nonatomic, assign)	BOOL			inBackground;

@property (nonatomic, retain)	id<KSMP3PlayerControllerDelegate> delegate;

+ (KSMP3PlayerController *) createMP3PlayerController:(CGRect)frame;

- (IBAction) playButtonPressed:(UIButton *)sender;
- (IBAction) rewButtonPressed:(UIButton *)sender;
- (IBAction) rewButtonReleased:(UIButton *)sender;
- (IBAction) ffwButtonPressed:(UIButton *)sender;
- (IBAction) ffwButtonReleased:(UIButton *)sender;
- (IBAction) volumeUpButtonPressed:(UIButton *)sender;
- (IBAction) volumeDownButtonPressed:(UIButton *)sender;
- (IBAction) progressSliderMoved:(UISlider *)sender;

- (void) setupMP3Info:(KSSectionInfo *) sectionInfo displayUnit:(BOOL)display;

- (void) play;
- (void) pause;
- (void) stop;
- (BOOL) isPlaying;

@end
