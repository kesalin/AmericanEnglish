//
//  KSSubjectConfig.m
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSSubjectConfig.h"
#import "KSDefine.h"
#import "KSLog.h"
#import "KSImageCache.h"

static NSComparisonResult _sortArrayByOrder(id obj1, id obj2, void *context)
{
    NSDictionary *item1 = (NSDictionary *)obj1;
    NSDictionary *item2 = (NSDictionary *)obj2;
    NSNumber *order1    = [item1 objectForKey:@"order"];
    NSNumber *order2    = [item2 objectForKey:@"order"];
    
    NSComparisonResult result = [order1 compare:order2];
    return result;
}

// KSSubjectConfig(PrivateMethods)
//
@interface KSSubjectConfig(PrivateMethods)

- (void) loadConfig;

@end


// KSSubjectConfig
//
static KSSubjectConfig *instance = nil;

@implementation KSSubjectConfig

@synthesize subjects = _subjects;

#pragma mark -
#pragma mark Lifecycle

+ (id) sharedInstance
{
    if (instance == nil)
        instance = [[self alloc] init];
    
    return instance;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        [self loadConfig];
    }
    
    return self;
}

- (void) dealloc
{
    [_subjects release];
    
    [super dealloc];
}

- (void) loadConfig
{
    // load subject config from plist.
    //
    NSString * path             = [[NSBundle mainBundle] pathForResource: kKSSubjectConfigFile ofType: @"plist"];
    NSDictionary * contents     = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *originalSubjects   = [contents objectForKey:@"subjects"];

    KSLog(@"loading config %@", path);
    
    NSMutableArray *mutableArray    = [[NSMutableArray alloc] initWithCapacity:[originalSubjects count]];
    for (NSDictionary *subject in originalSubjects)
    {
        BOOL isHidden       = [[subject objectForKey:@"hidden"] boolValue];
        if (isHidden)
            continue;

        NSMutableDictionary *subjectDef = [[NSMutableDictionary alloc] init];
        [subjectDef addEntriesFromDictionary: subject];
        
        NSDictionary *icons = [subjectDef objectForKey:@"icons"];
        [subjectDef addEntriesFromDictionary: icons];
        [subjectDef removeObjectForKey:@"icons"];
        
#ifdef KSDEBUG
        NSString * key      = [subjectDef objectForKey:@"key"];
        NSString * title    = [subjectDef objectForKey:@"title"];
        NSDictionary * items = [subjectDef objectForKey:@"items"];
        KSLog(@" - subject:%@, title:%@, items count:%d", key, KSLocal(title), [items count]);
#endif

        [mutableArray addObject:subjectDef];
        [subjectDef release];
    }

    [_subjects release];
    _subjects = [[NSArray alloc] initWithArray:mutableArray];
    _count = [_subjects count];
    
    [mutableArray release];
}

- (NSDictionary *) configForSubject:(NSString *) subjectKey
{
    if (KSIsNullOrEmpty(subjectKey))
    {
        KSLog(@"warning: Invalid subject key!");
        return nil;
    }
    
    NSDictionary * config = nil;
    for (NSDictionary *subject in _subjects)
    {
        NSString * key = [subject objectForKey:@"key"];
        if ([key isEqualToString:subjectKey])
        {
            config = subject;
            break;
        }
    }
    
    return config;
}

- (NSArray *) tabBarHeaders
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:_count];
    for (NSDictionary * dict in _subjects)
    {
        NSString *key       = [dict objectForKey:@"key"];
        NSString *title     = [dict objectForKey:@"title"];
        NSString *handler   = [dict objectForKey:@"handler"];
        NSString *delegate  = [dict objectForKey:@"delegate"];
        NSString *normalIcon = [dict objectForKey:@"icon_normal"];
        //NSString *highIcon  = [dict objectForKey:@"icon_highlighted"];
        UIImage *iconOff    = [KSImageCache imageNamed:normalIcon];
        //UIImage *iconOn     = [KSImageCache imageNamed:highIcon];
        
        KSLog(@" tabBarHeaders %@, %@, %@, %@", key, KSLocal(title), handler, normalIcon);
        
        NSDictionary *tabs  = [NSDictionary dictionaryWithObjectsAndKeys:
                               key,             @"key",
                               iconOff,         @"icon_normal",
                               //iconOn,          @"icon_highlighted",
                               KSLocal(title),  @"title",
                               handler,         @"handler",
                               delegate,        @"delegate",
                               nil];
        [array addObject:tabs];
    }
    
    [array sortUsingFunction:_sortArrayByOrder context:nil];
    
    return [array autorelease];
}

- (NSArray *)navigationItemsForTabIndex:(NSInteger)index
{
    if (index < 0 || index >= _count)
    {
        KSLog(@"Error! Invalid tab index %d in navigationItemsForTabIndex", index);
        return nil;
    }
    
    NSDictionary *dict = [_subjects objectAtIndex:index];
	NSArray *navItems = [dict objectForKey:@"items"];
    
    return navItems;
}

- (NSInteger)defaultNavigationItemIndexForTabIndex:(NSInteger)tabIndex
{
    NSInteger index = 0;
	NSArray *navItems = [self navigationItemsForTabIndex:tabIndex];
    for (NSDictionary *dict in navItems)
    {
        BOOL isDefault = [[dict objectForKey:@"default"] boolValue];
        if (isDefault)
            break;

        index++;
    }
    
    return index;
}

- (id)keyOfTabIndex:(NSInteger)index
{
    if (index < 0 || index >= _count)
    {
        KSLog(@"Error! Invalid index %d of subject!", index);
        return nil;
    }

    NSDictionary * dict = [_subjects objectAtIndex:index];
    NSString * key      =  [dict objectForKey:@"key"];
    
    return key;
}

@end
