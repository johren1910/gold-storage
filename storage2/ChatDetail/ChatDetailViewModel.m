//
//  ChatDetailViewModel.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatDetailViewModel.h"
#import "ChatMessageModel.h"
#import "MediaType.h"
#import "FileHelper.h"
#import "HashHelper.h"

@interface ChatDetailViewModel ()

@property (retain,nonatomic) NSMutableArray<ChatMessageModel *> *messages;
@property (nonatomic, copy) ChatRoomModel *chatRoom;
@end

@implementation ChatDetailViewModel

-(instancetype) initWithChatRoom: (ChatRoomModel*) chatRoom {
    self = [super init];
    if (self) {
        self.messages = [[NSMutableArray alloc] init];
    }
    _chatRoom = chatRoom;
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)getData:(void (^)(NSArray<ChatMessageModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    //TODO: FETCH DATA HERE
    
    __weak ChatDetailViewModel *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.chat.data", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        NSArray<ChatMessageModel*>* result = [weakself.databaseManager getChatMessagesByRoomId:weakself.chatRoom.chatRoomId];
        
        
        if (result != nil) {
            weakself.messages = [result mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.filteredChats = weakself.messages;
                successCompletion(weakself.filteredChats);
            });
        }
    });
    
    
}

- (ChatMessageModel *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.filteredChats.count) {
        return nil;
    }
    
    return self.filteredChats[indexPath.row];
}

- (void)changeSegment: (NSUInteger*) index {
    __weak ChatDetailViewModel *weakself = self;
    if (index == 0) {
        _filteredChats = _messages;
        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
        return;
    }
    
    NSString *predicateString = @"type =[c] %ld";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, index];
    
    if (index == 1) {
        predicateString = [predicateString stringByAppendingString:@"|| type =[c] %ld"];
         predicate = [NSPredicate predicateWithFormat:predicateString, Video, Picture];
    } else if (index == 2) {
         predicate = [NSPredicate predicateWithFormat:predicateString, File];
    } else {
        predicate = [NSPredicate predicateWithFormat:predicateString, Other];
    }
    
    NSArray *filteredArray = [_messages filteredArrayUsingPredicate:predicate];
    _filteredChats = filteredArray;
    
   
    dispatch_async( dispatch_get_main_queue(), ^{
        [weakself.delegate didUpdateData];
    });
}

- (NSUInteger) numberOfSections {
    return 1;
}

- (NSArray<ChatMessageModel*>*) items {
    return _filteredChats;
}

- (void)addImage:(UIImage *)image {
    __weak ChatDetailViewModel *weakself = self;
    NSString* chatRoomId = _chatRoom.chatRoomId;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.data", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        
        NSData *pngData = UIImagePNGRepresentation(image);
        
        NSString *messageId = [HashHelper hashDataMD5:pngData];
        
        double size = ((double)pngData.length/1024.0f)/1024.0f; // MB
        
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        
        ChatMessageModel *new = [[ChatMessageModel alloc] initWithMessage:messageId messageId:messageId chatRoomId:chatRoomId];
        
        NSString *fileName = [NSString stringWithFormat:@"%@.png", new.messageId];
        
        NSString *filePath = [FileHelper documentsPathForFileName:fileName];
        
        //TODO: -Check storage space, not enough space?
        [pngData writeToFile:filePath atomically:YES];
        new.size = size;
        new.type = Picture;
        new.filePath = filePath;
        new.createdAt = timeStamp;
        
        [weakself.databaseManager saveChatMessageData:new totalRoomSize:weakself.chatRoom.size];
        
        [weakself.messages insertObject:new atIndex:0];
        weakself.filteredChats = weakself.messages;
        // Reload data
        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
    });
}

- (void)addFile:(NSData *)data {
    __weak ChatDetailViewModel *weakself = self;
    double size = ((double)data.length/1024.0f)/1024.0f; // MB
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *messageId = [NSString stringWithFormat:@"%.0f", timeStamp];
    
    ChatMessageModel *new = [[ChatMessageModel alloc] initWithMessage:messageId messageId:messageId chatRoomId:_chatRoom.chatRoomId];
    new.size = size;
//    new.type = File;
//    new.data = data;
    //TEMP IMAGE
    if (@available(iOS 13.0, *)) {
//        new.image = [UIImage systemImageNamed:@"doc"];
    } else {
        // Fallback on earlier versions
    }
    [weakself.messages insertObject:new atIndex:0];
    weakself.filteredChats = weakself.messages;
    // Reload data
    dispatch_async( dispatch_get_main_queue(), ^{
        [weakself.delegate didUpdateData];
    });
}
@end
