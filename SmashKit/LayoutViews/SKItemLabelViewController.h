//
//  SKLayoutItemBarcodeViewController.h
//  Tamecco
//
//  Created by Matt on 10/26/12.
//  Copyright (c) 2012 Tamecco. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SKLayoutViewController.h"

NSString * const SKItemLabelTextKey;
NSString * const SKItemLabelFontKey;
NSString * const SKItemLabelAlignmentKey;
NSString * const SKItemLabelTextColorKey;

@interface SKItemLabelViewController : SKItemViewController

@property (strong, nonatomic) UILabel *label;
@property (weak, nonatomic) SKLayoutViewController *layoutViewController;

@end