//
//  ZSScanCodeUtil.m
//  Pods-TYCode_Example
//
//  Created by Josh on 2020/6/18.
//

#import "ZSScanCodeUtil.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>

@interface ZSScanCodeUtil ()<AVCaptureMetadataOutputObjectsDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, weak) ZSScanCodePreview *preview;
@property (nonatomic, assign, getter=isEnableDebug) BOOL enableDebug;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *metaOutput;
@end

@implementation ZSScanCodeUtil

+ (AVCaptureDevice *)zs_activeDevice {
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

+ (instancetype)zs_initToPreview:(ZSScanCodePreview *)preview isEnableDebuge:(BOOL)isEnableDebuge {
    
    NSAssert([preview isKindOfClass:[ZSScanCodePreview class]], @"zs_initToPreview preview not is TYScanCodePreview");
    
    ZSScanCodeUtil *util = [self new];
    
    util.preview = preview;
    util.enableDebug = isEnableDebuge;
    util.autoTorchEnable = YES;
    util.autoZoomEnable = YES;
    
    [util.preview addObserver:util forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:util selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:util selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    if ([util.delegate respondsToSelector:@selector(zs_willPrepareScan)])
    {
        [util.delegate zs_willPrepareScan];
    }
    
    __weak typeof(util)weak_self = util;
    // 在全局队列开启新线程，异步初始化AVCaptureSession（比较耗时）
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AVCaptureDevice *device = [self zs_activeDevice];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        AVCaptureMetadataOutput *metaOutput = [[AVCaptureMetadataOutput alloc] init];
        [metaOutput setMetadataObjectsDelegate:weak_self queue:dispatch_get_main_queue()];
        
        AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [videoOutput setSampleBufferDelegate:weak_self queue:dispatch_get_main_queue()];
        
        weak_self.session = [[AVCaptureSession alloc] init];
        weak_self.session.sessionPreset = AVCaptureSessionPresetHigh;
        
        if ([weak_self.session canAddInput:input])
        {
            [weak_self.session addInput:input];
        }
        
        // 添加相机捕捉数据输出
        if ([weak_self.session canAddOutput:metaOutput])
        {
            [weak_self.session addOutput:metaOutput];
            
            if ([metaOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode] &&
                [metaOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code] &&
                [metaOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code])
            {
                metaOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                                   AVMetadataObjectTypeCode128Code,
                                                   AVMetadataObjectTypeEAN13Code];
            }
        }
        weak_self.metaOutput = metaOutput;
        
        // 添加视频数据输出
        if ([weak_self.session canAddOutput:videoOutput])
        {
            [weak_self.session addOutput:videoOutput];
        }
        
        [device lockForConfiguration:nil];
        if (device.isFocusPointOfInterestSupported &&
            [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        [device unlockForConfiguration];
        
        // 回主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weak_self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:weak_self.session];
            weak_self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [weak_self.preview.layer insertSublayer:weak_self.previewLayer atIndex:0];
            
            [weak_self zs_layoutFrame];
            
            [weak_self.delegate zs_didPrepareScan];
        });
    });
    
    return util;
}

- (BOOL)zs_isOnTorch {
    return [ZSScanCodeUtil zs_activeDevice].torchMode == AVCaptureTorchModeOn;
}

- (void)zs_layoutFrame {
    
    if (!_previewLayer) { return; }
    
    _previewLayer.frame = _preview.layer.bounds;
    
    // 设置扫码区域
    CGRect rectFrame = _preview.zs_scanRect;
    if (!CGRectEqualToRect(rectFrame, CGRectZero))
    {
        CGFloat y = rectFrame.origin.y / _preview.bounds.size.height;
        CGFloat x = (_preview.bounds.size.width - rectFrame.origin.x - rectFrame.size.width) / _preview.bounds.size.width;
        CGFloat h = rectFrame.size.height / _preview.bounds.size.height;
        CGFloat w = rectFrame.size.width / _preview.bounds.size.width;
        _metaOutput.rectOfInterest = CGRectMake(y, x, h, w);
    }
}

- (void)zs_start {
    
    if (_session && !_session.isRunning) {
        [_session startRunning];
        [_preview zs_startScanAnimation];
        
        if ([_delegate respondsToSelector:@selector(zs_didStartScan)])
        {
            [_delegate zs_didStartScan];
        }
    }
}

