//
//  ChatDetailViewModel.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatDetailViewModel.h"
#import "ChatMessageData.h"
#import "ChatMessageModel.h"
#import "MediaType.h"
#import "FileHelper.h"
#import "HashHelper.h"
#import "CompressorHelper.h"

@interface ChatDetailViewModel ()
@property (retain,nonatomic) NSMutableArray<ChatMessageModel *> *messageModels;
@property (nonatomic, copy) ChatRoomModel *chatRoom;
@end

@implementation ChatDetailViewModel

-(instancetype) initWithChatRoom: (ChatRoomModel*) chatRoom {
    self = [super init];
    if (self) {
        self.messageModels = [[NSMutableArray alloc] init];
    }
    _chatRoom = chatRoom;
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messageModels = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)getData:(void (^)(NSArray<ChatMessageModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    __weak ChatDetailViewModel *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.chat.data", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        NSArray<ChatMessageData*>* result = [weakself.databaseManager getChatMessagesByRoomId:weakself.chatRoom.chatRoomId];
        
        if (result != nil) {
            
            NSMutableArray<ChatMessageModel*>* modelResult = [@[] mutableCopy];
            
            for (ChatMessageData* messageData in result) {
                
                UIImage* cachedImage = [weakself.cacheManager getImageByKey:messageData.messageId];
                
                ChatMessageModel* model = [[ChatMessageModel alloc] initWithMessageData:messageData thumbnail:cachedImage];
                
                [modelResult addObject:model];
            }
            weakself.messageModels = [modelResult mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.filteredChats = weakself.messageModels;
                successCompletion(weakself.messageModels);
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
        _filteredChats = _messageModels;
        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
        return;
    }
    
    NSString *predicateString = @"messageData.type =[c] %ld";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, index];
    
    if (index == 1) {
        predicateString = [predicateString stringByAppendingString:@"|| messageData.type =[c] %ld"];
         predicate = [NSPredicate predicateWithFormat:predicateString, Video, Picture];
    } else if (index == 2) {
         predicate = [NSPredicate predicateWithFormat:predicateString, File];
    } else {
        predicate = [NSPredicate predicateWithFormat:predicateString, Other];
    }
    
    NSArray *filteredArray = [_messageModels filteredArrayUsingPredicate:predicate];
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
        
        [weakself compressThenCache:image withKey:messageId];
        
        double size = ((double)pngData.length/1024.0f)/1024.0f; // MB
        
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        
        ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:chatRoomId];
        
        NSString *fileName = [NSString stringWithFormat:@"%@.png", newMessageData.messageId];
        
        NSString *filePath = [FileHelper documentsPathForFileName:fileName];
        
        //TODO: -Check storage space, not enough space?
        [pngData writeToFile:filePath atomically:YES];
        newMessageData.size = size;
        newMessageData.type = Picture;
        newMessageData.filePath = filePath;
        newMessageData.createdAt = timeStamp;
        
        [weakself.databaseManager saveChatMessageData:newMessageData totalRoomSize:weakself.chatRoom.size];
        ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:image];
        
        [weakself.messageModels insertObject:newModel atIndex:0];
        weakself.filteredChats = weakself.messageModels;
        // Reload data
        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
    });
}

- (void)compressThenCache: (UIImage*)image withKey:(NSString*) key {
    
    __weak ChatDetailViewModel *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.cache.image", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        [CompressorHelper compressImage:image quality:Thumbnail completionBlock:^(UIImage* compressedImage){
            
            [weakself.cacheManager cacheImageByKey:image withKey:key];
        }];
    });
}

- (void)addFile:(NSData *)data {
    __weak ChatDetailViewModel *weakself = self;
    double size = ((double)data.length/1024.0f)/1024.0f; // MB
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *messageId = [NSString stringWithFormat:@"%.0f", timeStamp];
    
    ChatMessageData *newMessageData = [[ChatMessageData alloc] initWithMessage:messageId messageId:messageId chatRoomId:_chatRoom.chatRoomId];
    newMessageData.size = size;
//    new.type = File;
//    new.data = data;
    //TEMP IMAGE
    if (@available(iOS 13.0, *)) {
//        new.image = [UIImage systemImageNamed:@"doc"];
    } else {
        // Fallback on earlier versions
    }
    
    ChatMessageModel *newModel = [[ChatMessageModel alloc] initWithMessageData:newMessageData thumbnail:nil];
    
    [weakself.messageModels insertObject:newModel atIndex:0];
    
    weakself.filteredChats = weakself.messageModels;
    // Reload data
    dispatch_async( dispatch_get_main_queue(), ^{
        [weakself.delegate didUpdateData];
    });
}

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    [_cacheManager cacheImageByKey:image withKey:key];
}
@end
