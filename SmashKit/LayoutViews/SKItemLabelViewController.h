#import <Foundation/Foundation.h>
#import "SKLayoutViewController.h"

NSString * const SKItemLabelTextKey;
NSString * const SKItemLabelAttributedTextKey;
NSString * const SKItemLabelFontKey;
NSString * const SKItemLabelAlignmentKey;
NSString * const SKItemLabelTextColorKey;

@interface SKItemLabelViewController : SKItemViewController

@property (strong, nonatomic) UILabel *label;
@property (weak, nonatomic) SKLayoutViewController *layoutViewController;

@end