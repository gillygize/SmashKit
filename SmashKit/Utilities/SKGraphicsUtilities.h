void drawLinearGradient(CGContextRef context, CGRect rect, UIColor *startColor, UIColor *endColor);
void drawDimmingEffect(CGContextRef context, CGRect rect);
void drawOnePixelStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, UIColor *color);
void drawCircle(CGRect rect, CGFloat lineWidth);

CGRect CGRectForCombinedImageViewAndLabel(UIImageView *imageSubview, UILabel *labelSubview, CGFloat horizontalMargin, CGFloat width);
CGSize CGSizeWithImageAndTitle(UIImage *image, NSString *title, CGFloat horizontalMargin, CGFloat width);
void positionCombinedImageViewAndLabelInsideRect(CGRect rect, UIImageView *imageSubview, UILabel *labelSubview);

NSArray * bounceAnimationValues(NSUInteger steps, CGFloat duration, CGFloat multiplier);
NSArray * invertedBounceAnimationValues(NSUInteger steps, CGFloat duration, CGFloat multiplier);