//
//  HashHelper.m
//  storage2
//
//  Created by LAP14885 on 19/06/2023.
//

#import "HashHelper.h"

@implementation HashHelper

+ (NSString *) hashStringMD5:(NSString *) string {
    const char *utf8Str = [string UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5( utf8Str, (int)strlen(utf8Str), result ); // This is the md5 call

        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", result[i]];

        return  output;
}

+ (NSString *) hashDataMD5:(NSData *) data {
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5( data.bytes, (int)data.length, result);

        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", result[i]];

        return  output;
}
@end
