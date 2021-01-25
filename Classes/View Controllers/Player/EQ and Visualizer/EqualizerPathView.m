//
//  EqualizerPathView.m
//  iSub
//
//  Created by Ben Baron on 1/27/12.
//  Copyright (c) 2012 Ben Baron. All rights reserved.
//

#import "EqualizerPathView.h"
#import "BassParamEqValue.h"
#import "SavedSettings.h"

static CGColorRef strokeColor;
static CGColorRef fillColorOff;
static CGColorRef fillColorOn;

@implementation EqualizerPathView

+ (void)initialize {
	strokeColor  = CGColorRetain([[UIColor alloc] initWithWhite:1. alpha:.5].CGColor);
	fillColorOff = CGColorRetain([[UIColor alloc] initWithWhite:1. alpha:.25].CGColor);
	fillColorOn  = CGColorRetain([[UIColor alloc] initWithRed:98./255. green:180./255. blue:223./255. alpha:.50].CGColor);
}

- (instancetype)init {
	if (self = [super init]) {
		points = NULL;
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		points = NULL;
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		points = NULL;
	}
	return self;
}

- (NSString *)stringFromFrequency:(NSInteger)frequency {
    if (frequency < 1000) {
		return [NSString stringWithFormat:@"%ld", (long)frequency];
    }
    
	return [NSString stringWithFormat:@"%ldk", (long)(frequency/1000)];
}

- (NSString *)stringFromGain:(CGFloat)gain {
    if ((int)gain == 0) {
		return [NSString stringWithFormat:@"%.0fdB", gain];
    } else if (gain == (int)gain) {
		return [NSString stringWithFormat:@"%.0fdB", gain];
    }
	return [NSString stringWithFormat:@"%.1fdB", gain];
}

- (void)drawTextLabelAtPoint:(CGPoint)point withString:(NSString *)string {
    [string drawAtPoint:point withAttributes:@{
        NSFontAttributeName : [UIFont fontWithName:@"Arial" size:10.0f],
        NSForegroundColorAttributeName: UIColor.whiteColor
    }];
}

- (void)drawTicksAndLabels {
	// Set font properties
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextSetTextMatrix(context, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
	CGContextSetTextDrawingMode(context, kCGTextFill);
	
	// Set drawing properties
    CGContextSetStrokeColorWithColor(context, strokeColor);
	CGContextSetFillColorWithColor(context, strokeColor);
    CGContextSetLineWidth(context, 1);
	
	// Create freq ticks and labels
	CGFloat bottom = self.frame.size.height;
	CGFloat tickHeight = self.frame.size.height / 30.0;
	CGFloat tickGap = self.frame.size.width / RANGE_OF_EXPONENTS;
	
	NSString *freqString = nil;
	for (int i = 0; i <= RANGE_OF_EXPONENTS; i++) {
		CGContextMoveToPoint(context, i*tickGap, bottom);
		CGContextAddLineToPoint(context, i*tickGap, bottom - tickHeight);
				
		freqString = [self stringFromFrequency:(MIN_FREQUENCY * (int)pow(2,i))];
		[self drawTextLabelAtPoint:CGPointMake(i*tickGap+4.0, (bottom-(tickHeight*0.75))) withString:freqString];
	}
	freqString = [self stringFromFrequency:MIN_FREQUENCY * (int)pow(2,RANGE_OF_EXPONENTS)];
	[self drawTextLabelAtPoint:CGPointMake(RANGE_OF_EXPONENTS*tickGap-20.0, (bottom-(tickHeight*0.75))) withString:freqString];
	
	// Create the decibel ticks and labels
	CGFloat leftTickGap = self.frame.size.height / 4.0;
	CGFloat decibelGap = MAX_GAIN / 2.0;
	NSString *decibelString = nil;
	for (int i = 0; i <= 3; i++) {
		CGContextMoveToPoint(context, 0.0, i*leftTickGap);
        if (i == 2) {
            // Draw the center line all the way across
            CGContextAddLineToPoint(context, self.frame.size.width, i*leftTickGap);
        } else {
            CGContextAddLineToPoint(context, tickHeight, i*leftTickGap);
        }
				
		decibelString = [self stringFromGain:MAX_GAIN - (decibelGap*i)];
		[self drawTextLabelAtPoint:CGPointMake(0.0, i*leftTickGap+4.0) withString:decibelString];
	}
    decibelString = [self stringFromGain:MAX_GAIN - (decibelGap*4)];
    [self drawTextLabelAtPoint:CGPointMake(0.0, 4*leftTickGap-30.0) withString:decibelString];
	CGContextStrokePath(context);
}

- (void)drawCurve {
	CGFloat octaveWidth = self.frame.size.width / RANGE_OF_EXPONENTS;
	CGFloat eqWidth = ((CGFloat)DEFAULT_BANDWIDTH / 12.0) * octaveWidth;
	CGFloat halfEqWidth = eqWidth / 2.0;
		
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, settingsS.isEqualizerOn ? fillColorOn : fillColorOff);
	CGContextSetBlendMode(context, kCGBlendModeLighten);
	
	for (int i = 0; i < length; i++) {
		CGPoint point = points[i];
		
		CGPoint start = CGPointMake(point.x - halfEqWidth, self.center.y);
		CGPoint end = CGPointMake(point.x + halfEqWidth, self.center.y);
		
		CGFloat modifier = point.y < self.center.y ? -1 : 1;
		CGFloat half = fabs(point.y - self.center.y);
		CGFloat controlY = point.y + half * modifier;
		CGPoint control = CGPointMake(point.x, controlY);

		CGContextMoveToPoint(context, start.x, start.y);
		CGContextAddQuadCurveToPoint(context, control.x, control.y, end.x, end.y);
		CGContextFillPath(context);
	}
}

- (void)drawRect:(CGRect)rect {
	// Draw the axis labels
	[self drawTicksAndLabels];
		
	// Smooth and draw the eq path
	[self drawCurve];
}

- (void)setPoints:(CGPoint *)thePoints length:(NSInteger)theLength {
    if (points != NULL) {
		free(points);
    }
	points = thePoints;
	length = theLength;
	[self setNeedsDisplay];
}

@end
