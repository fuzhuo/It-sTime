//
//  DetailContentViewController.m
//  tabview
//
//  Created by zfu on 6/19/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import "DetailContentViewController.h"
#import "FeedsData.h"
#import "UIApplication+RemoteControl.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

@interface DetailContentViewController ()

@end

@implementation DetailContentViewController
@synthesize title;
@synthesize row;
@synthesize section;
@synthesize player;

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"view Did Load, row = %ld", (long)row);
    musicDownloadOK = NO;
    self.tabBarController.tabBar.hidden=YES;
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    if (isPlaying) {
        [self.player pause];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[UIApplication sharedApplication] removeRemoteControl:self selector:@selector(onRemoteControleStateChanged:)];
    }
}

- (void)viewWillAppear:(BOOL)animated {    // Called when the view is about to made visible. Default does nothing
    //NSLog(@"view will appear, secion = %ld row = %ld", (long)section, (long)row);
    //RssItem_ *item = [[FeedsData getInstance].mRssData.items objectAtIndex:row];
    RssItem_ *item = [[[FeedsData getInstance].rssDatas objectAtIndex:section].items objectAtIndex:row];
    CGFloat fontSize = [FeedsData getInstance].fontSize;
    title = [NSString stringWithString:item.title];
    music_url = (item.musicURL)? [NSString stringWithString:item.musicURL] : nil;
    if (music_url == nil) {
        [self.musicStackView removeFromSuperview];
    }
    isPlaying = NO;
    self.navigationItem.title = item.title;
    NSString *str = [[NSString alloc] initWithFormat:@"<html>"
                     "<head>"
                     "<meta charset=\"UTF-8\">"
                     "<style type=\"text/css\">"
                     "figure {"
                         "text-align: center;"
                     "}"
                     "#body {"
                        "margin-left: 10px;"
                        "margin-right: 10px;"
                        "font-size: %.1f"
                     "}"
                     "</style>"
                     "</head>"
                     "  <body>"
                     "      <div id=\"body\">%@</div>"
                     "</html>",
                     fontSize,
                     item.content];
    [self.webview loadHTMLString:str baseURL:nil];
}
- (IBAction)playButton:(id)sender {
    if (music_url != nil && player==nil) {
        NSLog(@"try download music from URL for this Article: %@", music_url);
        NSURL *url = [NSURL URLWithString:music_url];
        AVURLAsset *asser = [AVURLAsset URLAssetWithURL:url options:nil];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asser];
        player = [AVPlayer playerWithPlayerItem:item];
        
        __weak DetailContentViewController *weakSelf = self;
        __weak NSString *weakTitle = title;
        [player addPeriodicTimeObserverForInterval:CMTimeMake(1*NSEC_PER_SEC, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
            float curr = CMTimeGetSeconds(time);
            float dur = CMTimeGetSeconds(item.duration);
            if (dur > 1.0 ) {
                weakSelf.progress.progress = curr/dur;
                if (musicDownloadOK==NO) {
                    musicDownloadOK=YES;
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject: weakTitle forKey:MPMediaItemPropertyTitle];
                    [dict setObject:@(dur) forKey:MPMediaItemPropertyPlaybackDuration];
                    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = dict;
                }
            }
            int min_curr = curr/60;
            int sec_curr = curr-min_curr*60;
            int min_durr = dur/60;
            int sec_durr = dur-min_durr*60;
            NSString *str = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d", min_curr, sec_curr, min_durr, sec_durr];
            weakSelf.durationTime.text = str;
        }];
        isPlaying = YES;
        //[self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"paused.png"] forState:UIControlStateNormal];
        [player play];
        NSLog(@"Playing");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        UIApplication *app = [UIApplication sharedApplication];
        [app observeRemoteControl:self selector:@selector(onRemoteControleStateChanged:)];
    } else {
        if (isPlaying) {
            isPlaying=!isPlaying;
            [player pause];
            //[self.playButton setTitle:@"Play" forState:UIControlStateNormal];
            [self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            NSLog(@"Stopping");
        } else {
            isPlaying=!isPlaying;
            //[self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
            [self.playButton setImage:[UIImage imageNamed:@"paused.png"] forState:UIControlStateNormal];
            [player play];
            NSLog(@"Playing");
        }
    }
}

-(void)handleInterreption:(NSNotification *)sender
{
    if(isPlaying)
    {
        [self.player pause];
        isPlaying=NO;
    }
    else
    {
        [self.player play];
        isPlaying=YES;
    }
}
         
- (void) onRemoteControleStateChanged:(NSNotification *)notification {
    if ([notification.name isEqualToString:kRemoteControlPlayTapped]) {
        isPlaying=YES;
        [self.player play];
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else if ([notification.name isEqualToString:kRemoteControlPauseTapped]) {
        isPlaying=NO;
        [self.player pause];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (IBAction)stopButton:(id)sender {
    if (player == nil) return;
    isPlaying=!isPlaying;
    [player pause];
    [player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    NSLog(@"Stopping");
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
