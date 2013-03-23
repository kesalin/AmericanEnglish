//
//  KSAudiosCategoryDelegate.m
//  AmericanEnglish
//
//  Created by kesalin on 11-7-24.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSAudiosCategoryDelegate.h"
#import "KSAudioConfig.h"
#import "KSDefine.h"
#import "KSLog.h"
#import "KSViewUtils.h"
#import "KSMP3PlayerController.h"
#import "KSSectionInfo.h"
#import "KSUtilities.h"
#import "KSImageCache.h"

@interface KSAudiosCategoryDelegate(PrivateMethods)

- (void) setupRightBarItem;
- (NSString *) titleForLoopMode:(KSLoopMode)mode;

- (void) setupAndPlay:(NSInteger)section withRow:(NSInteger)row forcePlay:(BOOL)forcePlay;
- (void) updateToNext;
- (void) updateToPrev;
@end

@implementation KSAudiosCategoryDelegate

#pragma mark -
#pragma mark Liftcycle

- (void) setup
{
    if (!allUnits)
    {
        // setup right navigation bar item
        //
        _currentLoopMode = eKSLoopModeCount;
        [self setupRightBarItem];

        KSAudioConfig *audioConfig = [KSAudioConfig sharedInstance];
        allUnits = [[audioConfig unitsForCategory:self.key] retain];
        
        // setup section titles
        //
        NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:[allUnits count]];
        for (KSUnitInfo *unit in allUnits)
        {
            // unit-01
            NSInteger unitNum = [KSUtilities unitNumberOf:unit.key];
            NSString *title = [NSString stringWithFormat:@"%d", unitNum];
            
            [titles addObject:title];
        }
        
        sectionTitles = [[NSArray alloc] initWithArray:titles];
        [titles release];

#ifdef KSDEBUG        
        KSLog(@" >> %@ : load config, parts count %d", self.key, [allUnits count]);
        NSInteger index  = 0;
        for (KSUnitInfo * unit in allUnits)
            KSLog(@"    %d, %@, %@, section count %d", index++, unit.key, unit.title, [unit.sections count]);
#endif
    }
    
    _currentUnit        = 0;
    _currentSection     = 0;
}

- (void) dealloc
{
    [sectionTitles release];
    [allUnits release];
    
    [super dealloc];
}

- (KSSectionInfo *) currentSectionInfo
{
    KSSectionInfo * sectionInfo = nil;
    if (_currentUnit >= 0 && _currentSection >= 0)
    {
        KSUnitInfo * unitInfo       = [allUnits objectAtIndex:_currentUnit];
        sectionInfo = [unitInfo.sections objectAtIndex:_currentSection];
    }
    
    return sectionInfo;
}

#pragma mark -
#pragma mark tableView methods

- (NSString *)tableView:(UITableView *)targetTableView titleForHeaderInSection:(NSInteger)section
{
    KSUnitInfo * unitInfo   = [allUnits objectAtIndex:section];
    NSString * title        = KSLocal(unitInfo.title);
    
    return title;
}

- (CGFloat)tableView:(UITableView *)targetTableView heightForHeaderInSection:(NSInteger)section
{
    return kKSAudioSectionHeaderDefaultHeight;
}

// return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)targetTableView
{
    return sectionTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)targetTableView
{
    return [allUnits count];
}

- (NSInteger) tableView:(UITableView *)targetTableView numberOfRowsInSection:(NSInteger)section
{
    KSUnitInfo * unitInfo   = [allUnits objectAtIndex:section];
    NSInteger sectionCount  = [unitInfo.sections count]; 
    
    return sectionCount;
}

- (CGFloat) tableView:(UITableView *)targetTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kKSAudioCellDefaultHeight;
}

- (UITableViewCell *) tableView:(UITableView *)targetTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section           = indexPath.section;
    NSInteger row               = indexPath.row;
    KSUnitInfo * unitInfo       = [allUnits objectAtIndex:section];
    KSSectionInfo * sectionInfo = [unitInfo.sections objectAtIndex:row];
    
    UITableViewCell * cell      = [KSViewUtils createDefaultTableViewCell:targetTableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
    
    NSString * cellInfo         = KSLocal(sectionInfo.title);
    cell.textLabel.text         = cellInfo;
    cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.font         = kKSCellDefaultFont;

    if (section == _currentUnit && row == _currentSection)
        cell.imageView.image    = [KSImageCache imageNamed:@"selected"];
    else
        cell.imageView.image    = [KSImageCache imageNamed:@"unselected"];
    
    return cell;
}

- (void) tableView:(UITableView *)targetTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.parentViewController mp3PlayerExists])
        return;

    _currentUnit                = indexPath.section;
    _currentSection             = indexPath.row;
    
    [self.parentViewController.tableView reloadData];
    [self setupAndPlay:_currentUnit withRow:_currentSection forcePlay:YES];
}

#pragma mark
#pragma mark MP3PlayerController Delegate

