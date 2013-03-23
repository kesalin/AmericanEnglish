//
//  KSConversationSectionView.m
//  AmericanEnglish
//
//  Created by kesalin on 8/8/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSConversationSectionView.h"
#import "KSLog.h"
#import <QuartzCore/QuartzCore.h>
#import "KSUtilities.h"

@interface KSConversationSectionView(PrivateMethod)


@end

@implementation KSConversationSectionView

- (void)dealloc
{
    [_textView release];
    
    [super dealloc];
}

- (void) setupViews
{
	KSLog(@" >> %@ setupViews", self.sectionInfo.title);
	
    _textView               = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.editable      = NO;
    _textView.layer.cornerRadius  = 6.0;
    _textView.font          = kKSFontArial17;
    
    [self addSubview:_textView];
    
    // setup text
    //
    NSMutableString * string = [[NSMutableString alloc] init];
    NSInteger partIndex = 1;
    BOOL isLastNewLine  = NO;
    for (NSDictionary * part in self.sectionInfo.content)
    {
        NSString * titleKey     = [part objectForKey:@"title"];
        titleKey                = [NSString stringWithFormat:@"txt-%@-S%@-%@", self.sectionInfo.unitKey, self.sectionInfo.key, titleKey];
        titleKey                = KSLocal(titleKey);
        
        [string appendFormat:@"%@\n\n", titleKey];
        
        NSString * contentKey   = [part objectForKey:@"content"];
        contentKey              = [NSString stringWithFormat:@"txt-%@-S%@-%@", self.sectionInfo.unitKey, self.sectionInfo.key, contentKey];
        contentKey              = KSLocal(contentKey);
        
        CGSize size             = CGSizeFromString(contentKey);
        
        NSInteger step          = 4;
        NSNumber *stepNum       = [part objectForKey:@"step"];
        if (stepNum)
            step = [stepNum intValue];

        // txt-unit-04-SF-01-01
        NSString *sectionStr    = [NSString stringWithFormat:@"txt-%@-S%@-%@-", self.sectionInfo.unitKey, self.sectionInfo.key, [KSUtilities stringOfNumber:partIndex]]; 
        for (NSInteger i = 0, index = size.width; index <= size.height; i++, index++)
        {
            NSString *format    = [KSUtilities stringOfNumber:index];
            format              = [NSString stringWithFormat:@"%@%@", sectionStr, format];
            format              = KSLocal(format);
            [string appendFormat:@"%@\n", format];
            
            isLastNewLine = NO;
            if (((i + 1) % step) == 0)
            {
                [string appendString:@"\n"];
                isLastNewLine = YES;
            }
        }
        
        if (!isLastNewLine)
            [string appendString:@"\n"];
        
        ++partIndex;
    }
    
    _textView.text          = string;
    [string release];    
}

- (void) layoutSubviews:(UIInterfaceOrientation)orientation
{
    CGRect rect         = _textView.frame;
    rect.size           = self.frame.size;
    _textView.frame     = rect;
}

@end
