//
//  CacheManager.h
//  storage2
//
//  Created by LAP14885 on 21/06/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CacheManager: NSObject
-(void)cacheImageByKey:(UIImage*)image withKey:(NSString*)key;
-(UIImage*)getImageByKey:(NSString*)key;
-(void)deleteImageByKey:(NSString*)key;
- (instancetype) init;
@end
