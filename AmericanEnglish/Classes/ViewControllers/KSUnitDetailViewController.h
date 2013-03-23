//
//  KSUnitDetailViewController.h
//  AmericanEnglish
//
//  Created by kesalin on 7/25/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSViewController.h"
#import "KSMP3PlayerController.h"

enum KSPlayMode_ {
    eKSPlayModeManual,
    eKSPlayModeAuto,
    
    eKSPlayModeCount
};

typedef NSInteger KSPlayMode;

@class KSMP3PlayerController;
@class KSUnitInfo;

@interface KSUnitDetailViewController : KSViewController <UIScrollViewDelegate, KSMP3PlayerControllerDelegate>
{
    KSPlayMode                  _currentPlayMode;
    KSUnitInfo *                _unitInfo;
    
    BOOL                        _isWithMP3Player;
    KSMP3PlayerController *     _mp3PlayerController;
    
    NSMutableArray *            _sectionViews;
    UIScrollView *              _scrollView;
    UIPageControl *             _pageControl;
    NSInteger                   _pageCount;
    
    CGFloat                     splitWidth;
    BOOL                        pageControlUsed;
    NSInteger                   lastPage;
}

- (id)initWithUnitInfo:(KSUnitInfo *)info;

@end
