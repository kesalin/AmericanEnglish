//
//  UIDevice+Resolutions.m
//  AmericanEnglish
//
//  Created by kesalin on 3/30/13.
//  Copyright (c) 2013 kesalin@gmail.com. All rights reserved.
//

#import "UIDevice+Resolutions.h"

@implementation UIDevice (Resolutions)

+ (UIDeviceResolution) currentResolution {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            CGSize result = CGSizeMake(screenSize.width * scale, screenSize.height * scale);
            if (result.height == 480) {
                return UIDevice_iPhoneStandardRes;
            }

            return (result.height == 960 ? UIDevice_iPhoneHiRes : UIDevice_iPhoneTallerHiRes);
        }
        else {
            return UIDevice_iPhoneStandardRes;
        }  
    }
    else {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            CGSize result = CGSizeMake(screenSize.width * scale, screenSize.height * scale);
            
            if (result.height == 1024) {
                return UIDevice_iPadStandardRes;
            }

            return UIDevice_iPadHiRes;
        }
        else {
            return UIDevice_iPadStandardRes;
        }
    }   
}

@end
