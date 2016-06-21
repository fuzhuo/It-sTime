//
//  DetailContentViewController.m
//  tabview
//
//  Created by zfu on 6/19/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import "DetailContentViewController.h"
#import "FeedsData.h"

@interface DetailContentViewController ()

@end

@implementation DetailContentViewController
@synthesize label;
@synthesize row;
@synthesize section;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view Did Load, row = %ld", (long)row);
    self.tabBarController.tabBar.hidden=YES;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {    // Called when the view is about to made visible. Default does nothing
    NSLog(@"view will appear, secion = %ld row = %ld", (long)section, (long)row);
    //RssItem_ *item = [[FeedsData getInstance].mRssData.items objectAtIndex:row];
    RssItem_ *item = [[[FeedsData getInstance].rssDatas objectAtIndex:section].items objectAtIndex:row];
    self.navigationItem.title = item.title;
    NSString *str = [[NSString alloc] initWithFormat:@"<head> <meta charset=\"UTF-8\">"
                     "<style type=\"text/css\">"
                     "figure {"
                         "text-align: center;"
                     "}"
                     "#body {"
                        "margin-left: 10px;"
                        "margin-right: 10px;"
                     "}"
                     "</style></head><body><div id=\"body\">%@</div></html>", item.content];
    [self.webview loadHTMLString:str baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"DetailContentViewController, self=%p", self);
}

@end
