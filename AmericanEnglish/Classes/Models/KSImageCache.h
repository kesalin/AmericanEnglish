//
//  KSImageCache.h
//  KSFramework
//
//  Created by Kesalin on 6/15/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSCache.h"

@interface KSImageCache : KSCache
{
    NSMutableDictionary	*	_imageCache;
}

+ (id)      imageNamed:(NSString *)name;
+ (void)    setImage:(UIImage *)image named:(NSString *)imageName;
+ (BOOL)    writeImage:(UIImage*)image toFile:(NSString*)aPath;

@end
