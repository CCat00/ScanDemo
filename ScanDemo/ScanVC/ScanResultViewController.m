//
//  ScanResultViewController.m
//  ScanDemo
//
//  Created by 韩威 on 16/4/7.
//  Copyright © 2016年 韩威. All rights reserved.
//

#import "ScanResultViewController.h"

@interface ScanResultViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"扫描结果";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_resultString) {
        return;
    }
    if ([self isURL]) {
        self.webView.hidden = NO;
        self.resultLabel.hidden = YES;
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_resultString]];
        [self.webView loadRequest:request];
    }
    else {
        self.webView.hidden = YES;
        self.resultLabel.hidden = NO;
        self.resultLabel.text = _resultString;
    }
}

#pragma mark - setter
- (void)setResultString:(NSString *)resultString {
    _resultString = resultString;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"开始加载");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"加载完成");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    NSLog(@"加载失败");
}

#pragma mark - private
- (BOOL)isURL {
    NSString *checkRegex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", checkRegex];
    return [emailTest evaluateWithObject:_resultString];
}

@end
