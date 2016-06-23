//
//  NSString+MD5.m
//  tabview
//
//  Created by zfu on 6/23/16.
//  Copyright © 2016 zfu. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MD5)
- (NSString*)stringToMD5:(NSString*)str {
    const char *fooData = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(fooData, (CC_LONG)strlen(fooData), result);
    
    NSMutableString *code_result = [NSMutableString string];
    
    for (int i=0; i< CC_MD5_DIGEST_LENGTH; i++) {
        [code_result appendFormat:@"%02x", result[i]];
    }
    return code_result;
}
@end
