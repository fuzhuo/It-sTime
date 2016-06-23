//
//  FirstViewController.m
//  tabview
//
//  Created by zfu on 6/18/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import "FirstViewController.h"
#import "FeedsData.h"
#import "TableViewCell.h"

static BOOL darkMode = YES;
@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize selectedRow;
@synthesize selectedSection;
@synthesize refresh;

- (void)viewDidLoad {
    [super viewDidLoad];
    [FeedsData getInstance].delegate = self;
    //[[FeedsData getInstance] addFeeds: @"test"];
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [[FeedsData getInstance] loadFeeds];
    // Do any additional setup after loading the view, typically from a nib.
    refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor lightGrayColor];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh"];
    [refresh addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshAction:(UIRefreshControl*)refresh {
    //NSLog(@"refresh");
    [[FeedsData getInstance] loadFeeds];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //NSLog(@"prepareForSegue, %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        DetailContentViewController *controller = (DetailContentViewController*)segue.destinationViewController;
        controller.row = self.selectedRow;
        controller.section = self.selectedSection;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[[FeedsData getInstance].rssDatas objectAtIndex:section].items count];//[[FeedsData getInstance].mRssData.items count];
    //NSLog(@"count=%ld", (long)count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifiler = @"Cell";
    TableViewCell *cell = (TableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifiler forIndexPath:indexPath];
    RssItem_ *item =[[[FeedsData getInstance].rssDatas objectAtIndex:indexPath.section].items objectAtIndex:indexPath.row];
    cell.title.text = item.title;
    if (item.unread == NO) {
        cell.title.textColor = [UIColor lightGrayColor];
    } else {
        cell.title.textColor = [UIColor blackColor];
    }
    //NSLog(@"reload cell for section[%lu, %lu]", indexPath.section, indexPath.row);
    NSString *str = [self htmlToPlainText:item.description];
    cell.description.text = str;
    UIImage *img = [[[FeedsData getInstance].rssDatas objectAtIndex:indexPath.section].images objectAtIndex:indexPath.row];
    if (img != nil) {
        [cell.image setImage:img];
    }
    if (item.musicURL != nil) [cell.podcastImage setImage:[UIImage imageNamed:@"podcast_cyan.png"]];
    else [cell.podcastImage setImage:[UIImage imageNamed:@"status_podcast.png"]];
                           
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"EEE, d MMM yyyy HH:mm:ss Z";
    NSDate *date = [dateFormatter dateFromString: item.pubDate];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    cell.dateLabel.text = [self pubTimeToNow:date];//[dateFormatter stringFromDate:date];
    
    /*
    if (darkMode) {
        self.tableView.backgroundColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor blackColor];
        cell.dateLabel.textColor = [UIColor whiteColor];
        cell.title.textColor = [UIColor whiteColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
        self.tabBarController.tabBar.backgroundColor = [UIColor blackColor];
    }
     */
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"click[%ld]", (long)indexPath.row);
    self.selectedRow = indexPath.row;
    self.selectedSection = indexPath.section;
    [self setHidesBottomBarWhenPushed:YES];
    [self performSegueWithIdentifier:@"showDetail" sender:self];
    [self setHidesBottomBarWhenPushed:NO];
    [[FeedsData getInstance] addCookieForItemAtSection:self.selectedSection row:self.selectedRow];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:self.selectedSection];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC),dispatch_get_main_queue(), ^{
        //NSLog(@"async reload rows");
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)feedsRequetSuccess: (FeedsData*)feedsData {
    //NSLog(@"Fist feeds success");
    [self.tableView reloadData];
    if (refresh.refreshing) {
        [self.refreshControl endRefreshing];
    }
}
- (void)feedsRequetFailed: (FeedsData*)feedsData {
    NSLog(@"Fist feeds failed");
}
-(NSString*)htmlToPlainText:(NSString*)html {
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    NSString * regEx = @"&#...; ?";
    NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:regEx options:NSRegularExpressionCaseInsensitive error:nil];
    html = [reg stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, [html length]) withTemplate:@""];
    return html;  
}

-(NSString*)pubTimeToNow:(NSDate*) date {
    NSTimeInterval late=[date timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval chas=now-late;
    int cha = (int)chas;
    
    if (cha/3600 < 1) {
        timeString = [NSString stringWithFormat:@"%d", cha/60];
        timeString=[NSString stringWithFormat:@"%@ min%@ ago", timeString, (cha/60 > 1)?@"s":@""];
    } else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%d", cha/3600];
        timeString=[NSString stringWithFormat:@"%@ hour%@ ago", timeString, (cha/3600 > 1)?@"s":@""];
    } else {
        cha/=86400;
        if (cha>=1 && cha<7)
        {
            timeString = [NSString stringWithFormat:@"%d", cha];
            timeString=[NSString stringWithFormat:@"%@ day%@ ago", timeString, (cha>1)?@"s":@""];
        } else if (cha<30) {
            timeString = [NSString stringWithFormat:@"%d", cha/7];
            timeString=[NSString stringWithFormat:@"%@ week%@ ago", timeString, (cha/7>1)?@"s":@""];
        } else if (cha<365) {                                                
            timeString = [NSString stringWithFormat:@"%d", cha/30];
            timeString=[NSString stringWithFormat:@"%@ month%@ ago", timeString, (cha/30>1)?@"s":@""];
        } else {                                                             
            timeString = [NSString stringWithFormat:@"%d", cha/365];
            timeString=[NSString stringWithFormat:@"%@ year%@ ago", timeString, (cha/365>1)?@"s":@""];
        }                                                                    
    }
    return timeString;
}
@end
