//
//  KSRecorderViewController.m
//  AmericanEnglish
//
//  Created by kesalin on 8/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSRecorderViewController.h"


@implementation KSRecorderViewController

@synthesize controller;

+ (KSRecorderViewController *) createKSRecorderViewController:(CGRect)frame;
{
    KSRecorderViewController * recorderCtl = [[KSRecorderViewController alloc] initWithNibName:@"KSRecorderView" bundle:nil];
    recorderCtl.view.frame = frame;
    
    return [recorderCtl autorelease];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) stop
{
    [self.controller stop];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.controller stop];
    self.controller = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
