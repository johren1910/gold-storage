//
//  HashHelper.h
//  storage2
//
//  Created by LAP14885 on 19/06/2023.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface HashHelper : NSObject
+ (NSString *) hashStringMD5:(NSString *) input;
+ (NSString *) hashDataMD5:(NSData *) data;
@end
