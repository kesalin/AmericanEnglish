//
//  KSExpressionSectionView.m
//  AmericanEnglish
//
//  Created by kesalin on 8/1/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSExpressionSectionView.h"
#import "KSViewUtils.h"

@interface KSExpressionSectionView(PrivateMethods)

- (NSString *) titleForPart:(NSInteger)partIndex;
- (NSArray *) expressionsForPart:(NSInteger)partIndex;

@end


@implementation KSExpressionSectionView


- (void)dealloc
{
    [_tableView release];
    
    [super dealloc];
}

- (void) setupViews
{
    KSLog(@" >> %@ setupViews", self.sectionInfo.title);
    
    _tableView              = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate     = self;
    _tableView.dataSource   = self;
    
    [self addSubview:_tableView];
}

- (void) layoutSubviews:(UIInterfaceOrientation)orientation
{
    CGRect rect         = _tableView.frame;
    rect.size           = self.frame.size;
    _tableView.frame    = rect;
}

- (void) refreshContent
{
    [_tableView reloadData];
}


- (NSString *) titleForPart:(NSInteger)partIndex
{
    NSDictionary *part  = [self.sectionInfo.content objectAtIndex:partIndex];
    NSString *partTitle = [part objectForKey:@"title"];
    partTitle           = [NSString stringWithFormat:@"txt-%@-S%@-%@", self.sectionInfo.unitKey, self.sectionInfo.key, partTitle];
    partTitle           = KSLocal(partTitle);
    
    return partTitle;
}

- (NSArray *) expressionsForPart:(NSInteger)partIndex
{
    NSDictionary *part  = [self.sectionInfo.content objectAtIndex:partIndex];
    NSString *exprStr   = [part objectForKey:@"content"];
    exprStr             = [NSString stringWithFormat:@"txt-%@-S%@-%@", self.sectionInfo.unitKey, self.sectionInfo.key, exprStr];
    exprStr             = KSLocal(exprStr);
    NSArray *expressions  = [exprStr componentsSeparatedByString:@"|"];
    
    return expressions;
}

#pragma mark -
#pragma mark tableView methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView; 
{
    NSInteger count = [self.sectionInfo.content count];
    return count;
}

//- (UIView *)          tableView:(UITableView *)targetTableView viewForHeaderInSection:(NSInteger)section
//{
//    return nil;
//}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *partTitle = [self titleForPart:section];
    
    return partTitle;
}

- (NSInteger) tableView:(UITableView *)targetTableView numberOfRowsInSection:  (NSInteger)section
{
    NSArray *expressions  = [self expressionsForPart:section];
    return [expressions count];
}

- (CGFloat) tableView:(UITableView *)targetTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kKSAudioCellDefaultHeight;
}

- (UITableViewCell *) tableView:(UITableView *)targetTableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath
{
    NSInteger section   = indexPath.section;
    NSInteger row       = indexPath.row;

    NSArray *wordsList  = [self expressionsForPart:section];
    
    UITableViewCell * cell = nil;
    cell                        = [KSViewUtils createDefaultTableViewCell:targetTableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font         = kKSFontArial15;
    cell.textLabel.text         = [wordsList objectAtIndex:row];
    
    return cell;
}

- (void) tableView:(UITableView *)targetTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
