//
//  KSVocabularyCheckView.m
//  AmericanEnglish
//
//  Created by kesalin on 7/29/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSVocabularyCheckView.h"
#import "KSImageCache.h"

@implementation KSVocabularyCheckView

@synthesize leftLabel = _leftLabel;
@synthesize rightLabel = _rightLabel;
@synthesize leftCheckBox = _leftCheckBox;
@synthesize rightCheckBox = _rightCheckBox;

+ (KSVocabularyCheckView *) loadFromNib:(UITableView *)targetTableView
{
    static NSString *defaultReuseIdentifier = @"KSVocabularyCheckView";
    KSVocabularyCheckView *cell = (KSVocabularyCheckView *)[targetTableView dequeueReusableCellWithIdentifier:defaultReuseIdentifier];
    if (cell == nil)
    {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"KSVocabularyCheckView" owner:self options:nil];
        for (id oneObject in objects)
            if ([oneObject isKindOfClass:[KSVocabularyCheckView class]])
                cell = (KSVocabularyCheckView *)oneObject;
    }

    [cell.leftCheckBox setImage:[KSImageCache imageNamed:@"unchecked"] forState:UIControlStateHighlighted];
    [cell.rightCheckBox setImage:[KSImageCache imageNamed:@"unchecked"] forState:UIControlStateHighlighted];
    
    return cell;
}

- (void)dealloc
{
    self.leftCheckBox = nil;
    self.rightCheckBox = nil;
    self.leftLabel = nil;
    self.rightLabel = nil;

    [super dealloc];
}

- (IBAction) leftCheckBoxClicked:(id)sender
{
    [self.rightCheckBox setImage:[KSImageCache imageNamed:@"unchecked"] forState:UIControlStateNormal];
    [self.rightCheckBox setImage:[KSImageCache imageNamed:@"unchecked"] forState:UIControlStateHighlighted];
    [self.leftCheckBox setImage:[KSImageCache imageNamed:@"checked"] forState:UIControlStateNormal];
    [self.leftCheckBox setImage:[KSImageCache imageNamed:@"checked"] forState:UIControlStateHighlighted];
}

- (IBAction) rightCheckBoxClicked:(id)sender
{
    [self.leftCheckBox setImage:[KSImageCache imageNamed:@"unchecked"] forState:UIControlStateNormal];
    [self.leftCheckBox setImage:[KSImageCache imageNamed:@"unchecked"] forState:UIControlStateHighlighted];
    [self.rightCheckBox setImage:[KSImageCache imageNamed:@"checked"] forState:UIControlStateNormal];
    [self.rightCheckBox setImage:[KSImageCache imageNamed:@"checked"] forState:UIControlStateHighlighted];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    if (CGRectContainsPoint(self.leftLabel.frame, point))
        [self leftCheckBoxClicked:nil];    
    else if (CGRectContainsPoint(self.rightLabel.frame, point)) 
        [self rightCheckBoxClicked:nil];
}

@end
