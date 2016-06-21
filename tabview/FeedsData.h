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
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *pubDate;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *content;
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
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *lastBuildDate;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSMutableArray<RssItem_ *> *items;
@property (nonatomic, retain) NSMutableArray<UIImage*> *images;

@end

@interface FeedsData : NSObject {
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
@property (nonatomic, retain) id<FeedsUpdate> delegate;
@property (nonatomic, retain) NSMutableArray<RssData_*> *rssDatas;
@property (nonatomic, assign) BOOL showDefault;
@property (nonatomic, assign) BOOL showHinti;
@property (nonatomic, assign) BOOL showChinese;
@property (nonatomic, assign) BOOL darkMode;
@property (nonatomic, assign) BOOL autoPlayAudio;
@property (nonatomic, assign) CGFloat fontSize;
@end