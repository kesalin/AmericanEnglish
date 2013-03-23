//
//  KSVocabularyCheckView.h
//  AmericanEnglish
//
//  Created by kesalin on 7/29/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KSVocabularyCheckView : UITableViewCell
{
    UIButton *      _leftCheckBox;
    UIButton *      _rightCheckBox;
    UILabel *       _leftLabel;
    UILabel *       _rightLabel;
}

@property (nonatomic, retain) IBOutlet UIButton *leftCheckBox;
@property (nonatomic, retain) IBOutlet UIButton *rightCheckBox;
@property (nonatomic, retain) IBOutlet UILabel *leftLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightLabel;

+ (KSVocabularyCheckView *) loadFromNib:(UITableView *)targetTableView;

- (IBAction) leftCheckBoxClicked:(id)sender;
- (IBAction) rightCheckBoxClicked:(id)sender;

@end
