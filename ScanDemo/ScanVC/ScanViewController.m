//
//  ScanViewController.m
//  ScanDemo
//
//  Created by 韩威 on 16/4/7.
//  Copyright © 2016年 韩威. All rights reserved.
//


#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SVProgressHUD.h"
#import "ScanResultViewController.h"
#import "ScanBoxView.h"

@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) ScanBoxView *scanBoxView;
@property (nonatomic, strong) UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

//- (void)_setupSubviews;

@end

@implementation ScanViewController

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"二维码/条码";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightNaviBarBtnClick)];
    
//    [self _setupSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopScanning];
}

#pragma mark - private Methods
//- (void)_setupSubviews {
//    
//}


#pragma mark - action Methods
- (void)rightNaviBarBtnClick {
    NSLog(@"相册");
}

- (void)initCapture {
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD showWithStatus:@"正在加载…"];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        __autoreleasing NSError *capDeviceInputError = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&capDeviceInputError];
        if (!input) {
            NSLog(@"init captureDeviceInput error. %@",[capDeviceInputError localizedDescription]);
            return;
        }
        AVCaptureMetadataOutput *captureMetadataOutput = [AVCaptureMetadataOutput new];
        _captureSession = [AVCaptureSession new];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        [_captureSession addInput:input];
        [_captureSession addOutput:captureMetadataOutput];
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        captureMetadataOutput.rectOfInterest = CGRectMake(0, 0, 1, 1);
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _videoPreviewLayer.frame = _previewView.layer.bounds;
        [_captureSession startRunning];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
            [_previewView.layer addSublayer:_videoPreviewLayer];
            [_previewView addSubview:self.scanBoxView];
            [self.scanBoxView startScanAnimation];
            [SVProgressHUD dismiss];
//        });
//    });
    
    
    
    
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        
        [self stopScanning];
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            //NSLog(@"isMainThread%d",[NSThread isMainThread]);
            
            ScanResultViewController *resultVC = [[ScanResultViewController alloc] initWithNibName:@"ScanResultViewController" bundle:nil];
            resultVC.resultString = metadataObj.stringValue;
            [self.navigationController pushViewController:resultVC animated:YES];
        }
    }
}

- (void)stopScanning {
    if (_captureSession && [_captureSession isRunning]) {
        [_captureSession stopRunning];
        _captureSession = nil;
    }
    [self.scanBoxView stopScanAnimation];
    [self.scanBoxView removeFromSuperview];
    [_label removeFromSuperview];
}

#pragma mark - getter
- (ScanBoxView *)scanBoxView {
    if (!_scanBoxView) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 60.0*2;
        CGFloat y = [UIScreen mainScreen].bounds.size.height/2.0 - width/2.0 - 64.f;
        _scanBoxView = [[ScanBoxView alloc] initWithFrame:CGRectMake(60, y, width, width)];
        
        _label = [UILabel new];
        //_label.backgroundColor = [UIColor redColor];
        _label.text = @"将二维码/条码放入框内，即可自动扫描";
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:13.f];
        [_label sizeToFit];
        CGRect frame = _label.frame;
        frame.origin.y = y + width + 5;
        _label.frame = frame;
        _label.center = CGPointMake(_scanBoxView.center.x, y + width + 5 + 10);
    }
    [_previewView addSubview:_label];
    return _scanBoxView;
}

@end




