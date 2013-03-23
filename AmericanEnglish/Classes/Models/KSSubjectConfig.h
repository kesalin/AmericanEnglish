//
//  KSSubjectConfig.h
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KSSubjectConfig : NSObject
{
    NSArray *           _subjects;
    NSInteger           _count;
}

@property (nonatomic, retain, readonly) NSArray *subjects;

+ (id)sharedInstance;

- (NSDictionary *) configForSubject:(NSString *) subjectKey;

- (NSArray *) tabBarHeaders;
- (id)keyOfTabIndex:(NSInteger)index;

- (NSArray *) navigationItemsForTabIndex:(NSInteger)index;
- (NSInteger) defaultNavigationItemIndexForTabIndex:(NSInteger)index;

@end
