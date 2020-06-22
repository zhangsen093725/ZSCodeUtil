//
//  ZSScanCodePreview.m
//  Pods-ZSCodeUtil_Example
//
//  Created by Josh on 2020/6/18.
//

#import "ZSScanCodePreview.h"

@interface ZSScanCodePreview ()

@end

@implementation ZSScanCodePreview

- (CGRect)zs_scanRect {
    
    CGFloat rectSide = MIN(self.layer.bounds.size.width, self.layer.bounds.size.height) * 2 / 3;
    return CGRectMake((self.layer.bounds.size.width - rectSide) / 2, (self.layer.bounds.size.height - rectSide) / 2, rectSide, rectSide);
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
}

- (void)zs_startScanAnimation {}

- (void)zs_stopScanAnimation {}

@end
