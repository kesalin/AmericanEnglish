//
//  KSAudiosCategoryDelegate.h
//  AmericanEnglish
//
//  Created by kesalin on 11-7-24.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSSubDelegate.h"

enum KSLoopMode_ {
    eKSLoopModeAll      = 0,
    eKSLoopModeUnit,
    eKSLoopModeSingle,
    
    eKSLoopModeCount,
};

typedef NSInteger KSLoopMode;

@interface KSAudiosCategoryDelegate : KSSubDelegate
{
    NSArray *       allUnits;
    NSArray *       sectionTitles;
    
    NSInteger       _currentUnit;
    NSInteger       _currentSection;
    KSLoopMode      _currentLoopMode;
}

@end
