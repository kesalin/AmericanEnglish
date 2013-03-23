//
//  KSWordPairView.h
//  AmericanEnglish
//
//  Created by kesalin on 8/1/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KSWordPairView : UITableViewCell
{
    UILabel *   _leftLabel;
    UILabel *   _rightLabel;
}

@property (nonatomic, retain) IBOutlet UILabel * leftLabel;
@property (nonatomic, retain) IBOutlet UILabel * rightLabel;

+ (KSWordPairView *) loadFromNib:(UITableView *)targetTableView;

@end
