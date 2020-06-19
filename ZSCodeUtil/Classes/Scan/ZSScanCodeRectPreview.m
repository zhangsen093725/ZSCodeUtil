//
//  ZSScanCodeRectPreview.m
//  Pods-TYCode_Example
//
//  Created by Josh on 2020/6/18.
//

#import "ZSScanCodeRectPreview.h"

@interface ZSScanCodeRectPreview ()
@property (nonatomic, strong) CAShapeLayer *rectLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *cornerLayer;
@property (nonatomic, strong) CAShapeLayer *lineLayer;
@end

@implementation ZSScanCodeRectPreview

- (CAShapeLayer *)rectLayer {
    
    if (!_rectLayer)
    {
        _rectLayer = [CAShapeLayer layer];
        _rectLayer.fillColor = [UIColor clearColor].CGColor;
        _rectLayer.lineWidth = 5;
        [self.layer addSublayer:_rectLayer];
    }
    return _rectLayer;
}

- (CAShapeLayer *)maskLayer {
    
    if (!_maskLayer)
    {
        _maskLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_maskLayer];
    }
    return _maskLayer;
}

- (CAShapeLayer *)cornerLayer {
    
    if (!_cornerLayer)
    {
        _cornerLayer = [CAShapeLayer layer];
        
        [self.layer addSublayer:_cornerLayer];
    }
    return _cornerLayer;
}

- (CAShapeLayer *)lineLayer {
    
    if (!_lineLayer)
    {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.shadowRadius = 5.0;
        _lineLayer.shadowOffset = CGSizeMake(0, 0);
        _lineLayer.shadowOpacity = 1.0;
        _lineLayer.hidden = YES;
        [self.layer addSublayer:_lineLayer];
    }
    return _lineLayer;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGRect rectFrame = [self zs_scanRect];
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(_rectLineWidth / 2, _rectLineWidth / 2, rectFrame.size.width - _rectLineWidth, rectFrame.size.height - _rectLineWidth)];
    self.rectLayer.path = rectPath.CGPath;
    _rectLayer.strokeColor = _rectColor.CGColor;
    _rectLayer.frame = rectFrame;
    
    // 根据rectFrame创建矩形拐角路径
    CGFloat cornerLength = MIN(rectFrame.size.width, rectFrame.size.height) / 12;
    UIBezierPath *cornerPath = [UIBezierPath bezierPath];
    // 左上角
    [cornerPath moveToPoint:(CGPoint){_cornerLineWidth / 2, .0}];
    [cornerPath addLineToPoint:(CGPoint){_cornerLineWidth / 2, cornerLength}];
    [cornerPath moveToPoint:(CGPoint){.0, _cornerLineWidth / 2}];
    [cornerPath addLineToPoint:(CGPoint){cornerLength, _cornerLineWidth / 2}];
    // 右上角
    [cornerPath moveToPoint:(CGPoint){rectFrame.size.width, _cornerLineWidth / 2}];
    [cornerPath addLineToPoint:(CGPoint){rectFrame.size.width - cornerLength, _cornerLineWidth / 2}];
    [cornerPath moveToPoint:(CGPoint){rectFrame.size.width - _cornerLineWidth / 2, .0}];
    [cornerPath addLineToPoint:(CGPoint){rectFrame.size.width - _cornerLineWidth / 2, cornerLength}];
    // 右下角
    [cornerPath moveToPoint:(CGPoint){rectFrame.size.width - _cornerLineWidth / 2, rectFrame.size.height}];
    [cornerPath addLineToPoint:(CGPoint){rectFrame.size.width - _cornerLineWidth / 2, rectFrame.size.height - cornerLength}];
    [cornerPath moveToPoint:(CGPoint){rectFrame.size.width, rectFrame.size.height - _cornerLineWidth / 2}];
    [cornerPath addLineToPoint:(CGPoint){rectFrame.size.width - cornerLength, rectFrame.size.height - _cornerLineWidth / 2}];
    // 左下角
    [cornerPath moveToPoint:(CGPoint){.0, rectFrame.size.height - _cornerLineWidth / 2}];
    [cornerPath addLineToPoint:(CGPoint){cornerLength, rectFrame.size.height - _cornerLineWidth / 2}];
    [cornerPath moveToPoint:(CGPoint){_cornerLineWidth / 2, rectFrame.size.height}];
    [cornerPath addLineToPoint:(CGPoint){_cornerLineWidth / 2, rectFrame.size.height - cornerLength}];
    
    // 根据矩形拐角路径画矩形拐角
    self.cornerLayer.frame = rectFrame;
    _cornerLayer.path = cornerPath.CGPath;
    _cornerLayer.lineWidth = _cornerLineWidth;
    _cornerLayer.strokeColor = _cornerColor.CGColor;
    
    // 遮罩+镂空
    self.layer.backgroundColor = self.backgroundColor.CGColor;
    self.maskLayer.fillColor = _maskColor.CGColor;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *subPath = [[UIBezierPath bezierPathWithRect:rectFrame] bezierPathByReversingPath];
    [maskPath appendPath:subPath];
    _maskLayer.path = maskPath.CGPath;
    
    // 根据rectFrame画扫描线
    CGRect lineFrame = CGRectMake(rectFrame.origin.x + 5.0, rectFrame.origin.y, rectFrame.size.width - 5.0 * 2, _scanLineWidth);
    UIBezierPath *linePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, lineFrame.size.width, lineFrame.size.height)];
    self.lineLayer.frame = lineFrame;
    _lineLayer.path = linePath.CGPath;
    _lineLayer.fillColor = _scanLineColor.CGColor;
    _lineLayer.shadowColor = _scanLineColor.CGColor;
    
    // 扫描线动画
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    lineAnimation.fromValue = [NSValue valueWithCGPoint:(CGPoint){_lineLayer.frame.origin.x + _lineLayer.frame.size.width / 2, rectFrame.origin.y + _lineLayer.frame.size.height}];
    lineAnimation.toValue = [NSValue valueWithCGPoint:(CGPoint){_lineLayer.frame.origin.x + _lineLayer.frame.size.width / 2, rectFrame.origin.y + rectFrame.size.height - _lineLayer.frame.size.height}];
    lineAnimation.repeatCount = CGFLOAT_MAX;
    lineAnimation.autoreverses = NO;
    lineAnimation.duration = 2;
    [_lineLayer removeAnimationForKey:@"lineAnimation"];
    [_lineLayer addAnimation:lineAnimation forKey:@"lineAnimation"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setRectColor:(UIColor *)rectColor {
    _rectColor = rectColor;
    [self setNeedsDisplay];
}

- (void)setRectLineWidth:(CGFloat)rectLineWidth {
    _rectLineWidth = rectLineWidth;
    [self setNeedsDisplay];
}

- (void)setCornerColor:(UIColor *)cornerColor {
    _cornerColor = cornerColor;
    [self setNeedsDisplay];
}

- (void)setCornerLineWidth:(CGFloat)cornerLineWidth {
    _cornerLineWidth = cornerLineWidth;
    [self setNeedsDisplay];
}

- (void)setScanLineColor:(UIColor *)scanLineColor {
    _scanLineColor = scanLineColor;
    [self setNeedsDisplay];
}

- (void)setScanLineWidth:(CGFloat)scanLineWidth {
    _scanLineWidth = scanLineWidth;
    [self setNeedsDisplay];
}

- (void)zs_startScanAnimation {
    self.lineLayer.hidden = NO;
}

- (void)zs_stopScanAnimation {
    self.lineLayer.hidden = YES;
}

@end
