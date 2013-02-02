//
//  SKItemLabelViewController.h
//  Tamecco
//
//  Created by Matt on 10/26/12.


#import "SKItemLabelViewController.h"

NSString * const SKItemLabelTextKey = @"SKItemLabelTextKey";
NSString * const SKItemLabelFontKey = @"SKItemLabelFontKey";
NSString * const SKItemLabelAlignmentKey = @"SKItemLabelAlignmentKey";
NSString * const SKItemLabelTextColorKey = @"SKItemLabelTextColorKey";

@implementation SKItemLabelViewController

+ (NSSet*)requiredConfigurationKeys {
  return [NSSet setWithArray:@[SKItemLabelTextKey, SKItemLabelFontKey]];
}

+ (void)setConfiguration:(NSMutableDictionary *)configuration withObject:(id)object {
  if (!configuration[SKItemLabelTextColorKey]) {
    configuration[SKItemLabelTextColorKey] = [UIColor blackColor];
  }

  if (!configuration[SKItemLabelTextColorKey]) {
    configuration[SKItemLabelTextColorKey] = [UIColor blackColor];
  }
}

+ (void)setHeightWithConfiguration:(NSMutableDictionary *)configuration width:(CGFloat)width {
  configuration[SKItemHeightKey] = [NSNumber
    numberWithFloat:[configuration[SKItemLabelTextKey]
      sizeWithFont:configuration[SKItemLabelFontKey]
      constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
      lineBreakMode:UILineBreakModeWordWrap].height];
}

- (void)loadView {
  [super loadView];

  self.label = [[UILabel alloc] initWithFrame:CGRectZero];
  [self.view addSubview:self.label];
}

- (void)loadWithConfiguration:(NSMutableDictionary *)configuration {
  self.label.frame = CGRectMake(
    0.0f,
    0.0f,
    [configuration[SKItemWidthKey] floatValue],
    [configuration[SKItemHeightKey] floatValue]
  );
  self.label.font = configuration[SKItemLabelFontKey];
  self.label.text = configuration[SKItemLabelTextKey];
  self.label.textColor = configuration[SKItemLabelTextColorKey];
  self.label.textAlignment = [configuration[SKItemLabelAlignmentKey] integerValue];
  self.label.numberOfLines = 0;
  self.label.lineBreakMode = UILineBreakModeWordWrap;
}

@end