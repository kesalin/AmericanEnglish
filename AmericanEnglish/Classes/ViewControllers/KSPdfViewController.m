//
//  KSPdfViewController.m
//  AmericanEnglish
//
//  Created by kesalin on 7/28/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSPdfViewController.h"
#import "KSDefine.h"
#import "KSLog.h"

@implementation KSPdfViewController

- (id) initWithPdf:(NSDictionary *)fileDict
{
    self = [super init];
    
    if (self)
    {
        NSString * titleValue   = [fileDict objectForKey:@"title"];
        self.title              = KSLocal(titleValue);
        
        NSString * fileValue    = [fileDict objectForKey:@"file"];
        NSRange range           = [fileValue rangeOfString:@"."];
        if (range.location != NSNotFound && range.location < [fileValue length] - 1)
        {
            NSString *name      = [fileValue substringToIndex:range.location];
            _fileName           = [[NSString alloc] initWithFormat:@"%@", name];
        }
    }
    
    return self;
}

- (void) dealloc
{
    [_fileName release];
    
    [super dealloc];
}

- (void) loadView
{
    UIWebView *webView      = [[UIWebView alloc] initWithFrame:CGRectZero];
    webView.delegate        = self;
    webView.scalesPageToFit = YES;

    if (!KSIsNullOrEmpty(_fileName))
    {
        NSString *pdfPath   = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"pdf"];
        if (!KSIsNullOrEmpty(pdfPath)) 
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:pdfPath]]];
        
        KSLog(@" >> load file %@, path:%@", _fileName, pdfPath);
    }
    
    self.view = webView;
    [webView release];

    //self.view.transform     = CGAffineTransformScale(self.view.transform, 1.25, 1.25);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setTabBarHidden:YES animated:animated];
}

#pragma mark -
#pragma mark - web view

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    KSLog(@"Error! Failed to load file %@", _fileName);
}

@end
