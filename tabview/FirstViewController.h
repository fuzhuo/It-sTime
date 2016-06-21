//
//  FirstViewController.h
//  tabview
//
//  Created by zfu on 6/18/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedsData.h"

#import "DetailContentViewController.h"
@interface FirstViewController : UITableViewController <UITableViewDelegate, FeedsUpdate> {
    UIRefreshControl *refresh;
}

@property NSInteger selectedRow;
@property NSInteger selectedSection;
@property (strong, nonatomic) UIRefreshControl *refresh;

-(NSString*)htmlToPlainText:(NSString*)html;
-(void)refreshAction:(UIRefreshControl*)refresh;
-(NSString*)pubTimeToNow:(NSDate*) date;
@end

