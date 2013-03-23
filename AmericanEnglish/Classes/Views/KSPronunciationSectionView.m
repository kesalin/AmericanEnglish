//
//  KSPronunciationSectionView.m
//  AmericanEnglish
//
//  Created by kesalin on 7/29/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSPronunciationSectionView.h"
#import <QuartzCore/QuartzCore.h>

@interface KSPronunciationSectionView(PrivateMethods)

//- (NSString *) titleForPart:(NSInteger)partIndex;
- (NSString *) contentForPart:(NSInteger)partIndex;

@end

@implementation KSPronunciationSectionView

- (void)dealloc
{
    [_textView release];

    [super dealloc];
}

- (void) setupViews
{
    NSString * text     = [self contentForPart:0];

    _textView           = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.editable  = NO;
    _textView.layer.cornerRadius  = 6.0;
    _textView.font      = kKSFontArial17;
    _textView.text      = text;

    [self addSubview:_textView];
}

- (void) layoutSubviews:(UIInterfaceOrientation)orientation
{
    CGRect rect         = _textView.frame;
    rect.size           = self.frame.size;
    _textView.frame     = rect;
}

- (void) refreshContent
{

}

#pragma mark -
#pragma mark PrivateMethods

- (NSString *) contentForPart:(NSInteger)partIndex
{
    NSString * textContent  = [self.sectionInfo.content objectAtIndex:0];
    textContent             = [NSString stringWithFormat:@"txt-%@-S%@-%@", self.sectionInfo.unitKey, self.sectionInfo.key, textContent];
    textContent             = KSLocal(textContent);
    
    return textContent;
}

@end
