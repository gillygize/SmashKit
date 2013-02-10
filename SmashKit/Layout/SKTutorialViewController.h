#import <Foundation/Foundation.h>
#import "SKPopupViewController.h"
#import "SKLineup.h"

NSString const * SKTutorialViewControllerGoLeftKey;

@interface SKTutorialViewController : SKPopupViewController

- (void)didTransitionToLineup:(SKLineup *)lineup;
- (void)transitionToLineup:(SKLineup *)line animated:(BOOL)animated userInfo:(NSDictionary*)userInfo;

- (CAAnimation*)transitionAnimationWithOptions:(NSDictionary*)userInfo;

@end