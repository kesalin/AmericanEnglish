//
//  KSAudioConfig.m
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSAudioConfig.h"
#import "KSDefine.h"
#import "KSLog.h"
#import "KSSectionInfo.h"
#import "KSUtilities.h"

#ifdef KSDEBUG
#define CHECK_DATA
#endif

// KSAudioConfig(PrivateMethods)
//
@interface KSAudioConfig(PrivateMethods)

- (void) loadConfig;
- (NSDictionary *) unitsDictForCategory:(NSString *)categoryKey;
- (NSArray *) unitsForSymbol;
- (NSArray *) unitsForSound;

@end


// KSSubjectConfig
//
static KSAudioConfig *instance = nil;

@implementation KSAudioConfig

@synthesize allAudios   = _allAudios;

#pragma mark -
#pragma mark Lifecycle

+ (id) sharedInstance
{
    if (instance == nil)
    {
        instance = [[self alloc] init];

        [instance loadConfig];
    }
    
    return instance;
}

- (void) dealloc
{
    [_audioDict release];
    
    [super dealloc];
}

- (void) loadConfig
{
    // load audio config from plist.
    //
    NSString *path = [[NSBundle mainBundle] pathForResource: kKSAudioConfigFile ofType: @"plist"];
    _audioDict = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
    
    KSLog(@" >> loading audio config %@", path);

    NSDictionary *vowelUnitsDict = [[self unitsDictForCategory:kKSCategoryKeyVowel] retain];
    NSDictionary *consonantUnitsDict = [[self unitsDictForCategory:kKSCategoryKeyConsonant] retain];
    
#ifdef CHECK_DATA
    NSArray *vowelUnits = [vowelUnitsDict objectForKey:@"units"];
    for (KSUnitInfo * unit in vowelUnits)
        NSLog(@" %@, %@, %d", unit.key, unit.title, [unit.sections count]);
#endif
    
    _allAudios  = [[NSArray alloc] initWithObjects:vowelUnitsDict, consonantUnitsDict, nil];
    [vowelUnitsDict release];
    [consonantUnitsDict release];
    
    KSLog(@" == load %d category", [_allAudios count]);
}

- (NSDictionary *) unitsDictForCategory:(NSString *)key
{
    if (!key || (![key isEqualToString:kKSCategoryKeyVowel] && ![key isEqualToString:kKSCategoryKeyConsonant]))
    {
        KSLog(@"Error! unitsDictForCategory : Invalid category key!");
        return nil;
    }

    NSDictionary * categoryDict     = [_audioDict objectForKey:key];
    NSString * categoryKey          = [categoryDict objectForKey:@"key"];
    NSArray *  unitItems            = [categoryDict objectForKey:@"units"];
    NSString * categoryTitle        = [NSString stringWithFormat:@"txt-%@", categoryKey];
    
    NSMutableArray * unitArray      = [[NSMutableArray alloc] initWithCapacity:[unitItems count]];
    for (NSDictionary *unitDict in unitItems)
    {
        NSString * unitkey              = [unitDict objectForKey:@"key"];                                                       // unit-01
        NSInteger unitNum               = [KSUtilities unitNumberOf:unitkey];                                                   // 1, 2, 30
        NSString * unitNumString        = (unitNum >= 10 ? [NSString stringWithFormat:@"%d", unitNum] : [NSString stringWithFormat:@"0%d", unitNum]);
        KSUnitInfo * unitInfo           = [[KSUnitInfo alloc] init];
        unitInfo.key                    = unitkey;   
        unitInfo.title                  = [NSString stringWithFormat:@"txt-%@-title", unitkey];                                 // txt-unit-01-title

        NSArray * sectionItems          = [unitDict objectForKey:@"sections"];
        NSMutableArray * sectionArray   = [[NSMutableArray alloc] initWithCapacity:[sectionItems count]];
        for (NSDictionary * sectionDict in sectionItems)
        {
            NSString * sectionKey       = [sectionDict objectForKey:@"key"];
            BOOL hasMP3                 = [[sectionDict objectForKey:@"mp3"] boolValue];
            BOOL isPronunciationSection = [sectionKey isEqualToString:@"0"];
            NSString *sectionTitle      = isPronunciationSection ? @"txt-default-pronunciation-title" : [NSString stringWithFormat:@"txt-%@-S%@-title", unitkey, sectionKey]; // txt-unit-01-SA-title
            NSString *mp3File           = hasMP3 ? [NSString stringWithFormat:@"%@-%@.mp3", unitNumString, sectionKey] : nil;   // 01-0.mp3 or 01-A.mp3
            
            KSSectionInfo * sectionInfo = [[KSSectionInfo alloc] init];
            sectionInfo.unitKey         = unitkey;
            sectionInfo.key             = sectionKey;
            sectionInfo.title           = sectionTitle;                 
            sectionInfo.mp3             = mp3File;
            sectionInfo.contentType     = [sectionDict objectForKey:@"content-type"];
            sectionInfo.content         = [[sectionDict objectForKey:@"content"] retain];

            KSLog(@" >> load %@, %@, %@ - %@, %@ - %@", categoryKey, unitkey, sectionKey, KSLocal(sectionTitle), mp3File, sectionInfo.contentType);
    
            [sectionArray addObject:sectionInfo];
            [sectionInfo release];
        }
        
        unitInfo.sections               = sectionArray;
        [unitArray addObject:unitInfo];

        [sectionArray release];
        [unitInfo release];
    }

    KSLog(@" == load %@, %d units", categoryKey, [unitArray count]);

    NSMutableDictionary * returnDict  = [[NSMutableDictionary alloc] init];
    [returnDict setObject:categoryKey forKey:@"key"];
    [returnDict setObject:categoryTitle forKey:@"title"];
    [returnDict setObject:unitArray forKey:@"units"];
    [unitArray release];
    
    return [returnDict autorelease];
}

