//
//  KSWordPairsSectionView.h
//  AmericanEnglish
//
//  Created by kesalin on 8/1/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSSectionView.h"

@interface KSWordPairsSectionView : KSSectionView <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *       _tableView;
}
@end
