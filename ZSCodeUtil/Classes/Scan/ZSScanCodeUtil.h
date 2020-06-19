//
//  ZSScanCodeUtil.h
//  Pods-TYCode_Example
//
//  Created by Josh on 2020/6/18.
//

#import <Foundation/Foundation.h>
#import "ZSScanCodePreview.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZSScanCodeUtilDelegate <NSObject>

@required

/// 设备配置已经就绪，收到回调调用 zs_start 即生效
- (void)zs_didPrepareScan;

/// 扫描完成
/// @param resultString 扫描结果
- (void)zs_didScanFinish:(NSString *)resultString;

@optional

/// 即将准备配置设备
- (void)zs_willPrepareScan;

/// 已经开始扫描
- (void)zs_didStartScan;

/// 已经停止扫描
- (void)zs_didStopScan;

/// 扫描过程中对亮度的监测
/// @param isDark 是否过暗
- (void)zs_scanBrightness:(BOOL)isDark;

@end

/**
 * 如果有多个码，将根据扫描到的码的数组从 index = 0 往后找，找到可识别的码即停止
 */
@interface ZSScanCodeUtil : NSObject

/// 是否开启亮度检测自动开启手电筒，默认YES
@property (nonatomic, assign, getter=isAutoTorchEnable) BOOL autoTorchEnable;

/// 是否开启距离检测，自动放大，默认YES
@property (nonatomic, assign, getter=isAutoZoomEnable) BOOL autoZoomEnable;

/// 代理
@property (nonatomic, weak) id<ZSScanCodeUtilDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE ;

+ (instancetype)new NS_UNAVAILABLE ;

/// 扫描工具初始化
/// @param preview 需要呈现的preview
/// @param isEnableDebuge 是否开启Debug
+ (instancetype)zs_initToPreview:(ZSScanCodePreview *)preview isEnableDebuge:(BOOL)isEnableDebuge;

/// 当前手电是否开启
- (BOOL)zs_isOnTorch;

/// 开始扫描识别
- (void)zs_start;

/// 关闭扫描识别
- (void)zs_stop;

/// 识别图片二维码
/// @param image 图片
- (void)zs_discern:(UIImage *)image;

/// 手电筒的开关
/// @param isOn 是否开启
- (void)zs_switchTorch:(BOOL)isOn;

@end

NS_ASSUME_NONNULL_END
