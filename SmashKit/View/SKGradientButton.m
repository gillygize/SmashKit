#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "SKGradientButton.h"
#import "SKGraphicsUtilities.h"

@interface UIButton(SKGradientButtonExtensions)
@end

@implementation UIButton(SKGradientButtonExtensions)

static char topColorKey;
static char bottomColorKey;

- (void)setTopColor:(UIColor*)topColor {
  objc_setAssociatedObject(self, &topColorKey, topColor, OBJC_ASSOCIATION_RETAIN);
}

- (UIColor*)topColor{
  return objc_getAssociatedObject(self, &topColorKey);
}

- (void)setBottomColor:(UIColor*)bottomColor {
  objc_setAssociatedObject(self, &topColorKey, bottomColor, OBJC_ASSOCIATION_RETAIN);
}

- (UIColor*)bottomColor{
  return objc_getAssociatedObject(self, &bottomColorKey);
}
@end

@implementation SKGradientButton

+ (id)button {
  UIButton *button = [super buttonWithType:UIButtonTypeCustom];
    
  button.layer.borderWidth = 1.0f;
  button.layer.borderColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:142.0f/255.0f alpha:1.0f].CGColor;
  button.layer.masksToBounds = YES;
  button.layer.cornerRadius = 8.0f;
  
  [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
  [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

  button.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
  button.titleLabel.numberOfLines = 0;
  button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
  
  button.imageView.contentMode = UIViewContentModeScaleAspectFit;

  button.topColor = [UIColor whiteColor];
  button.bottomColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];

  return button;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  drawLinearGradient(context, rect, self.topColor, self.bottomColor);

  if (self.highlighted) {
    drawDimmingEffect(context, rect);
  }
}

- (void)setEnabled:(BOOL)enabled {
  CGFloat topColorRed = 1.0f, topColorGreen = 1.0f, topColorBlue = 1.0f, topColorAlpha = 1.0f;
  CGFloat bottomColorRed = 1.0f, bottomColorGreen = 1.0f, bottomColorBlue = 1.0f, bottomColorAlpha = 1.0f;

  [self.topColor getRed:&topColorRed green:&topColorGreen blue:&topColorBlue alpha:&topColorAlpha];
  [self.bottomColor getRed:&bottomColorRed green:&bottomColorGreen blue:&bottomColorBlue alpha:&bottomColorAlpha];

  if (!enabled) {
    self.topColor = [UIColor colorWithRed:topColorRed green:topColorGreen blue:topColorBlue alpha:0.8f];
    self.bottomColor = [UIColor colorWithRed:bottomColorRed green:bottomColorGreen blue:bottomColorBlue alpha:0.8f];
  } else{
    self.topColor = [UIColor colorWithRed:topColorRed green:topColorGreen blue:topColorBlue alpha:1.0f];
    self.bottomColor = [UIColor colorWithRed:bottomColorRed green:bottomColorGreen blue:bottomColorBlue alpha:1.0f];
  }

  [super setEnabled:enabled];
  [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  [self setNeedsDisplay];
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  positionCombinedImageViewAndLabelInsideRect(self.bounds, self.imageView, self.titleLabel);
}

+ (CGSize)sizeWithImage:(UIImage*)image title:(NSString*)title width:(CGFloat)width {
  return CGSizeWithImageAndTitle(image, title, 5.0f, width);
}
@end
