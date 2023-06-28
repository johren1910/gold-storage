//
//  HomeViewModel.m
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "HomeViewModel.h"
#import "ChatRoomModel.h"
#import "DatabaseManager.h"
#import "HashHelper.h"

@interface HomeViewModel ()
@property (retain,nonatomic) NSMutableArray<ChatRoomModel *> *selectedModels;
@end

@implementation HomeViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.chats = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)getData:(void (^)(NSMutableArray<ChatRoomModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    _chats = [[NSMutableArray alloc] init];
    dispatch_queue_t databaseQueue = dispatch_queue_create("storage.database", DISPATCH_QUEUE_CONCURRENT);
    
    __weak id<DatabaseManagerType> weakDatabaseManager = _databaseManager;
    __weak HomeViewModel *weakself = self;
    dispatch_async(databaseQueue, ^{
        NSArray<ChatRoomModel*>* result = [weakDatabaseManager getChatRoomsByPage:1];
        NSLog(@"Nice %@", result);
        if (result != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.chats = [result mutableCopy];
                successCompletion(weakself.chats);
                [weakself.delegate didUpdateData];
            });
        }
    });
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
    __weak HomeViewModel *weakself = self;
    dispatch_async( dispatch_get_main_queue(), ^{
        
        [weakself.delegate didUpdateObject:chatRoom];
    });
}
- (void) deselectChatRoom:(ChatRoomModel *) chatRoom {
    [_selectedModels removeObject:chatRoom];
    for (ChatRoomModel *model in _chats) {
        if (chatRoom.chatRoomId == model.chatRoomId) {
            
            model.selected = FALSE;
            break;
        }
    }
    __weak HomeViewModel *weakself = self;
    dispatch_async( dispatch_get_main_queue(), ^{
        
        [weakself.delegate didUpdateObject:chatRoom];
    });
}

- (void)deleteSelected {
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.data", DISPATCH_QUEUE_CONCURRENT);
    __weak HomeViewModel* weakself = self;
    dispatch_async(myQueue, ^{
        for (ChatRoomModel* model in weakself.selectedModels) {
            [weakself.databaseManager deleteChatRoom:model];
        }
            
            //TODO: Storage manager, to delete files of chatRoom, message, and temp, cache
            
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.delegate didUpdateData];
        });
    });
    
}

- (void)createNewChat: (NSString *) name {

    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *chatRoomFormat = [NSString stringWithFormat:@"%lf-%@", timeStamp, name];
    
    NSString *chatRoomId = [HashHelper hashStringMD5:chatRoomFormat];
   
    ChatRoomModel *newChat = [[ChatRoomModel alloc] initWithName:name chatRoomId: chatRoomId];
    newChat.createdAt = timeStamp;
    newChat.size = 0;
    [_chats insertObject:newChat atIndex: 0];
    
    dispatch_queue_t databaseQueue = dispatch_queue_create("storage.database", DISPATCH_QUEUE_CONCURRENT);
    
    __weak id<DatabaseManagerType> weakDatabaseManager = [self databaseManager];
    dispatch_async(databaseQueue, ^{
        
        [weakDatabaseManager saveChatRoomData:newChat];
    });
}
@end
