//
//  CacheManager.m
//  storage2
//
//  Created by LAP14885 on 21/06/2023.
//

#import "CacheManager.h"

@interface CacheManager ()
@property (strong, nonatomic) NSMutableDictionary* ramImageCaches;
@property (strong, nonatomic) NSMutableDictionary* diskImageCaches;

@end

@implementation CacheManager

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.ramImageCaches = [@{} mutableCopy];
        self.diskImageCaches = [@{} mutableCopy];
    }
    
    return self;
}

-(void)cacheImageByKey:(UIImage*)image withKey:(NSString*)key {
    [_ramImageCaches setObject:image forKey:key];
}

-(UIImage*)getImageByKey:(NSString*)key {
    return _ramImageCaches[key];
}
-(void)deleteImageByKey:(NSString*)key {
    [_ramImageCaches removeObjectForKey: key];
}

@end
