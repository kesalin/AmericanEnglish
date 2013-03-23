//
//  KSUtilities.m
//  KSFramework
//
//  Created by kesalin on 7/1/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSUtilities.h"
#import "KSDefine.h"
#import "KSLog.h"

float* getGradientColor(KSGradientColorType type)
{
#define kGradientColorComponentsLen     16
    
    static const float components[] = {
        0.400, 0.400, 0.400, 1.0,
        0.333, 0.333, 0.333, 1.0,
        0.265, 0.265, 0.265, 1.0,
        0.200, 0.200, 0.200, 1.0,//black
        
        0.843, 0.843, 0.843, 1.0,
        0.549, 0.549, 0.549, 1.0,
        0.302, 0.302, 0.302, 1.0,
        0.200, 0.200, 0.200, 1.0,//gray
        
        0.976, 0.984, 0.999, 1.0,
        0.706, 0.800, 0.925, 1.0,
        0.500, 0.658, 0.876, 1.0,
        0.447, 0.625, 0.863, 1.0,//blue
        
        0.860, 0.860, 0.860, 1.0,
        0.900, 0.900, 0.900, 1.0,
        0.940, 0.940, 0.940, 1.0,
        1.000, 1.000, 1.000, 1.0,//white
        
        0.999, 0.984, 0.976, 1.0,
        0.925, 0.800, 0.706, 1.0,
        0.876, 0.658, 0.500, 1.0,
        0.863, 0.625, 0.447, 1.0,//red
        
        0.984, 0.999, 0.976, 1.0,
        0.800, 0.925, 0.706, 1.0,
        0.658, 0.876, 0.500, 1.0,
        0.625, 0.863, 0.447, 1.0,//green
        
    };
    
    if (type <= KSGradientColorNone || type >= KSGradientColorMax)
        return NULL;
    
    static float colors[kGradientColorComponentsLen];
    memcpy(colors, (float *)(&components[(type - 1) * kGradientColorComponentsLen]), kGradientColorComponentsLen * sizeof(float));
    return colors;
    
#undef kColorComponentsLen
}

NSComparisonResult sortArrayByOrder(id obj1, id obj2, void *context)
{
    NSDictionary *item1 = (NSDictionary *)obj1;
    NSDictionary *item2 = (NSDictionary *)obj2;
    NSNumber *order1    = [item1 objectForKey:@"order"];
    NSNumber *order2    = [item2 objectForKey:@"order"];
    
    NSComparisonResult result = [order1 compare:order2];
    return result;
}

// KSUtilities
// 
@implementation KSUtilities

+ (NSString *)copyFile2Docs:(NSString *)bundleFileName
{
    return [self copyFile2Docs:bundleFileName overwrite:NO];
}

+ (NSString *)copyFile2Docs:(NSString *)bundleFileName overwrite:(BOOL)yesOrNo
{    
	NSFileManager *fileManager	= [NSFileManager defaultManager];
	NSString *writablePlistPath = [KSDocumentPath() stringByAppendingPathComponent:bundleFileName];
	BOOL success				= [fileManager fileExistsAtPath:writablePlistPath];
    if (!yesOrNo && success)
        return writablePlistPath;
    
    NSError *error;
	if (yesOrNo)
		[fileManager removeItemAtPath:writablePlistPath error:&error];
    
	// The writable plist does not exist, so copy the default to the appropriate location.
    NSString *defaultPlistPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundleFileName];
    
    success = [fileManager copyItemAtPath:defaultPlistPath toPath:writablePlistPath error:&error];
    if (!success) {
        KSLog(@"Failed to create file %@ with message '%@'.", bundleFileName, [error localizedDescription]);
        return nil;
    }
    
    return writablePlistPath;
}

+ (NSInteger) unitNumberOf:(NSString *)unitKey
{
    if (KSIsNullOrEmpty(unitKey))
    {
        KSLog(@"Error! unitKeyToDisplayKey : Invalid unit key!");
        return -1;
    }
    
    NSRange range = [unitKey rangeOfString:@"-"];
    if (range.location == NSNotFound || ((range.location + 1) >= [unitKey length]))
    {
        KSLog(@"Error! unitKeyToDisplayKey : Invalid format of unit key!");
        return -1;
    }
    
    NSInteger unitNum = [[unitKey substringFromIndex:(range.location + 1)] intValue];
    return unitNum;
}

+ (NSString *) stringOfNumber:(NSInteger) number
{
    NSString *string = number < 10? [NSString stringWithFormat:@"0%d", number] : [NSString stringWithFormat:@"%d", number];
    return string;
}

@end
