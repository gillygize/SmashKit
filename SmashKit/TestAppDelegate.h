//
//  TestAppDelegate.h
//  SmashKit
//
//  Created by Matt on 1/19/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKLayoutViewController.h"
#import "SKTutorialViewController.h"

@interface TestAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SKLayoutViewController *layoutViewController;
@property (strong, nonatomic) SKPopupViewController *popupViewController;
@property (strong, nonatomic) SKTutorialViewController *tutorialViewController;

@end
