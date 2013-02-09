//
//  SKItemLabelViewController.h
//  Tamecco
//
//  Created by Matt on 10/26/12.


#import "SKItemLabelViewController.h"

NSString * const SKItemLabelTextKey = @"SKItemLabelTextKey";
NSString * const SKItemLabelAttributedTextKey = @"SKItemLabelAttibutedTextKey";
NSString * const SKItemLabelFontKey = @"SKItemLabelFontKey";
NSString * const SKItemLabelAlignmentKey = @"SKItemLabelAlignmentKey";
NSString * const SKItemLabelTextColorKey = @"SKItemLabelTextColorKey";

@implementation SKItemLabelViewController

+ (NSSet*)requiredConfigurationKeys {
  return nil;
}

+ (void)setConfiguration:(NSMutableDictionary *)configuration withObject:(id)object {
  if (!configuration[SKItemLabelFontKey]) {
    configuration[SKItemLabelFontKey] = [UIFont systemFontOfSize:13.0f];
  }
  
  if (!configuration[SKItemLabelTextColorKey]) {
    configuration[SKItemLabelTextColorKey] = [UIColor blackColor];
  }

  if (!configuration[SKItemLabelTextColorKey]) {
    configuration[SKItemLabelTextColorKey] = [UIColor blackColor];
  }
}

+ (void)setHeightWithConfiguration:(NSMutableDictionary *)configuration width:(CGFloat)width {
  if (configuration[SKItemLabelAttributedTextKey]) {
    configuration[SKItemHeightKey] = @([configuration[SKItemLabelAttributedTextKey] size].height);
  } else {
    configuration[SKItemHeightKey] = @([configuration[SKItemLabelTextKey]
      sizeWithFont:configuration[SKItemLabelFontKey]
      constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
      lineBreakMode:UILineBreakModeWordWrap].height);
  }
}

- (void)loadView {
  [super loadView];

  self.label = [[UILabel alloc] initWithFrame:CGRectZero];
  [self.view addSubview:self.label];
}

- (void)loadWithConfiguration:(NSMutableDictionary *)configuration {
  self.label.frame = CGRectMake(
    [configuration[SKItemLeftHorizontalMarginKey] floatValue],
    [configuration[SKItemTopVerticalMarginKey] floatValue],
    [configuration[SKItemWidthKey] floatValue] -
      [configuration[SKItemLeftHorizontalMarginKey] floatValue] -
      [configuration[SKItemRightHorizontalMarginKey] floatValue],
    [configuration[SKItemHeightKey] floatValue] -
      [configuration[SKItemTopVerticalMarginKey] floatValue] -
      [configuration[SKItemBottomVerticalMarginKey] floatValue]
  );
  self.label.font = configuration[SKItemLabelFontKey];
  self.label.text = configuration[SKItemLabelTextKey];
  self.label.attributedText = configuration[SKItemLabelAttributedTextKey];
  self.label.textColor = configuration[SKItemLabelTextColorKey];
  self.label.textAlignment = [configuration[SKItemLabelAlignmentKey] integerValue];
  self.label.numberOfLines = 0;
  self.label.lineBreakMode = UILineBreakModeWordWrap;
}

@end