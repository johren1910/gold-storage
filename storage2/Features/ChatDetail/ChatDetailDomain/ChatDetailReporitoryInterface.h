//
//  ChatDetailReporitoryInterface.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//
#import "ChatDetailEntity.h"
#import "ChatMessageData.h"
#import "ZODownloadItem.h"
#import "ChatMessageProvider.h"
#import "FileDataProvider.h"

@protocol ChatDetailRepositoryInterface

@property (nonatomic) id<ChatMessageProviderType> chatMessageProvider;
@property (nonatomic) id<FileDataProviderType> fileDataProvider;

- (void)startDownloadWithItem:(ZODownloadItem*)item
                   forMessage: (ChatMessageData*)message completionBlock:(void(^)(FileData* fileData, UIImage* thumbnail))completionBlock;
@end
