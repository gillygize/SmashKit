#import <UIKit/UIKit.h>
#import "SKLayoutViewController.h"
#import "SKGradientButton.h"

NSString * const SKItemButtonImageKey;
NSString * const SKItemButtonTitleKey;
NSString * const SKItemButtonEventNameKey;
NSString * const SKItemButtonTargetKey;
NSString * const SKItemButtonActionKey;
NSString * const SKItemButtonTitleColorKey;
NSString * const SKItemButtonTopColorKey;
NSString * const SKItemButtonTopBottomColorKey;

@interface SKItemButtonViewController : SKItemViewController

@property (strong, nonatomic) SKGradientButton *button;

- (void)buttonPressed:(id)sender;

@end
