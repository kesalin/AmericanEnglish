//
//  KSBaseView.h
//  KSFramework
//
//  Created by kesalin on 7/1/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSUtilities.h"

@interface KSTableViewCell : UITableViewCell
{
    KSGradientColorType     _gradientColorType;
}

@property (nonatomic, assign) KSGradientColorType gradientColorType;

@end
