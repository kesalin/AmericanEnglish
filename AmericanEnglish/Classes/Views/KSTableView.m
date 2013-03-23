//
//  KSTableView.m
//  KSFramework
//
//  Created by kesalin on 6/30/11.
//  Copyright 2011 kesalin@gmail.com. All rights reserved.
//

#import "KSTableView.h"
#import "KSDefine.h"
#import "KSImageCache.h"

@implementation KSTableView

- (id)initWithTitle:(NSString *)title {
    
	UIImage *background = [KSImageCache imageNamed:@"red_gradient_44"];
	if (!background)
		return nil;
    
    CGRect rect = CGRectMake(-8, 0, kKSAppWidth, 44);
    
    self = [super initWithFrame:rect style:UITableViewStylePlain];
	if (self)
	{
		UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.center = self.center;
        [self addSubview:imageView];
        [imageView release];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | 
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self superview].autoresizesSubviews = YES;
        
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *label          = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor   = [UIColor clearColor];
        label.textColor         = [UIColor whiteColor];
        label.font              = [UIFont fontWithName:kKSZhBoldFontName size:24];
        label.text              = title;
        [label sizeToFit];
        CGRect labelFrame       = label.frame;
        labelFrame.origin.x     = (self.bounds.size.width - labelFrame.size.width - 8) / 2;
        labelFrame.origin.y     = (self.bounds.size.height - labelFrame.size.height) / 2;
        label.frame             = labelFrame;
        [self addSubview:label];
        [label release];
	}
	
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (void)dealloc
{
    [super dealloc];
}

@end