- (void) audioPlayerDidFinishPlaying:(KSMP3PlayerController *)mp3PlayerController
{
    if (![self.parentViewController mp3PlayerExists])
        return;
    
    [self updateToNext];
    
    [self setupAndPlay:_currentUnit withRow:_currentSection forcePlay:YES];
}

- (void) audioPlayerNextButtonPressed:(KSMP3PlayerController *)mp3PlayerController
{
    if (![self.parentViewController mp3PlayerExists])
        return;

    [self updateToNext];
    
    [self setupAndPlay:_currentUnit withRow:_currentSection forcePlay:NO];
}

- (void) audioPlayerPrevButtonPressed:(KSMP3PlayerController *)mp3PlayerController
{
    if (![self.parentViewController mp3PlayerExists])
        return;

    [self updateToPrev];

    [self setupAndPlay:_currentUnit withRow:_currentSection forcePlay:NO];
}

#pragma mark -
#pragma mark Navigation bar item.

- (NSString *) titleForLoopMode:(KSLoopMode)mode
{
    NSString *title = nil;
    switch (mode) {
        case eKSLoopModeAll:
            title   = KSLocal(@"txt-loop-mode-all");
            break;
        
        case eKSLoopModeUnit:
            title   = KSLocal(@"txt-loop-mode-unit");
            break;
            
        case eKSLoopModeSingle:
            title   = KSLocal(@"txt-loop-mode-single");
            break;
    }
    
    return title;
}

- (void) setupRightBarItem
{
    NSString * loopMode = [self.config objectForKey:@"loop_mode"];
    if (!KSIsNullOrEmpty(loopMode))
    {
        _currentLoopMode = eKSLoopModeAll;
        if ([loopMode isEqualToString:kKSLoopModeUnit])
            _currentLoopMode = eKSLoopModeUnit;
        else if ([loopMode isEqualToString:kKSLoopModeSingle])
            _currentLoopMode = eKSLoopModeSingle;
    
        self.parentViewController.rightItemTitle = [self titleForLoopMode:_currentLoopMode];
    }
}

- (void)rightItemButtonTouched:(id)sender
{
    KSLog(@" >> rightItemButtonTouched");
    
    if (++ _currentLoopMode >= eKSLoopModeCount)
        _currentLoopMode = 0;
    
    self.parentViewController.rightItemTitle = [self titleForLoopMode:_currentLoopMode];
}

#pragma mark -
#pragma mark PrivateMethods

- (void) setupAndPlay:(NSInteger)section withRow:(NSInteger)row forcePlay:(BOOL)forcePlay
{
    if (![self.parentViewController mp3PlayerExists])
        return;
    
    //KSLog(@" >> setup and play Unit %d, section %d", section, row);

    NSIndexPath *indexPath              = [NSIndexPath indexPathForRow:row inSection:section];
    [self.parentViewController.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [self.parentViewController.tableView reloadData];
    
    KSUnitInfo * unitInfo               = [allUnits objectAtIndex:section];
    KSSectionInfo * sectionInfo         = [unitInfo.sections objectAtIndex:row];
    
    KSMP3PlayerController *mp3Player    = self.parentViewController.mp3PlayerController;
    BOOL isPlaying                      = [mp3Player isPlaying];
    
    [mp3Player setupMP3Info:sectionInfo displayUnit:YES];
    if (forcePlay || isPlaying)
        [mp3Player play];
}

- (void) updateToNext
{
    if (_currentLoopMode == eKSLoopModeAll)
    {
        KSUnitInfo * unitInfo       = [allUnits objectAtIndex:_currentUnit];
        if (_currentSection < [unitInfo.sections count] - 1)
        {
            _currentSection         += 1;
        }
        else
        {
            _currentSection         = 0;
            _currentUnit            += 1;
            
            if (_currentUnit >= [allUnits count])
                _currentUnit        = 0;        
        }
    }
    
    else if (_currentLoopMode == eKSLoopModeUnit) 
    {
        KSUnitInfo * unitInfo       = [allUnits objectAtIndex:_currentUnit];
        if (_currentSection < [unitInfo.sections count] - 1)
            _currentSection         += 1;
        else
            _currentSection         = 0;
    }
}

- (void) updateToPrev
{
    if (_currentLoopMode == eKSLoopModeAll)
    {
        if (_currentSection > 0)
        {
            _currentSection         -= 1;
        }
        else
        {
            if (_currentUnit > 0)
                _currentUnit        -= 1;
            else
                _currentUnit        = [allUnits count] - 1;
            
            KSUnitInfo * unitInfo   = [allUnits objectAtIndex:_currentUnit];
            _currentSection         = [unitInfo.sections count] - 1;
        }
    }
    
    else if (_currentLoopMode == eKSLoopModeUnit) 
    {
        KSUnitInfo * unitInfo       = [allUnits objectAtIndex:_currentUnit];
        if (_currentSection > 0)
            _currentSection         -= 1;
        else
            _currentSection         = [unitInfo.sections count] - 1;
    }
}

@end
