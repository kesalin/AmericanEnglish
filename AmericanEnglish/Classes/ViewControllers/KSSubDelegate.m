//
//  KSSubDelegate.m
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSSubDelegate.h"

@implementation KSSubDelegate

@synthesize config = _config;
@synthesize key = _key;
@synthesize parentViewController = _parentViewController;

- (id)initWithController:(KSTabViewController *) parentController withKey:(NSDictionary *)navItemConfig
{
    self = [super init];
    if (self)
    {
        _config = [navItemConfig retain];
        _key = [[NSString alloc] initWithString:[navItemConfig objectForKey:@"key"]];
        _parentViewController = parentController;
        
        [self setup];
    }
    
    return self;
}

- (void) dealloc
{
    [_config release];
    [_key release];

    [super dealloc];
}

- (void) setup
{
    
}

- (void) viewDidUnload
{
}

- (void) viewWillAppear
{
}

- (void) viewDidAppear
{
}

- (void) viewWillDisappear
{
}

- (void) viewDidDisappear
{
}

- (void)rightItemButtonTouched:(id)sender
{

}

- (KSSectionInfo *) currentSectionInfo
{
    return nil;
}

#pragma mark -
#pragma mark tableView methods

- (UIView *)          tableView:(UITableView *)targetTableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)         tableView:(UITableView *)targetTableView numberOfRowsInSection:  (NSInteger)section
{
    return 0;
}

- (CGFloat)           tableView:(UITableView *)targetTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)targetTableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath
{
    return nil;
}

- (void)              tableView:(UITableView *)targetTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
