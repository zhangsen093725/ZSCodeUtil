//
//  ZSGenerateCodeUtil+QR.m
//  Pods-TYCode_Example
//
//  Created by Josh on 2020/6/18.
//

#import "ZSGenerateCodeUtil+QR.h"

@implementation ZSGenerateCodeUtil (QR)

+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size {
    
    return [self zs_QRCode:code size:size color:nil backgroudColor:nil logo:nil];
}

+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size
                         color:(UIColor *)color {
    
    return [self zs_QRCode:code size:size color:color backgroudColor:nil logo:nil];
}

+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size
                         color:(UIColor *)color
                backgroudColor:(UIColor *)backgroudColor {
    
    return [self zs_QRCode:code size:size color:color backgroudColor:backgroudColor logo:nil];
}

+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size
                          logo:(ZSGenerateCodeLogo *)logo {
    
    return [self zs_QRCode:code size:size color:nil backgroudColor:nil logo:logo];
}

+ (UIImage *)zs_QRCode:(NSString *)code
                          size:(CGSize)size
                         color:(nullable UIColor *)color
                backgroudColor:(nullable UIColor *)backgroudColor
                          logo:(nullable ZSGenerateCodeLogo *)logo {
    
    NSData *qrImageData = [code dataUsingEncoding:NSUTF8StringEncoding];
    
    // 1、创建滤镜对象
    /**
     inputCorrectionLevel容错等级
     一共分为4档：L、M、Q、H。
     L对应：7%；
     M对应：15%；
     Q对应：25%；
     H对应：30%。
     */
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"
                            withInputParameters:@{
                                @"inputMessage": qrImageData,
                                @"inputCorrectionLevel": @"H"
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
    
    UIImage *codeImage = [UIImage imageWithCIImage:[color_filter outputImage]];
    
    if (logo == nil) { return codeImage; }
    
    // 4、定义logo的绘制参数
    UIGraphicsBeginImageContextWithOptions(codeImage.size, YES, [UIScreen mainScreen].scale);
    [codeImage drawInRect:CGRectMake(0, 0, codeImage.size.width, codeImage.size.height)];
    
    if (CGSizeEqualToSize(logo.size, CGSizeZero))
    {
        CGFloat logoSide = fminf(codeImage.size.width, codeImage.size.height) / 4;
        logo.size = CGSizeMake(logoSide, logoSide);
    }
    
    CGFloat logoX = (codeImage.size.width - logo.size.width) * 0.5;
    CGFloat logoY = (codeImage.size.height - logo.size.height) * 0.5;
    CGRect logoRect = CGRectMake(logoX, logoY, logo.size.width, logo.size.height);
    
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:logoRect cornerRadius:logo.cornerRadius];
    [cornerPath setLineWidth:logo.boardWidth];
    [logo.boardColor ? logo.boardColor : [UIColor whiteColor] set];
    [cornerPath stroke];
    [cornerPath addClip];
    
    // 将logo画到上下文中
    [logo.image drawInRect:logoRect];
    
    // 从上下文中读取image
    codeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return codeImage;
}

@end