- (NSArray *) allUnits
{
    NSMutableArray *units = [[NSMutableArray alloc] init];
    for (NSDictionary *categoryDict in _allAudios)
    {
        NSArray * categoryUnits = [categoryDict objectForKey:@"units"];
        [units addObjectsFromArray:categoryUnits];
    }
    
    KSLog(@" >> load all units %d", [units count]);
    return [units autorelease];
}

- (NSArray *) unitsForSound
{
    NSMutableArray * units          = [[NSMutableArray alloc] init];
    
    NSArray * allUnits              = [self allUnits];
    for (KSUnitInfo * unitInfo in allUnits)
    {
        NSMutableArray * sections       = [[NSMutableArray alloc] init];
        
		BOOL isSymbol = FALSE;
        for (KSSectionInfo *sectionInfo in unitInfo.sections)
        {
            NSString * contentType  = sectionInfo.contentType;
            if ([contentType isEqualToString:kKSContentKeyPronunciation])
				isSymbol = TRUE;
			
			if	(isSymbol)
                [sections addObject:sectionInfo];
        }
        
        if ([sections count] > 0)
        {
            KSUnitInfo * aUnit      = [[KSUnitInfo alloc] init];
            aUnit.key               = unitInfo.key;
            aUnit.title             = unitInfo.title;
            aUnit.sections          = sections;
            
            [units addObject:aUnit];
            [aUnit release];
        }
        
        [sections release];
    }
    
    return [units autorelease]; 
}

- (NSArray *) unitsForSymbol
{
    NSMutableArray * units          = [[NSMutableArray alloc] init];

    NSArray * allUnits              = [self allUnits];
    for (KSUnitInfo * unitInfo in allUnits)
    {
        NSMutableArray * sections       = [[NSMutableArray alloc] init];
        
		BOOL isSymbol = FALSE;
        for (KSSectionInfo *sectionInfo in unitInfo.sections)
        {
            NSString * contentType  = sectionInfo.contentType;
            if ([contentType isEqualToString:kKSContentKeyPronunciation])
            {
                [sections addObject:sectionInfo];
				isSymbol = TRUE;
            }
			
			else if	(isSymbol)
			{
				if ([contentType isEqualToString:kKSContentKeyVocabulary]
					|| [contentType isEqualToString:kKSContentKeyWordPairs]
					|| [contentType isEqualToString:kKSContentKeyExpressions])
				{
					[sections addObject:sectionInfo];
				}
			}
        }
        
        if ([sections count] > 0)
        {
            KSUnitInfo * aUnit      = [[KSUnitInfo alloc] init];
            aUnit.key               = unitInfo.key;
            aUnit.title             = unitInfo.title;
            aUnit.sections          = sections;
            
            [units addObject:aUnit];
            [aUnit release];
        }
        
        [sections release];
    }
    
    return [units autorelease]; 
}

- (NSArray *) unitsForCategory:(NSString *)key
{
    if (!key || (![key isEqualToString:kKSCategoryKeyAll] 
                 && ![key isEqualToString:kKSCategoryKeyVowel] 
                 && ![key isEqualToString:kKSCategoryKeyConsonant]
                 && ![key isEqualToString:kKSCategoryKeySymbol]
                 && ![key isEqualToString:kKSCategoryKeySound]))
    {
        KSLog(@"Error! unitsForCategory : Invalid category key!");
        return nil;
    }
    
    if ([key isEqualToString:kKSCategoryKeyAll])
        return [self allUnits];

    else if ([key isEqualToString:kKSCategoryKeySymbol])
        return [self unitsForSymbol];
    
    else if ([key isEqualToString:kKSCategoryKeySound])
        return [self unitsForSound];
    
    NSMutableArray *units = [[NSMutableArray alloc] init];
    for (NSDictionary *categoryDict in _allAudios)
    {
        NSString * categoryKey = [categoryDict objectForKey:@"key"];
        if ([categoryKey isEqualToString:key])
        {
            [units addObjectsFromArray:[categoryDict objectForKey:@"units"]];
            break;
        }
    }

    KSLog(@" >> load all units %d for %@", [units count], key);
    return [units autorelease];
}

@end
