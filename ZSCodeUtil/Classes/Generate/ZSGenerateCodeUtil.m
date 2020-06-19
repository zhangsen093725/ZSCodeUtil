//
//  ZSGenerateCodeUtil.m
//  Pods-TYCode_Example
//
//  Created by Josh on 2020/6/18.
//  Core Image Filter Reference
//  参考文档： https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP30000136-SW142

#import "ZSGenerateCodeUtil.h"

@implementation ZSGenerateCodeLogo

@end


@implementation ZSGenerateCodeUtil

+ (UIImage *)zs_scaleImage:(CIImage *)image toSize:(CGSize)size {
    
    // 将CIImage转成CGImageRef
    CGRect integralRect = image.extent;
    
    // 将rect取整后返回，origin取舍，size取入
    CGImageRef imageRef = [[CIContext context] createCGImage:image fromRect:integralRect];
    
    // 计算需要缩放的比例
    CGFloat sideScale = fminf(size.width / integralRect.size.width, size.width / integralRect.size.height) * [UIScreen mainScreen].scale;
    size_t contextRefWidth = ceilf(integralRect.size.width * sideScale);
    size_t contextRefHeight = ceilf(integralRect.size.height * sideScale);
    
    // 可以通过设置 CGColorSpaceRef 改变颜色，但是这里颜色矩阵有些繁琐，所以设置为 灰度、不透明
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, contextRefWidth, contextRefHeight, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpaceRef);
    
    // 设置上下文无插值
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    // 设置上下文缩放
    CGContextScaleCTM(contextRef, sideScale, sideScale);
    // 在上下文中的integralRect中绘制imageRef
    CGContextDrawImage(contextRef, integralRect, imageRef);
    CGImageRelease(imageRef);
    
    // 从上下文中获取CGImageRef
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    
    // 将CGImageRefc转成UIImage
    UIImage *scaledImage = [UIImage imageWithCGImage:scaledImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(scaledImageRef);
    
    return scaledImage;
}

@end
