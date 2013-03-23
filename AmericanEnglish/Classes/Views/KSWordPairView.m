//
//  KSWordPairView.m
//  AmericanEnglish
//
//  Created by kesalin on 8/1/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSWordPairView.h"

@implementation KSWordPairView

@synthesize leftLabel = _leftLabel;
@synthesize rightLabel = _rightLabel;

+ (KSWordPairView *) loadFromNib:(UITableView *)targetTableView
{
    static NSString *defaultReuseIdentifier = @"KSWordPairView";
    KSWordPairView *cell = (KSWordPairView *)[targetTableView dequeueReusableCellWithIdentifier:defaultReuseIdentifier];
    if (cell == nil)
    {   
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"KSWordPairView" owner:self options:nil];
        for (id oneObject in objects)
            if ([oneObject isKindOfClass:[KSWordPairView class]])
                cell = (KSWordPairView *)oneObject;
    }

    return cell;
}

- (void)dealloc
{
    self.leftLabel = nil;
    self.rightLabel = nil;

    [super dealloc];
}

@end
