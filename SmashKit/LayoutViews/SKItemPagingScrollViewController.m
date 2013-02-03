//
//  SKItemPagingScrollViewController.m
//  SmashKit
//
//  Created by Matt on 1/27/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "SKItemPagingScrollViewController.h"

@interface SKItemPagingScrollViewController ()

@property (nonatomic, strong) NSMutableSet *recycledViews;
@property (nonatomic, strong) NSMutableSet *visibleViews;

@end

NSString * const SKItemPagingScrollViewArray = @"SKItemPagingScrollViewArray";

@implementation SKItemPagingScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.recycledViews = [[NSMutableSet alloc] init];
    self.visibleViews = [[NSMutableSet alloc] init];
  }
  return self;
}

- (void)loadView {
  [super loadView];
  
  self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
  [self.view addSubview:self.scrollView];
}

- (void)loadWithConfiguration:(NSMutableDictionary *)configuration {
  self.objects = configuration[SKItemPagingScrollViewArray];

  if (self.objects.count == 0) {
    return;
  }

  self.scrollView.frame = CGRectMake(
    [configuration[SKItemLeftHorizontalMarginKey] floatValue],
    [configuration[SKItemTopVerticalMarginKey] floatValue],
    [configuration[SKItemWidthKey] floatValue] -
      [configuration[SKItemLeftHorizontalMarginKey] floatValue] -
      [configuration[SKItemRightHorizontalMarginKey] floatValue],
    [configuration[SKItemHeightKey] floatValue] -
      [configuration[SKItemTopVerticalMarginKey] floatValue] -
      [configuration[SKItemBottomVerticalMarginKey] floatValue]
  );
  self.scrollView.pagingEnabled = YES;
  self.scrollView.backgroundColor = [UIColor clearColor];
  self.scrollView.showsVerticalScrollIndicator = NO;
  self.scrollView.showsHorizontalScrollIndicator = NO;
  self.scrollView.contentSize = CGSizeMake(
    [configuration[SKItemWidthKey] floatValue] * self.objects.count,
    [configuration[SKItemHeightKey] floatValue]
  );
  self.scrollView.delegate = self;
  
  [self tilePages];
}

- (void)tilePages {
  CGRect visibleBounds = self.scrollView.bounds;
  
  NSInteger firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
  NSInteger lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
  
  firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
  lastNeededPageIndex  = MIN(lastNeededPageIndex, self.objects.count - 1);
    
  for (UIView *view in self.visibleViews) {
    NSUInteger viewIndex = view.tag - 1;
  
    if (viewIndex < firstNeededPageIndex || viewIndex > lastNeededPageIndex) {
      [self.recycledViews addObject:view];
      [view removeFromSuperview];
    }
  }
  
  [self.visibleViews minusSet:self.recycledViews];
    
  for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
    if (![self isDisplayingViewForIndex:index]) {
      UIView *view = [self dequeueRecycledView];
      
      if (view == nil) {
        view = [self.delegate viewForObject:self.objects[index] atIndex:index];
      }
      
      view.frame = [self frameForViewAtIndex:index];
      view.tag = index + 1;
      
      [self.delegate configureView:view forObject:self.objects[index] atIndex:index];
      
      [self.scrollView addSubview:view];
      [self.visibleViews addObject:view];
    }
  }
}

- (BOOL)isDisplayingViewForIndex:(NSUInteger)index {
  BOOL foundView = NO;
  
  for (UIView *view in self.visibleViews) {
    NSUInteger viewIndex = view.tag - 1;

    if (viewIndex == index) {
      foundView = YES;
      break;
    }
  }
  
  return foundView;
}

- (UIView *)dequeueRecycledView {
  UIView *view = [self.recycledViews anyObject];

  if (view) {
    [self.recycledViews removeObject:view];
  }

  return view;
}

- (CGRect)frameForViewAtIndex:(NSUInteger)index {
  CGRect bounds = self.scrollView.bounds;
  CGRect pageFrame = bounds;
  pageFrame.origin.x = (bounds.size.width * index);
  
  return pageFrame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  [self tilePages];
}

@end
