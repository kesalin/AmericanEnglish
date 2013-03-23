//
//  KSImageCache.m
//  KSFramework
//
//  Created by Kesalin on 6/15/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSImageCache.h"
#import "KSDefine.h"
#import "KSLog.h"

//============================================================================================
//                                    KSImageValue
//============================================================================================
@interface KSImageValue : NSObject
{
	NSString    *imagePath;
	UIImage     *imageData;
}

@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, retain) UIImage *imageData;

@end

@implementation KSImageValue

@synthesize imagePath, imageData;

@end

//============================================================================================
//                                    KSImageCache
//============================================================================================
#define kHBImageListFile	@"image_config.plist"

// KSImageCache(PrivateMethods)
//
@interface KSImageCache(PrivateMethods)

- (UIImage *)imageForKey:(NSString *)imageName;
- (void)setImage:(UIImage *)image forKey:(NSString *)key needSave:(BOOL)save;

@end

// KSImageCache
//
@implementation KSImageCache

static KSImageCache *sharedInstance = nil;

+ (id)sharedInstance
{
	if (sharedInstance == nil)
    {
		sharedInstance = [[self alloc] init];
	}
    
	return sharedInstance;
}

#pragma mark -
#pragma mark Life cycle

- (id)init
{
    self = [super init];
	if (self)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource: kKSImageConfigFile ofType: @"plist"];
		_imageCache = [[NSMutableDictionary dictionaryWithContentsOfFile:path] retain];
	}
    
	return self;
}

- (void)dealloc
{
	[_imageCache release];
	[super dealloc];
}

#pragma mark -
#pragma mark KSCache

- (void)saveOnExit
{
}

#pragma mark -
#pragma mark Write and read

+ (BOOL)writeImage:(UIImage*)image toFile:(NSString*)aPath
{
	if (image == nil) 
    {
        KSLog(@"warning: Cann't write nil image to %@!", aPath);
		return NO;
	}
    
    if (KSIsNullOrEmpty(aPath))
    {
        KSLog(@"warning: Cann't write image to invalid path!");
        return NO;
    }
	
	NSData *imageData = UIImagePNGRepresentation(image);
	if ((imageData == nil) || ([imageData length] <= 0))
    {
        KSLog(@"warning: Cann't write invalid image data to file %@", aPath);
		return NO;
	}
	
	[imageData writeToFile:aPath atomically:YES];	
	
	return YES;	
}

+ (UIImage *)imageNamed:(NSString *)imageName 
{
    if (KSIsNullOrEmpty(imageName))
    {
        KSLog(@"warning: Cann't get image by invalid name!");
        return nil;
    }
    
    UIImage *retImage = [[self sharedInstance] imageForKey:imageName];
    
    return retImage;
}

+ (void)setImage:(UIImage *)image named:(NSString *)imageName
{
    if (image == nil)
    {
        KSLog(@"warning: Cann't set invalid image named %@!", imageName);
        return;
    }
    
    if (KSIsNullOrEmpty(imageName))
    {
        KSLog(@"warning: Cann't set image by invalid name!");
        return;
    }

	[[self sharedInstance] setImage:image forKey:imageName needSave:YES];
}

- (UIImage *)imageForKey:(NSString *)imageName
{
    if (KSIsNullOrEmpty(imageName))
    {
        KSLog(@"warning: Cann't get image by invalid key!");
        return nil;
    }
    
	id imageRef = [_imageCache objectForKey:imageName];
    
    if ([imageRef isKindOfClass:[NSString class]])
    {
        imageRef = [UIImage imageNamed:imageRef];
        if (imageRef != nil)
        {
            [self setImage:imageRef forKey:imageName needSave:NO];
		}
    }
    
    else if ([imageRef isKindOfClass:[KSImageValue class]])
    {
        imageRef = ((KSImageValue *)imageRef).imageData;
    }
    
    else if (!imageRef)
    {
		KSLog(@"Requested image \"%@\" was not configured in cache.", imageName);
    }
    
	return imageRef;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key needSave:(BOOL)save
{
    if (!image || KSIsNullOrEmpty(key))
        return;
	
	KSImageValue *cacheItem  = [[KSImageValue alloc] init];
	cacheItem.imagePath		 = [NSString stringWithFormat:@"%@.%@", key, @"png"];
	cacheItem.imageData		 = image;
	[_imageCache setObject:cacheItem forKey:key];
    
    if (save)
    {
        NSString *homeDir   = NSHomeDirectory();
        homeDir             = [homeDir stringByAppendingPathComponent:@"Documents"];
        NSString *imagePath = [homeDir stringByAppendingPathComponent:cacheItem.imagePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        {
            [[self class] writeImage:image toFile:imagePath];
        }
    }
    
	[cacheItem release];
}

@end
