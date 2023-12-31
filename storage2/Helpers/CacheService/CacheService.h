//
//  CacheService.h
//  storage2
//
//  Created by LAP14885 on 21/06/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CacheServiceType

-(void)cacheImageByKey:(UIImage*)image withKey:(NSString*)key;
-(UIImage*)getImageByKey:(NSString*)key;
-(void)deleteImageByKey:(NSString*)key;
-(void)clearCacheDirectory:(void(^)(BOOL isFinish))completionBlock;
-(void)clearTmpDirectory:(void(^)(BOOL isFinish))completionBlock;

@end

@interface CacheService : NSObject  <CacheServiceType>
- (instancetype) init;
@end
