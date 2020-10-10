//
//  QFDashView.m
//  PaiXianPinDemo
//
//  Created by cheng on 2020/7/21.
//  Copyright © 2020 cqf. All rights reserved.
//

#import "QFGaugeView.h"
#import "UIView+Common.h"
#import "UIColor+Common.h"
#import <objc/runtime.h>


@interface QFGaugeView ()<CAAnimationDelegate>

/// 表盘 + 分数
@property (nonatomic, strong) CAShapeLayer *baseLayer, *scoreLayer;

/// 起始点
@property (nonatomic, assign) CGFloat starAngle;
/// 结束点
@property (nonatomic, assign) CGFloat endAngle;
/// 半径
@property (nonatomic, assign) CGFloat radius;
/// 圆点
@property (nonatomic, assign) CGPoint centerPoint;
/// 虚线长度
@property (nonatomic, assign) CGFloat dottedLineLength;
/// 虚线间距
@property (nonatomic, assign) CGFloat dottedLineSpacing;
/// 表盘宽度
@property (nonatomic, assign) CGFloat baseLineWidth;

@end

/// 弧度转角度
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
/// 角度转弧度
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation QFGaugeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self configBeginValue];
        [self createGaugePanel];
    }
    return self;
}

- (void)configBeginValue {
    /// 起始点
    self.starAngle = DEGREES_TO_RADIANS(-200);
    /// 结束点
    self.endAngle = DEGREES_TO_RADIANS(20);
    /// 半径 (留一点边距 左右上 各 10)
    self.radius = (self.width - 20) / 2.0f;
    /// 圆点
    self.centerPoint = CGPointMake(self.width / 2.0, self.width / 2.0);
    /// 虚线长度
    self.dottedLineLength = 3.9;
    /// 虚线间距
    self.dottedLineSpacing = 15;
    /// 表盘宽度
    self.baseLineWidth = 9.0;
    
}

#pragma mark - Setting && Getting
- (void)setScore:(CGFloat)score {
    objc_setAssociatedObject(self, @selector(score), @(score), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self configGaugePanelWithScore:score];
}

- (CGFloat)score {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

/// 绘制表盘
- (void)createGaugePanel {
    /// 防止图层重叠
    [self.baseLayer removeFromSuperlayer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:self.starAngle endAngle:self.endAngle clockwise:YES];
    /// 结束绘制
    [path stroke];
    
    self.baseLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:self.baseLayer];
    
    self.baseLayer.lineCap = kCALineCapButt;
    self.baseLayer.lineWidth = self.baseLineWidth;
    /// 连接样式 圆滑衔接
    [self.baseLayer setLineJoin:kCALineJoinRound];
    self.baseLayer.fillColor = [UIColor clearColor].CGColor;
    self.baseLayer.strokeColor = [[UIColor themeColor] colorWithAlphaComponent:0.1].CGColor;
    
    [self.baseLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithFloat:self.dottedLineLength], [NSNumber numberWithFloat:self.dottedLineSpacing], nil]];
    self.baseLayer.path = [path CGPath];
}

/// 设置分数
- (void)configGaugePanelWithScore:(CGFloat)score {
    /// 防止图层重叠
    [self.scoreLayer removeFromSuperlayer];
    /// 结束点
    CGFloat endPoint = DEGREES_TO_RADIANS(-200 + (240.0 * score));
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:self.starAngle endAngle:endPoint clockwise:YES];
    /// 结束绘制
    [path stroke];
    
    self.scoreLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:self.scoreLayer];
    
    self.scoreLayer.lineCap = kCALineCapButt;
    self.scoreLayer.lineWidth = self.baseLineWidth;
    /// 连接样式 圆滑衔接
    [self.scoreLayer setLineJoin:kCALineJoinRound];
    self.scoreLayer.fillColor = [UIColor clearColor].CGColor;
    self.scoreLayer.strokeColor = [[UIColor themeColor] colorWithAlphaComponent:0.7].CGColor;
    
    [self.scoreLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithFloat:self.dottedLineLength], [NSNumber numberWithFloat:self.dottedLineSpacing], nil]];
    self.scoreLayer.path = [path CGPath];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    self.scoreLayer.autoreverses = NO;
    animation.duration = 1.0;
    
    /// 设置layer的animation
    [self.scoreLayer addAnimation:animation forKey:nil];
    animation.delegate = self;

}

@end
