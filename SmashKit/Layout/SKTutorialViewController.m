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
  UIScrollView *oldScrollView = self.currentScene.scrollView;

  void (^completionBlock)() = ^{
    [self didTransitionToLineup:line];
  };

  if (animated) {
    [CATransaction begin];
  }

  [oldScrollView removeFromSuperview];
  [self showLineupWithName:line.name];
  self.currentScene.scrollView.frame = CGRectMake(
    0.0f,
    0.0f,
    self.view.bounds.size.width,
    self.currentScene.allObjectsHeight
  );
  self.currentScene.scrollView.center = self.view.center;
  [self.clearView addSubview:self.currentScene.scrollView];
  
  NSAssert(line == self.currentScene, @"After setting a new scene, scene != self.currentScene");
  
  [self.clearView addSubview:self.currentScene.scrollView];

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