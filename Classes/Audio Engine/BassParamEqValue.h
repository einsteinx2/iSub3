//
//  EqualizerValue.h
//  iSub
//
//  Created by Ben Baron on 11/19/11.
//  Copyright (c) 2011 Ben Baron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "bass.h"

#define MIN_FREQUENCY 32
#define MAX_FREQUENCY 16384
#define RANGE_OF_EXPONENTS 9

#define MIN_GAIN -6
#define MAX_GAIN 6

#define DEFAULT_BANDWIDTH 18

@interface BassParamEqValue : NSObject

@property BASS_DX8_PARAMEQ parameters;
@property HFX handle;
@property NSInteger arrayIndex;

@property float frequency;
@property float gain;
@property float bandwidth;

- (instancetype)initWithParameters:(BASS_DX8_PARAMEQ)params handle:(HFX)theHandle arrayIndex:(NSInteger)index;
+ (BassParamEqValue *)valueWithParams:(BASS_DX8_PARAMEQ)params handle:(HFX)theHandle arrayIndex:(NSInteger)index;

- (instancetype)initWithParameters:(BASS_DX8_PARAMEQ)parameters;
+ (BassParamEqValue *)valueWithParams:(BASS_DX8_PARAMEQ)parameters;

- (instancetype)initWithParameters:(BASS_DX8_PARAMEQ)parameters arrayIndex:(NSInteger)index;
+ (BassParamEqValue *)valueWithParams:(BASS_DX8_PARAMEQ)parameters arrayIndex:(NSInteger)index;

BASS_DX8_PARAMEQ BASS_DX8_PARAMEQMake(float center, float gain, float bandwidth);
BASS_DX8_PARAMEQ BASS_DX8_PARAMEQFromPoint(float percentX, float percentY, float bandwidth);

@end
