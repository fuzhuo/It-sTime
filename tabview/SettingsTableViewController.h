//
//  SettingsTableViewController.h
//  tabview
//
//  Created by zfu on 6/20/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SettingsSwitch) {
    SettingsSwitchEnglish,
    SettingsSwitchHinti,
    SettingsSwitchChinese
};

@interface SettingsTableViewController : UITableViewController {
    
}

@property (nonatomic, weak) IBOutlet UISwitch *switchEnglish;
@property (nonatomic, weak) IBOutlet UISwitch *switchHinti;
@property (nonatomic, weak) IBOutlet UISwitch *switchChinese;
@property (nonatomic, weak) IBOutlet UISwitch *switchAutoPlayAudio;
@property (nonatomic, weak) IBOutlet UISwitch *switchDarkMode;
@property (nonatomic, weak) IBOutlet UISlider *sliderFontSize;
@property (nonatomic, weak) IBOutlet UILabel *fontSizeLabel;
- (IBAction)valueChanged:(id)sender;
- (IBAction)fontValueChanged:(id)sender;
@end
