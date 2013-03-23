//
//  KSSectionInfo.h
//  AmericanEnglish
//
//  Created by kesalin on 11-7-23.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

enum eKSSectionType
{
    KSSectionTypeNone,
    KSSectionTypePronunciation,
    KSSectionTypeVocabulary,
    KSSectionTypeWordPair,
    KSSectionTypeDialog,
    KSSectionTypeConversation,
    KSSectionTypeExpression,
    KSSectionTypeTextContent,
    
    KSSectionTypeCount,
};

typedef NSInteger KSSectionType;

// KSUnitInfo
//
@interface KSUnitInfo : NSObject <NSCopying>
{
    NSString *      _key;
    NSString *      _title;
    NSArray *       _sections;
}

@property (nonatomic, retain) NSString  *key;
@property (nonatomic, retain) NSString  *title;
@property (nonatomic, retain) NSArray   *sections;

@end

// KSSectionInfo
//
@interface KSSectionInfo : NSObject <NSCopying>
{
    NSString *      _key;
    NSString *      _title;
    NSString *      _unitKey;
    NSString *      _mp3;
    NSString *      _contentType;
    NSArray *       _content;
    KSSectionType   _sectionType;
}

@property (nonatomic, retain) NSString  *key;
@property (nonatomic, retain) NSString  *title;
@property (nonatomic, retain) NSString  *unitKey;
@property (nonatomic, retain) NSString  *mp3;
@property (nonatomic, retain) NSString  *contentType;
@property (nonatomic, retain) NSArray   *content;
@property (nonatomic, assign) KSSectionType sectionType;

@end
