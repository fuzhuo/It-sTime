//
//  DetailContentViewController.h
//  tabview
//
//  Created by zfu on 6/19/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailContentViewController : UIViewController {
    NSString *label;
}
@property NSString *label;
@property NSInteger section;
@property NSInteger row;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@end
