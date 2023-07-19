//
//  StorageRepositoryInterface.h
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import "FileDataProvider.h"
#import "ChatMessageProvider.h"

@protocol StorageRepositoryInterface

@property (nonatomic) id<FileDataProviderType> fileDataProvider;
@property (nonatomic) id<CacheServiceType> cacheService;
@property (nonatomic) id<ChatMessageProviderType> chatMessageProvider;
@end

