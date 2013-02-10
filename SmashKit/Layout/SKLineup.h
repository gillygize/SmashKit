#import <Foundation/Foundation.h>

@class SKLineup;
@class SKLayoutViewController;
@class SKItemViewController;

@protocol SKLineupDelegate <NSObject>

- (UIScrollView*)scrollViewForLineup:(SKLineup *)lineup;

@end

NSString * const SKLayoutSceneDefaultName;

@interface SKItem : NSObject

@property (strong, nonatomic) id object;
@property (strong, nonatomic) NSMutableDictionary *configuration;
@property (strong) Class viewControllerClass;
@property (weak, nonatomic) SKItemViewController *viewController;
@property (weak, nonatomic) id delegate;
@property CGFloat yPosition;
@property CGFloat height;

- (id)initWithObject:(id)object
 configuration:(NSMutableDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass;

- (id)initWithObject:(id)object
 configuration:(NSMutableDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass
 delegate:(id)delegate;

@end

@interface SKLineup : NSObject

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic, readonly) NSString *name;
@property (weak, nonatomic, readonly) SKLayoutViewController *layoutViewController;
@property (weak, nonatomic) id<SKLineupDelegate> delegate;
@property (weak, nonatomic) UIScrollView *scrollView;

- (id)initWithName:(NSString*)name
 layoutViewController:(SKLayoutViewController*)layoutViewController
 delegate:(id<SKLineupDelegate>)delegate;

- (void)prepareToShow;
- (void)prepareToHide;

- (void)addObject:(id)object
 configuration:(NSDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass;
- (void)addObject:(id)object
 configuration:(NSDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass
 delegate:(id)delegate;
- (void)addObjects:(NSArray*)objects
 configuration:(NSDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass;
- (void)addObjects:(NSArray*)objects
 configuration:(NSDictionary*)configuration
 width:(CGFloat)width
 viewControllerClass:(Class)viewControllerClass
 delegate:(id)delegate;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;
- (CGFloat)heightAtIndex:(NSUInteger)index;
- (SKItemViewController *)viewControllerAtIndex:(NSUInteger)index;
- (CGFloat)allObjectsHeight;

@end
