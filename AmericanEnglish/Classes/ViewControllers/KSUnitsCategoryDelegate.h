//
//  KSUnitsCategoryDelegate.h
//  AmericanEnglish
//
//  Created by kesalin on 7/25/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSSubDelegate.h"

@interface KSUnitsCategoryDelegate : KSSubDelegate
{
    NSArray *       allUnits;
    
    NSInteger       _currentUnit; 
}

@end
