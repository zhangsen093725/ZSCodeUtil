//
//  ZSScanCodeRectPreview.h
//  Pods-TYCode_Example
//
//  Created by Josh on 2020/6/18.
//

#import "ZSScanCodePreview.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZSScanCodeRectPreview : ZSScanCodePreview

/// 遮盖的颜色，默认为clearColor
@property (nonatomic, strong) UIColor *maskColor;

/// 矩形边框的颜色，默认为clearColor
@property (nonatomic, strong) UIColor *rectColor;

/// 矩形边框的宽度
@property (nonatomic, assign) CGFloat rectLineWidth;

/// 矩形边框四个角的颜色，默认为systemBlueColor
@property (nonatomic, strong) UIColor *cornerColor;

/// 矩形边框四个角的宽度
@property (nonatomic, assign) CGFloat cornerLineWidth;

/// 扫描线的颜色，默认为systemBlueColor
@property (nonatomic, strong) UIColor *scanLineColor;

/// 扫描线的宽度
@property (nonatomic, assign) CGFloat scanLineWidth;

@end

NS_ASSUME_NONNULL_END
