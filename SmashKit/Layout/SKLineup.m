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

@interface SKTableLayoutViewCell : UITableViewCell

@property (strong, nonatomic, readonly) SKItemViewController *viewController;
- (id)initWithLayoutItem:(SKItem *)item width:(CGFloat)width;

@end

@implementation SKTableLayoutViewCell

- (id)initWithLayoutItem:(SKItem *)item width:(CGFloat)width {
  if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(item.viewControllerClass)]) {
    _viewController = (SKItemViewController *)[[item.viewControllerClass alloc] initWithNibName:nil bundle:nil];
    _viewController.view.frame = CGRectMake(
      0.0f,
      0.0f,
      [item.configuration[SKItemWidthKey] floatValue],
      [item.configuration[SKItemHeightKey] floatValue]
    );
        
    [self.contentView addSubview:_viewController.view];
  }
  return self;
}

@end

@interface SKLineup ()

@property (strong, nonatomic, readwrite) NSString *name;
@property (weak, nonatomic, readwrite) SKLayoutViewController *layoutViewController;

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
  }
  return self;
}

- (void)prepareToShow {
  self.tableView = [self.delegate tableViewForLineup:self];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
}

- (void)prepareToHide {
  self.tableView.dataSource = nil;
  self.tableView.delegate = nil;
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
  UITableView *tableView = [self.delegate tableViewForLineup:self];
  
  SKTableLayoutViewCell *cell = (SKTableLayoutViewCell*)[tableView
    cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
  return cell.viewController;
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {  
  SKItem *layoutItem = [self.items objectAtIndex:[indexPath row]];
  
  NSString *identifier = NSStringFromClass(layoutItem.viewControllerClass);
  
  SKTableLayoutViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  
  if (nil == cell) {
    cell = [[SKTableLayoutViewCell alloc] initWithLayoutItem:layoutItem width:tableView.bounds.size.width];
    ((SKItemViewController *)cell.viewController).layoutViewController = self.layoutViewController;
  }

  if (layoutItem.delegate) {
    cell.viewController.delegate = layoutItem.delegate;
  }
  [cell.viewController loadWithConfiguration:layoutItem.configuration];
  
    
  return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  SKItem *layoutItem = [self.items objectAtIndex:[indexPath row]];
  return [layoutItem.configuration[SKItemHeightKey] floatValue];
}

@end
