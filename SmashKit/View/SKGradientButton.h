//
//  SKGradientButton.h
//  Tamecco
//
//  Created by Matt on 12/12/12.
//  Copyright (c) 2012 Tamecco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKGradientButton : UIButton

@property (strong, nonatomic) UIColor *topColor;
@property (strong, nonatomic) UIColor *bottomColor;

+ (CGSize)sizeWithImage:(UIImage*)image title:(NSString*)title width:(CGFloat)width;
+ (id)button;

@end

