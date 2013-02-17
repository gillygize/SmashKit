#import "SKLayoutViewController.h"
#import "SKLineup.h"

NSString * const SKItemHeightKey = @"SKItemHeightKey";
NSString * const SKItemWidthKey = @"SKItemWidthKey";
NSString * const SKItemLeftHorizontalMarginKey = @"SKItemLeftHorizontalMarginKey";
NSString * const SKItemRightHorizontalMarginKey = @"SKItemRightHorizontalMarginKey";
NSString * const SKItemTopVericalMarginKey = @"SKItemTopVericalMarginKey";
NSString * const SKItemBottomVerticalMarginKey = @"SKItemBottomVerticalMarginKey";

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

  if (!configuration[SKItemLeftHorizontalMarginKey]) {
    configuration[SKItemLeftHorizontalMarginKey] = @(0.0f);
  }

  if (!configuration[SKItemRightHorizontalMarginKey]) {
    configuration[SKItemLeftHorizontalMarginKey] = @(0.0f);
  }

  if (!configuration[SKItemTopVericalMarginKey]) {
    configuration[SKItemTopVericalMarginKey] = @(0.0f);
  }
  
  if (!configuration[SKItemBottomVerticalMarginKey]) {
    configuration[SKItemBottomVerticalMarginKey] = @(0.0f);
  }
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
    SKLineup *defaultScene = [[SKLineup alloc]
      initWithFrame:[[UIScreen mainScreen] applicationFrame]
      name:SKLayoutSceneDefaultName
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
  self.view = [self lineupWithName:SKLayoutSceneDefaultName];
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
  SKLineup *lineup = [self.lineupDict objectForKey:sceneName];

  [self lineupWillShow:lineup];

  [lineup prepareToShow];

  [self lineupDidShow:lineup];
}

- (void)hideLineupWithName:(NSString *)sceneName {
  SKLineup *lineup = [self.lineupDict objectForKey:sceneName];

  [self lineupWillHide:lineup];

  [lineup prepareToHide];

  [self lineupDidHide:lineup];
}

- (void)lineupWillShow:(SKLineup*)lineup {}
- (void)lineupDidShow:(SKLineup*)lineup {}
- (void)lineupWillHide:(SKLineup*)lineup {}
- (void)lineupDidHide:(SKLineup *)lineup {}

- (SKLineup *)lineupWithName:(NSString *)name {
  return [self.lineupDict objectForKey:name];
}

@end
