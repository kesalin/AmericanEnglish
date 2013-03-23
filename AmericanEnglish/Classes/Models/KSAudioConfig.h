//
//  KSAudioConfig.h
//  AmericanEnglish
//
//  Created by kesalin on 7/19/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KSAudioConfig : NSObject
{
    NSDictionary *              _audioDict;
    NSArray *              _allAudios;
}

@property (nonatomic, retain, readonly) NSArray * allAudios;

+ (id)sharedInstance;

- (NSArray *) allUnits;
- (NSArray *) unitsForCategory:(NSString *)key;

@end
