//
//  HomeViewModel.m
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatRoomViewModel.h"
#import "ChatRoomData.h"
#import "ChatRoomEntity.h"
#import "HashHelper.h"

@interface ChatRoomViewModel ()
@property (retain,nonatomic) NSMutableArray<ChatRoomEntity *> *selectedModels;
@end

@implementation ChatRoomViewModel

-(instancetype) initWithUseCase:(id<ChatRoomUseCaseInterface>)chatRoomUsecase {
    self = [super init];
    if (self) {
        self.chats = [[NSMutableArray alloc] init];
        self.selectedModels = [[NSMutableArray alloc] init];
        self.chatRoomUsecase = chatRoomUsecase;
    }
    
    return self;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.chats = [[NSMutableArray alloc] init];
        self.selectedModels = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)_loadData {
    __weak ChatRoomViewModel *weakself = self;
    [_chatRoomUsecase getChatRoomsByPage:1 completionBlock:^(NSArray<ChatRoomEntity*>* rooms){
        weakself.chats = [rooms mutableCopy];
        [weakself.delegate endLoading];
        [weakself.delegate didUpdateData];
    } errorBlock:^(NSError* error){
        
    }];
}

- (void) onViewDidLoad {
    [_delegate startLoading];
    [self _loadData];
}

- (ChatRoomEntity *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.chats.count) {
        return nil;
    }
    
    return self.chats[indexPath.row];
}

- (NSUInteger) numberOfSections {
    return 1;
}

- (NSMutableArray<ChatRoomEntity*>*) items {
    return _chats;
}

- (void) selectChatRoom:(ChatRoomEntity *) chatRoom {
    [_selectedModels addObject:chatRoom];
    for (ChatRoomEntity *model in _chats) {
        if (chatRoom.roomId == model.roomId) {
            
            model.selected = TRUE;
            break;
        }
    }
    [self.delegate didUpdateObject:chatRoom];
}
- (void) deselectChatRoom:(ChatRoomEntity *) chatRoom {
    [_selectedModels removeObject:chatRoom];
    for (ChatRoomEntity *model in _chats) {
        if (chatRoom.roomId == model.roomId) {
            
            model.selected = FALSE;
            break;
        }
    }
    [self.delegate didUpdateObject:chatRoom];
}

- (void)deleteSelected {
    
    __weak ChatRoomViewModel* weakself = self;
    for (ChatRoomEntity* model in weakself.selectedModels) {
        [_chatRoomUsecase deleteChatRoom:model completionBlock:^(BOOL isSuccess){
            [weakself.chats removeObject:model];
            [self.delegate didUpdateData];
        } errorBlock:nil];
    }
}

- (void)requestCreateNewChat: (NSString *) name {

    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *chatRoomFormat = [NSString stringWithFormat:@"%lf-%@", timeStamp, name];
    
    NSString *chatRoomId = [HashHelper hashStringMD5:chatRoomFormat];
   
    ChatRoomData *newChat = [[ChatRoomData alloc] initWithName:name chatRoomId: chatRoomId];
    newChat.createdAt = timeStamp;
    [_chats insertObject:[newChat toChatRoomEntity] atIndex: 0];
    
    __weak ChatRoomViewModel* weakself = self;
    [_chatRoomUsecase createChatRoom:newChat completionBlock:^(BOOL isSuccess){
        [weakself.delegate didUpdateData];
    } errorBlock:nil];
}
@end
