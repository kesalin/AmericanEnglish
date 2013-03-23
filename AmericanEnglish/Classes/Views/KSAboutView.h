//
//  KSAboutView.h
//  AmericanEnglish
//
//  Created by kesalin on 8/6/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KSAboutView : UIView
{
    UITextView * _textView;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;

+ (KSAboutView *) loadFromNib;

@end
