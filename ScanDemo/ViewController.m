//
//  ViewController.m
//  ScanDemo
//
//  Created by 韩威 on 16/4/7.
//  Copyright © 2016年 韩威. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"微信";
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightNaviBarBtnClick)];
}

#pragma mark - action Methods
- (void)rightNaviBarBtnClick {
    ScanViewController *scanVC = [ScanViewController new];
    [self.navigationController pushViewController:scanVC animated:YES];
}

@end
