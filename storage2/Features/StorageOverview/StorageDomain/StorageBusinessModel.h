//
//  StorageBusinessModel.h
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import <Foundation/Foundation.h>
#import "StorageRepositoryInterface.h"

@protocol StorageBusinessModelInterface
- (void)getAppSize:(void (^)(long long size))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)getPhoneSize:(void (^)(long long size))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)getTotalMediaSize:(FileType)fileType completionBlock:(void (^)(double size))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)getHeavyFiles:(void (^)(NSArray* files))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)deleteCache;
- (void)getCacheSize:(void (^)(double size))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)deleteAllMediaType:(FileType)fileType completionBlock:(void (^)(BOOL isFinish))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)getAllMediaSize:(void (^)(BOOL isFinish))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
@end

@interface StorageBusinessModel : NSObject<StorageBusinessModelInterface>
@property (nonatomic) id<StorageRepositoryInterface> storageRepository;
-(instancetype) initWithRepository:(id<StorageRepositoryInterface>)repository;

@end

