//
//  KSSectionView.m
//  AmericanEnglish
//
//  Created by kesalin on 7/29/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSSectionView.h"
#import "KSPronunciationSectionView.h"
#import "KSVocabularySectionView.h"
#import "KSExpressionSectionView.h"
#import "KSWordPairsSectionView.h"
#import "KSConversationSectionView.h"
#import "KSTextSectionView.h"
#import "KSImageCache.h"

@implementation KSSectionView

@synthesize sectionInfo = _sectionInfo;

+ (KSSectionView *) createSectionViewFactory:(KSSectionInfo *)info
{
    KSSectionView * sectionView = nil;
    
    if (info.sectionType == KSSectionTypePronunciation)
        sectionView                 = [[KSPronunciationSectionView alloc] initWithSectionInfo:info];
    
    else if (info.sectionType == KSSectionTypeVocabulary)
        sectionView                 = [[KSVocabularySectionView alloc] initWithSectionInfo:info];

    else if (info.sectionType == KSSectionTypeExpression)
        sectionView                 = [[KSExpressionSectionView alloc] initWithSectionInfo:info];

    else if (info.sectionType == KSSectionTypeWordPair)
        sectionView                 = [[KSWordPairsSectionView alloc] initWithSectionInfo:info];

    else if (info.sectionType == KSSectionTypeConversation || info.sectionType == KSSectionTypeDialog)
        sectionView                 = [[KSConversationSectionView alloc] initWithSectionInfo:info];

    else if (info.sectionType == KSSectionTypeTextContent)
        sectionView                 = [[KSTextSectionView alloc] initWithSectionInfo:info];

    else
    {
        sectionView                 = [[KSSectionView alloc] initWithFrame:CGRectZero];
        sectionView.backgroundColor = [UIColor whiteColor];
        UIImageView * imageView     = [[UIImageView alloc] initWithImage:[KSImageCache imageNamed:@"navigation_background"]];
        imageView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [sectionView addSubview:imageView];
        [imageView release];
    }
    
    return sectionView;

}

- (id)initWithSectionInfo:(KSSectionInfo *)info
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        _sectionInfo = [info retain];
        
        [self setupViews];
    }

    return self;
}

- (void)dealloc
{
    [_sectionInfo release];
    
    [super dealloc];
}

- (void) setupViews
{
    
}

- (void) layoutSubviews:(UIInterfaceOrientation)orientation
{
    
}

- (void) refreshContent
{
    
}

@end
