//
//  SKItemButtonViewController.m
//  Tamecco
//
//  Created by Matt on 12/25/12.
//  Copyright (c) 2012 Tamecco. All rights reserved.
//

#import "SKItemButtonViewController.h"

NSString * const SKItemButtonImageKey = @"SKItemButtonImageKey";
NSString * const SKItemButtonTitleKey = @"SKItemButtonTitleKey";
NSString * const SKItemButtonEventNameKey = @"SKItemButtonEventNameKey";
NSString * const SKItemButtonTargetKey = @"SKItemButtonTargetKey";
NSString * const SKItemButtonActionKey = @"SKItemButtonActionKey";
NSString * const SKItemButtonTitleColorKey = @"SKItemButtonTitleColorKey";
NSString * const SKItemButtonTopColorKey = @"SKItemButtonTopColorKey";
NSString * const SKItemButtonTopBottomColorKey = @"SKItemButtonTopBottomColorKey";

@implementation SKItemButtonViewController

+ (NSSet*)requiredConfigurationKeys {
  return [NSSet setWithArray:@[SKItemButtonTitleKey]];
}

+ (void)setHeightWithConfiguration:(NSMutableDictionary *)configuration width:(CGFloat)width {
  configuration[SKItemHeightKey] = @(
    MAX([SKGradientButton
      sizeWithImage:(UIImage*)configuration[SKItemButtonImageKey]
      title:configuration[SKItemButtonTitleKey]
      width:width].height, 34.0f
    )
  );
}

- (void)loadView {
  [super loadView];
  
  self.button = [SKGradientButton button];
  [self.view addSubview:self.button];
}

- (void)loadWithConfiguration:(NSMutableDictionary *)configuration {
  self.button.frame = CGRectMake(
    [configuration[SKItemLeftHorizontalMarginKey] floatValue],
    [configuration[SKItemTopVerticalMarginKey] floatValue],
    [configuration[SKItemWidthKey] floatValue] -
      [configuration[SKItemLeftHorizontalMarginKey] floatValue] -
      [configuration[SKItemRightHorizontalMarginKey] floatValue],
    [configuration[SKItemHeightKey] floatValue] -
      [configuration[SKItemTopVerticalMarginKey] floatValue] -
      [configuration[SKItemBottomVerticalMarginKey] floatValue]
  );
  [self.button setTitle:configuration[SKItemButtonTitleKey] forState:UIControlStateNormal];
  [self.button setImage:configuration[SKItemButtonImageKey] forState:UIControlStateNormal];
  
  id buttonTarget = [configuration[SKItemButtonTargetKey] nonretainedObjectValue];
  SEL buttonAction = [configuration[SKItemButtonActionKey] pointerValue];
  
  if ([buttonTarget respondsToSelector:buttonAction]) {
    [self.button
      addTarget:buttonTarget
      action:buttonAction
      forControlEvents:UIControlEventTouchUpInside];
  } else {
    [self.button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  }
  
  self.button.topColor = configuration[SKItemButtonTopColorKey];
  self.button.bottomColor = configuration[SKItemButtonTopBottomColorKey];
  [self.button setTitleColor:configuration[SKItemButtonTitleColorKey] forState:UIControlStateNormal];
}

- (void)buttonPressed:(id)sender{
}
@end
