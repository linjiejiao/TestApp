//
//  ViewController.m
//  TestApp
//
//  Created by liang jiajian on 2018/4/4.
//  Copyright © 2018年 liang jiajian. All rights reserved.
//

#import "ViewController.h"
#import "ServerSocketManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [[ServerSocketManager sharedInstance] setupServer];
}

@end
