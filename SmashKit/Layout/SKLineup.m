#import "SKLineup.h"
#import "SKLayoutViewController.h"

NSString * const SKLayoutSceneDefaultName = @"SKLayoutSceneDefaultName";

@implementation SKItem

- (id)initWithObject:(id)object
 configuration:(NSMutableDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass {
  return [self
    initWithObject:object
    configuration:configuration
    width:width
    viewControllerClass:viewControllerClass
    delegate:nil];
}

- (id)initWithObject:(id)object
 configuration:(NSMutableDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass
 delegate:(id)delegate {
  if (self = [super init]) {
    self.viewControllerClass = viewControllerClass;
    self.configuration = configuration;
    self.configuration[SKItemWidthKey] = [NSNumber numberWithFloat:width];
    self.object = object;
    self.delegate = delegate;
  }
  return self;
}

@end

@interface SKLineup () <UIScrollViewDelegate>

@property (strong, nonatomic, readwrite) NSString *name;
@property NSRange visibleViewControllerRange;
@property (strong, nonatomic) NSMutableDictionary *recycledViewControllers;
@property (weak, nonatomic, readwrite) SKLayoutViewController *layoutViewController;
@property CGFloat currentYPosition;

@end

@implementation SKLineup

- (id)initWithFrame:(CGRect)frame
 name:(NSString*)name
 layoutViewController:(SKLayoutViewController*)layoutViewController
 delegate:(id<SKLineupDelegate>)delegate {
  if (self = [super initWithFrame:frame]) {
    self.name = name;
    self.layoutViewController = layoutViewController;
    self.items = [[NSMutableArray alloc] init];
    self.delegate = delegate;
    self.recycledViewControllers = [[NSMutableDictionary alloc] init];
    self.visibleViewControllerRange = NSMakeRange(0, 0);
    self.currentYPosition = 0.0f;    
  }
  return self;
}

- (void)prepareToShow {
  if (!self.scrollView) {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    [self addSubview:self.scrollView];
  }

  self.scrollView.delegate = self;

  [self tilePages];

  SKItem *lastItem = [self.items lastObject];
  
  self.scrollView.contentSize = CGSizeMake(
    lastItem.rect.size.width,
    lastItem.rect.origin.y + lastItem.rect.size.height
  );
}

- (void)prepareToHide {
  [self.scrollView removeFromSuperview];
  self.scrollView = nil;
  self.scrollView.delegate = nil;  
}

- (void)addObject:(id)object
 configuration:(NSDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass {
  [self addObject:object configuration:configuration width:width viewControllerClass:viewControllerClass delegate:nil];
}

- (void)addObject:(id)object
 configuration:(NSDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass
 delegate:(id)delegate {
  NSAssert([viewControllerClass isSubclassOfClass:[SKItemViewController class]],
    @"view controller is not a subclass of SKItemViewController");
 
  SKItem *item = [[SKItem alloc]
    initWithObject:object
    configuration:[NSMutableDictionary dictionaryWithDictionary:configuration]
    width:width
    viewControllerClass:viewControllerClass
    delegate:delegate];

  [viewControllerClass checkObject:item.object];
  [viewControllerClass setConfiguration:item.configuration withObject:item.object];
  [viewControllerClass checkConfiguration:item.configuration];
  [viewControllerClass setHeightWithConfiguration:item.configuration width:width];
  [viewControllerClass checkHeight:item.configuration];

  item.rect = CGRectMake(
    0.0f,
    self.currentYPosition,
    [item.configuration[SKItemWidthKey] floatValue],
    [item.configuration[SKItemHeightKey] floatValue]
  );

  self.currentYPosition += item.rect.size.height;

  [self.items addObject:item];
}

- (void)addObjects:(NSArray*)objects
 configuration:(NSDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass {
  [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [self addObject:obj configuration:configuration width:width viewControllerClass:viewControllerClass];
  }];
}

- (void)addObjects:(NSArray*)objects
 configuration:(NSDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass
 delegate:(id)delegate {
  [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [self
      addObject:obj
      configuration:configuration
      width:width
      viewControllerClass:viewControllerClass
      delegate:delegate];
  }];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
  [self.items removeObjectAtIndex:index];
}

- (void)removeAllObjects {
  [self.items removeAllObjects];
}

- (CGFloat)heightAtIndex:(NSUInteger)index {
  SKItem *item = [self sceneItemAtIndex:index];
  
  if (nil == item) {
    return 0.0f;
  }
  
  return item.rect.size.height;
}

- (SKItemViewController *)viewControllerAtIndex:(NSUInteger)index {
  SKItem *item = [self.items objectAtIndex:index];
  
  return item.viewController;
}

- (CGFloat)allObjectsHeight {
  CGFloat __block allObjectsHeight = 0.0f;

  [self.items enumerateObjectsUsingBlock:^(SKItem *item, NSUInteger idx, BOOL *stop){
    allObjectsHeight += [item.configuration[SKItemHeightKey] floatValue];
  }];

  return allObjectsHeight;
}

#pragma mark - Private Methods

- (SKItem *)sceneItemAtIndex:(NSUInteger)index {
  NSAssert(index < self.items.count, @"The index is higher than the number of layout items");
  return [self.items objectAtIndex:index];
}

- (NSInteger)numberOfRowsInScrollView:(UIScrollView *)scrollView {
  return self.items.count;
}

- (SKItemViewController *)scrollView:(UIScrollView *)scrollView itemViewControllerForIndex:(NSUInteger)index {
  SKItem *item = [self.items objectAtIndex:index];
  
  SKItemViewController *viewController = [self
    dequeueReusableItemViewControllerWithIdentifier:(id<NSCopying>)item.viewControllerClass];
  
  if (nil == viewController) {
    viewController = [[item.viewControllerClass alloc] initWithNibName:nil bundle:nil];
  }

  viewController.view.frame = item.rect;
  viewController.layoutViewController = self.layoutViewController;
  
  if (item.delegate) {
    viewController.delegate = item.delegate;
  }
  
  [viewController loadWithConfiguration:item.configuration];
  
  return viewController;
}

- (void)layoutSubviews{
  [self tilePages];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self setNeedsLayout];
}

- (void)tilePages {  
  CGRect visibleBounds = self.scrollView.bounds;
  
  CGFloat topPagePosition = CGRectGetMinY(visibleBounds);
  CGFloat bottomPagePosition = CGRectGetMaxY(visibleBounds);
  
  NSUInteger __block location = self.visibleViewControllerRange.location;
  NSUInteger __block length = self.visibleViewControllerRange.length;
  
  NSRange visibleRange = NSMakeRange(location, length);
  
  [self.items
    enumerateObjectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:visibleRange]
    options:0
    usingBlock:^(SKItem *item, NSUInteger idx, BOOL *stop) {
      BOOL rectIsInRange = CGRectIntersectsRect(item.rect, visibleBounds);
  
      if (item.viewController && !rectIsInRange) {
        if (topPagePosition > CGRectGetMaxY(item.rect)) {
          location++;
        }
      
        length--;
      
        NSMutableSet *recycledSetForClass = self.recycledViewControllers[(id<NSCopying>)item.viewControllerClass];
      
        if (!recycledSetForClass) {
          recycledSetForClass = [[NSMutableSet alloc] init];
          self.recycledViewControllers[(id<NSCopying>)item.viewControllerClass] = recycledSetForClass;
        }
      
        [recycledSetForClass addObject:item.viewController];
        [item.viewController.view removeFromSuperview];
        item.viewController = nil;
      }
    }];

  NSRange beforeVisibleRange = NSMakeRange(0, location);
  NSRange afterVisibleRange = NSMakeRange(
    location + length,
    self.items.count - (location + length)
  );
  
  [self.items
    enumerateObjectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:beforeVisibleRange]
    options:NSEnumerationReverse
    usingBlock:^(SKItem *item, NSUInteger idx, BOOL *stop) {
      BOOL rectIsInRange = CGRectIntersectsRect(item.rect, visibleBounds);
      
      if (rectIsInRange) {
        SKItemViewController *viewController = [self scrollView:self.scrollView itemViewControllerForIndex:idx];
      
        [self.scrollView addSubview:viewController.view];

        location = idx;
        length++;

        NSMutableSet *recycledSetForClass = self.recycledViewControllers[(id<NSCopying>)item.viewControllerClass];
        [recycledSetForClass removeObject:viewController];

        item.viewController = viewController;
      } else if (item.rect.origin.y > bottomPagePosition) {
        *stop = YES;
      }
    }];

  [self.items
    enumerateObjectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:afterVisibleRange]
    options:0
    usingBlock:^(SKItem *item, NSUInteger idx, BOOL *stop) {
      BOOL rectIsInRange = CGRectIntersectsRect(item.rect, visibleBounds);
      
      if (rectIsInRange) {
        SKItemViewController *viewController = [self scrollView:self.scrollView itemViewControllerForIndex:idx];
        [self.scrollView addSubview:viewController.view];

        length++;

        NSMutableSet *recycledSetForClass = self.recycledViewControllers[(id<NSCopying>)item.viewControllerClass];
        [recycledSetForClass removeObject:viewController];

        item.viewController = viewController;
      } else if (topPagePosition > CGRectGetMaxY(item.rect)) {
        *stop = YES;
      }
    }];
  
  self.visibleViewControllerRange = NSMakeRange(location, length);
}

- (SKItemViewController*)dequeueReusableItemViewControllerWithIdentifier:(id<NSCopying>)identifier {
  NSSet *recycledViewControllerSet = self.recycledViewControllers[identifier];
  
  if (!recycledViewControllerSet || recycledViewControllerSet.count == 0) {
    return nil;
  }  
  
  return [recycledViewControllerSet anyObject];
}

@end
