//
//  SKGraphicsUtilties.h
//  Tamecco
//
//  Created by Matt on 12/10/12.
//  Copyright (c) 2012 Tamecco. All rights reserved.
//

#import "SKGraphicsUtilities.h"

void drawLinearGradient(CGContextRef context, CGRect rect, UIColor *startColor, UIColor *endColor) {
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGFloat locations[] = { 0.0, 1.0 };
 
  NSArray *colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
 
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
 
  CGContextSaveGState(context);
  CGContextAddRect(context, rect);
  CGContextClip(context);
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGContextRestoreGState(context);
 
  CGGradientRelease(gradient);
  CGColorSpaceRelease(colorSpace);
}

void drawDimmingEffect(CGContextRef context, CGRect rect) {
  CGContextSaveGState(context);
  CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f].CGColor);
  CGContextFillRect(context, rect);
  CGContextRestoreGState(context);
}

void drawOnePixelStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, UIColor *color) {
  CGContextSaveGState(context);
  CGContextSetLineCap(context, kCGLineCapSquare);
  CGContextSetStrokeColorWithColor(context, color.CGColor);
  CGContextSetLineWidth(context, 1.0);
  CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
  CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
  CGContextStrokePath(context);
  CGContextRestoreGState(context);
}

void drawCircle(CGRect rect, CGFloat lineWidth) {
  UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(
    rect.origin.x+lineWidth,
    rect.origin.y+lineWidth,
    rect.size.width-2.0f*lineWidth,
    rect.size.height-2.0f*lineWidth
  )];
  [[UIColor clearColor] setFill];
  [ovalPath fill];
  [[UIColor redColor] setStroke];
  ovalPath.lineWidth = lineWidth;
  [ovalPath stroke];
}

CGSize CGSizeWithImageAndTitle(UIImage *image, NSString *title, CGFloat horizontalMargin, CGFloat width) {
  CGSize labelSize = CGSizeZero;
  
  if (nil == image) {
    labelSize = [title
      sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f]
      constrainedToSize:CGSizeMake(width - 2.0 * horizontalMargin, CGFLOAT_MAX)
      lineBreakMode:UILineBreakModeCharacterWrap];  
  } else {
    labelSize = [title
      sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f]
      constrainedToSize:CGSizeMake(width - image.size.width - 3.0 * horizontalMargin, CGFLOAT_MAX)
      lineBreakMode:UILineBreakModeCharacterWrap];
  }
 
  return CGSizeMake(
    width,
    MAX(image.size.height, labelSize.height)
  );
}

CGRect CGRectForCombinedImageViewAndLabel(UIImageView *imageSubview, UILabel *labelSubview, CGFloat horizontalMargin, CGFloat width) {
  CGSize size = CGSizeWithImageAndTitle(imageSubview.image, labelSubview.text, horizontalMargin, width);

  CGRect imageAndLabelCombinedFrame = CGRectMake(
    0.0f,
    0.0f,
    size.width,
    size.height
  );
    
  CGRect imageFrame, labelFrame;
  CGRectDivide(
    imageAndLabelCombinedFrame,
    &imageFrame,
    &labelFrame,
    imageSubview.bounds.size.width + horizontalMargin,
    CGRectMinXEdge
  );
    
  imageSubview.frame = CGRectMake(
    imageFrame.origin.x + 5.0f,
    imageFrame.origin.y,
    imageFrame.size.width - 5.0f,
    imageFrame.size.height
  );
  labelSubview.frame = CGRectMake(
    labelFrame.origin.x + 5.0f,
    labelFrame.origin.y,
    labelFrame.size.width - 10.0f,
    labelFrame.size.height
  );
  
  return imageAndLabelCombinedFrame;
}

void positionCombinedImageViewAndLabelInsideRect(CGRect rect, UIImageView *imageSubview, UILabel *labelSubview) {
  if (nil == imageSubview.image) {
    labelSubview.textAlignment = UITextAlignmentCenter;
    return;
  }
  
  CGRect containerRect = CGRectForCombinedImageViewAndLabel(imageSubview, labelSubview, 5.0f, rect.size.width);
  
  labelSubview.textAlignment = UITextAlignmentLeft;
  
  imageSubview.frame = CGRectMake(
    imageSubview.frame.origin.x,
    (rect.size.height - containerRect.size.height) / 2.0f,
    imageSubview.frame.size.width,
    imageSubview.frame.size.height
  );
  labelSubview.frame = CGRectMake(
    labelSubview.frame.origin.x,
    (rect.size.height - containerRect.size.height) / 2.0f,
    labelSubview.frame.size.width,
    labelSubview.frame.size.height
  );
}

NSArray * bounceAnimationValues(NSUInteger steps, CGFloat duration, CGFloat multiplier) {
  NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
  CGFloat e = M_E;
  
  for (int i = 0; i < steps; i++) {
    CGFloat currentStep = i * duration / steps;
  
    CGFloat currentValue = multiplier * pow(e, -5 * currentStep) * cos(10 * currentStep);
    [values addObject:[NSNumber numberWithFloat:currentValue]];
  }

  return values;
}

NSArray * invertedBounceAnimationValues(NSUInteger steps, CGFloat duration, CGFloat multiplier) {
  NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
  CGFloat e = M_E;
  
  for (int i = 0; i < steps; i++) {
    CGFloat currentStep = ((CGFloat) i) / steps;
    CGFloat currentValue = (1 - pow(e, -5 * currentStep) * cos(10 * currentStep)) * multiplier;
    
    [values addObject:[NSNumber numberWithFloat:currentValue]];
  }

  return values;
}