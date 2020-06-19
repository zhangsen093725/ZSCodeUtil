//
//  TYCodeUtil+QR.h
//  Pods-TYCode_Example
//
//  Created by Josh on 2020/6/18.
//

#import "ZSGenerateCodeUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZSGenerateCodeUtil (QR)

/// 生成二维码
/// @param code 需要编码的字符串
/// @param size 生成二维码的大小
/// @param color 生成二维码的颜色，默认为黑色
/// @param backgroudColor 生成二维码的背景颜色，默认为白色
/// @param logo 生成二维码的logo，默认在中心
+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size
                         color:(nullable UIColor *)color
                backgroudColor:(nullable UIColor *)backgroudColor
                          logo:(nullable ZSGenerateCodeLogo *)logo;

/// 生成二维码
/// @param code 需要编码的字符串
/// @param size 生成二维码的大小
/// @param color 生成二维码的颜色，默认为黑色
+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size
                         color:(UIColor *)color;

/// 生成二维码
/// @param code 需要编码的字符串
/// @param size 生成二维码的大小
/// @param color 生成二维码的颜色，默认为黑色
/// @param backgroudColor 生成二维码的背景颜色，默认为白色
+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size
                         color:(UIColor *)color
                backgroudColor:(UIColor *)backgroudColor;

/// 生成二维码
/// @param code 需要编码的字符串
/// @param size 生成二维码的大小
/// @param logo 生成二维码的logo，默认在中心
+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size
                          logo:(ZSGenerateCodeLogo *)logo;

/// 生成二维码
/// @param code 需要编码的字符串
/// @param size 生成二维码的大小
+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
