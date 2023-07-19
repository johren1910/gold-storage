//
//  StorageDataRepository.m
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import "StorageDataRepository.h"
#import <UIKit/UIKit.h>
#import "ChatMessageProvider.h"
#import "FileDataProvider.h"

@interface StorageDataRepository ()
@property (nonatomic) id<StorageManagerType> storageManager;
@property (nonatomic) dispatch_queue_t backgroundQueue;
@end

@implementation StorageDataRepository

-(instancetype) initWithFileDataProvider:(id<FileDataProviderType>)fileDataProvider
                       andChatMessageProvider:(id<ChatMessageProviderType>)chatMessageProvider  andStorageManager:(id<StorageManagerType>)storageManager; {
    if (self == [super init]) {
        self.storageManager = storageManager;
        self.chatMessageProvider = chatMessageProvider;
        self.fileDataProvider = fileDataProvider;
        self.cacheService = [self.storageManager getCacheService];
        self.backgroundQueue = dispatch_queue_create("com.storage.datarepository.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
@synthesize fileDataProvider;
@synthesize chatMessageProvider;
@synthesize cacheService;
@end

