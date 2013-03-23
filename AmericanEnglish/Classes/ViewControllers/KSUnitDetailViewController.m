//
//  KSUnitDetailViewController.m
//  AmericanEnglish
//
//  Created by kesalin on 7/25/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSUnitDetailViewController.h"
#import "KSMP3PlayerController.h"
#import "KSSectionInfo.h"
#import "KSDefine.h"
#import "KSLog.h"
#import "KSSectionView.h"
#import "KSPronunciationSectionView.h"

@interface KSUnitDetailViewController(PrivateMethods)

- (void) pageChanged:(id)sender;
- (void) layoutViews:(UIInterfaceOrientation)interfaceOrientation;
- (void) layoutSectionViews:(UIInterfaceOrientation)interfaceOrientation;

- (void) setupRightBarItem;
- (NSString *) titleForLoopMode:(KSPlayMode)mode;
- (void) steupMP3Info:(KSSectionInfo *)info;

@end

@implementation KSUnitDetailViewController

- (id)initWithUnitInfo:(KSUnitInfo *)info
{
    self = [super init];
    if (self)
    {
        _unitInfo           = [info retain];
        self.title          = KSLocal(_unitInfo.title);
        
        _pageCount          = [_unitInfo.sections count];
        
        _pageCount          = 0;
        for (KSSectionInfo * info in _unitInfo.sections)
        {
#ifndef Display_All_Sections_In_Unit
            if (info.sectionType != KSSectionTypeNone)
                _pageCount++;
#else
            _pageCount++;
#endif
        }
        
        _sectionViews       = [[NSMutableArray alloc] initWithCapacity:_pageCount];
        
        _isWithMP3Player    = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [_sectionViews release];
    [_scrollView release];
    [_pageControl release];

    [_mp3PlayerController release];
    [_unitInfo release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    KSLog(@" >> %@, viewWillAppear", self.title);
    
    [super viewWillAppear:animated];

    [self setTabBarHidden:YES animated:animated];

    [self layoutViews:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    KSLog(@" >> %@, viewDidAppear", self.title);
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@" >> %@, viewWillDisappear", self.title);
    
    [super viewWillDisappear:animated];
    
    if (_mp3PlayerController)
        [_mp3PlayerController stop];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@" >> %@, viewDidDisappear", self.title);
    
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Views

- (void)loadView
{    
    UIView *ksView          = [[UIView alloc] initWithFrame:CGRectZero];
    ksView.backgroundColor  = [UIColor blackColor];
    self.view               = ksView;
    [ksView release];
    
    // setup right bar item
    //
    [self setupRightBarItem];
    
    // create mp3player
    //
    if (_isWithMP3Player)
    {
        CGRect rect                     = CGRectMake(0, 0, kKSAppWidth, kKSMP3PlayerHeight);
        _mp3PlayerController            = [[KSMP3PlayerController createMP3PlayerController:rect] retain];
        _mp3PlayerController.delegate   = self;
        [self.view addSubview:_mp3PlayerController.view];
    }

    // create scroll view
    //
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.pagingEnabled = YES;    // a page is the width of the scroll view
    _scrollView.scrollEnabled = YES;
    _scrollView.backgroundColor = [UIColor grayColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    
    // setup subviews of scrollView
    //
    BOOL isFirstSection = YES;
    for (KSSectionInfo * info in _unitInfo.sections)
    {
#ifndef Display_All_Sections_In_Unit        
        if (info.sectionType == KSSectionTypeNone)
            continue;
#endif
        
        if (isFirstSection && _mp3PlayerController)
        {
            isFirstSection = NO;
            
            [self steupMP3Info:info];
        }

        KSSectionView *sectionView = [KSSectionView createSectionViewFactory:info];
        [sectionView refreshContent];

        [_sectionViews addObject:sectionView];
        [_scrollView addSubview:sectionView];
    }
    
    [self.view addSubview:_scrollView];

    // create page control
    //
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    _pageControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_pageControl];
}

- (void) layoutSectionViews:(UIInterfaceOrientation)interfaceOrientation
{
    CGRect frameRect    = self.view.frame;
    CGRect rect         = CGRectMake(0, 0, frameRect.size.width, _scrollView.frame.size.height);
    CGFloat xOffset     = 0;
    
    for (UIView * view in _sectionViews)
    {
        rect.origin.x   = xOffset;
        view.frame      = rect;
        xOffset         += rect.size.width;
        
        if ([view isKindOfClass:[KSSectionView class]])
        {
            [((KSSectionView *)view) layoutSubviews:interfaceOrientation];
        }
    }
}

- (void)layoutViews:(UIInterfaceOrientation)interfaceOrientation
{
    CGRect frameRect                = self.view.frame;
    CGRect rect                     = CGRectMake(0, 0, frameRect.size.width, 0);

    if (_isWithMP3Player)
    {
        rect.size.height    = kKSMP3PlayerHeight;
        _mp3PlayerController.view.frame = rect;
        rect.origin.y       += rect.size.height;
    }
    
    CGSize pageCtlSize  = [_pageControl sizeForNumberOfPages:_pageCount];

    rect.size.height    = (frameRect.size.height -  (_isWithMP3Player ? kKSMP3PlayerHeight : 0) - pageCtlSize.height);
    _scrollView.frame   = rect;
    _scrollView.contentSize = CGSizeMake(rect.size.width * _pageCount, rect.size.height);
    
    [self layoutSectionViews:interfaceOrientation];
    
    rect.origin.x       = (frameRect.size.width - pageCtlSize.width)/2;
    rect.origin.y       += rect.size.height;
    rect.size           = pageCtlSize;
    _pageControl.frame  = rect;
    _pageControl.numberOfPages = _pageCount;
    
    KSLog(@" >> page control (%.2f, %.2f) - (%.2f, %.2f)",
          rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

#pragma mark -
#pragma mark ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)sender
{    
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
    
    KSSectionView * sectionView = [_sectionViews objectAtIndex:page];
    [sectionView refreshContent];
    
    if (_mp3PlayerController)
    {
        KSSectionInfo *currentSection = [_unitInfo.sections objectAtIndex:page];
        
        NSInteger index = 0;
        for (KSSectionInfo * info in _unitInfo.sections)
        {
#ifndef Display_All_Sections_In_Unit
            if (info.sectionType == KSSectionTypeNone)
                continue;
#endif
            if (index == page)
                currentSection = info;

            index++;
        }
        
        [self steupMP3Info:currentSection];
    }
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self.view setNeedsDisplay];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)sender
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    pageControlUsed = NO;
}

#pragma mark -
#pragma mark Navigation bar item.

- (NSString *) titleForLoopMode:(KSPlayMode)mode
{
    NSString *title = nil;
    switch (mode) {
        case eKSPlayModeManual:
            title   = KSLocal(@"txt-play-mode-manual");
            break;
            
        case eKSPlayModeAuto:
            title   = KSLocal(@"txt-play-mode-auto");
            break;
    }
    
    return title;
}

- (void) setupRightBarItem
{
    _currentPlayMode = eKSPlayModeManual;
        
    self.rightItemTitle = [self titleForLoopMode:_currentPlayMode];
}

- (void)rightItemButtonTouched:(id)sender
{
    KSLog(@" >> rightItemButtonTouched");
    
    if (++ _currentPlayMode >= eKSPlayModeCount)
        _currentPlayMode = 0;
    
    self.rightItemTitle = [self titleForLoopMode:_currentPlayMode];
    if (_currentPlayMode == eKSPlayModeAuto && _mp3PlayerController && ![_mp3PlayerController isPlaying])
        [_mp3PlayerController play];
}


#pragma mark -
#pragma mark KSUnitDetailViewController(PrivateMethods)

- (void)pageChanged:(id)sender
{
    int page = _pageControl.currentPage;
    
    NSLog(@" >> pageChanged %d", page);
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    //[self.view setNeedsDisplay];
    // todo

	// update the scroll view to the appropriate page
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

#pragma mark -
#pragma mark KSMP3PlayerControllerDelegate

- (void) audioPlayerDidFinishPlaying:(KSMP3PlayerController *)mp3PlayerController
{
    if (_currentPlayMode == eKSPlayModeAuto)
        [self audioPlayerNextButtonPressed:mp3PlayerController];
}

- (void) audioPlayerNextButtonPressed:(KSMP3PlayerController *)mp3PlayerController
{
    NSInteger page = _pageControl.currentPage;
    if (++page >= _pageCount)
    {
        page = 0;
        return;
    }

    _pageControl.currentPage = page;
    [self pageChanged:_pageControl];
    
    KSSectionInfo *currentSection = [_unitInfo.sections objectAtIndex:page];
    
    NSInteger index = 0;
    for (KSSectionInfo * info in _unitInfo.sections)
    {
#ifndef Display_All_Sections_In_Unit
        if (info.sectionType == KSSectionTypeNone)
            continue;
#endif
        if (index == page)
            currentSection = info;
        
        index++;
    }
    
    [self steupMP3Info:currentSection];
}

- (void) audioPlayerPrevButtonPressed:(KSMP3PlayerController *)mp3PlayerController
{
    NSInteger page = _pageControl.currentPage;
    if (--page < 0)
    {
        page = _pageCount - 1;
        return;
    }
    
    _pageControl.currentPage = page;
    [self pageChanged:_pageControl];
    
    KSSectionInfo *currentSection = [_unitInfo.sections objectAtIndex:page];
    
    NSInteger index = 0;
    for (KSSectionInfo * info in _unitInfo.sections)
    {
#ifndef Display_All_Sections_In_Unit
        if (info.sectionType == KSSectionTypeNone)
            continue;
#endif
        if (index == page)
            currentSection = info;
        
        index++;
    }
    
    [self steupMP3Info:currentSection];
}

- (void) steupMP3Info:(KSSectionInfo *)info
{
    [_mp3PlayerController setupMP3Info:info displayUnit:NO];
    if (_currentPlayMode == eKSPlayModeAuto)
        [_mp3PlayerController play]; 
}

@end
