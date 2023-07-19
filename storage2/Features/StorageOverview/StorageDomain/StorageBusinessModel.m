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
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "FileHelper.h"

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
    
    __block int totalOperation = 0;
    dispatch_async(_backgroundQueue, ^{
        for (StorageSpaceItem* item in items) {
            
            switch (item.fileType) {
                case Video:
                case Picture: {
                    [weakself _handleDeleteMediaFileType:item.fileType completionBlock:^(BOOL isFinish) {
                        totalOperation += 1;
                        if(totalOperation==items.count){
                            completionBlock(true);
                        }
                    }];
                    break;
                }
                case Misc:
                    [weakself.storageRepository.cacheService clearCacheDirectory:^(BOOL isDeleted){
                        [weakself.storageRepository.cacheService clearTmpDirectory:^(BOOL isDeleted){
                            totalOperation+=1;
                            if(totalOperation==items.count){
                                completionBlock(true);
                            }
                        }];
                    }];
                    break;
            }
        }
    });
}

- (void)deleteFiles:(NSArray<FileData*>*)items completionBlock:(void (^)(BOOL isFinish))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    __weak StorageBusinessModel* weakself = self;
    
    NSString* whereStr = @"checksum in (";
    for (FileData* item in items) {
        
        NSString* checksumStr = [NSString stringWithFormat:@"\"%@\"", item.checksum];
        whereStr = [whereStr stringByAppendingString:checksumStr];
        if(item != items.lastObject) {
            whereStr = [whereStr stringByAppendingString:@","];
        }
    }
    whereStr = [whereStr stringByAppendingString:@")"];
    
    [_storageRepository.fileDataProvider getFilesWhere:whereStr select:nil isDistinct:false groupBy:nil orderBy:nil completionBlock:^(NSArray* items) {
        
        NSMutableArray<ChatMessageData*>* messages = [[NSMutableArray alloc] init];
        
        for (FileData* item in items) {
            ChatMessageData* message = [[ChatMessageData alloc] initWithMessage:item.messageId messageId:item.messageId chatRoomId:nil];
            message.file = item;
            
            [messages addObject:message];
        }
        
        [weakself.storageRepository.chatMessageProvider deleteChatMessagesOf:messages completionBlock:^(BOOL isFinish) {
            completionBlock(isFinish);
        }];
        
    } errorBlock:nil];
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

- (void)getHeavyFiles:(void (^)(NSArray* items))completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    __weak StorageBusinessModel* weakself = self;
    [self.storageRepository.fileDataProvider getFilesWhere:nil select:nil isDistinct:true groupBy:@"checksum" orderBy:@"size" completionBlock:^(NSArray *items){
        
        dispatch_async(weakself.backgroundQueue, ^{
            NSMutableArray* entities = [[NSMutableArray alloc] init];
            
            for (FileData* item in items) {
                ChatDetailEntity* entity = [[ChatDetailEntity alloc] init];
                entity.file = item;
                entity.messageId = [[NSUUID UUID] UUIDString];
                UIImage *thumbnail = nil;
                thumbnail = [weakself.storageRepository.cacheService getImageByKey:item.checksum];
                
                if(!thumbnail) {
                    ZOMediaInfo *mediaInfo = nil;
                    switch (item.type) {
                        case Picture: {
                            NSData *fileData = [FileHelper readFileAtPathAsData:[FileHelper absolutePath:item.filePath]];
                            
                            thumbnail = [UIImage imageWithData:fileData];
                            NSData* compressed = UIImageJPEGRepresentation(thumbnail, 0.5);
                            thumbnail = [UIImage imageWithData:compressed];
                            [weakself.storageRepository.cacheService cacheImageByKey:thumbnail withKey:item.checksum];
                            break;
                        }
                        case Video:
                            mediaInfo = [FileHelper getMediaInfoOfFilePath:[FileHelper absolutePath:item.filePath]];
                            thumbnail = mediaInfo.thumbnail;
                            [weakself.storageRepository.cacheService cacheImageByKey:thumbnail withKey:item.checksum];
                            
                            break;
                        default:
                            break;
                    }
                }
                
                entity.thumbnail = thumbnail;
                [entities addObject:entity];
            }
            
            completionBlock(entities);
        });
            
    } errorBlock:nil];
}

@end
