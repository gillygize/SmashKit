#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "SKTutorialViewController.h"

NSString const * SKTutorialViewControllerGoLeftKey = @"SKTutorialViewControllerGoLeftKey";

@interface SKTutorialViewController ()
@property (strong, nonatomic) UIView *clearView;
@end

@implementation SKTutorialViewController
- (void)loadView {
  [super loadView];

  self.clearView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.clearView.backgroundColor = [UIColor clearColor];

  [self.view addSubview:self.clearView];
}

- (void)didTransitionToLineup:(SKLineup *)lineup {
}

- (void)transitionToLineup:(SKLineup *)line animated:(BOOL)animated userInfo:(NSDictionary*)userInfo {
  UITableView *oldTableView = self.currentScene.tableView;

  void (^completionBlock)() = ^{
    [self didTransitionToLineup:line];
  };

  if (animated) {
    [CATransaction begin];
  }

  [oldTableView removeFromSuperview];
  [self showLineupWithName:line.name];
  self.currentScene.tableView.frame = CGRectMake(
    0.0f,
    0.0f,
    self.view.bounds.size.width,
    self.currentScene.allObjectsHeight
  );
  self.currentScene.tableView.center = self.view.center;
  [self.clearView addSubview:self.currentScene.tableView];
  
  NSAssert(line == self.currentScene, @"After setting a new scene, scene != self.currentScene");
  
  [self.clearView addSubview:self.currentScene.tableView];

  if (animated) {
    [CATransaction setCompletionBlock:completionBlock];
    
    CAAnimation *animation = [self transitionAnimationWithOptions:userInfo];
    
    [self.clearView.layer addAnimation:animation forKey:nil];
    [CATransaction commit];
  } else{
    completionBlock();
  }
}

- (UIView*)tableViewContainerView {
  return self.clearView;
}

- (CAAnimation*)transitionAnimationWithOptions:(NSDictionary*)userInfo {
  BOOL goLeft = [userInfo[SKTutorialViewControllerGoLeftKey] boolValue];

  CATransition *transition = [CATransition animation];
  transition.duration = 0.5f;
  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  transition.type = kCATransitionPush;
  transition.subtype = goLeft ? kCATransitionFromLeft : kCATransitionFromRight;
  return transition;
}

@end