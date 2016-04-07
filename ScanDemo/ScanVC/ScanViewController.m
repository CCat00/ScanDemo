//
//  ScanViewController.m
//  ScanDemo
//
//  Created by 韩威 on 16/4/7.
//  Copyright © 2016年 韩威. All rights reserved.
//

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height

#define kScanBoxX       80.0f
#define kScanBoxWidth   (kScreenWidth - kScanBoxX*2)
#define kScanBoxY       (kScreenHeight/2.0 - kScanBoxWidth/2.0 - 64.f)

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

- (void)_setup;

@end

@implementation ScanViewController

#pragma mark - life circle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"二维码/条码";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightNaviBarBtnClick)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self initCapture];
    [self _setup];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self stopScanning];
}

#pragma mark - private Methods
- (void)_setup {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    [self initCapture];
                } else {
                    NSLog(@"%@", @"访问受限");
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            [self initCapture];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            NSLog(@"%@", @"访问受限");
            break;
        }
            
        default: {
            break;
        }
    }

}


#pragma mark - action Methods
- (void)rightNaviBarBtnClick {
    NSLog(@"相册");
}

- (void)initCapture {

    _captureSession = [AVCaptureSession new];
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    __autoreleasing NSError *capDeviceInputError = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&capDeviceInputError];
    if (!input) {
        NSLog(@"init captureDeviceInput error. %@",[capDeviceInputError localizedDescription]);
    }
    else {
        [_captureSession addInput:input];
        AVCaptureMetadataOutput *captureMetadataOutput = [AVCaptureMetadataOutput new];
        
        [_captureSession addOutput:captureMetadataOutput];
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        
        AVCaptureVideoPreviewLayer *videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        videoPreviewLayer.frame = _previewView.layer.bounds;
        [_previewView.layer addSublayer:videoPreviewLayer];
        
        //设置识别范围
        //http://c0ming.me/qr-code-scan/
        [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock: ^(NSNotification *_Nonnull note) {
                                                          captureMetadataOutput.rectOfInterest = [videoPreviewLayer metadataOutputRectOfInterestForRect:CGRectMake(kScanBoxX, kScanBoxY, kScanBoxWidth, kScanBoxWidth)];
                                                      }];

        [_previewView addSubview:self.scanBoxView];
        [_captureSession startRunning];
        [self.scanBoxView startScanAnimation];
    }
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
        _scanBoxView = [[ScanBoxView alloc] initWithFrame:CGRectMake(kScanBoxX, kScanBoxY, kScanBoxWidth, kScanBoxWidth)];
        
        _label = [UILabel new];
        //_label.backgroundColor = [UIColor redColor];
        _label.text = @"将二维码/条码放入框内，即可自动扫描";
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:13.f];
        [_label sizeToFit];
        CGRect frame = _label.frame;
        frame.origin.y = kScanBoxY + kScanBoxWidth + 5;
        _label.frame = frame;
        _label.center = CGPointMake(_scanBoxView.center.x, kScanBoxY + kScanBoxWidth + 5 + 10);
    }
    [_previewView addSubview:_label];
    return _scanBoxView;
}

@end




