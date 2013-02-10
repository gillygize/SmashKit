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
@property (strong, nonatomic) NSMutableSet *visibleViewControllers;
@property (strong, nonatomic) NSMutableDictionary *recycledViewControllers;
@property (weak, nonatomic, readwrite) SKLayoutViewController *layoutViewController;
@property CGFloat currentYPosition;

@end

@implementation SKLineup

- (id)initWithName:(NSString*)name
 layoutViewController:(SKLayoutViewController*)layoutViewController
 delegate:(id<SKLineupDelegate>)delegate {
  if (self = [super init]) {
    self.name = name;
    self.layoutViewController = layoutViewController;
    self.items = [[NSMutableArray alloc] init];
    self.delegate = delegate;
    self.visibleViewControllers = [[NSMutableSet alloc] init];
    self.recycledViewControllers = [[NSMutableDictionary alloc] init];
    self.currentYPosition = 0.0f;
    
    [self tilePages];
  }
  return self;
}

- (void)prepareToShow {
  self.scrollView = [self.delegate scrollViewForLineup:self];
  self.scrollView.delegate = self;
}

- (void)prepareToHide {
  self.scrollView.delegate = nil;
}

- (void)addObject:(id)object
 configuration:(NSDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass {
  NSAssert([viewControllerClass isSubclassOfClass:[SKItemViewController class]],
    @"view controller is not a subclass of SKItemViewController");
 
  SKItem *item = [[SKItem alloc]
    initWithObject:object
    configuration:[NSMutableDictionary dictionaryWithDictionary:configuration]
    width:width
    viewControllerClass:viewControllerClass];

  [viewControllerClass checkObject:item.object];
  [viewControllerClass setConfiguration:item.configuration withObject:item.object];
  [viewControllerClass checkConfiguration:item.configuration];
  [viewControllerClass setHeightWithConfiguration:item.configuration width:width];
  [viewControllerClass checkHeight:item.configuration];

  [self.items addObject:item];
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
  
  return [item.configuration[SKItemHeightKey] floatValue];
}

- (SKItemViewController *)viewControllerAtIndex:(NSUInteger)index {
  UIScrollView *scrollView = [self.delegate scrollViewForLineup:self];
  return [self scrollView:scrollView itemViewControllerForIndex:index];
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
  
  item.yPosition = self.currentYPosition;
  item.height = [item.configuration[SKItemHeightKey] floatValue];
  
  SKItemViewController *viewController = [self
    dequeueReusableItemViewControllerWithIdentifier:(id<NSCopying>)item.viewControllerClass];
  
  if (nil == viewController) {
    viewController = [[SKItemViewController alloc] initWithNibName:nil bundle:nil];
  }
  
  viewController.view.frame = CGRectMake(
    0.0f,
    item.yPosition,
    [item.configuration[SKItemWidthKey] floatValue],
    item.height
  );
  viewController.layoutViewController = self.layoutViewController;
  
  self.currentYPosition += item.height;

  if (item.delegate) {
    viewController.delegate = item.delegate;
  }
  [viewController loadWithConfiguration:item.configuration];
  
  return viewController;
}

- (CGFloat)scrollView:(UIScrollView *)scrollView heightForRowAtIndex:(NSUInteger)index {
  SKItem *layoutItem = [self.items objectAtIndex:index];
  return [layoutItem.configuration[SKItemHeightKey] floatValue];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  [self tilePages];
}

- (void)tilePages {
  CGRect visibleBounds = self.scrollView.bounds;
  
  NSInteger firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
  NSInteger lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
  
  firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
  lastNeededPageIndex  = MIN(lastNeededPageIndex, self.items.count - 1);
    
  [self.items enumerateObjectsUsingBlock:^(SKItem *item, NSUInteger idx, BOOL *stop) {
    if (item.viewController && (idx < firstNeededPageIndex || idx > lastNeededPageIndex)) {
      NSMutableSet *recycledSetForClass = self.recycledViewControllers[(id<NSCopying>)item.viewControllerClass];
      
      if (!recycledSetForClass) {
        recycledSetForClass = [[NSMutableSet alloc] init];
      }
      
      [recycledSetForClass addObject:item.viewController];
      self.recycledViewControllers[(id<NSCopying>)item.viewControllerClass] = recycledSetForClass;
      [self.visibleViewControllers removeObject:item.viewController];
      [item.viewController.view removeFromSuperview];
      item.viewController = nil;
    }
  }];
  
  for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
    if (![self isDisplayingViewForIndex:index]) {
      SKItemViewController *viewController = [self scrollView:self.scrollView itemViewControllerForIndex:index];

      [self.scrollView addSubview:viewController.view];
      [self.visibleViewControllers addObject:viewController];
    }
  }
}

- (BOOL)isDisplayingViewForIndex:(NSUInteger)index {
  BOOL __block foundView = NO;
  
  [self.visibleViewControllers enumerateObjectsUsingBlock:^(UIViewController* viewController, BOOL *stop) {
    NSUInteger viewIndex = viewController.view.tag - 1;

    if (viewIndex == index) {
      *stop = foundView = YES;
    }
  }];
  
  return foundView;
}

- (SKItemViewController*)dequeueReusableItemViewControllerWithIdentifier:(id<NSCopying>)identifier {
  NSSet *recycledViewControllerSet = self.recycledViewControllers[identifier];
  
  if (!recycledViewControllerSet) {
    return nil;
  }
  
  return [recycledViewControllerSet anyObject];
}

@end
