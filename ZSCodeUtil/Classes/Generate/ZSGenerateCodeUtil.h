//
//  ZSGenerateCodeUtil.h
//  Pods-TYCode_Example
//
//  Created by Josh on 2020/6/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZSGenerateCodeLogo : NSObject

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) CGFloat boardWidth;

@property (nonatomic, strong, nullable) UIColor *boardColor;

@end

@interface ZSGenerateCodeUtil : NSObject

/// 生成指定大小的高质量图片
/// @param image CIImage
/// @param size 图片大小
+ (UIImage *)zs_scaleImage:(CIImage *)image toSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
