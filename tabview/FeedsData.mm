//
//  FeedsData.m
//  tabview
//
//  Created by zfu on 6/18/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import "FeedsData.h"
#import "NSString+MD5.h"
#include "RssParser.h"
#include "AFNetworking.h"

#define HINDI @"http://www.itstimetomeditate.org/category/Hindi/feed/"
#define CHINESE @"http://www.itstimetomeditate.org/category/chinese/feed/"
#define DEFAULT @"http://www.itstimetomeditate.org/category/uncategorized/feed/"

@implementation RssItem_

@synthesize title;
@synthesize link;
@synthesize pubDate;
@synthesize description;
@synthesize content;
@synthesize musicURL;
@synthesize md5;
@synthesize unread;

@end

@implementation RssData_
@synthesize version;
@synthesize title;
@synthesize link;
@synthesize lastBuildDate;
@synthesize description;
@synthesize language;
@synthesize items;
@synthesize images;
@end

@implementation FeedsData
@synthesize delegate;
@synthesize rssDatas;
@synthesize showDefault;
@synthesize showHindi;
@synthesize showChinese;
@synthesize autoPlayAudio;
@synthesize darkMode;
@synthesize fontSize;
@synthesize cookie;

static FeedsData *_sharedFeedsData;
+ (FeedsData*)getInstance {
    if (_sharedFeedsData == nil) {
        _sharedFeedsData = [[FeedsData alloc] init];
    }
    return _sharedFeedsData;
}

- (id)init {
    self = [super init];
    self.rssDatas = [[NSMutableArray alloc] init];
    for (int i=0; i<3; i++) {
        RssData_ *data = [[RssData_ alloc] init];
        data.items = [[NSMutableArray alloc] init];
        data.images = [[NSMutableArray alloc] init];
        [self.rssDatas addObject:data];
    }
    
    //configurations
    [self loadSettings];
    [self loadCookie];
    return self;
}

- (void)changeStatus {
    [[rssDatas objectAtIndex:0].items removeAllObjects];
    [[rssDatas objectAtIndex:1].items removeAllObjects];
    [[rssDatas objectAtIndex:2].items removeAllObjects];
    [[rssDatas objectAtIndex:0].images removeAllObjects];
    [[rssDatas objectAtIndex:1].images removeAllObjects];
    [[rssDatas objectAtIndex:2].images removeAllObjects];
    [self loadFeeds];
    [self saveSettings];
}

- (void)changeSettings {
    [self saveSettings];
}

- (void)loadFeeds {
    if (self.showDefault) [self fetchFeedsFromURL:DEFAULT toIndex:0];
    if (self.showHindi) [self fetchFeedsFromURL:HINDI toIndex:1];
    if (self.showChinese) [self fetchFeedsFromURL:CHINESE toIndex:2];
}

- (void)fetchFeedsFromURL:(NSString*)feed_url toIndex:(NSInteger) index {
    //NSLog(@"start fetch");
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setAllowsCellularAccess:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObject:@"application/rss+xml"];
    [manager GET:feed_url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSData *data = responseObject;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        RssParser *parser = new RssParser;
        parser->initWithString([str UTF8String]);
        RssData &rssData = parser->rssData;
        RssData_ *mRssData = [self.rssDatas objectAtIndex: index];
        [mRssData.items removeAllObjects];
        [mRssData.images removeAllObjects];
        mRssData.version = [NSString stringWithUTF8String: rssData.version.c_str()];
        mRssData.title = [NSString stringWithUTF8String: rssData.title.c_str()];
        mRssData.link = [NSString stringWithUTF8String: rssData.link.c_str()];
        mRssData.lastBuildDate = [NSString stringWithUTF8String: rssData.lastBuildDate.c_str()];
        mRssData.description = [NSString stringWithUTF8String: rssData.description.c_str()];
        mRssData.language = [NSString stringWithUTF8String: rssData.language.c_str()];
        
        for (int i=0; i<rssData.items.size(); i++) {
            //NSLog(@"Title %@", [NSString stringWithUTF8String: rssData.items[i].title.c_str()]);
            RssItem_ *item_ = [[RssItem_ alloc] init];
            RssItem &item = rssData.items[i];
            item_.title = [NSString stringWithUTF8String:item.title.c_str()];
            item_.link = [NSString stringWithUTF8String:item.link.c_str()];
            item_.pubDate = [NSString stringWithUTF8String:item.pubDate.c_str()];
            item_.description = [NSString stringWithUTF8String:item.description.c_str()];
            item_.content = [NSString stringWithUTF8String:item.content.c_str()];
            item_.md5 = [item_.link stringToMD5:item_.link];
            id c = [cookie objectForKey:item_.md5];
            if (c!=nil && [c boolValue]) {
                item_.unread = NO;
            } else {
                item_.unread = YES;
            }
            //NSLog(@"[%lu,%d], unread[%d], md5[%@], link[%@]", index, i, item_.unread, item_.md5, item_.link);
            [mRssData.images addObject:[UIImage imageNamed:@"pic_placeholder.png" ]];
            //for img
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img class=.*src=\"(.*)\" alt=.*/>" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *matches = [regex matchesInString:item_.content options:0 range:NSMakeRange(0, item_.content.length)];
            NSString *img_url = nil;
            if ([matches count]!=0) {
                img_url = [item_.content substringWithRange:[matches[0] rangeAtIndex:1]];
                //NSLog(@"img: url=%@", img_url);
            }
            [self fetchImageFromURL:img_url section:index row:i];
            
            //for music
            NSRegularExpression *music_regex = [NSRegularExpression regularExpressionWithPattern:@"<audio.*src=\"([^<> \"]*)\" /><a.*</audio>" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *music_matches = [music_regex matchesInString:item_.content options:0 range:NSMakeRange(0, item_.content.length)];
            NSString *music_url = nil;
            if ([music_matches count]!=0) {
                music_url = [item_.content substringWithRange:[music_matches[0] rangeAtIndex:1]];
                //NSLog(@"music_url %@", music_url);
            }
            item_.musicURL = music_url;
            //remove <audio> .. </audio> from contents
            /*
            NSRegularExpression *regex_remove_audio = [NSRegularExpression regularExpressionWithPattern:@"<audio.*</audio>" options:NSRegularExpressionCaseInsensitive error:nil];
            NSMutableString *str = [NSMutableString stringWithString:item_.content];
            [regex_remove_audio replaceMatchesInString:str options:0 range:NSMakeRange(0, item_.content.length) withTemplate:@""];
            item_.content = [NSString stringWithFormat:@"%@", str];
             */
            [mRssData.items addObject:item_];
        }
        delete parser;
        if (delegate!=nil) {
            [delegate feedsRequetSuccess:self];
        } else {
            //NSLog(@"Warning No delegate set");
            [delegate feedsRequetFailed:self];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error, %@", error);
    }];
    //NSLog(@"end fetch");
}

