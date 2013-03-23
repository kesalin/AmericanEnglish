//
//  KSUnitsCategoryDelegate.m
//  AmericanEnglish
//
//  Created by kesalin on 7/25/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSUnitsCategoryDelegate.h"
#import "KSDefine.h"
#import "KSLog.h"
#import "KSViewUtils.h"
#import "KSSectionInfo.h"
#import "KSAudioConfig.h"
#import "KSUtilities.h"
#import "KSImageCache.h"
#import "KSUnitDetailViewController.h"

@interface KSUnitsCategoryDelegate(PrivateMethods)

@end

@implementation KSUnitsCategoryDelegate

- (void) setup
{
    if (!allUnits)
    {        
        KSAudioConfig *audioConfig = [KSAudioConfig sharedInstance];
		allUnits = [[audioConfig unitsForCategory:self.key] retain];

        
#ifdef KSDEBUG        
        KSLog(@" >> %@ : load config, parts count %d", self.key, [allUnits count]);
        NSInteger index  = 0;
        for (KSUnitInfo * unit in allUnits)
            KSLog(@"    %d, %@, %@, section count %d", index++, unit.key, unit.title, [unit.sections count]);
#endif
    }
    
    _currentUnit        = -1;
}

- (void) dealloc
{
    [allUnits release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark tableView methods

- (NSInteger) tableView:(UITableView *)targetTableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [allUnits count];
    return count;
}

- (CGFloat) tableView:(UITableView *)targetTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kKSAudioCellDefaultHeight;
}

- (UITableViewCell *) tableView:(UITableView *)targetTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row               = indexPath.row;
    KSUnitInfo * unitInfo       = [allUnits objectAtIndex:row];
    
    UITableViewCell * cell      = [KSViewUtils createDefaultTableViewCell:targetTableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType          = kKSDefaultAccessoryStyle;
    cell.textLabel.text         = KSLocal(unitInfo.title);
    cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.font         = kKSCellDefaultFont;
    
    return cell;
}

- (void) tableView:(UITableView *)targetTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentUnit                = indexPath.row;
    KSUnitInfo * unitInfo       = [allUnits objectAtIndex:_currentUnit];
    if (unitInfo)
    {
        KSUnitDetailViewController *unitDetailViewController = [[KSUnitDetailViewController alloc] initWithUnitInfo:unitInfo];
        [self.parentViewController pushViewController:unitDetailViewController animated:YES];
        [unitDetailViewController release];
    }
}

#pragma mark -
#pragma mark PrivateMethods

- (KSSectionInfo *) currentSectionInfo
{
    KSSectionInfo * sectionInfo = nil;
    if (_currentUnit >= 0)
    {
        KSUnitInfo * unitInfo       = [allUnits objectAtIndex:_currentUnit];
        sectionInfo = [unitInfo.sections objectAtIndex:0];
    }
    
    return sectionInfo;
}

@end
