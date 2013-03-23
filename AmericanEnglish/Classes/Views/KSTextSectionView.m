//
//  KSTextSectionView.m
//  AmericanEnglish
//
//  Created by Simon on 8/22/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSTextSectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "KSUtilities.h"

@interface KSTextSectionView(PrivateMethods)

- (NSString *) textContent;

@end


@implementation KSTextSectionView


- (void)dealloc
{
    [_textView release];
    
    [super dealloc];
}

- (void) setupViews
{
    NSString * text     = [self textContent];
    
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

- (NSString *) textContent
{
    NSMutableString * text  = [[NSMutableString alloc] init];
    NSInteger index         = 1;
    for (NSDictionary * content in self.sectionInfo.content)
    {
        NSString *indexStr  = [KSUtilities stringOfNumber:index];
        NSString *titleKey  = [NSString stringWithFormat:@"txt-%@-S%@-%@-title", self.sectionInfo.unitKey, self.sectionInfo.key, indexStr];
        NSString *contentKey= [NSString stringWithFormat:@"txt-%@-S%@-%@-content", self.sectionInfo.unitKey, self.sectionInfo.key, indexStr];

        [text appendFormat:@"%@", KSLocal(titleKey)];
        [text appendFormat:@"\n\n"];
        [text appendFormat:@"%@", KSLocal(contentKey)];
        [text appendFormat:@"\n\n\n"];
        
        ++index;
    }

    return [text autorelease];
}


@end
