//
//  ChatDetailReporitoryInterface.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//
#import "ChatDetailEntity.h"
#import "ChatMessageData.h"
#import "ZODownloadUnit.h"
#import "ChatMessageProvider.h"
#import "FileDataProvider.h"

@protocol ChatDetailRepositoryInterface

@property (nonatomic) id<ChatMessageProviderType> chatMessageProvider;
@property (nonatomic) id<FileDataProviderType> fileDataProvider;

- (void)startDownloadWithUnit:(ZODownloadUnit*)unit
                   forMessage: (ChatMessageData*)message completionBlock:(void(^)(FileData* fileData, UIImage* thumbnail))completionBlock;

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
@end
