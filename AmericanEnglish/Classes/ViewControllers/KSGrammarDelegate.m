//
//  KSGrammarDelegate.m
//  AmericanEnglish
//
//  Created by kesalin on 7/28/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSGrammarDelegate.h"
#import "KSDefine.h"
#import "KSLog.h"
#import "KSViewUtils.h"
#import "KSPdfViewController.h"

@implementation KSGrammarDelegate

- (void) setup
{
    if (!_pdfList)
    {
        KSLog(@" >> setup GrammarDelegate : %@", self.key);

        NSString *path = [[NSBundle mainBundle] pathForResource: kKSPDFConfigFile ofType: @"plist"];
        NSDictionary * contents = [NSDictionary dictionaryWithContentsOfFile:path];
        _pdfList = [[contents objectForKey:@"pdfs"] retain];
        
        for (NSDictionary *fileDict in _pdfList)
            KSLog(@" >> grammar file : %@ - %@", [fileDict objectForKey:@"file"], [fileDict objectForKey:@"title"]);
    }
}

- (void) dealloc
{
    [_pdfList release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark tableView methods

- (NSInteger) tableView:(UITableView *)targetTableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [_pdfList count];
    return count;
}

- (CGFloat) tableView:(UITableView *)targetTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kKSAudioCellDefaultHeight;
}

- (UITableViewCell *) tableView:(UITableView *)targetTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row               = indexPath.row;
    NSDictionary * fileDict     = [_pdfList objectAtIndex:row];
    NSString * titleKey         = [fileDict objectForKey:@"title"];

    UITableViewCell * cell      = [KSViewUtils createDefaultTableViewCell:targetTableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType          = kKSDefaultAccessoryStyle;
    cell.textLabel.text         = KSLocal(titleKey);
    cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.font         = kKSCellDefaultFont;
    
    return cell;
}

- (void) tableView:(UITableView *)targetTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row               = indexPath.row;
    NSDictionary * fileDict     = [_pdfList objectAtIndex:row];
    if (fileDict && [fileDict count] >= 2)
    {
        KSPdfViewController * pdfViewController = [[KSPdfViewController alloc] initWithPdf:fileDict];
        [self.parentViewController pushViewController:pdfViewController animated:YES];
        [pdfViewController release];
    }
}


@end
