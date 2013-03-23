//
//  KSButton.m
//  KSFramework
//
//  Created by Kesalin on 6/17/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSButton.h"

@interface KSButton ()
@property (nonatomic, retain) UIImageView *iconView;;
@property (nonatomic, retain) UILabel *textLabel;
@end


@implementation KSButton

@synthesize iconView  = _iconView;
@synthesize textLabel = _textLabel;
@synthesize needLayoutLabel = _needLayoutLabel;


+ (id)buttonWithType:(UIButtonType)buttonType
{
    KSButton *button     = [super buttonWithType:buttonType];
    
    [button addTarget:button action:@selector(adjustsImage:) forControlEvents:UIControlEventTouchDown];
    button.needLayoutLabel= YES;
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    button.iconView       = iconView;
    [button addSubview:iconView];
    [iconView release];
    
    UILabel *label        = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment   = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor       = [UIColor blackColor];
	label.shadowColor	  = [UIColor grayColor];
    label.shadowOffset    = CGSizeMake(0.5f, 0.5f);
    button.textLabel      = label;
    button.textLabel.adjustsFontSizeToFitWidth  = NO;
    [button addSubview:label];
    [label release];
    
    return button;
}

+ (id)button
{
    return [self buttonWithType:UIButtonTypeCustom];
}

- (void)dealloc
{
    [_textLabel release];
    [_iconView release];
    
    [super dealloc];
}

- (NSString *)title
{
	return [_textLabel text];
}

- (void)setTitle:(NSString *)aTitle
{
	[_textLabel setText:aTitle];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_needLayoutLabel)
    {
        [self.textLabel sizeToFit];
        CGSize labelSize = self.textLabel.frame.size;
        CGSize size = self.bounds.size;
        
        self.textLabel.frame  = CGRectMake(floor((size.width - labelSize.width) / 2),
                                           floor((size.height - labelSize.height) / 2),
                                           floor(labelSize.width), floor(labelSize.height));
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self.textLabel setHighlighted:highlighted];
}

- (void)adjustsImage:(id)sender
{
    if (self.adjustsImageWhenHighlighted)
        [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    if (self.adjustsImageWhenHighlighted)
    {
        CGBlendMode mode = self.enabled ? kCGBlendModeNormal : kCGBlendModeLuminosity;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        CGContextSetRGBFillColor(context, 0.4, 0.4, 0.4, 1.0);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
        
        if (_iconView.image != nil)
            [_iconView.image drawInRect:self.bounds blendMode:mode alpha:1.0];
        
    }

    UIGraphicsBeginImageContext(_iconView.image.size);

    UIGraphicsEndImageContext();
}

@end
