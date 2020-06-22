//
//  ZSGenerateCodeUtil+Bar.m
//  Pods-ZSCodeUtil_Example
//
//  Created by Josh on 2020/6/18.
//

#import "ZSGenerateCodeUtil+Bar.h"

@implementation ZSGenerateCodeUtil (Bar)

+ (UIImage *)zs_BarCode:(NSString *)code
                          size:(CGSize)size {
    
    return [self zs_BarCode:code size:size color:nil backgroudColor:nil];
}

+ (UIImage *)zs_BarCode:(NSString *)code
                          size:(CGSize)size
                         color:(UIColor *)color {
    
    return [self zs_BarCode:code size:size color:color backgroudColor:nil];
}

+ (UIImage *)zs_BarCode:(NSString *)code
                           size:(CGSize)size
                          color:(nullable UIColor *)color
                 backgroudColor:(nullable UIColor *)backgroudColor {
    
    NSData *qrImageData = [code dataUsingEncoding:NSUTF8StringEncoding];
    
    // 1、创建滤镜对象
    /**
     inputQuietSpace: 条形码外边留白距离
     inputBarcodeHeight: 条形码高度
     */
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"
                            withInputParameters:@{
                                @"inputMessage": qrImageData,
                                @"inputQuietSpace": @2
                            }];
    
    // 2、获得滤镜输出的图像
    UIImage *outputImage = [self zs_scaleImage:[filter outputImage] toSize:size];
    
    if (color == nil) { return outputImage; }
    
    // 3、创建彩色过滤器
    /**
     inputColor0：背景颜色
     inputColor1 主颜色
     注意不要使用 [CIColor redColor][CIColor blueColor]，这些类似于UIColor的方法只有在iOS 10系统才有
     */
    
    CIColor *ciColor = [CIColor colorWithCGColor:(color ? color : UIColor.blackColor).CGColor];
    CIColor *cibackgroudColor = [CIColor colorWithCGColor:(backgroudColor ? backgroudColor : UIColor.whiteColor).CGColor];
    
    CIFilter * color_filter = [CIFilter filterWithName:@"CIFalseColor"
                                   withInputParameters:@{
                                       @"inputImage" : [CIImage imageWithCGImage:outputImage.CGImage],
                                       @"inputColor0" : ciColor,
                                       @"inputColor1" : cibackgroudColor
                                   }];
    
    return [UIImage imageWithCIImage:[color_filter outputImage]];
}

@end
