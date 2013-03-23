//
//  KSPdfViewController.h
//  AmericanEnglish
//
//  Created by kesalin on 7/28/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSViewController.h"

@interface KSPdfViewController : KSViewController <UIWebViewDelegate>
{
    NSString * _fileName;
}

- (id) initWithPdf:(NSDictionary *)fileDict;

@end
