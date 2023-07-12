//
//  StorageBusinessModel.m
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import <Foundation/Foundation.h>
#import "StorageBusinessModel.h"
#import "FileHelper.h"
#import "CacheService.h"
#import "FileData.h"

@interface StorageBusinessModel ()
@property (nonatomic) dispatch_queue_t backgroundQueue;

@end

@implementation StorageBusinessModel

-(instancetype) initWithRepository:(id<StorageRepositoryInterface>)repository {
    if (self == [super init]) {
        self.storageRepository = repository;
        self.backgroundQueue = dispatch_queue_create("com.storage.businessModel.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)getAppSize:(void (^)(long long size))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    [[_storageRepository fileDataProvider] getAppSize:completionBlock errorBlock:errorBlock];
    
}
- (void)getPhoneSize:(void (^)(long long size))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    [[_storageRepository fileDataProvider] getPhoneSize:completionBlock errorBlock:errorBlock];
}

- (void)getAllMediaSize:(void (^)(BOOL isFinish))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {

}
@end

