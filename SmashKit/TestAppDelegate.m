//
//  TestAppDelegate.m
//  SmashKit
//
//  Created by Matt on 1/19/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "TestAppDelegate.h"
#import "SKItemLabelViewController.h"
#import "SKItemButtonViewController.h"
#import "SKItemPagingScrollViewController.h"

@interface TestAppDelegate() <SKItemPagingScrollViewControllerDelegate>
@end

@implementation TestAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  self.layoutViewController = [[SKLayoutViewController alloc] initWithNibName:nil bundle:nil];
  
  SKLineup *testLineup = [[SKLineup alloc]
    initWithName:@"testScene"
    layoutViewController:self.layoutViewController
    delegate:self.layoutViewController];
  [testLineup
    addObject:nil
    configuration:@{
      SKItemLabelTextKey :@"Test over several lines",
      SKItemLabelFontKey :[UIFont fontWithName:@"Helvetica" size:40.0f]
    }
    width:self.window.bounds.size.width
    viewControllerClass:[SKItemLabelViewController class]];
  [testLineup
    addObject:nil
    configuration:@{
      SKItemPagingScrollViewArray: @[
        [UIColor blueColor],
        [UIColor redColor],
        [UIColor greenColor],
        [UIColor blueColor],
        [UIColor redColor],
        [UIColor purpleColor]
      ],
      SKItemHeightKey:@(200.0f)
    }
    width:self.window.bounds.size.width
    viewControllerClass:[SKItemPagingScrollViewController class]
    delegate:self];
  self.layoutViewController.lineups = @[testLineup];

  self.window.rootViewController = self.layoutViewController;
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  
  
  int64_t delayInSeconds = 1.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    self.popupViewController = [[SKPopupViewController alloc] initWithNibName:nil bundle:nil];
    SKLineup *popupLineup = [[SKLineup alloc]
      initWithName:@"popupScene"
      layoutViewController:self.popupViewController
      delegate:self.popupViewController];
    [popupLineup
      addObject:nil
      configuration:@{
        SKItemButtonTitleKey : @"Hello",
        SKItemButtonTargetKey : [NSValue valueWithNonretainedObject:self],
        SKItemButtonActionKey : [NSValue valueWithPointer:@selector(helloButtonPressed:)]
      }
      width:self.window.bounds.size.width
      viewControllerClass:[SKItemButtonViewController class]];
    self.popupViewController.lineups = @[popupLineup];
    [self.popupViewController displayViewInViewController:self.layoutViewController];
  });
  
  return YES;
}

- (void)helloButtonPressed:(id)sender {
  [self.popupViewController dismissFromParentViewController];
  
  int64_t delayInSeconds = 1.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    self.tutorialViewController = [[SKTutorialViewController alloc] initWithNibName:nil bundle:nil];
  
    SKLineup *tutorialScene1 = [[SKLineup alloc]
      initWithName:@"tutorialScene1"
      layoutViewController:self.popupViewController
      delegate:self.popupViewController];
    [tutorialScene1
      addObject:nil
      configuration:@{
        SKItemButtonTitleKey : @"Next",
        SKItemButtonTargetKey : [NSValue valueWithNonretainedObject:self],
        SKItemButtonActionKey : [NSValue valueWithPointer:@selector(nextButtonPressed:)]
      }
      width:self.window.bounds.size.width
      viewControllerClass:[SKItemButtonViewController class]];
  
    SKLineup *tutorialScene2 = [[SKLineup alloc]
      initWithName:@"tutorialScene2"
      layoutViewController:self.popupViewController
      delegate:self.popupViewController];
    [tutorialScene2
      addObject:nil
      configuration:@{
        SKItemButtonTitleKey : @"Close",
        SKItemButtonTargetKey : [NSValue valueWithNonretainedObject:self],
        SKItemButtonActionKey : [NSValue valueWithPointer:@selector(closeButtonPressed:)]
      }
      width:self.window.bounds.size.width
      viewControllerClass:[SKItemButtonViewController class]];
    self.tutorialViewController.lineups = @[tutorialScene1, tutorialScene2];
    [self.tutorialViewController displayViewInViewController:self.layoutViewController];
  });
}

- (void)nextButtonPressed:(id)sender {
  [self.tutorialViewController
    transitionToLineup:[self.tutorialViewController lineupWithName:@"tutorialScene2"]
    animated:YES userInfo:nil];
}

- (void)closeButtonPressed:(id)sender {
  [self.tutorialViewController dismissFromParentViewController];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - SKItemPagingScrollViewControllerDelegate
- (UIView*)viewForObject:(id)object atIndex:(NSUInteger)index {
  return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)configureView:(UIView*)view forObject:(id)object atIndex:(NSUInteger)index {
  view.backgroundColor = object;  
}

@end
