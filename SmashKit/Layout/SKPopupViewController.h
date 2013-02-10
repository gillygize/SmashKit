#import <UIKit/UIKit.h>
#import "SKLayoutViewController.h"

@interface SKPopupViewController : SKLayoutViewController

@property (weak, nonatomic) SKLineup *currentScene;
@property (strong, nonatomic) UIView *containerView;

- (UIView*)tableViewContainerView;

- (void)displayViewInViewController:(UIViewController*)viewController;
- (void)dismissFromParentViewController;

- (CAAnimation*)showAnimationWithOptions:(NSDictionary*)userInfo;
- (CAAnimation*)dismissAnimationWithOptions:(NSDictionary*)userInfo;
@end
