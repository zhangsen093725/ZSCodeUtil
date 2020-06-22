//
//  ZSScanCodePreview.h
//  Pods-ZSCodeUtil_Example
//
//  Created by Josh on 2020/6/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZSScanCodePreview : UIView

/// 扫描识别区域， 默认为中心一个矩形
- (CGRect)zs_scanRect;

/// 开启扫描动画
- (void)zs_startScanAnimation;

/// 停止扫描动画
- (void)zs_stopScanAnimation;

@end

NS_ASSUME_NONNULL_END
