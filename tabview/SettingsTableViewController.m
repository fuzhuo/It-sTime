//
//  SettingsTableViewController.m
//  tabview
//
//  Created by zfu on 6/20/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "FeedsData.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"load settings");
    FeedsData *feedsData = [FeedsData getInstance];
    [self.switchChinese setOn: feedsData.showChinese];
    [self.switchHindi setOn: feedsData.showHindi];
    [self.switchEnglish setOn: feedsData.showDefault];
    [self.switchDarkMode setOn: feedsData.darkMode];
    [self.switchAutoPlayAudio setOn: feedsData.autoPlayAudio];
    [self.sliderFontSize setValue:feedsData.fontSize];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%d", (int)feedsData.fontSize];
    Boolean englishOn = [self.switchEnglish isOn];
    Boolean hindiOn = [self.switchHindi isOn];
    Boolean chineseOn = [self.switchChinese isOn];
    int total = englishOn + hindiOn + chineseOn;
    if (total==1) {
        if (englishOn) [self.switchEnglish setEnabled:NO];
        else if (hindiOn) [self.switchHindi setEnabled:NO];
        else if (chineseOn) [self.switchChinese setEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)valueChanged:(id)sender {
    if (sender == self.switchHindi || sender == self.switchEnglish || sender == self.switchChinese) {
        Boolean englishOn = [self.switchEnglish isOn];
        Boolean hindiOn = [self.switchHindi isOn];
        Boolean chineseOn = [self.switchChinese isOn];
        int total = englishOn + hindiOn + chineseOn;
        if (total==1) {
            if (englishOn) [self.switchEnglish setEnabled:NO];
            else if (hindiOn) [self.switchHindi setEnabled:NO];
            else if (chineseOn) [self.switchChinese setEnabled:NO];
        } else {
            [self.switchEnglish setEnabled:YES];
            [self.switchHindi setEnabled:YES];
            [self.switchChinese setEnabled:YES];
        }
        [FeedsData getInstance].showChinese = chineseOn;
        [FeedsData getInstance].showDefault = englishOn;
        [FeedsData getInstance].showHindi = hindiOn;
        [[FeedsData getInstance] changeStatus];
    }
    [FeedsData getInstance].autoPlayAudio = [self.switchAutoPlayAudio isOn];
    [FeedsData getInstance].darkMode = [self.switchDarkMode isOn];
    [[FeedsData getInstance] changeSettings];
}
- (IBAction)fontValueChanged:(id)sender {
    NSInteger value = [self.sliderFontSize value];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%ld", value];
    [FeedsData getInstance].fontSize = value;
    [[FeedsData getInstance] changeSettings];
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}
 */

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
