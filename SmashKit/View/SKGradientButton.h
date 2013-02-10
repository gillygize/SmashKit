#import <UIKit/UIKit.h>

@interface SKGradientButton : UIButton

@property (strong, nonatomic) UIColor *topColor;
@property (strong, nonatomic) UIColor *bottomColor;

+ (CGSize)sizeWithImage:(UIImage*)image title:(NSString*)title width:(CGFloat)width;
+ (id)button;

@end

