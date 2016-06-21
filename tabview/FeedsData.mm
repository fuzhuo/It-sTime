//
//  FeedsData.m
//  tabview
//
//  Created by zfu on 6/18/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import "FeedsData.h"
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
@synthesize showHinti;
@synthesize showChinese;
@synthesize autoPlayAudio;
@synthesize darkMode;
@synthesize fontSize;

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
    if (self.showHinti) [self fetchFeedsFromURL:HINDI toIndex:1];
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
            [mRssData.items addObject:item_];
            [mRssData.images addObject:[UIImage imageNamed:@"favicon_color.png" ]];
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img class=.*src=\"(.*)\" alt=.*/>" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *matches = [regex matchesInString:item_.content options:0 range:NSMakeRange(0, item_.content.length)];
            NSString *img_url = nil;
            if ([matches count]!=0) {
                img_url = [item_.content substringWithRange:[matches[0] rangeAtIndex:1]];
                //NSLog(@"img: url=%@", img_url);
            }
            [self fetchImageFromURL:img_url section:index row:i];
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
    NSLog(@"read diction: %@", dict);
    //default settings
    if (dict == nil) {
        self.showChinese= YES;
        self.showHinti = YES;
        self.showDefault = YES;
        self.fontSize = 14.0f;
        self.darkMode = NO;
        self.autoPlayAudio = YES;
    } else {
        self.showChinese = [[dict valueForKey:@"showChinese"] boolValue];
        self.showHinti = [[dict valueForKey:@"showHinti"] boolValue];
        self.showDefault = [[dict valueForKey:@"showDefault"] boolValue];
        self.darkMode = [[dict valueForKey:@"darkMode"] boolValue];
        self.autoPlayAudio = [[dict valueForKey:@"autoPlayAudio"] boolValue];
        self.fontSize = [[dict valueForKey:@"fontSize"] doubleValue];
    }
}

- (void)saveSettings {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"settings.plst"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:(self.showDefault)?@"YES":@"NO" forKey:@"showDefault"];
    [dict setObject:(self.showHinti)?@"YES":@"NO" forKey:@"showHinti"];
    [dict setObject:(self.showChinese)?@"YES":@"NO" forKey:@"showChinese"];
    [dict setObject:(self.autoPlayAudio)?@"YES":@"NO" forKey:@"autoPlayAudio"];
    [dict setObject:(self.darkMode)?@"YES":@"NO" forKey:@"darkMode"];
    [dict setObject:[NSString stringWithFormat:@"%f", self.fontSize] forKey:@"fontSize"];
    [dict writeToFile:filePath atomically:YES];
    NSLog(@"save settings %@", dict);
}
@end
