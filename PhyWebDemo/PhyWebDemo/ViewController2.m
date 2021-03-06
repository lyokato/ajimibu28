//
//  ViewController2.m
//  PhyWebDemo
//
//  Created by Lyo Kato on 2015/06/12.
//  Copyright (c) 2015年 Lyo Kato. All rights reserved.
//

#import "ViewController2.h"
#import "UBUriBeaconScanner.h"
#import "UBUriBeacon.h"

#import "AFHTTPSessionManager.h"

@interface ViewController2 ()
@property (nonatomic, strong) UBUriBeaconScanner *scanner;
@property (nonatomic, strong) UILabel *urlLabel;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupStartButton];
    [self setupStopButton];
    [self setupLabel];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.scanner = [[UBUriBeaconScanner alloc] init];
}

- (void)setupLabel
{
    CGRect r = CGRectMake(10, 160, 300, 50);
    UILabel *v = [[UILabel alloc] initWithFrame:r];
    
    v.numberOfLines = 2;
    v.textAlignment = NSTextAlignmentLeft;
    v.textColor = UIColor.blackColor;
    v.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:14];
    [self.view addSubview:v];
    self.urlLabel = v;
}

- (void)setupStartButton
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b setTitle:@"スキャン開始" forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.layer.backgroundColor = UIColor.grayColor.CGColor;
    b.layer.cornerRadius = 10.0;
    b.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:18];
    b.titleLabel.textColor = UIColor.blackColor;
    b.frame = CGRectMake(10, 50, 200, 50);
    [self.view addSubview:b];
    
    [b addTarget:self action:@selector(onStartButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onStartButtonTapped:(id)sender
{
    [self startScan];
}

- (void)setupStopButton
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b setTitle:@"スキャン停止" forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.layer.backgroundColor = UIColor.grayColor.CGColor;
    b.layer.cornerRadius = 10.0;
    b.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:18];
    b.titleLabel.textColor = UIColor.blackColor;
    b.frame = CGRectMake(10, 110, 200, 50);
    [self.view addSubview:b];
    
    [b addTarget:self action:@selector(onStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onStopButtonTapped:(id)sender
{
    [self stopScanning];
}

- (void)startScan {
    __weak typeof(self) wself = self;
    [self.scanner startScanningWithUpdateBlock:^{
        NSArray *beacons = [wself.scanner beacons];
        for(UBUriBeacon *beacon in beacons) {
            NSURL *u = beacon.URI;
            [self resolveURI:u];
        }
    }];
}

- (void)resolveURI:(NSURL *)url
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *params = @{
                             @"objects": @[
                                     @{ @"url": url.absoluteString }
                                     ]};
    
    [manager POST:@"http://atl-phyweb.net/resolve-scan"
       parameters:params
          success:^(NSURLSessionDataTask *task, id responseObject) {
              NSDictionary *results = (NSDictionary *)responseObject;
              NSArray *metadatas = results[@"metadata"];
              for (NSDictionary *metadata in metadatas) {
                  NSString *title = (NSString *)metadata[@"title"];
                  NSString *url = (NSString *)metadata[@"url"];
                  NSString *iconUrl = (NSString *)metadata[@"icon"];
                  NSString *description = (NSString *)metadata[@"description"];
                  
                  NSLog(@"%@:%@:%@:%@", title, url, iconUrl, description);
              }
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              
          }];
}

- (void)stopScanning {
    [self.scanner stopScanning];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
