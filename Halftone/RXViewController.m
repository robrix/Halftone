//
//  RXViewController.m
//  Halftone
//
//  Created by Rob Rix on 2013-02-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.
//

#import "RXViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RXViewController ()
@end

@implementation RXViewController {
	CADisplayLink *_displayLink;
}

+(void)initialize {
	srandomdev();
}

-(void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(dot:)];
//	_displayLink.frameInterval = 10;
	[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}


typedef struct {
	CGFloat min, max;
} RXInterval;

static inline CGFloat RXIntervalLength(RXInterval interval) {
	return interval.max - interval.min;
}

static inline CGFloat RXRandomInterval(RXInterval interval) {
	CGFloat denominator = 4294967296 / 2;//1u << ((sizeof(long) * 8) - 1);
	return (((CGFloat)random()) / denominator) * RXIntervalLength(interval) + interval.min;
}

static inline CGRect RXSquare(CGFloat size) {
	return (CGRect){
		{0, 0},
		{size, size},
	};
}

static inline RXInterval RXRectGetXInterval(CGRect rect) {
	return (RXInterval){CGRectGetMinX(rect), CGRectGetMaxX(rect)};
}

static inline RXInterval RXRectGetYInterval(CGRect rect) {
	return (RXInterval){CGRectGetMinY(rect), CGRectGetMaxY(rect)};
}

static inline CGPoint RXRandomPoint(CGRect bounds) {
	return (CGPoint){
		RXRandomInterval(RXRectGetXInterval(bounds)),
		RXRandomInterval(RXRectGetYInterval(bounds)),
	};
}

static CALayer *RXNewHalftoneDotLayer(RXViewController *self) {
	CAShapeLayer *dot = [CAShapeLayer layer];
	
	const RXInterval kDiameterInterval = (RXInterval){
		50,
		100
	};
	
	UIColor *colour = [UIColor colorWithRed:RXRandomInterval((RXInterval){0.5, 1.0}) green:0.25 blue:RXRandomInterval((RXInterval){0.5, 1.0}) alpha:1.0];
	CGFloat diameter = RXRandomInterval(kDiameterInterval);
	CGRect bounds = RXSquare(diameter);
	
	UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
	
	dot.bounds = bounds;
	dot.position = RXRandomPoint(self.view.bounds);
	dot.path = path.CGPath;
	dot.fillColor = colour.CGColor;
	
	CAKeyframeAnimation *pop = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	pop.values = @[
				[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.001, 0.001, 1.0)],
				[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
				[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]
				];
	pop.keyTimes = @[ @0.0, @0.67, @1.0 ];
	pop.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	pop.duration = 0.25;
	[dot addAnimation:pop forKey:kCATransition];
	
	return dot;
}

-(void)dot:(CADisplayLink *)link {
	[self.view.layer addSublayer:RXNewHalftoneDotLayer(self)];
}

@end
