//
//  ChatDetailDataRepository.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatDetailReporitoryInterface.h"
#import "StorageManager.h"
#import "ZODownloadManagerType.h"

@interface ChatDetailDataRepository : NSObject <ChatDetailRepositoryInterface>
-(instancetype) initWithDownloadManager:(id<ZODownloadManagerType>)downloadManager andFileDataProvider:(id<FileDataProviderType>)fileDataProvider
        andChatMessageProvider:(id<ChatMessageProviderType>)messageProvider andStorageManager:(id<StorageManagerType>)storageManager;

@end
