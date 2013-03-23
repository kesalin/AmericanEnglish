//
//  KSAboutView.m
//  AmericanEnglish
//
//  Created by kesalin on 8/6/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSAboutView.h"


@implementation KSAboutView

@synthesize textView;

+ (KSAboutView *) loadFromNib
{
    KSAboutView * aboutView = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"KSAboutView" owner:self options:nil];
    for (id oneObject in objects)
        if ([oneObject isKindOfClass:[KSAboutView class]])
            aboutView = (KSAboutView *)oneObject;
    
    return aboutView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    self.textView = nil;

    [super dealloc];
}

@end
