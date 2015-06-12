//
//  ViewController3.m
//  PhyWebDemo
//
//  Created by Lyo Kato on 2015/06/12.
//  Copyright (c) 2015年 Lyo Kato. All rights reserved.
//

#import "ViewController3.h"
#import "MetadataCell.h"
#import "Metadata.h"

#import "UBUriBeaconScanner.h"
#import "UBUriBeacon.h"

#import "AFHTTPSessionManager.h"

#define MAX_NUMBER_OF_METADATA 5

@interface ViewController3 () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) UBUriBeaconScanner *scanner;
@property (nonatomic, strong) NSMutableArray *metadatas;
@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupStartButton];
    [self setupStopButton];
    [self setupListView];
    
    self.metadatas = @[].mutableCopy;
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.scanner = [[UBUriBeaconScanner alloc] init];
}

- (void)setupListView {
    CGRect s = [[UIApplication sharedApplication] statusBarFrame];
    CGRect b = UIScreen.mainScreen.bounds;
    CGRect r = CGRectMake(0, 170, b.size.width, b.size.height - 150);
    UITableView *v = [[UITableView alloc] initWithFrame:r];
    //v.backgroundColor = UIColorFromRGB(BaseColor);
    v.backgroundColor = UIColor.clearColor;
    v.separatorStyle = UITableViewCellSeparatorStyleNone;
    v.delegate = self;
    v.dataSource = self;
    //v.refresher = self;
    self.listView = v;
    [self.view addSubview:v];
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
                  
                  Metadata *m = [[Metadata alloc] init];
                  m.title = (NSString *)metadata[@"title"];
                  m.url = (NSString *)metadata[@"url"];
                  m.iconUrl = (NSString *)metadata[@"icon"];
                  m.desc = (NSString *)metadata[@"description"];
                  
                  [self.metadatas insertObject:m atIndex:0];
                  if (self.metadatas.count > MAX_NUMBER_OF_METADATA) {
                      [self.metadatas removeLastObject];
                  }
                  [self.listView reloadData];
                  
                  
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

#pragma mark UITableView Delegate & DataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // OpenURL
    Metadata *m = [self.metadatas objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:m.url]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.metadatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MetadataCell";
    MetadataCell *cell = [self.listView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MetadataCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:cellIdentifier];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
    }

    cell.metadata = [self.metadatas objectAtIndex:indexPath.row];
    [cell configure];
    
    
    return cell;
}

@end
