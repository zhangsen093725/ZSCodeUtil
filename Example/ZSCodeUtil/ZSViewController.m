//
//  ZSViewController.m
//  ZSCodeUtil
//
//  Created by zhangsen on 06/19/2020.
//  Copyright (c) 2020 zhangsen. All rights reserved.
//

#import "ZSViewController.h"
#import "ZSScanCodeController.h"
#import <ZSCode.h>

@interface ZSViewController ()
@property (nonatomic, strong) UIImageView *codeImageView;
@property (nonatomic, strong) UIButton *openScanBtn;
@end

@implementation ZSViewController

- (UIImageView *)codeImageView {
    
    if (!_codeImageView)
    {
        _codeImageView = [UIImageView new];
        _codeImageView.backgroundColor = [UIColor redColor];
        [self.view addSubview:_codeImageView];
    }
    return _codeImageView;
}

- (UIButton *)openScanBtn {
    
    if (!_openScanBtn)
    {
        _openScanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_openScanBtn setTitle:@"扫一扫" forState:UIControlStateNormal];
        [_openScanBtn addTarget:self action:@selector(scanAcyion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_openScanBtn];
    }
    return _openScanBtn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ZSGenerateCodeLogo *logo = [ZSGenerateCodeLogo new];
       logo.image = [UIImage imageNamed:@"下载"];
       
       self.codeImageView.image = [ZSGenerateCodeUtil zs_QRCode:@"https://www.qq.com"
                                                           size:CGSizeMake(150, 150)
                                                          color:UIColor.whiteColor
                                                 backgroudColor:UIColor.blackColor
                                                           logo:logo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.codeImageView.frame = CGRectMake((self.view.bounds.size.width - 300) * 0.5, (self.view.bounds.size.height - 300) * 0.5, 300, 300);
    self.openScanBtn.frame = CGRectMake(0, CGRectGetMaxY(_codeImageView.frame), self.view.bounds.size.width, 30);
}

- (void)scanAcyion
{
    [self presentViewController:[ZSScanCodeController new] animated:YES completion:nil];
}

@end
