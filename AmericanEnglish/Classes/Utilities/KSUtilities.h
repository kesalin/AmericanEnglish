//
//  KSUtilities.h
//  KSFramework
//
//  Created by kesalin on 7/1/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#ifndef __KSUtilities_H__
#define __KSUtilities_H__

#import <Foundation/Foundation.h>

enum {
    KSGradientColorNone,
    KSGradientColorBlack,
    KSGradientColorGray,
    KSGradientColorBlue,
    KSGradientColorWhite,
    KSGradientColorRed,
    KSGradientColorGreen,

    KSGradientColorMax
};

typedef NSInteger KSGradientColorType;

// Function declare
//
float* getGradientColor(KSGradientColorType type);
NSComparisonResult sortArrayByOrder(id obj1, id obj2, void *context);

// KSUtilities
//
@interface KSUtilities : NSObject
{

}

+ (NSString *)copyFile2Docs:(NSString *)bundleFileName;
+ (NSString *)copyFile2Docs:(NSString *)bundleFileName overwrite:(BOOL)yesOrNo;

+ (NSInteger) unitNumberOf:(NSString *)unitKey;
+ (NSString *) stringOfNumber:(NSInteger) number;


@end

#endif //__KSUtilities_H__
