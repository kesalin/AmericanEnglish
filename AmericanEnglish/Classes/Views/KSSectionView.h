//
//  KSSectionView.h
//  AmericanEnglish
//
//  Created by kesalin on 7/29/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSSectionInfo.h"
#import "KSDefine.h"
#import "KSLog.h"

@interface KSSectionView : UIView
{
    KSSectionInfo * _sectionInfo;
}

@property (nonatomic, retain) KSSectionInfo * sectionInfo;

+ (KSSectionView *) createSectionViewFactory:(KSSectionInfo *)info;

- (id) initWithSectionInfo:(KSSectionInfo *) info;

- (void) setupViews;

- (void) layoutSubviews:(UIInterfaceOrientation)orientation;

- (void) refreshContent;

@end
