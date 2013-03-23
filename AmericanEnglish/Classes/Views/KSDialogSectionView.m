//
//  KSDialogSectionView.m
//  AmericanEnglish
//
//  Created by kesalin on 8/1/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSDialogSectionView.h"


@implementation KSDialogSectionView

- (void)dealloc
{
    [_textView release];

    [super dealloc];
}

- (void) setupViews
{
    NSString * textkey      = [self.sectionInfo.content objectAtIndex:0];
    _textView               = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.editable      = NO;
    _textView.font          = kKSFontArial17;
    _textView.text          = KSLocal(textkey);
    
    [self addSubview:_textView];
}

- (void) layoutSubviews:(UIInterfaceOrientation)orientation
{
    CGRect rect         = _textView.frame;
    rect.size           = self.frame.size;
    _textView.frame     = rect;
}


@end
