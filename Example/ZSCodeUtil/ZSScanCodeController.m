//
//  ZSScanCodeController.m
//  ZSCodeUtil_Example
//
//  Created by Josh on 2020/6/18.
//  Copyright © 2020 zhangsen. All rights reserved.
//

#import "ZSScanCodeController.h"
#import <ZSCode.h>

@interface ZSScanCodeController ()<ZSScanCodeUtilDelegate>
@property (nonatomic, strong) ZSScanCodeUtil *scanCodeUtil;
@property (nonatomic, strong) ZSScanCodeRectPreview *scanPreview;
@end

@implementation ZSScanCodeController

- (ZSScanCodeUtil *)scanCodeUtil {
    
    if (!_scanCodeUtil)
    {
        _scanCodeUtil = [ZSScanCodeUtil zs_initToPreview:self.scanPreview isEnableDebuge:YES];
    }
    return _scanCodeUtil;
}

- (ZSScanCodeRectPreview *)scanPreview {
    
    if (!_scanPreview)
    {
        _scanPreview = [ZSScanCodeRectPreview new];
        _scanPreview.cornerColor = [UIColor systemBlueColor];
        _scanPreview.cornerLineWidth = 3;
        _scanPreview.scanLineColor = [UIColor systemBlueColor];
        _scanPreview.scanLineWidth = 3;
        [self.view addSubview:_scanPreview];
    }
    
    return _scanPreview;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scanCodeUtil.delegate = self;
//    [_scanCodeUtil zs_discern:[UIImage imageNamed:@"WX20200619-153937"]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.scanPreview.frame = self.view.bounds;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)zs_didPrepareScan {
    
    [_scanCodeUtil zs_start];
}

- (void)zs_didScanFinish:(nonnull NSString *)resultString {
    
    NSLog(@"%@", resultString);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)zs_scanBrightness:(BOOL)isDark isOnTorch:(BOOL)isOnTorch {
    
    NSLog(@"%d--------%d", isDark, isOnTorch);
    [_scanCodeUtil zs_switchTorch:!isOnTorch];
}

- (void)dealloc {
    
    NSLog(@"TYScanCodeController dealloc");
}

@end