- (void)zs_stop {
    
    if (_session && _session.isRunning) {
        [self zs_resetZoomFactor];
        [_session stopRunning];
        [_preview zs_stopScanAnimation];
        
        if ([_delegate respondsToSelector:@selector(zs_didStopScan)])
        {
            [_delegate zs_didStopScan];
        }
    }
}

- (void)zs_discern:(UIImage *)image {
    
    CIImage *detectImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    CIQRCodeFeature *feature = (CIQRCodeFeature *)[detector featuresInImage:detectImage options:nil].firstObject;
    
    [_delegate zs_didScanFinish:feature.messageString];
}

- (void)zs_switchTorch:(BOOL)isOn {
    
    AVCaptureDevice *device = [ZSScanCodeUtil zs_activeDevice];
    
    AVCaptureTorchMode torchMode = isOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    
    if (device.torchMode == torchMode) { return; }
    
    if ([device isTorchModeSupported:torchMode])
    {
        
        NSError *error;
        if ([device lockForConfiguration:&error])
        {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        else if (self.isEnableDebug)
        {
            NSLog(@"TYScanCodeUtil switch torch error: %@", error);
        }
    }
}

- (void)zs_resetZoomFactor {
    
    [self zs_videoZoomFactor:1 animation:NO];
}

- (void)zs_videoZoomFactor:(CGFloat)zoomValue animation:(BOOL)animation {
    
    AVCaptureDevice *device = [ZSScanCodeUtil zs_activeDevice];
    
    if (!device.isRampingVideoZoom)
    {
        NSError *error;
        if ([device lockForConfiguration:&error])
        {
            CGFloat zoomFactor = MIN(device.activeFormat.videoMaxZoomFactor, zoomValue);
            animation ? [device rampToVideoZoomFactor:zoomFactor withRate:10] : [device setVideoZoomFactor:zoomFactor];
            [device unlockForConfiguration];
        }
        else if (self.isEnableDebug)
        {
            NSLog(@"TYScanCodeUtil zoom factor error: %@", error);
        }
    }
}

- (void)dealloc {
    
    NSLog(@"TYScanCodeUtil dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_preview removeObserver:self forKeyPath:@"frame"];
}

// TODO: Notification functions
- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    [self zs_start];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
    [self zs_stop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (object == _preview)
    {
        [self zs_layoutFrame];
    }
}

// TODO: AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    __weak typeof(self)weak_self = self;
    [metadataObjects enumerateObjectsUsingBlock:^(__kindof AVMetadataObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        AVMetadataObject *transformedCode = [weak_self.previewLayer transformedMetadataObjectForMetadataObject:obj];
        
        CGFloat size = MAX(transformedCode.bounds.size.width, transformedCode.bounds.size.height);
        
        AVCaptureDevice *device = [ZSScanCodeUtil zs_activeDevice];
        
        if (device.rampingVideoZoom)
        {
            *stop = YES;
            return;
        }
        
        if (weak_self.isAutoTorchEnable && size < 150 && device.videoZoomFactor == 1)
        {
            [weak_self zs_videoZoomFactor: 150 / size animation:YES];
            *stop = YES;
            return;
        }
        
        if ([transformedCode isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        {
            AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject *)transformedCode;
            if (code.stringValue)
            {
                [weak_self.delegate zs_didScanFinish:code.stringValue];
                [weak_self zs_stop];
            }
            *stop = YES;
            return;
        }
    }];
}

// TODO: AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDicRef = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadataDic = (__bridge NSDictionary *)metadataDicRef;
    NSDictionary *exifDic = metadataDic[(__bridge NSString *)kCGImagePropertyExifDictionary];
    CFRelease(metadataDicRef);
    
    // brightness值代表光线强度，值越小代表光线越暗
    CGFloat brightness = [exifDic[(__bridge NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    AVCaptureDevice *device = [ZSScanCodeUtil zs_activeDevice];
    
    BOOL isDark = brightness <= 0;
    
    if ([_delegate respondsToSelector:@selector(zs_scanBrightness:)])
    {
        [_delegate zs_scanBrightness:isDark];
    }
    
    if (!self.isAutoTorchEnable) { return; }
    
    if (isDark && device.torchMode == AVCaptureTorchModeOff)
    {
        [self zs_switchTorch:YES];
    }
}

@end
