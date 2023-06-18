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

@interface HomeViewModel ()

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
    
    __weak DatabaseManager *weakDatabaseManager = [DatabaseManager getSharedInstance];
    __weak HomeViewModel *weakself = self;
    dispatch_async(databaseQueue, ^{
        NSArray<ChatRoomModel*>* result = [weakDatabaseManager getChatsByPage:1];
        NSLog(@"Nice %@", result);
        if (result != nil) {
            weakself.chats = [result mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
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

- (void)createNewChat: (NSString *) name {

    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *chatId = [NSString stringWithFormat:@"%.0f", timeStamp];
   
    ChatRoomModel *newChat = [[ChatRoomModel alloc] initWithName:name chatId: chatId];
    [_chats insertObject:newChat atIndex: 0];
    
    dispatch_queue_t databaseQueue = dispatch_queue_create("storage.database", DISPATCH_QUEUE_CONCURRENT);
    
    __weak DatabaseManager *weakDatabaseManager = [DatabaseManager getSharedInstance];
    dispatch_async(databaseQueue, ^{
        
        [weakDatabaseManager saveChatRoomData:chatId name:name];
    });
}
@end
