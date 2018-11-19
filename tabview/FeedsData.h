//
//  FeedsData.h
//  tabview
//
//  Created by zfu on 6/18/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FeedsData;
@protocol FeedsUpdate <NSObject>
- (void)feedsRequetSuccess: (FeedsData*)feedsData;
- (void)feedsRequetFailed: (FeedsData*)feedsData;
@end

@interface RssItem_ : NSObject {
    NSString *title;
    NSString *link;
    NSString *pubDate;
    NSString *description;
    NSString *content;
    NSString *musicURL;
    NSString *md5;
    BOOL unread;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *pubDate;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *musicURL;
@property (nonatomic, retain) NSString *md5;
@property (nonatomic, assign) BOOL unread;
@end

@interface RssData_ : NSObject {
    NSMutableArray<RssItem_ *> *items;
    NSString *version;
    NSString *title;
    NSString *link;
    NSString *lastBuildDate;
    NSString *description;
    NSString *language;
}
@property (nonatomic, readwrite, copy) NSString *version;
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *link;
@property (nonatomic, readwrite, copy) NSString *lastBuildDate;
@property (nonatomic, readwrite, copy) NSString *description;
@property (nonatomic, readwrite, copy) NSString *language;
@property (nonatomic, readwrite, strong) NSMutableArray<RssItem_ *> *items;
@property (nonatomic, readwrite, strong) NSMutableArray<UIImage*> *images;

@end

@interface FeedsData : NSObject {
    NSMutableDictionary *cookie;
}
- (void)fetchFeedsFromURL:(NSString*)feed_url toIndex:(NSInteger) index;
- (void)fetchImageFromURL:(NSString*)feed_url section:(NSInteger) section row:(NSInteger) row;
- (id)init;
- (void)loadFeeds;
- (void)changeStatus;
+ (FeedsData*)getInstance;
- (void)changeSettings;
- (void)loadSettings;
- (void)saveSettings;
//cookies is for mark unread/read
- (void)loadCookie;
- (void)saveCookie;
- (void)addCookieForItemAtSection:(NSInteger)section row: (NSInteger) row;
- (void)addCookie:(NSString*)md5;
- (void)delCookie:(NSString*)md5;
@property (nonatomic, readwrite, weak) id<FeedsUpdate> delegate;
@property (nonatomic, readwrite, strong) NSMutableArray<RssData_*> *rssDatas;
@property (nonatomic, readwrite, strong) NSMutableDictionary *cookie;
@property (nonatomic, readwrite, assign) BOOL showDefault;
@property (nonatomic, readwrite, assign) BOOL showHindi;
@property (nonatomic, readwrite, assign) BOOL showChinese;
@property (nonatomic, readwrite, assign) BOOL darkMode;
@property (nonatomic, readwrite, assign) BOOL autoPlayAudio;
@property (nonatomic, readwrite, assign) CGFloat fontSize;
@end
