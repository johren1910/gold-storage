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
    __weak StorageBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [[weakself.storageRepository fileDataProvider] getAppSize:completionBlock errorBlock:errorBlock];
    });
    
}
- (void)getPhoneSize:(void (^)(long long size))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak StorageBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [[weakself.storageRepository fileDataProvider] getPhoneSize:completionBlock errorBlock:errorBlock];
    });
    
}

- (void)getAllMediaSize:(void (^)(NSArray* items))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    __weak StorageBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [[weakself.storageRepository fileDataProvider] getAllStorageItem:^(NSArray* items) {
            completionBlock(items);
        } errorBlock:nil];
    });
    
}

- (void)deleteAllMediaTypes:(NSArray<StorageSpaceItem*>*)items completionBlock:(void (^)(BOOL isFinish))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak StorageBusinessModel* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        for (StorageSpaceItem* item in items) {
            
            switch (item.fileType) {
                case Video:
                case Picture: {
                    [weakself _handleDeleteMediaFileType:item.fileType completionBlock:completionBlock];
                    break;
                }
                case Misc:
                    completionBlock(true);
                    break;
            }
        }
    });
}

-(void)_handleDeleteMediaFileType:(FileType)fileType completionBlock:(void (^)(BOOL isFinish))completionBlock{
    [self.storageRepository.fileDataProvider getAllFilesByType:fileType completionBlock:^(NSArray* objects) {
        
        NSMutableArray* messages = [[NSMutableArray alloc] init];
        for (FileData* file in objects) {
            ChatMessageData* tmpMessageData = [[ChatMessageData alloc] initWithMessage:file.messageId messageId:file.messageId chatRoomId:nil];
            tmpMessageData.file = file;
            [messages addObject:tmpMessageData];
        }
        
        [self.storageRepository.chatMessageProvider deleteChatMessagesOf:messages completionBlock:completionBlock];
    } errorBlock:nil];
}
@end
