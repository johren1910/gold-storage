//
//  ChatDetailDataRepository.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatDetailDataRepository.h"

@implementation ChatDetailDataRepository

- (void)getChatDataOfRoomId:(NSString*)roomId successCompletion:(void (^)(NSArray<ChatDetailEntity *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    __weak ChatDetailDataRepository* weakself = self;
    [_localDataSource getChatDataOfRoomId:roomId successCompletion:^(NSArray<ChatMessageData*>* chats) {
        NSMutableArray<ChatDetailEntity*>* results = [[NSMutableArray alloc] init];
        for (ChatMessageData* data in chats) {
            ChatDetailEntity* entity = [data toChatDetailEntity];
            UIImage* thumbnail = [weakself.storageManager getImageByKey:data.file.checksum];
            if (!thumbnail && data.file.filePath != nil) {
                
                if (data.file.type == Video) {
                    ZOMediaInfo *mediaInfo = [FileHelper getMediaInfoOfFilePath:data.file.filePath];
                    thumbnail = mediaInfo.thumbnail;
                    [weakself.storageManager compressThenCache:thumbnail withKey:data.file.checksum];
                } else {
                    NSData *imageData = [NSData dataWithContentsOfFile:data .file.filePath];
                    thumbnail = [UIImage imageWithData:imageData];
                }
                
            }
            entity.thumbnail = thumbnail;
            [results addObject:[data toChatDetailEntity]];
        }
        
        successCompletion([results copy]);
        }
                                    error:errorCompletion];
}

@end
