#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SKLineup.h"

@protocol SKItemViewController <NSObject>
@end

@class SKLayoutViewController;

NSString * const SKItemHeightKey;
NSString * const SKItemWidthKey;
NSString * const SKItemLeftHorizontalMarginKey;
NSString * const SKItemRightHorizontalMarginKey;
NSString * const SKItemTopVerticalMarginKey;
NSString * const SKItemBottomVerticalMarginKey;

@interface SKItemViewController : UIViewController

@property (weak, nonatomic) SKLayoutViewController *layoutViewController;
@property (weak, nonatomic) id<SKItemViewController> delegate;

+ (void)checkObject:(id)object;
+ (void)setConfiguration:(NSMutableDictionary*)configuration withObject:(id)object;
+ (void)checkConfiguration:(NSMutableDictionary*)configuration;
+ (void)setHeightWithConfiguration:(NSMutableDictionary*)configuration width:(CGFloat)width;
+ (void)checkHeight:(NSMutableDictionary *)configuration;
- (void)loadWithConfiguration:(NSMutableDictionary*)configuration;

+ (Class)requiredObjectBaseClass;
+ (NSSet *)requiredConfigurationKeys;

@end

@interface SKLayoutViewController : UITableViewController <SKLineupDelegate>

@property (strong, nonatomic, readwrite) NSMutableDictionary *lineupDict;

- (void)setLineups:(NSArray*)lineups;
- (void)showLineupWithName:(NSString*)lineupName;
- (void)hideLineupWithName:(NSString*)lineupName;
- (SKLineup *)lineupWithName:(NSString*)name;

- (void)lineupWillShow:(SKLineup*)lineup;
- (void)lineupDidShow:(SKLineup*)lineup;
- (void)lineupWillHide:(SKLineup*)lineup;
- (void)lineupDidHide:(SKLineup*)lineup;
@end

