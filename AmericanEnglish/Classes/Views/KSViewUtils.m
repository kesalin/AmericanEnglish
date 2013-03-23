//
//  KSViewUtils.m
//  AmericanEnglish
//
//  Created by kesalin on 7/20/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSViewUtils.h"
#import "KSBaseView.h"

@implementation KSViewUtils

+ (UITableViewCell *) createDefaultTableViewCell:(UITableView *)targetTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 0    
    static NSString *defaultReuseIdentifier = @"KSDefaultTableViewCell";
    KSTableViewCell *cell = (KSTableViewCell *)[targetTableView dequeueReusableCellWithIdentifier:defaultReuseIdentifier];
    if (cell == nil)
        cell = [[[KSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultReuseIdentifier] autorelease];
    cell.gradientColorType = KSGradientColorWhite;
#else
    static NSString *defaultReuseIdentifier = @"KSDefaultTableViewCell";
    UITableViewCell *cell = (UITableViewCell *)[targetTableView dequeueReusableCellWithIdentifier:defaultReuseIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultReuseIdentifier] autorelease];
#endif

    return cell;
}

@end