- (void)fetchImageFromURL:(NSString*)feed_url section:(NSInteger) section row:(NSInteger) row {
    if (!feed_url) return;
    NSLog(@"fetchImageFromURL %@", feed_url);
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setAllowsCellularAccess:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    [manager GET:feed_url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"get image success[%@]", feed_url);
        UIImage *image = responseObject;
        [[self.rssDatas objectAtIndex:section].images replaceObjectAtIndex:row withObject:image];
        [delegate feedsRequetSuccess:self];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //NSLog(@"get image failed");
        [delegate feedsRequetFailed:self];
    }];
}

- (void)loadSettings {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"settings.plst"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    //NSLog(@"read diction: %@", dict);
    //default settings
    if (dict == nil) {
        self.showChinese= YES;
        self.showHindi = YES;
        self.showDefault = YES;
        self.fontSize = 14;
        self.darkMode = NO;
        self.autoPlayAudio = YES;
    } else {
        self.showChinese = [[dict valueForKey:@"showChinese"] boolValue];
        self.showHindi = [[dict valueForKey:@"showHindi"] boolValue];
        self.showDefault = [[dict valueForKey:@"showDefault"] boolValue];
        self.darkMode = [[dict valueForKey:@"darkMode"] boolValue];
        self.autoPlayAudio = [[dict valueForKey:@"autoPlayAudio"] boolValue];
        self.fontSize = [[dict valueForKey:@"fontSize"] floatValue];
    }
}

- (void)saveSettings {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"settings.plst"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:(self.showDefault)?@"YES":@"NO" forKey:@"showDefault"];
    [dict setObject:(self.showHindi)?@"YES":@"NO" forKey:@"showHindi"];
    [dict setObject:(self.showChinese)?@"YES":@"NO" forKey:@"showChinese"];
    [dict setObject:(self.autoPlayAudio)?@"YES":@"NO" forKey:@"autoPlayAudio"];
    [dict setObject:(self.darkMode)?@"YES":@"NO" forKey:@"darkMode"];
    [dict setObject:[NSString stringWithFormat:@"%f", self.fontSize] forKey:@"fontSize"];
    [dict writeToFile:filePath atomically:YES];
    //NSLog(@"save settings %@", dict);
}
- (void)loadCookie {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"cookie.plst"];
    cookie = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    NSLog(@"load cookie!!");
    if (cookie == nil) {
        cookie = [[NSMutableDictionary alloc] init];
    }
}

- (void)saveCookie {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"cookie.plst"];
    [cookie writeToFile:filePath atomically:YES];
}

- (void)addCookieForItemAtSection:(NSInteger)section row: (NSInteger) row {
    [[rssDatas objectAtIndex:section].items objectAtIndex:row].unread = NO;
    NSString *md5 = [[rssDatas objectAtIndex:section].items objectAtIndex:row].md5;
    [self addCookie:md5];
}
- (void)addCookie:(NSString*)md5 {
    [cookie setObject:@(YES) forKey:md5];
    [self saveCookie];
}
- (void)delCookie:(NSString*)md5 {
    [cookie removeObjectForKey:md5];
    [self saveCookie];
}
@end
