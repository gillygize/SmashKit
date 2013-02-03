//
//  SKLayoutViewController.m
//  
//
//  Created by Matt on 10/19/12.
//
//

#import "SKLayoutViewController.h"
#import "SKLineup.h"

NSString * const SKItemHeightKey = @"SKItemHeightKey";
NSString * const SKItemWidthKey = @"SKItemWidthKey";

@implementation SKItemViewController : UIViewController

#pragma mark - Public methods

+ (Class)requiredObjectBaseClass {
  return nil;
}

+ (NSSet*)requiredConfigurationKeys {
  return nil;
}

+ (Protocol *)requiredDelegateProtocol {
  return nil;
}

+ (void)checkObject:(id)object {
  Class requiredObjectBaseClass = [self requiredObjectBaseClass];

  if (object || requiredObjectBaseClass) {
    NSAssert1(
      [object isKindOfClass:requiredObjectBaseClass],
      @"object is not a kind of class %@",
      NSStringFromClass(requiredObjectBaseClass)
    );
  }  
}

+ (void)setConfiguration:(NSMutableDictionary*)configuration withObject:(id)object {
}

+ (void)checkConfiguration:(NSMutableDictionary*)configuration {
  NSSet *allKeysSet = [NSSet setWithArray:[configuration allKeys]];
  NSSet *requiredConfigurationKeys = [self requiredConfigurationKeys];
  NSSet *absentKeys = [requiredConfigurationKeys objectsPassingTest:^BOOL(id obj, BOOL *stop) {
    return ![allKeysSet containsObject:obj];
  }];
  NSAssert(absentKeys.count == 0, @"Required keys: %@ are not found", absentKeys);
}

+ (void)setHeightWithConfiguration:(NSMutableDictionary*)configuration width:(CGFloat)width {
}

+ (void)checkHeight:(NSMutableDictionary *)configuration {
  NSAssert(
    nil != configuration[SKItemHeightKey],
    @"height is not defined.  Set the value of the SKLayoutHeightKey in setHeightWithConfiguration:width: or when the layout item is created"
  );
}

- (void)loadWithConfiguration:(NSMutableDictionary*)configuration {
}

@end

@implementation SKLayoutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.lineupDict = [[NSMutableDictionary alloc] initWithCapacity:8];
    self.recycledTableViews = [[NSMutableSet alloc] initWithCapacity:2];
    self.usedTableViews = [[NSMutableSet alloc] initWithCapacity:2];
    
    SKLineup *defaultScene = [[SKLineup alloc]
      initWithName:SKLayoutSceneDefaultName
      layoutViewController:self
      delegate:self];
    [self setLineups:@[defaultScene]];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  self.view.backgroundColor = [UIColor whiteColor];    
}

- (void)setLineups:(NSArray *)collections {
  if (nil == collections || collections.count < 1) {
    return;
  }

  [self.lineupDict enumerateKeysAndObjectsUsingBlock:^(id key, SKLineup *scene, BOOL *stop) {
    [self hideLineupWithName:scene.name];
  }];

  [self.lineupDict removeAllObjects];
  
  [collections enumerateObjectsUsingBlock:^(SKLineup *scene, NSUInteger idx, BOOL *stop) {
    NSAssert([scene isKindOfClass:[SKLineup class]], @"Object is not a SKLineup");
    [self.lineupDict setObject:scene forKey:scene.name];
    scene.delegate = self;
  }];

  [self showLineupWithName:((SKLineup *) collections[0]).name];
}

- (void)showLineupWithName:(NSString*)sceneName {
  SKLineup *scene = [self.lineupDict objectForKey:sceneName];
  [scene prepareToShow];
  [self.view addSubview:scene.tableView];
}

- (void)hideLineupWithName:(NSString *)sceneName {
  SKLineup *scene = [self.lineupDict objectForKey:sceneName];
  UITableView *tableView = scene.tableView;

  [scene prepareToHide];
  
  [self.recycledTableViews addObject:tableView];
  [self.usedTableViews removeObject:tableView];
}

- (SKLineup *)lineupWithName:(NSString *)name {
  return [self.lineupDict objectForKey:name];
}

#pragma mark - SKLayoutSceneDelegate
- (UITableView*)tableViewForLineup:(SKLineup *)scene {
  if (scene.tableView) {
    return scene.tableView;
  }

  UITableView *tableView = [self.recycledTableViews anyObject];
  
  if (tableView == nil) {
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.allowsSelection = NO;
    
    [self.usedTableViews addObject:tableView];
  } else {
    [self.usedTableViews addObject:tableView];
    [self.recycledTableViews removeObject:tableView];
  }
  
  return tableView;
}

@end
