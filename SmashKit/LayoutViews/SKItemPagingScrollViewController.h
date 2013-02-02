//
//  SKItemPagingScrollViewController.h
//  SmashKit
//
//  Created by Matt on 1/27/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "SKLayoutViewController.h"

@protocol SKItemPagingScrollViewControllerDelegate <SKItemViewController>
- (UIView*)viewForObject:(id)object atIndex:(NSUInteger)index;
- (void)configureView:(UIView*)view forObject:(id)object atIndex:(NSUInteger)index;
@end

NSString * const SKItemPagingScrollViewArray;

@interface SKItemPagingScrollViewController : SKItemViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *objects;
@property (weak, nonatomic) id<SKItemPagingScrollViewControllerDelegate> delegate;

@end
