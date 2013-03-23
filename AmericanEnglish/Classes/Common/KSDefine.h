/*
 *  KSDefine.h
 *  AmericanEnglish
 *
 *  Created by kesalin on 7/19/11.
 *  Copyright 2011 kesalin@gmail.com. All rights reserved.
 *
 */

#ifndef __KSDEFINE_H__
#define __KSDEFINE_H__

#define Display_All_Sections_In_Unit
#define Debug_Support_Conversation  1
#define Debug_Support_Dialog        1

// Uitilities code
//
#define KSIsIPad                        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define KSDocumentPath()                [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define KSLocal(_a)                     NSLocalizedString((_a), nil)

#define KSIsNullOrEmpty(str)            ((nil == (str)) || ([(str) isEqualToString:@""])) 
#define KSReplaceNULL2Empty(str)        ((nil == (str)) ? @"" : (str))
#define KSReplaceEmpty2NULL(str)        ((nil == (str)) ? [NSNull null] : (str))
#define KSReplaceNULL2HoriLine(str)     ((nil == (str)) ? @"--" : (str))

#define UIColorFromRGB(rgbValue)        [UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16))/255.0 green: ((float)((rgbValue & 0xFF00) >> 8))/255.0 blue: ((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kKSSaveRecordFilePath           NSTemporaryDirectory()

// Constants
//
#define kKSAppWidth                     [[UIScreen mainScreen] bounds].size.width
#define kKSAppHeight                    [[UIScreen mainScreen] bounds].size.height

#define kKSNavigationBarHeight			44.0
#define kKSTabItemHeight                44.0
#define kKSNaviItemHeight               32.0
#define kKSNaviItemWidth                70.0
#define kKSSectionHeaderHeight          24.0
#define kKSStatusHeight                 20.0
#define kKSTableViewCellHeight          36.0
#define kKSTableViewSectionHeaderHeight 44.0
#define kKSMP3PlayerHeight              88.0
#define kKSPageControlHeight            22.0

#define kKSAppHeightWithoutTab          (kKSAppHeight - kKSTabItemHeight)
#define kKSAppFrame                     CGRectMake(0, 0, kKSAppWidth, kKSAppHeightWithoutTab - kKSNavigationBarHeight)
#define kKSUnitContentHeight            (kKSAppHeight - kKSNavigationBarHeight - kKSMP3PlayerHeight - kKSTabItemHeight) // 124.0

#define kKSSliderBarItemInterval                5

#define kKSAudioCellDefaultHeight               36
#define kKSAudioSectionHeaderDefaultHeight      36

#define kKSNavigationTintColorRed       [UIColor colorWithRed:153.0/255.0 green:17.0/255.0 blue:21.0/255.0 alpha:1]
#define kKSNavigationTintColorBlack     [UIColor colorWithRed:18.0/255.0 green:17.0/255.0 blue:21.0/255.0 alpha:1]

#define kKSDefaultAccessoryStyle        UITableViewCellAccessoryDisclosureIndicator
//#define kKSDefaultAccessoryStyle        UITableViewCellAccessoryDetailDisclosureButton

// Configs
//
#define kKSSubjectConfigFile            @"subject_config"
#define kKSImageConfigFile              @"image_config"
#define kKSAudioConfigFile              @"audio_config"
#define kKSPDFConfigFile                @"pdf_config"

#define kKSZhFontName                   @"STHeitiSC-Light"
#define kKSZhBoldFontName               @"STHeitiSC-Medium"
#define kKSAlphaFontName                @"Helvetica"
#define kKSAlphaBoldFontName            @"Helvetica-Bold"

#define kKSCategoryKeyAll               @"all"
#define kKSCategoryKeyVowel             @"vowel"
#define kKSCategoryKeyConsonant         @"consonant"
#define kKSCategoryKeySymbol            @"symbol"
#define kKSCategoryKeySound             @"sound"

#define kKSLoopModeAll                  @"all"
#define kKSLoopModeUnit                 @"unit"
#define kKSLoopModeSingle               @"single"

#define kKSContentKeyPronunciation      @"pronunciation"
#define kKSContentKeyVocabulary         @"vocabulary"
#define kKSContentKeyDialog             @"dialog"
#define kKSContentKeySRI                @"stress-rhythm-intonation"
#define kKSContentKeyExpressions        @"expressions"
#define kKSContentKeyWordPairs          @"word-pairs"

#define kKSContentKeyAlphabet           @"alphabet"

#define kKSAudioSessionInterruptionListener @"AudioSessionInterruptionListener"

// Fonts
//
#define kKSDefaultFontName				@"ArialMT"
#define kKSDefaultFontNameBold			@"Arial-BoldMT"

#define kKSFontArial15					[UIFont fontWithName:@"ArialMT" size:15]
#define kKSFontArial17					[UIFont fontWithName:@"ArialMT" size:17]
#define kKSFontArial17Bold				[UIFont fontWithName:@"Arial-BoldMT" size:17]
#define kKSCellDefaultFont              kKSFontArial15

#endif //__KSDEFINE_H__
