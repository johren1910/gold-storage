//
//  HomeViewModel.m
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatRoomViewModel.h"
#import "ChatRoomModel.h"
#import "HashHelper.h"

@interface ChatRoomViewModel ()
@property (retain,nonatomic) NSMutableArray<ChatRoomModel *> *selectedModels;
@end

@implementation ChatRoomViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.chats = [[NSMutableArray alloc] init];
        self.selectedModels = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)getData:(void (^)(NSMutableArray<ChatRoomModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    _chats = [[NSMutableArray alloc] init];
    
    __weak id<StorageManagerType> weakStorageManager = _storageManager;
    __weak ChatRoomViewModel *weakself = self;
    
    [weakStorageManager getChatRoomsByPage:1 completionBlock:^(id object){
        NSArray* result = (NSArray*)object;
        if (result != nil) {
            weakself.chats = [result mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.delegate didUpdateData];
                successCompletion(weakself.chats);
            });
            
        }
    }];
   
}

- (ChatRoomModel *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.chats.count) {
        return nil;
    }
    
    return self.chats[indexPath.row];
}

- (NSUInteger) numberOfSections {
    return 1;
}

- (NSMutableArray<ChatRoomModel*>*) items {
    return _chats;
}

- (void) selectChatRoom:(ChatRoomModel *) chatRoom {
    [_selectedModels addObject:chatRoom];
    for (ChatRoomModel *model in _chats) {
        if (chatRoom.chatRoomId == model.chatRoomId) {
            
            model.selected = TRUE;
            break;
        }
    }
    [self.delegate didUpdateObject:chatRoom];
}
- (void) deselectChatRoom:(ChatRoomModel *) chatRoom {
    [_selectedModels removeObject:chatRoom];
    for (ChatRoomModel *model in _chats) {
        if (chatRoom.chatRoomId == model.chatRoomId) {
            
            model.selected = FALSE;
            break;
        }
    }
    [self.delegate didUpdateObject:chatRoom];
}

- (void)deleteSelected {
    
    __weak ChatRoomViewModel* weakself = self;
    for (ChatRoomModel* model in weakself.selectedModels) {
        [self.storageManager deleteChatRoom:model completionBlock:^(BOOL isSuccess){
            if (isSuccess) {
                // TODO: - REFACTOR TO CANCEL ONLY DOWNLOADING LINK OF SELECTED ROOM
                [weakself.downloadManager cancelAllDownload];
                [weakself.chats removeObject:model];
            }
        }];
    }
    
    [self.delegate didUpdateData];
}

- (void)createNewChat: (NSString *) name {

    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *chatRoomFormat = [NSString stringWithFormat:@"%lf-%@", timeStamp, name];
    
    NSString *chatRoomId = [HashHelper hashStringMD5:chatRoomFormat];
   
    ChatRoomModel *newChat = [[ChatRoomModel alloc] initWithName:name chatRoomId: chatRoomId];
    newChat.createdAt = timeStamp;
    newChat.size = 0;
    [_chats insertObject:newChat atIndex: 0];
    
    __weak ChatRoomViewModel* weakself = self;
    [_storageManager createChatRoom:newChat completionBlock:^(BOOL isSuccess){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
    }];
}
@end
