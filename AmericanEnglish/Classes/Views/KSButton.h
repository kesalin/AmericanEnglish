//
//  KSButton.h
//  KSFramework
//
//  Created by Kesalin on 6/17/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KSButton : UIButton
{

@private
	UIImageView *   _iconView;
    UILabel *       _textLabel;
    
    BOOL            _needLayoutLabel;
}

@property (nonatomic, retain, readonly) UIImageView *iconView;
@property (nonatomic, retain, readonly) UILabel *textLabel; //we can manipulate this label...
@property (nonatomic) BOOL needLayoutLabel;
@property (nonatomic, copy) NSString *title;

+ (id)button;

@end
