//
//  EqualizerPointView.h
//  iSub
//
//  Created by Ben Baron on 11/19/11.
//  Copyright (c) 2011 Ben Baron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "bass.h"

@class BassParamEqValue;
@interface EqualizerPointView : UIImageView

@property (strong) BassParamEqValue *eqValue;
@property (readonly) NSInteger frequency;
@property (readonly) CGFloat gain;
@property (readonly) HFX handle;
@property CGPoint position;
@property CGSize parentSize;

- (instancetype)initWithCGPoint:(CGPoint)point parentSize:(CGSize)size;
- (instancetype)initWithEqValue:(BassParamEqValue *)value parentSize:(CGSize)size;

- (CGFloat)percentXFromFrequency:(NSInteger)frequency;
- (CGFloat)percentYFromGain:(CGFloat)gain;

@end
