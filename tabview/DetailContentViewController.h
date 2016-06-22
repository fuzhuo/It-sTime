//
//  DetailContentViewController.h
//  tabview
//
//  Created by zfu on 6/19/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

@interface DetailContentViewController : UIViewController {
    NSString *title;
    NSString *music_url;
    BOOL isPlaying;
    BOOL musicDownloadOK;
}

@property NSInteger section;
@property NSInteger row;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *durationTime;
@property (weak, nonatomic) IBOutlet UIStackView *mainStackView;
@property (weak, nonatomic) IBOutlet UIStackView *musicStackView;
@property (nonatomic, strong) AVPlayer *player;
- (IBAction)playButton:(id)sender;
- (IBAction)stopButton:(id)sender;

@end
