//
//  SKReedemedViewController.m
//  
//
//  Created by Matt on 11/8/12.
//  Copyright (c) 2012 Tamecco. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SKPopupViewController.h"
#import "SKGraphicsUtilities.h"

@implementation SKPopupViewController

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  self.view.backgroundColor = [UIColor clearColor];
  
  self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.containerView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
  [self.view addSubview:self.containerView];
}

- (void)showLineupWithName:(NSString *)sceneName {
  [super showLineupWithName:sceneName];
  self.currentScene = [self.lineupDict objectForKey:sceneName];
}

#pragma mark - Public Methods
- (void)displayViewInViewController:(UIViewController*)viewController {
  if (self == viewController) {
    return;
  }

  [viewController addChildViewController:self];

  self.view.frame = viewController.view.bounds;
  [viewController.view addSubview:self.view];
  [viewController addChildViewController:self];
  [self didMoveToParentViewController:viewController];
  
  self.currentScene.tableView.frame = CGRectMake(
    0.0f,
    0.0f,
    self.view.bounds.size.width,
    self.currentScene.allObjectsHeight
  );
  self.currentScene.tableView.center = self.view.center;
  [[self tableViewContainerView] addSubview:self.currentScene.tableView];

  CAAnimation *bounce = [self showAnimationWithOptions:nil];
  [[self.currentScene.tableView layer] addAnimation:bounce forKey:@"bounceAnimation"];
}

- (void)dismissFromParentViewController {
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self willMoveToParentViewController:nil];
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    });
  }];

  CAAnimation *dismiss = [self dismissAnimationWithOptions:nil];

  [[self.currentScene.tableView layer] addAnimation:dismiss forKey:@"dismissAnimation"];
  self.currentScene.tableView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
  [CATransaction commit];
}

- (CAAnimation*)showAnimationWithOptions:(NSDictionary*)userInfo {
  CAKeyframeAnimation *showAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  showAnimation.values = invertedBounceAnimationValues(100, 0.5f, 1.0);
  showAnimation.duration = 0.5f;
  
  return showAnimation;
}

- (CAAnimation*)dismissAnimationWithOptions:(NSDictionary*)userInfo {
  CABasicAnimation *dismiss = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  dismiss.fromValue = [NSNumber numberWithFloat:1.0f];
  dismiss.toValue = [NSNumber numberWithFloat:0.0f];
  dismiss.duration = 0.1f;
  
  return dismiss;
}

- (UIView*)tableViewContainerView {
  return self.containerView;
}

@end
