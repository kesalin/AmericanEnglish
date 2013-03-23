//
//  KSVocabularySectionView.m
//  AmericanEnglish
//
//  Created by kesalin on 7/29/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSVocabularySectionView.h"
#import "KSViewUtils.h"
#import "KSVocabularyCheckView.h"
#import "KSWordPairView.h"

@interface KSVocabularySectionView(PrivateMethods)

- (NSString *) titleForPart:(NSInteger)partIndex;
- (NSArray *) wordsForPart:(NSInteger)partIndex;

@end

@implementation KSVocabularySectionView


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

- (NSArray *) wordsForPart:(NSInteger)partIndex
{
    NSDictionary *part  = [self.sectionInfo.content objectAtIndex:partIndex];
    NSString *wordsStr  = [part objectForKey:@"content"];
    wordsStr            = [NSString stringWithFormat:@"txt-%@-S%@-%@", self.sectionInfo.unitKey, self.sectionInfo.key, wordsStr];
    wordsStr            = KSLocal(wordsStr);
    NSArray *wordsList  = [wordsStr componentsSeparatedByString:@","];
    
    return wordsList;
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
    NSDictionary *part  = [self.sectionInfo.content objectAtIndex:section];
    BOOL isOneLine      = [[part objectForKey:@"is-one-line"] boolValue];
    NSArray *wordsList  = [self wordsForPart:section];
    
    NSInteger count     = [wordsList count];
    if (!isOneLine)
        count           = (NSInteger)(ceilf(count/2.0));

    return count;
}

- (CGFloat) tableView:(UITableView *)targetTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kKSAudioCellDefaultHeight;
}

- (UITableViewCell *) tableView:(UITableView *)targetTableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath
{
    NSInteger section   = indexPath.section;
    NSInteger row       = indexPath.row;

    NSDictionary *part  = [self.sectionInfo.content objectAtIndex:section];
    BOOL isCheckBox     = [[part objectForKey:@"checkbox"] boolValue];
    NSArray *wordsList  = [self wordsForPart:section];
    
    UITableViewCell * cell = nil;
    if (isCheckBox)
    {
        NSString *wordsPair             = [wordsList objectAtIndex:row];
        NSArray *wordsPairList          = [wordsPair componentsSeparatedByString:@"|"];
        KSVocabularyCheckView * checkCell = [KSVocabularyCheckView loadFromNib:targetTableView];
        checkCell.leftLabel.text        = [wordsPairList objectAtIndex:0];
        checkCell.rightLabel.text       = [wordsPairList objectAtIndex:1];
        
        cell                            = checkCell;
        cell.selectionStyle             = UITableViewCellSelectionStyleNone;
    }
    else
    {   
        BOOL isOneLine                  = [[part objectForKey:@"is-one-line"] boolValue];
        
        if (isOneLine)
        {
            NSString *text1             = [wordsList objectAtIndex:row];
            text1                       = [text1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            cell                        = [KSViewUtils createDefaultTableViewCell:targetTableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text         = text1;
            
            cell.textLabel.font         = kKSFontArial15;
        }
        else
        {
            KSWordPairView * wordPaircell   = [KSWordPairView loadFromNib:targetTableView];
            
            NSString *text1                 = [wordsList objectAtIndex:(row * 2)];
            text1                           = [text1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            wordPaircell.leftLabel.text     = text1;
            
            if ((row * 2 + 1) < [wordsList count])
            {
                NSString *text2                 = [wordsList objectAtIndex:(row * 2 + 1)];
                text2                           = [text2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                wordPaircell.rightLabel.text    = text2;
            }
            
            cell                            = wordPaircell;
        }

        cell.selectionStyle             = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)targetTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
