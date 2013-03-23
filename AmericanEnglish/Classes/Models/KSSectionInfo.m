//
//  KSSectionInfo.m
//  AmericanEnglish
//
//  Created by kesalin on 11-7-23.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSSectionInfo.h"
#import "KSLog.h"
#import "KSDefine.h"

#pragma -
#pragma mark KSUnitInfo

@implementation KSUnitInfo

@synthesize key         = _key;
@synthesize title       = _title;
@synthesize sections    = _sections;

- (void) dealloc
{
    self.key            = nil;
    self.title          = nil;
    self.sections       = nil;
    
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
    KSUnitInfo *info    = [[[self class] allocWithZone:zone] init];
    info.key            = self.key;
    info.title          = self.title;
    info.sections       = self.sections;
    
    return info;
}

@end

#pragma -
#pragma mark KSSectionInfo

@implementation KSSectionInfo

@synthesize key         = _key;
@synthesize title       = _title;
@synthesize unitKey     = _unitKey;
@synthesize mp3         = _mp3;
@synthesize contentType = _contentType;
@synthesize content     = _content;
@synthesize sectionType = _sectionType;

- (void) dealloc
{
    self.key            = nil;
    self.title          = nil;
    self.unitKey        = nil;
    self.mp3            = nil;
    self.contentType    = nil;
    self.content        = nil;
    
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
    KSSectionInfo *info = [[[self class] allocWithZone:zone] init];
    info.key            = self.key;
    info.title          = self.title;
    info.unitKey        = self.unitKey;
    info.mp3            = self.mp3;
    info.contentType    = self.contentType;
    info.content        = self.content;
    info.sectionType    = self.sectionType;
    
    return info;
}

- (void) setContentType:(NSString *)type
{
    [type retain];
    [_contentType release];
    _contentType = type;
    
    KSSectionType sttype = KSSectionTypeNone;
    
    if ([_contentType isEqualToString:@"pronunciation"])
        sttype = KSSectionTypePronunciation;
    
    else if ([_contentType isEqualToString:@"vocabulary"])
        sttype = KSSectionTypeVocabulary;
    
    else if ([_contentType isEqualToString:@"expressions"])
        sttype = KSSectionTypeExpression;
    
    else if ([_contentType isEqualToString:@"wordpairs"])
        sttype = KSSectionTypeWordPair;
    
    else if ([_contentType isEqualToString:@"conversation"])
        sttype = KSSectionTypeConversation;

    else if ([_contentType isEqualToString:@"dialog"])
        sttype = KSSectionTypeDialog;
    
    else if ([_contentType isEqualToString:@"text-content"])
        sttype = KSSectionTypeTextContent;
    
    _sectionType = sttype;
    
    KSLog(@" == contentType %@ - %d", _contentType, _sectionType);
}


@end
